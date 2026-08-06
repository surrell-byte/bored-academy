#!/usr/bin/env bash
# ==========================================================================
# Bored Academy — sign-up form: student/teacher + join-a-class
#
# Run AFTER apply_architecture.sh and apply_roles_and_locking.sh, from the
# repo root.
#   chmod +x apply_signup_flow.sh
#   ./apply_signup_flow.sh
#
# What it does to auth.html:
#   1. Adds an "I am a..." Student/Teacher toggle to the sign-up form.
#   2. Adds an optional "Class code" field, shown only for Student.
#   3. signUp() call now passes accountType through to BoredAuth.signUp().
#   4. If a class code was entered, calls BoredClassroom.joinClass() +
#      BoredAuth.addClass() right after a successful sign-up.
#   5. After login/signup, routes via BoredRouter.goToDashboard(user)
#      instead of hardcoding index.html, so teachers land on the teacher
#      dashboard and students on the student dashboard.
#   6. Loads the new script dependencies (roles, permissions, classroom,
#      router) that auth.html didn't have before.
#
# Safe to re-run — checks for its own marker before patching.
# ==========================================================================
set -euo pipefail

log() { printf '\033[1;36m▸ %s\033[0m\n' "$1"; }
skip() { printf '  (skip) %s\n' "$1"; }

F="auth.html"
[ -f "$F" ] || { echo "Can't find $F in $(pwd)." >&2; exit 1; }

if grep -q 'BOREDACADEMY_SIGNUP_PATCH' "$F"; then
  skip "$F already patched"
  exit 0
fi

log "Patching $F"

python3 - "$F" <<'PYEOF'
import sys
path = sys.argv[1]
src = open(path).read()

# --- 1. add script deps right after existing auth.js include -------------
old_scripts = '<script src="assets/js/auth/auth.js"></script>\n<script src="assets/js/app/theme.js"></script>'
new_scripts = (
    '<!-- BOREDACADEMY_SIGNUP_PATCH -->\n'
    '<script src="assets/js/auth/roles.js"></script>\n'
    '<script src="assets/js/auth/permissions.js"></script>\n'
    '<script src="assets/js/auth/auth.js"></script>\n'
    '<script src="assets/js/classroom/classroom.js"></script>\n'
    '<script src="assets/js/app/router.js"></script>\n'
    '<script src="assets/js/app/theme.js"></script>'
)
if old_scripts not in src:
    print("ERROR: expected <script> block not found, aborting.", file=sys.stderr)
    sys.exit(1)
src = src.replace(old_scripts, new_scripts, 1)

# --- 2. redirect-if-logged-in should also respect role --------------------
old_redirect = """<script>
  if(window.BoredAuth && BoredAuth.currentUser()){
    window.location.href = 'index.html';
  }
</script>"""
new_redirect = """<script>
  if(window.BoredAuth && BoredAuth.currentUser()){
    if(window.BoredRouter){ BoredRouter.goToDashboard(BoredAuth.currentUser()); }
    else { window.location.href = 'index.html'; }
  }
</script>"""
if old_redirect not in src:
    print("ERROR: redirect script block not found, aborting.", file=sys.stderr)
    sys.exit(1)
src = src.replace(old_redirect, new_redirect, 1)

# --- 3. add role toggle + class code field to the sign-up form -----------
old_signup_form = '''    <form id="signupForm" class="auth-form" style="display:none">
      <h2>Create your account</h2>
      <p class="auth-hint">Free — takes about 20 seconds.</p>
      <label>Name
        <input type="text" id="signupName" required autocomplete="name">
      </label>
      <label>Email
        <input type="email" id="signupEmail" required autocomplete="email">
      </label>
      <label>Password
        <input type="password" id="signupPassword" required autocomplete="new-password" minlength="6">
        <span class="auth-field-hint">At least 6 characters.</span>
      </label>
      <div class="auth-error" id="signupError"></div>
      <button type="submit" class="welcome-btn full">Create Account</button>
    </form>'''

new_signup_form = '''    <form id="signupForm" class="auth-form" style="display:none">
      <h2>Create your account</h2>
      <p class="auth-hint">Free — takes about 20 seconds.</p>

      <label>I am a...</label>
      <div class="auth-tabs" id="accountTypeToggle" role="group" aria-label="Account type">
        <button type="button" class="auth-tab active" data-account-type="student">Student</button>
        <button type="button" class="auth-tab" data-account-type="teacher">Teacher</button>
      </div>

      <label>Name
        <input type="text" id="signupName" required autocomplete="name">
      </label>
      <label>Email
        <input type="email" id="signupEmail" required autocomplete="email">
      </label>
      <label>Password
        <input type="password" id="signupPassword" required autocomplete="new-password" minlength="6">
        <span class="auth-field-hint">At least 6 characters.</span>
      </label>
      <label id="classCodeLabel">Class code <span class="auth-field-hint">(optional — your teacher gives you this)</span>
        <input type="text" id="signupClassCode" placeholder="ABCX-93KD" autocomplete="off">
      </label>
      <div class="auth-error" id="signupError"></div>
      <button type="submit" class="welcome-btn full">Create Account</button>
    </form>'''

if old_signup_form not in src:
    print("ERROR: sign-up form block not found, aborting.", file=sys.stderr)
    sys.exit(1)
src = src.replace(old_signup_form, new_signup_form, 1)

# --- 4. update the <script> logic at the bottom ---------------------------
old_tail = '''  loginForm.addEventListener('submit', function(e){
    e.preventDefault();
    const email = document.getElementById('loginEmail').value;
    const password = document.getElementById('loginPassword').value;
    const errEl = document.getElementById('loginError');
    const result = BoredAuth.login(email, password);
    if(!result.ok){ errEl.textContent = result.error; return; }
    window.location.href = 'index.html';
  });

  signupForm.addEventListener('submit', function(e){
    e.preventDefault();
    const name = document.getElementById('signupName').value;
    const email = document.getElementById('signupEmail').value;
    const password = document.getElementById('signupPassword').value;
    const errEl = document.getElementById('signupError');
    const result = BoredAuth.signUp(name, email, password);
    if(!result.ok){ errEl.textContent = result.error; return; }
    window.location.href = 'index.html';
  });
</script>'''

new_tail = '''  loginForm.addEventListener('submit', function(e){
    e.preventDefault();
    const email = document.getElementById('loginEmail').value;
    const password = document.getElementById('loginPassword').value;
    const errEl = document.getElementById('loginError');
    const result = BoredAuth.login(email, password);
    if(!result.ok){ errEl.textContent = result.error; return; }
    goToDashboardOrHome(result.user);
  });

  // --- account type toggle (student/teacher) --------------------------
  let accountType = 'student';
  const accountTypeToggle = document.getElementById('accountTypeToggle');
  const classCodeLabel = document.getElementById('classCodeLabel');
  function setAccountType(type){
    accountType = type;
    accountTypeToggle.querySelectorAll('.auth-tab').forEach(function(btn){
      btn.classList.toggle('active', btn.dataset.accountType === type);
    });
    classCodeLabel.style.display = type === 'student' ? '' : 'none';
  }
  accountTypeToggle.querySelectorAll('.auth-tab').forEach(function(btn){
    btn.addEventListener('click', function(){ setAccountType(btn.dataset.accountType); });
  });

  signupForm.addEventListener('submit', function(e){
    e.preventDefault();
    const name = document.getElementById('signupName').value;
    const email = document.getElementById('signupEmail').value;
    const password = document.getElementById('signupPassword').value;
    const classCode = document.getElementById('signupClassCode').value.trim();
    const errEl = document.getElementById('signupError');
    errEl.textContent = '';

    const result = BoredAuth.signUp(name, email, password, accountType);
    if(!result.ok){ errEl.textContent = result.error; return; }

    if(accountType === 'student' && classCode && window.BoredClassroom){
      const joinResult = BoredClassroom.joinClass(result.user.email, classCode);
      if(joinResult.ok){
        BoredAuth.addClass(result.user.email, joinResult.class.id);
      } else {
        // Account was still created successfully — just surface the
        // class-code problem so the student can join later from settings.
        errEl.textContent = joinResult.error + ' Your account was created — you can join a class later from Settings.';
      }
    }

    goToDashboardOrHome(BoredAuth.currentUser());
  });

  function goToDashboardOrHome(user){
    if(window.BoredRouter){ BoredRouter.goToDashboard(user); }
    else { window.location.href = 'index.html'; }
  }
</script>'''

if old_tail not in src:
    print("ERROR: bottom script block not found, aborting.", file=sys.stderr)
    sys.exit(1)
src = src.replace(old_tail, new_tail, 1)

open(path, 'w').write(src)
print("  patched form, scripts, and submit handlers")
PYEOF

log "Done."
echo
echo "Next steps:"
echo "  1. teacher/teacher-dashboard.html and student/student-dashboard.html"
echo "     are still stubs from apply_architecture.sh — build them out."
echo "  2. welcome.html likely links to auth.html?mode=signup — no change"
echo "     needed there, the toggle defaults to Student."
echo "  3. Consider the same student/teacher toggle on welcome.html if it"
echo "     has its own inline sign-up form (this script only touches auth.html)."
