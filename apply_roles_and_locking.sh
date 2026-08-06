#!/usr/bin/env bash
# ==========================================================================
# Bored Academy — wire up roles + lesson locking
#
# Run AFTER apply_architecture.sh, from the repo root.
#   chmod +x apply_roles_and_locking.sh
#   ./apply_roles_and_locking.sh
#
# What it does:
#   1. auth.js: signUp() now takes an accountType ('student'|'teacher'),
#      assigns a default role (student_free / teacher_free), and stores
#      classIds: []. Adds BoredAuth.setRole() and BoredAuth.addClass().
#   2. course-loader.js: first 2 lessons of every course become "free"
#      automatically; everything else is locked unless the signed-in user
#      is premium/admin or the lesson is assigned to one of their classes.
#      Locked lessons render a lock overlay instead of quiz content.
#   3. Course pages (courses/*.html) get the auth/roles/permissions
#      scripts added before course-loader.js so it can see them.
#
# Safe to re-run — it checks for its own markers before patching.
# ==========================================================================
set -euo pipefail

log() { printf '\033[1;36m▸ %s\033[0m\n' "$1"; }
skip() { printf '  (skip) %s\n' "$1"; }

AUTH="assets/js/auth/auth.js"
LOADER="assets/js/courses/course-loader.js"

[ -f "$AUTH" ] || { echo "Can't find $AUTH — run apply_architecture.sh first." >&2; exit 1; }
[ -f "$LOADER" ] || { echo "Can't find $LOADER — run apply_architecture.sh first." >&2; exit 1; }

# --------------------------------------------------------------------------
# 1. auth.js — add role assignment
# --------------------------------------------------------------------------
if grep -q 'BOREDACADEMY_ROLES_PATCH' "$AUTH"; then
  skip "$AUTH already patched"
else
  log "Patching $AUTH (roles on signup)"
  python3 - "$AUTH" <<'PYEOF'
import sys, re
path = sys.argv[1]
src = open(path).read()

old_signup = """  function signUp(name, email, password){
    email = (email||'').trim().toLowerCase();
    name = (name||'').trim();
    if(!email || !password) return { ok:false, error:'Enter an email and password.' };
    if(password.length < 6) return { ok:false, error:'Password must be at least 6 characters.' };
    const users = readUsers();
    if(users[email]) return { ok:false, error:'An account with that email already exists.' };
    users[email] = { name: name || email.split('@')[0], passHash: hash(password) };
    writeUsers(users);
    const session = { email, name: users[email].name };
    try{ localStorage.setItem(SESSION_KEY, JSON.stringify(session)); }catch(e){}
    try{ localStorage.setItem('boredacademy:name', session.name); }catch(e){}
    return { ok:true, user: session };
  }"""

new_signup = """  // BOREDACADEMY_ROLES_PATCH
  // accountType: 'student' (default) or 'teacher'. New accounts start on
  // the free tier for that type; upgrades/admin grants happen via
  // BoredAuth.setRole() (should eventually be server-driven, not client).
  function defaultRoleFor(accountType){
    const Roles = window.BoredRoles ? window.BoredRoles.ROLES : {};
    return accountType === 'teacher' ? Roles.TEACHER_FREE : Roles.STUDENT_FREE;
  }

  function signUp(name, email, password, accountType){
    email = (email||'').trim().toLowerCase();
    name = (name||'').trim();
    accountType = accountType === 'teacher' ? 'teacher' : 'student';
    if(!email || !password) return { ok:false, error:'Enter an email and password.' };
    if(password.length < 6) return { ok:false, error:'Password must be at least 6 characters.' };
    const users = readUsers();
    if(users[email]) return { ok:false, error:'An account with that email already exists.' };
    users[email] = {
      name: name || email.split('@')[0],
      passHash: hash(password),
      role: defaultRoleFor(accountType),
      classIds: []
    };
    writeUsers(users);
    const session = { email, name: users[email].name, role: users[email].role, classIds: users[email].classIds };
    try{ localStorage.setItem(SESSION_KEY, JSON.stringify(session)); }catch(e){}
    try{ localStorage.setItem('boredacademy:name', session.name); }catch(e){}
    return { ok:true, user: session };
  }

  // Grants/changes a role for an existing account and refreshes the
  // session if it's the current user. TODO: once there's a backend, this
  // must be called from a trusted server context only (e.g. after a real
  // payment webhook, or a validated admin invite), never from client code
  // that a user controls.
  function setRole(email, role){
    email = (email||'').trim().toLowerCase();
    const users = readUsers();
    if(!users[email]) return { ok:false, error:'No such account.' };
    users[email].role = role;
    writeUsers(users);
    const session = currentUser();
    if(session && session.email === email){
      session.role = role;
      try{ localStorage.setItem(SESSION_KEY, JSON.stringify(session)); }catch(e){}
    }
    return { ok:true };
  }

  // Adds a classId to a student's session + stored account (call this
  // after BoredClassroom.joinClass succeeds).
  function addClass(email, classId){
    email = (email||'').trim().toLowerCase();
    const users = readUsers();
    if(!users[email]) return { ok:false, error:'No such account.' };
    users[email].classIds = users[email].classIds || [];
    if(users[email].classIds.indexOf(classId) === -1) users[email].classIds.push(classId);
    if(users[email].role === (window.BoredRoles && window.BoredRoles.ROLES.STUDENT_FREE)){
      users[email].role = window.BoredRoles.ROLES.STUDENT_CLASSROOM;
    }
    writeUsers(users);
    const session = currentUser();
    if(session && session.email === email){
      session.classIds = users[email].classIds;
      session.role = users[email].role;
      try{ localStorage.setItem(SESSION_KEY, JSON.stringify(session)); }catch(e){}
    }
    return { ok:true };
  }"""

if old_signup not in src:
    print("WARNING: could not find exact signUp() block to patch — skipping auth.js edit.", file=sys.stderr)
    sys.exit(1)

src = src.replace(old_signup, new_signup)
src = src.replace(
    "window.BoredAuth = { currentUser, signUp, login, logout, requireAuth };",
    "window.BoredAuth = { currentUser, signUp, login, logout, requireAuth, setRole, addClass };"
)
open(path, 'w').write(src)
print("  patched signUp/setRole/addClass")
PYEOF
fi

# --------------------------------------------------------------------------
# 2. course-loader.js — lesson locking
# --------------------------------------------------------------------------
if grep -q 'BOREDACADEMY_LOCK_PATCH' "$LOADER"; then
  skip "$LOADER already patched"
else
  log "Patching $LOADER (lesson locking)"
  python3 - "$LOADER" <<'PYEOF'
import sys
path = sys.argv[1]
src = open(path).read()

# --- 2a. mark first 2 lessons per unit as free, add lock helper ----------
anchor = "let current = 0;"
if anchor not in src:
    print("WARNING: anchor not found in course-loader.js, skipping.", file=sys.stderr)
    sys.exit(1)

lock_helpers = """// BOREDACADEMY_LOCK_PATCH
// First 2 lessons of each unit are free demo lessons (matches the "Guest
// can complete first 2-3 lessons of every course" rule). Everything else
// needs BoredPermissions.canAccessLesson() to return true.
(function markFreeLessons(){
  const seen = {};
  DATA.forEach(l => {
    seen[l.unit] = seen[l.unit] || 0;
    l.free = seen[l.unit] < 2;
    seen[l.unit]++;
  });
})();

function currentBoredUser(){
  return window.BoredAuth ? window.BoredAuth.currentUser() : null;
}

function isLessonLocked(l){
  if(!window.BoredPermissions) return false; // permissions.js not loaded — fail open, don't break the page
  return !window.BoredPermissions.canAccessLesson(currentBoredUser(), l);
}

let current = 0;"""

src = src.replace(anchor, lock_helpers, 1)

# --- 2b. gate renderMain()'s quiz/notes behind the lock, show upsell -----
old_block = """    <section class=\"block\">
      <h3 class=\"block-title\">Lesson Notes</h3>
      ${l.html}
    </section>

    <section class=\"block quiz-section\" id=\"quizSection\">
      <h3 class=\"block-title\">Check Your Understanding</h3>
      ${quizHtml}
    </section>"""

new_block = """    ${isLessonLocked(l) ? `
    <section class=\"block lock-block\">
      <h3 class=\"block-title\">🔒 This lesson is locked</h3>
      <p>Join a classroom with a teacher's code, or go Premium, to unlock this lesson and its notes/quiz.</p>
      <div class=\"lock-actions\">
        <a class=\"btn\" href=\"../auth.html\">Join a classroom</a>
        <a class=\"btn btn-primary\" href=\"../settings.html\">Go Premium</a>
      </div>
    </section>
    ` : `
    <section class=\"block\">
      <h3 class=\"block-title\">Lesson Notes</h3>
      ${l.html}
    </section>

    <section class=\"block quiz-section\" id=\"quizSection\">
      <h3 class=\"block-title\">Check Your Understanding</h3>
      ${quizHtml}
    </section>
    `}"""

if old_block not in src:
    print("WARNING: could not find lesson-notes/quiz block to patch — skipping lock UI.", file=sys.stderr)
    sys.exit(1)

src = src.replace(old_block, new_block)

# --- 2c. block answer() on locked lessons ---------------------------------
old_answer = """function answer(id, qi, oi){
  quizState[id].answered[qi] = oi;"""
new_answer = """function answer(id, qi, oi){
  const l0 = DATA.find(x=>x.id===id);
  if(l0 && isLessonLocked(l0)) return; // guard against calls from stale/cached DOM
  quizState[id].answered[qi] = oi;"""

if old_answer not in src:
    print("WARNING: could not find answer() to patch — skipping.", file=sys.stderr)
    sys.exit(1)
src = src.replace(old_answer, new_answer)

open(path, 'w').write(src)
print("  patched lock helpers, renderMain(), answer()")
PYEOF
fi

# --------------------------------------------------------------------------
# 3. Make sure course pages load auth/roles/permissions before course-loader
# --------------------------------------------------------------------------
log "Ensuring courses/*.html load auth/roles/permissions"
for f in courses/*.html; do
  [ -f "$f" ] || continue
  if grep -q 'auth/permissions.js' "$f"; then
    skip "$f already wired"
    continue
  fi
  if ! grep -q 'courses/course-loader.js' "$f"; then
    echo "  WARNING: $f doesn't reference course-loader.js — check manually."
    continue
  fi
  # Insert the three scripts right before the course-loader.js script tag
  python3 - "$f" <<'PYEOF'
import sys
path = sys.argv[1]
src = open(path).read()
needle = '<script src="../assets/js/courses/course-loader.js">'
inject = ('<script src="../assets/js/auth/roles.js"></script>\n'
          '<script src="../assets/js/auth/permissions.js"></script>\n'
          '<script src="../assets/js/auth/auth.js"></script>\n')
if needle in src and inject not in src:
    src = src.replace(needle, inject + needle, 1)
    open(path, 'w').write(src)
    print("  wired:", path)
PYEOF
done

# --------------------------------------------------------------------------
# 4. Minimal CSS for the lock block / buttons (only if not already present)
# --------------------------------------------------------------------------
CSS="assets/css/dashboard.css"
if [ -f "$CSS" ] && ! grep -q 'lock-block' "$CSS"; then
  log "Appending .lock-block styles to $CSS"
  cat >> "$CSS" <<'EOF'

/* BOREDACADEMY_LOCK_PATCH */
.lock-block { text-align: center; padding: 2.5rem 1.5rem; }
.lock-block .lock-actions { display: flex; gap: .75rem; justify-content: center; margin-top: 1rem; flex-wrap: wrap; }
.lock-block .btn { padding: .6rem 1.2rem; border-radius: 8px; text-decoration: none; border: 1px solid currentColor; }
.lock-block .btn-primary { background: currentColor; }
EOF
else
  skip "$CSS lock styles"
fi

log "Done."
echo
echo "Next steps:"
echo "  1. Update the sign-up form (welcome.html / auth.html) to pass an"
echo "     accountType ('student' or 'teacher') into BoredAuth.signUp()."
echo "  2. After BoredClassroom.joinClass() succeeds, call"
echo "     BoredAuth.addClass(email, classId) so the student's role/classIds"
echo "     update and locked lessons unlock."
echo "  3. Build the actual Premium upgrade flow (subscriptions/billing.js)"
echo "     and call BoredAuth.setRole() from its success callback."
