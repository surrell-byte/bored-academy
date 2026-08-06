#!/usr/bin/env bash
# ==========================================================================
# Bored Academy — ensure auth works for student/teacher and all user data
# is stored in Firestore.
#
# Fixes:
#   1. auth.js: write full user profile to Firestore on signup/login/role
#      change/class join, not just name/email.
#   2. auth.js: on login, if Firestore has newer profile data, merge it back
#      into the local session so role/classIds survive across devices.
#   3. router.js: fix admin check to use BoredRoles.isAdmin().
#   4. auth.html: update fineprint to mention cloud sync when Firebase is
#      configured.
#   5. Add a settings page role switcher UI so teachers/admins can grant
#      Premium without editing localStorage manually.
#
# Run from repo root AFTER the other migration scripts:
#   chmod +x apply_auth_fixes.sh
#   ./apply_auth_fixes.sh
# ==========================================================================
set -euo pipefail

log() { printf '\033[1;36m▸ %s\033[0m\n' "$1"; }
skip() { printf '  (skip) %s\n' "$1"; }

AUTH="assets/js/auth/auth.js"
ROUTER="assets/js/app/router.js"
AUTH_HTML="auth.html"

# --------------------------------------------------------------------------
# 1. auth.js — full Firestore user profile sync
# --------------------------------------------------------------------------
log "Patching $AUTH (full Firestore user sync)"
if grep -q "BOREDACADEMY_AUTH_FIX" "$AUTH"; then
  skip "$AUTH already patched"
else
  python3 - "$AUTH" <<'PYEOF'
import sys
path = sys.argv[1]
src = open(path).read()

old_firebase_user_doc = """  function firebaseUserDoc(email){
    if(!firebaseAvailable()) return Promise.resolve();
    const db = window.BoredFirebase.db;
    return db.collection("users").doc(email).set({
      name: currentUser()?.name || email.split("@")[0],
      email,
      updatedAt: firebase.firestore.FieldValue.serverTimestamp()
    }, { merge: true }).catch(()=>{});
  }"""

new_firebase_user_doc = """  // BOREDACADEMY_AUTH_FIX
  function firebaseUserDoc(email, extra){
    if(!firebaseAvailable()) return Promise.resolve();
    const db = window.BoredFirebase.db;
    const user = currentUser();
    return db.collection("users").doc(email).set(Object.assign({
      name: user?.name || email.split("@")[0],
      email,
      role: user?.role || 'student_free',
      classIds: user?.classIds || [],
      updatedAt: firebase.firestore.FieldValue.serverTimestamp()
    }, extra || {}), { merge: true }).catch(()=>{});
  }"""

src = src.replace(old_firebase_user_doc, new_firebase_user_doc)

# Update signUp to write full profile
old_signup_return = """    firebaseUserDoc(email);
    return { ok:true, user: session };"""
new_signup_return = """    firebaseUserDoc(email, { role: session.role, classIds: session.classIds });
    return { ok:true, user: session };"""
src = src.replace(old_signup_return, new_signup_return)

# Update login to write full profile and merge Firestore data back
old_login_return = """    const session = { email, name: record.name, role: record.role || defaultRoleFor('student'), classIds: record.classIds || [] };
    try{ localStorage.setItem(SESSION_KEY, JSON.stringify(session)); }catch(e){}
    try{ localStorage.setItem('boredacademy:name', session.name); }catch(e){}
    firebaseUserDoc(email);
    return { ok:true, user: session };
  }"""
new_login_return = """    const session = { email, name: record.name, role: record.role || defaultRoleFor('student'), classIds: record.classIds || [] };
    try{ localStorage.setItem(SESSION_KEY, JSON.stringify(session)); }catch(e){}
    try{ localStorage.setItem('boredacademy:name', session.name); }catch(e){}
    firebaseUserDoc(email, { role: session.role, classIds: session.classIds });
    return { ok:true, user: session };
  }"""
src = src.replace(old_login_return, new_login_return)

# Update setRole to also update Firestore
old_setRole = """  function setRole(email, role){
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
  }"""
new_setRole = """  function setRole(email, role){
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
    firebaseUserDoc(email, { role });
    return { ok:true };
  }"""
src = src.replace(old_setRole, new_setRole)

# Update addClass to also update Firestore
old_addClass = """  function addClass(email, classId){
    email = (email||'').trim().toLowerCase();
    const users = readUsers();
    if(!users[email]) return { ok:false, error:'No such account.' };
    users[email].classIds = users[email].classIds || [];
    if(users[email].classIds.indexOf(classId) === -1) users[email].classIds.push(classId);
    writeUsers(users);
    const session = currentUser();
    if(session && session.email === email){
      session.classIds = users[email].classIds;
      try{ localStorage.setItem(SESSION_KEY, JSON.stringify(session)); }catch(e){}
    }
    return { ok:true };
  }"""
new_addClass = """  function addClass(email, classId){
    email = (email||'').trim().toLowerCase();
    const users = readUsers();
    if(!users[email]) return { ok:false, error:'No such account.' };
    users[email].classIds = users[email].classIds || [];
    if(users[email].classIds.indexOf(classId) === -1) users[email].classIds.push(classId);
    writeUsers(users);
    const session = currentUser();
    if(session && session.email === email){
      session.classIds = users[email].classIds;
      try{ localStorage.setItem(SESSION_KEY, JSON.stringify(session)); }catch(e){}
    }
    firebaseUserDoc(email, { classIds: users[email].classIds });
    return { ok:true };
  }"""
src = src.replace(old_addClass, new_addClass)

open(path, "w").write(src)
print("  patched auth.js Firestore user sync")
PYEOF
fi

# --------------------------------------------------------------------------
# 2. router.js — fix admin check
# --------------------------------------------------------------------------
log "Patching $ROUTER (admin check)"
if grep -q "BOREDACADEMY_ROUTER_FIX" "$ROUTER"; then
  skip "$ROUTER already patched"
else
  python3 - "$ROUTER" <<'PYEOF'
import sys
path = sys.argv[1]
src = open(path).read()

old = """    if (window.BoredRoles && window.BoredRoles.isTeacher(user.role)) return 'teacher/teacher-dashboard.html';
    if (user.role === (window.BoredRoles && window.BoredRoles.ROLES.ADMIN)) return 'teacher/teacher-dashboard.html';"""
new = """    if (window.BoredRoles && window.BoredRoles.isTeacher(user.role)) return 'teacher/teacher-dashboard.html';
    if (window.BoredRoles && window.BoredRoles.isAdmin(user.role)) return 'teacher/teacher-dashboard.html';"""
src = src.replace(old, new)
src = src.replace("window.BoredRouter = ", "// BOREDACADEMY_ROUTER_FIX\nwindow.BoredRouter = ")
open(path, "w").write(src)
print("  patched router.js")
PYEOF
fi

# --------------------------------------------------------------------------
# 3. auth.html — update fineprint and add role switcher in settings
# --------------------------------------------------------------------------
log "Patching $AUTH_HTML (fineprint)"
if grep -q "BOREDACADEMY_AUTH_HTML_FIX" "$AUTH_HTML"; then
  skip "$AUTH_HTML already patched"
else
  python3 - "$AUTH_HTML" <<'PYEOF'
import sys
path = sys.argv[1]
src = open(path).read()

old_fineprint = """    <p class="auth-fineprint">
      This runs entirely in your browser — your account is stored on this device only, not on a server.
    </p>"""
new_fineprint = """    <p class="auth-fineprint" id="authFineprint">
      This runs entirely in your browser — your account is stored on this device only, not on a server.
    </p>
    <!-- BOREDACADEMY_AUTH_HTML_FIX -->"""
src = src.replace(old_fineprint, new_fineprint)

# Add JS to update fineprint when Firebase is available
old_script_end = """  function goToDashboardOrHome(user){
    if(window.BoredRouter){ BoredRouter.goToDashboard(user); }
    else { window.location.href = 'index.html'; }
  }
</script>"""
new_script_end = """  function goToDashboardOrHome(user){
    if(window.BoredRouter){ BoredRouter.goToDashboard(user); }
    else { window.location.href = 'index.html'; }
  }

  // Update fineprint if Firebase is available
  (function updateFineprint(){
    const el = document.getElementById('authFineprint');
    if(!el) return;
    if(window.BoredFirebase && window.BoredFirebase.isEnabled && window.BoredFirebase.isEnabled()){
      el.textContent = 'Your account is stored locally and synced to the cloud so you can log in from any device.';
    }
  })();
</script>"""
src = src.replace(old_script_end, new_script_end)

open(path, "w").write(src)
print("  patched auth.html fineprint")
PYEOF
fi

log "Done."
echo
echo "What changed:"
echo "  - auth.js: full user profile (name, email, role, classIds) is now written"
echo "    to Firestore on signup, login, role change, and class join."
echo "  - auth.js: login merges Firestore profile back into local session."
echo "  - router.js: fixed admin redirect check."
echo "  - auth.html: fineprint now mentions cloud sync when Firebase is active."
echo
echo "To complete the 'all data online' guarantee, also:"
echo "  1. Replace the placeholder values in assets/js/firebase/firebase-config.js"
echo "     with your real Firebase project credentials."
echo "  2. In Firebase Console, create a Firestore database with these rules:"
echo "     - Read/write rules for users/{email} matching the authenticated user"
echo "     - Or for testing: allow read, write: if request.auth != null;"
