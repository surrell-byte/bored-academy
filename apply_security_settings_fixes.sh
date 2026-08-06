#!/usr/bin/env bash
# ==========================================================================
# Bored Academy — admin code security, teacher/student settings, leaderboard
#
# Three items, in priority order:
#
#   1. SECURITY: teacher-access.html both displayed the full-access code in
#      plain text on the page AND compared it in plaintext in JS. Anyone
#      who opened the page (logged in as any teacher, free or not) could
#      read the code directly off the screen — no view-source required.
#      This fixes the immediate leak (code no longer rendered on the page,
#      comparison is now against a hash instead of plaintext) and adds
#      basic rate-limiting. IMPORTANT — this is still a client-side check
#      and is NOT a substitute for real server-side validation. The
#      original architecture doc flagged this months ago: the real fix is
#      a Cloud Function or Firestore-rule-gated write, not a better client
#      check. Treat this as harm reduction, not a fix.
#
#   2. teacher-settings.html and student-settings.html were literal
#      "TODO: build this view" stubs, linked from every nav in the app.
#      Rebuilt to match the real dash-shell pages and reuse the same
#      settings logic already in dashboard.js (name, theme, role card).
#      Also adds a Sign Out control — audited and found NO page under
#      teacher/ or student/ had any way to log out at all.
#
#   3. Leaderboard: NOT built as a fake local-only view. Real classroom
#      leaderboards need scores visible across students, but
#      classroom.js/assignments.js/grading.js are 100% localStorage —
#      zero Firestore sync — even though Firebase itself IS configured
#      with live credentials in firebase-config.js. A leaderboard built on
#      that data would only ever show the current device's own local
#      copy, which silently breaks the moment a teacher and student are on
#      different devices (i.e. always, in real use). This script does NOT
#      paper over that with a fake single-player leaderboard. See the
#      final echo block for what real options look like.
#
# Run from the repo root, after your existing migration scripts:
#   chmod +x apply_security_settings_fixes.sh
#   ./apply_security_settings_fixes.sh
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
# 1. teacher-access.html — stop leaking the access code, hash the compare,
#    add basic rate-limiting
# --------------------------------------------------------------------------
log "Hardening teacher/teacher-access.html"
if grep -q "BOREDACADEMY_ACCESS_CODE_HARDEN" teacher/teacher-access.html 2>/dev/null; then
  echo "  (skip) already patched"
else
  python3 - <<'PYEOF'
path = "teacher/teacher-access.html"
src = open(path).read()

# 1a. Stop rendering the code in the page.
old_banner = '''        <div style="margin-top:1.4em;padding:1em;background:var(--flame-soft);border-radius:12px;border-left:4px solid var(--flame);">
          <p style="margin:.2em 0;font-size:.92em;"><strong>Full access code:</strong> <code style="background:var(--paper);padding:.15em .4em;border-radius:6px;font-family:'Courier New',monospace;letter-spacing:.06em;">B4RI$H97</code></p>
          <p style="margin:.4em 0 0;font-size:.82em;color:var(--muted);">Free plan: limited classes and students.<br>Full access: unlimited classes, students, and premium content.</p>
        </div>'''
assert old_banner in src, "access-code banner not found"

# 1a-ii. The input's placeholder also showed the real code in plain text.
old_placeholder = 'placeholder="B4RI$H97"'
assert old_placeholder in src, "access-code placeholder not found"
src = src.replace(old_placeholder, 'placeholder="Enter code"')
new_banner = '''        <!-- BOREDACADEMY_ACCESS_CODE_HARDEN -->
        <div style="margin-top:1.4em;padding:1em;background:var(--flame-soft);border-radius:12px;border-left:4px solid var(--flame);">
          <p style="margin:.2em 0;font-size:.82em;color:var(--muted);">Don't have a code? Ask your administrator, or continue with the free plan below.<br>Free plan: limited classes and students. Full access: unlimited classes, students, and premium content.</p>
        </div>'''
src = src.replace(old_banner, new_banner)

# 1b. Hash the comparison instead of storing/comparing plaintext, and
#     rate-limit repeated wrong guesses (5 tries, then 60s lockout).
old_script = '''  const FULL_ACCESS_CODE = 'B4RI$H97';

  accessForm.addEventListener('submit', function(e){
    e.preventDefault();
    accessError.textContent = '';
    const code = accessCodeInput.value.trim();
    if(!code){
      accessError.textContent = 'Please enter an access code.';
      return;
    }
    if(code !== FULL_ACCESS_CODE){
      accessError.textContent = 'Invalid access code. Please check with your administrator.';
      return;
    }
    if(window.BoredAuth){'''
assert old_script in src, "access-code form handler not found"
new_script = '''  // Hash instead of a plaintext constant, so the raw code isn't sitting in
  // the JS bundle either. NOTE: this is still a client-side check and can
  // still be defeated by anyone willing to read the JS and hash candidate
  // strings themselves — it stops casual screen-reading, not a determined
  // attacker. Real fix is server-side (Cloud Function / Firestore rule).
  function hashCode(str){
    let h = 0;
    for(let i=0;i<str.length;i++){ h = (h<<5) - h + str.charCodeAt(i); h |= 0; }
    return 'ac_' + h;
  }
  // Precomputed hash of the real code. The plaintext itself is never
  // shipped in this file, so reading the source no longer hands it over.
  const FULL_ACCESS_HASH = 'ac_383067179';

  const LOCKOUT_KEY = 'boredacademy:access_lockout';
  const ATTEMPTS_KEY = 'boredacademy:access_attempts';
  const MAX_ATTEMPTS = 5;
  const LOCKOUT_MS = 60000;

  function isLockedOut(){
    const until = parseInt(localStorage.getItem(LOCKOUT_KEY) || '0', 10);
    return Date.now() < until;
  }
  function recordFailure(){
    const n = parseInt(localStorage.getItem(ATTEMPTS_KEY) || '0', 10) + 1;
    localStorage.setItem(ATTEMPTS_KEY, String(n));
    if(n >= MAX_ATTEMPTS){
      localStorage.setItem(LOCKOUT_KEY, String(Date.now() + LOCKOUT_MS));
      localStorage.setItem(ATTEMPTS_KEY, '0');
    }
  }
  function clearAttempts(){
    localStorage.removeItem(ATTEMPTS_KEY);
    localStorage.removeItem(LOCKOUT_KEY);
  }

  accessForm.addEventListener('submit', function(e){
    e.preventDefault();
    accessError.textContent = '';
    if(isLockedOut()){
      accessError.textContent = 'Too many attempts. Try again in a minute.';
      return;
    }
    const code = accessCodeInput.value.trim();
    if(!code){
      accessError.textContent = 'Please enter an access code.';
      return;
    }
    if(hashCode(code) !== FULL_ACCESS_HASH){
      recordFailure();
      accessError.textContent = 'Invalid access code. Please check with your administrator.';
      return;
    }
    clearAttempts();
    if(window.BoredAuth){'''
src = src.replace(old_script, new_script)

open(path, "w").write(src)
print("  removed plaintext code from page, hashed comparison, added rate-limit")
PYEOF
fi

# --------------------------------------------------------------------------
# 2. teacher-settings.html / student-settings.html — real pages
# --------------------------------------------------------------------------
log "Building out teacher/teacher-settings.html"
if grep -q "BOREDACADEMY_SETTINGS_PAGE" teacher/teacher-settings.html 2>/dev/null; then
  echo "  (skip) already built"
else
cat > teacher/teacher-settings.html <<'HTMLEOF'
<!DOCTYPE html>
<html lang="en" data-theme="light">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Settings — Bored Academy</title>
<link rel="icon" href="../favicon.webp?v=2" sizes="any">
<link rel="icon" type="image/webp" href="../assets/img/favicon.webp?v=2">
<link rel="apple-touch-icon" href="../assets/img/favicon.webp?v=2">
<link rel="stylesheet" href="../assets/css/base.css">
<link rel="stylesheet" href="../assets/css/dashboard.css">
<link rel="stylesheet" href="../assets/css/responsive.css">
<script src="../assets/js/firebase/firebase-config.js"></script>
<script src="../assets/js/firebase/firestore.js"></script>
<script src="../assets/js/auth/roles.js"></script>
<script src="../assets/js/auth/permissions.js"></script>
<script src="../assets/js/auth/auth.js"></script>
<script src="../assets/js/app/router.js"></script>
<script src="../assets/js/app/theme.js"></script>
</head>
<body class="dash-page">
<!-- BOREDACADEMY_SETTINGS_PAGE -->

<script>
  (function(){
    if(!window.BoredAuth || !BoredAuth.requireAuth()) return;
    const user = BoredAuth.currentUser();
    const isTeacher = window.BoredRoles && (BoredRoles.isTeacher(user.role) || BoredRoles.isAdmin(user.role));
    if(!isTeacher){
      window.location.href = '../student/student-settings.html';
    }
  })();
</script>

<div class="dash-shell">
  <aside class="dash-sidebar" id="shellSidebar">
    <div class="dash-brand">
      <span class="logo"><img src="../assets/img/logo.webp" alt="Bored Academy logo" width="28" height="28"></span>
      <h1>Bored Academy</h1>
    </div>
    <nav class="dash-nav">
      <a href="teacher-dashboard.html"><span class="n-label">Dashboard</span></a>
      <a href="teacher-assignments.html"><span class="n-label">Assignments</span></a>
      <a href="teacher-tests.html"><span class="n-label">Tests</span></a>
      <a href="teacher-gradebook.html"><span class="n-label">Gradebook</span></a>
      <a href="teacher-calendar.html"><span class="n-label">Calendar</span></a>
      <a href="teacher-settings.html" class="active"><span class="n-label">Settings</span></a>
    </nav>
  </aside>

  <main class="dash-main">
    <div class="dash-topbar">
      <div class="dash-topbar-right">
        <span class="dash-role-badge" id="roleBadge"></span>
      </div>
    </div>

    <div class="dash-content">
      <div class="dash-welcome"><h2>Settings</h2><p>Manage your account, appearance, and data.</p></div>
      <div id="settingsContent"></div>
      <div class="settings-card">
        <h4>Sign out</h4>
        <p class="settings-hint">You'll need to log back in to access your classes.</p>
        <button class="settings-btn danger" id="signOutBtn">Sign out</button>
      </div>
    </div>
  </main>
</div>

<script src="../assets/js/app/icons.js"></script>
<script src="../assets/js/app/dashboard.js"></script>
<script>
  document.getElementById('roleBadge').textContent = BoredAuth.currentUser().role.replace('_',' ');
  renderSettingsPage();
  document.getElementById('signOutBtn').addEventListener('click', function(){
    if(confirm('Sign out of Bored Academy?')){
      BoredAuth.logout();
      window.location.href = '../welcome.html';
    }
  });
</script>
</body>
</html>
HTMLEOF
echo "  written"
fi

log "Building out student/student-settings.html"
if grep -q "BOREDACADEMY_SETTINGS_PAGE" student/student-settings.html 2>/dev/null; then
  echo "  (skip) already built"
else
cat > student/student-settings.html <<'HTMLEOF'
<!DOCTYPE html>
<html lang="en" data-theme="light">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Settings — Bored Academy</title>
<link rel="icon" href="../favicon.webp?v=2" sizes="any">
<link rel="icon" type="image/webp" href="../assets/img/favicon.webp?v=2">
<link rel="apple-touch-icon" href="../assets/img/favicon.webp?v=2">
<link rel="stylesheet" href="../assets/css/base.css">
<link rel="stylesheet" href="../assets/css/dashboard.css">
<link rel="stylesheet" href="../assets/css/responsive.css">
<script src="../assets/js/firebase/firebase-config.js"></script>
<script src="../assets/js/firebase/firestore.js"></script>
<script src="../assets/js/auth/roles.js"></script>
<script src="../assets/js/auth/permissions.js"></script>
<script src="../assets/js/auth/auth.js"></script>
<script src="../assets/js/app/router.js"></script>
<script src="../assets/js/app/theme.js"></script>
</head>
<body class="dash-page">
<!-- BOREDACADEMY_SETTINGS_PAGE -->

<script>
  (function(){
    if(!window.BoredAuth || !BoredAuth.requireAuth()) return;
    const user = BoredAuth.currentUser();
    const isTeacher = window.BoredRoles && (BoredRoles.isTeacher(user.role) || BoredRoles.isAdmin(user.role));
    if(isTeacher){
      window.location.href = '../teacher/teacher-settings.html';
    }
  })();
</script>

<div class="dash-shell">
  <aside class="dash-sidebar" id="shellSidebar">
    <div class="dash-brand">
      <span class="logo"><img src="../assets/img/logo.webp" alt="Bored Academy logo" width="28" height="28"></span>
      <h1>Bored Academy</h1>
    </div>
    <nav class="dash-nav">
      <a href="student-dashboard.html"><span class="n-label">Dashboard</span></a>
      <a href="../courses.html"><span class="n-label">Courses</span></a>
      <a href="student-leaderboard.html"><span class="n-label">Leaderboard</span></a>
      <a href="student-assignments.html"><span class="n-label">Assignments</span></a>
      <a href="student-tests.html"><span class="n-label">Tests</span></a>
      <a href="student-gradebook.html"><span class="n-label">Gradebook</span></a>
      <a href="student-calendar.html"><span class="n-label">Calendar</span></a>
      <a href="student-settings.html" class="active"><span class="n-label">Settings</span></a>
    </nav>
  </aside>

  <main class="dash-main">
    <div class="dash-topbar">
      <div class="dash-topbar-right">
        <span class="dash-role-badge" id="roleBadge"></span>
      </div>
    </div>

    <div class="dash-content">
      <div class="dash-welcome"><h2>Settings</h2><p>Manage your account, appearance, and data.</p></div>
      <div id="settingsContent"></div>
      <div class="settings-card">
        <h4>Sign out</h4>
        <p class="settings-hint">You'll need to log back in to access your classes.</p>
        <button class="settings-btn danger" id="signOutBtn">Sign out</button>
      </div>
    </div>
  </main>
</div>

<script src="../assets/js/app/icons.js"></script>
<script src="../assets/js/app/dashboard.js"></script>
<script>
  document.getElementById('roleBadge').textContent = BoredAuth.currentUser().role.replace('_',' ');
  renderSettingsPage();
  document.getElementById('signOutBtn').addEventListener('click', function(){
    if(confirm('Sign out of Bored Academy?')){
      BoredAuth.logout();
      window.location.href = '../welcome.html';
    }
  });
</script>
</body>
</html>
HTMLEOF
echo "  written"
fi

log "Done with items 1 and 2."
echo
echo "What changed:"
echo "  1. teacher-access.html no longer displays the access code on the"
echo "     page, and compares a hash instead of a plaintext constant, with"
echo "     a 5-attempt/60s lockout. Still client-side — see script header."
echo "  2. teacher-settings.html and student-settings.html are real pages"
echo "     now: name, theme picker, the Account & role card from the last"
echo "     fix, reset-progress, and a working Sign Out button. (Audited:"
echo "     no page under teacher/ or student/ had any sign-out control"
echo "     before this.)"
echo
echo "3. LEADERBOARD — not built, and here's why:"
echo "   classroom.js, assignments.js, and grading.js are all pure"
echo "   localStorage with zero Firestore writes, even though"
echo "   firebase-config.js has real, live project credentials already in"
echo "   it (not placeholders). That means right now a teacher's class,"
echo "   assignments, and grades only exist in that teacher's own browser"
echo "   — a student on a different device never actually sees a synced"
echo "   copy of any of it. That's not a leaderboard-specific gap, it's"
echo "   the actual data layer for your entire classroom feature set."
echo "   A leaderboard built on today's data would only ever rank against"
echo "   the current device's local copy, which would look fine in a demo"
echo "   and be silently broken/misleading for two real users."
echo "   Two honest ways forward — tell me which and I'll build it:"
echo "     a) Real fix: add Firestore read/write to classroom.js,"
echo "        assignments.js, and grading.js (classes, assignments,"
echo "        submissions, grades all synced), THEN build a leaderboard"
echo "        that reads real cross-student data from Firestore."
echo "     b) Faster, scoped-down: build the leaderboard UI now against"
echo "        localStorage, clearly labeled 'this device only' — useful"
echo "        for solo/demo use, but not a real multi-student ranking."
