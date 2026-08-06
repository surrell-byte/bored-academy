#!/usr/bin/env bash
# ==========================================================================
# Bored Academy — role switcher + auth redirect fixes
#
# Context from an end-to-end audit of the real repo:
#
#   1. Gradebook is NOT missing — assets/js/classroom/grading.js,
#      teacher/teacher-gradebook.html, student/student-assignments.html and
#      student/student-tests.html already implement a full submit -> grade
#      loop (verified: createSubmission is called from both student pages,
#      teacher-gradebook.html reads it back and writes grades). Nothing to
#      build there.
#   2. CSS is already consistent — every <button>/<a class="...btn..."> in
#      the app resolves to a real rule in welcome.css/dashboard.css/base.css
#      using the --teal brand color. No unstyled/default-grey buttons found.
#   3. Two REAL auth-flow bugs, both the same root cause (hardcoded
#      root-relative redirect paths used from pages one folder deep):
#        - BoredAuth.requireAuth() always redirects to 'welcome.html'. From
#          teacher/*.html or student/*.html that resolves to
#          teacher/welcome.html or student/welcome.html — 404, user stuck.
#        - teacher/teacher-access.html and student/student-join-class.html
#          hardcode window.location.href = 'auth.html?mode=login' for the
#          logged-out case — same problem, same fix.
#   4. Settings had no way to change your own role. This adds a real,
#      self-serve "Account & Role" card (student -> Premium Student,
#      teacher -> Premium Teacher), clearly labeled as local/testing only,
#      matching the existing warning already in billing.js.
#
# Run from the repo root, after your existing migration scripts:
#   chmod +x apply_role_switcher_and_auth_fixes.sh
#   ./apply_role_switcher_and_auth_fixes.sh
#
# Safe to re-run — every patch checks for its own marker first.
# ==========================================================================
set -euo pipefail
BLUE='\033[1;36m'; NC='\033[0m'
log(){ echo -e "${BLUE}▸ $1${NC}"; }

if [ ! -f "assets/js/auth/auth.js" ]; then
  echo "Run this from the repo root (assets/js/auth/auth.js not found)."
  exit 1
fi

# --------------------------------------------------------------------------
# 1. auth.js — requireAuth() redirects correctly from nested pages
# --------------------------------------------------------------------------
log "Patching assets/js/auth/auth.js (requireAuth nested-page redirect)"
if grep -q "BOREDACADEMY_REQUIREAUTH_DEPTH_FIX" assets/js/auth/auth.js; then
  echo "  (skip) already patched"
else
  python3 - <<'PYEOF'
path = "assets/js/auth/auth.js"
src = open(path).read()
old = """  function requireAuth(){
    if(!currentUser()){
      window.location.href = 'welcome.html';
      return false;
    }
    return true;
  }"""
assert old in src, "requireAuth() block not found"
new = """  // BOREDACADEMY_REQUIREAUTH_DEPTH_FIX
  // Pages one folder deep (teacher/*.html, student/*.html, courses/*.html)
  // need '../welcome.html', not 'welcome.html' — otherwise a logged-out
  // user hitting one of those pages gets redirected to a 404 in that same
  // subfolder instead of the real welcome page.
  function rootRelative(path){
    const inSubfolder = /\\/(teacher|student|courses)\\/[^/]*$/.test(window.location.pathname);
    return inSubfolder ? '../' + path : path;
  }

  function requireAuth(){
    if(!currentUser()){
      window.location.href = rootRelative('welcome.html');
      return false;
    }
    return true;
  }"""
src = src.replace(old, new)

old_export = "  window.BoredAuth = { currentUser, signUp, login, logout, requireAuth, setRole, addClass, firebaseAvailable, markOnboardingDone, needsOnboarding, setTeacherAccess, hasTeacherAccess };"
assert old_export in src, "export line not found — check auth.js hasn't changed shape"
new_export = "  window.BoredAuth = { currentUser, signUp, login, logout, requireAuth, setRole, addClass, firebaseAvailable, markOnboardingDone, needsOnboarding, setTeacherAccess, hasTeacherAccess, rootRelative };"
src = src.replace(old_export, new_export)

open(path, "w").write(src)
print("  patched requireAuth() + exported rootRelative()")
PYEOF
fi

# --------------------------------------------------------------------------
# 2. teacher-access.html / student-join-class.html — same redirect bug
# --------------------------------------------------------------------------
log "Fixing hardcoded login redirects in nested pages"
for f in teacher/teacher-access.html student/student-join-class.html; do
  if [ ! -f "$f" ]; then
    echo "  WARNING: $f not found — skipping"
    continue
  fi
  old="  if(!window.BoredAuth || !BoredAuth.currentUser()){
    window.location.href = 'auth.html?mode=login';
  }"
  if grep -qF "window.BoredAuth.rootRelative" "$f" 2>/dev/null; then
    echo "  (skip) $f already fixed"
    continue
  fi
  if ! grep -qF "$old" "$f"; then
    echo "  WARNING: anchor not found in $f — skipping"
    continue
  fi
  new="  if(!window.BoredAuth || !BoredAuth.currentUser()){
    window.location.href = (window.BoredAuth.rootRelative ? window.BoredAuth.rootRelative('auth.html?mode=login') : '../auth.html?mode=login');
  }"
  python3 - "$f" "$old" "$new" <<'PYEOF'
import sys
path, old, new = sys.argv[1], sys.argv[2], sys.argv[3]
src = open(path).read()
assert src.count(old) == 1, f"expected exactly one match in {path}"
open(path, "w").write(src.replace(old, new))
PYEOF
  echo "  patched $f"
done

# --------------------------------------------------------------------------
# 3. Settings — "Account & Role" card with a real, self-serve role switcher
# --------------------------------------------------------------------------
log "Adding role switcher to assets/js/app/dashboard.js (renderSettingsStandalone)"
if grep -q "BOREDACADEMY_ROLE_SWITCHER" assets/js/app/dashboard.js; then
  echo "  (skip) already patched"
else
  python3 - <<'PYEOF'
path = "assets/js/app/dashboard.js"
src = open(path).read()

old = """    <div class=\"settings-card\">
      <h4>Reset progress</h4>
      <p class=\"settings-hint\">Clears all saved quiz answers, streaks and activity on this device. This can't be undone.</p>
      <button class=\"settings-btn danger\" id=\"resetProgressBtn\">Reset all progress</button>
    </div>
  `;"""
assert old in src, "settings card markup not found — check dashboard.js hasn't changed shape"

new = """    <div class=\"settings-card\" id=\"roleCard\"></div>
    <div class=\"settings-card\">
      <h4>Reset progress</h4>
      <p class=\"settings-hint\">Clears all saved quiz answers, streaks and activity on this device. This can't be undone.</p>
      <button class=\"settings-btn danger\" id=\"resetProgressBtn\">Reset all progress</button>
    </div>
  `;

  // BOREDACADEMY_ROLE_SWITCHER
  renderRoleCard();"""
src = src.replace(old, new)

# Insert the renderRoleCard() function just before renderSettingsStandalone,
# so it's defined in the same scope and can be called from inside it.
anchor = "function renderSettingsStandalone(){"
assert anchor in src, "renderSettingsStandalone() not found"
role_fn = """// BOREDACADEMY_ROLE_SWITCHER
function renderRoleCard(){
  const card = document.getElementById('roleCard');
  if(!card || !window.BoredAuth) return;
  const user = window.BoredAuth.currentUser();
  if(!user || !window.BoredRoles) { card.style.display = 'none'; return; }

  const Roles = window.BoredRoles.ROLES;
  const isTeacher = window.BoredRoles.isTeacher(user.role);
  const isPremium = window.BoredRoles.isPremium(user.role);
  const isAdmin = window.BoredRoles.isAdmin(user.role);
  const label = (user.role || '').replace('_', ' ');

  let upgradeHtml = '';
  if(isAdmin){
    upgradeHtml = '<p class=\\"settings-hint\\">Admin accounts already have full access.</p>';
  } else if(isPremium){
    upgradeHtml = '<p class=\\"settings-hint\\">You have Premium access. Every course and game is unlocked.</p>';
  } else {
    const targetRole = isTeacher ? Roles.TEACHER_PREMIUM : Roles.STUDENT_PREMIUM;
    const targetLabel = isTeacher ? 'Premium Teacher' : 'Premium Student';
    upgradeHtml =
      '<p class=\\"settings-hint\\">Unlock every course, game and AI feature.</p>' +
      '<button class=\\"settings-btn\\" id=\\"upgradeRoleBtn\\" data-target-role=\\"' + targetRole + '\\">Upgrade to ' + targetLabel + '</button>' +
      '<p class=\\"settings-hint\\" style=\\"margin-top:.6em;margin-bottom:0;\\">Local/testing switch only — wire a real payment provider in billing.js before launch.</p>';
  }

  card.innerHTML =
    '<h4>Account &amp; role</h4>' +
    '<p class=\\"settings-hint\\">Signed in as ' + (user.email || '') + '</p>' +
    '<span class=\\"dash-role-badge\\">' + label + '</span>' +
    '<div style=\\"margin-top:1em;\\">' + upgradeHtml + '</div>';

  const btn = document.getElementById('upgradeRoleBtn');
  if(btn){
    btn.addEventListener('click', function(){
      const target = btn.dataset.targetRole;
      if(window.BoredBilling) window.BoredBilling.startCheckout(target);
      window.BoredAuth.setRole(user.email, target);
      renderRoleCard();
    });
  }
}

"""
src = src[:src.index(anchor)] + role_fn + src[src.index(anchor):]

open(path, "w").write(src)
print("  added renderRoleCard() + wired into renderSettingsStandalone()")
PYEOF
fi

log "Done."
echo
echo "What changed:"
echo "  - requireAuth() (and the two hardcoded login redirects in"
echo "    teacher-access.html / student-join-class.html) now redirect"
echo "    correctly whether the page lives at the repo root or one folder"
echo "    deep (teacher/, student/, courses/). Previously a logged-out user"
echo "    landing on any teacher/*.html or student/*.html page got sent to"
echo "    a 404 instead of welcome.html."
echo "  - settings.html has a new 'Account & role' card: shows your role as"
echo "    a badge, and — unless you're already Premium or Admin — a real"
echo "    'Upgrade to Premium' button that calls BoredAuth.setRole() (and"
echo "    BoredBilling.startCheckout, still a stub). Clearly labeled as a"
echo "    local/testing switch, matching billing.js's existing warning not"
echo "    to ship a client-side upgrade toggle to production as-is."
echo "  - Gradebook and CSS button styling were audited and are already"
echo "    correct — no changes made there, see script header for details."
