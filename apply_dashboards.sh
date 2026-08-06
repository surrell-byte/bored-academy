#!/usr/bin/env bash
# ==========================================================================
# Bored Academy — build out teacher/student dashboards
#
# Run AFTER apply_architecture.sh, apply_roles_and_locking.sh, and
# apply_signup_flow.sh, from the repo root.
#   chmod +x apply_dashboards.sh
#   ./apply_dashboards.sh
#
# Replaces the stub teacher/teacher-dashboard.html and
# student/student-dashboard.html (created by apply_architecture.sh) with
# working pages:
#
#   Teacher dashboard:
#     - Auth-guarded (redirects non-teachers away)
#     - "Create a class" form -> BoredClassroom.createClass()
#     - Lists the teacher's classes with join code + student count
#     - Respects the free-tier class limit from BoredPermissions.classLimitFor
#
#   Student dashboard:
#     - Auth-guarded (redirects non-students away)
#     - "Join a class" form -> BoredClassroom.joinClass + BoredAuth.addClass
#     - Lists classes the student has joined
#     - Lists available courses with a locked/unlocked badge per
#       BoredPermissions.canAccessLesson-style logic (course-level: locked
#       unless premium or in a class; free courses always show as browsable)
#
# Safe to re-run — it will overwrite the two dashboard files each time
# (they're generated, not meant to be hand-edited after this point). If you
# HAVE hand-edited them, this script backs them up to *.bak before
# overwriting.
# ==========================================================================
set -euo pipefail

log() { printf '\033[1;36m▸ %s\033[0m\n' "$1"; }

[ -f "assets/js/auth/auth.js" ] || { echo "Run apply_architecture.sh first." >&2; exit 1; }
[ -f "assets/js/classroom/classroom.js" ] || { echo "Run apply_architecture.sh first." >&2; exit 1; }

mkdir -p teacher student

backup_if_exists() {
  local f="$1"
  if [ -f "$f" ]; then
    cp "$f" "$f.bak"
    echo "  backed up: $f -> $f.bak"
  fi
}

# --------------------------------------------------------------------------
# Teacher dashboard
# --------------------------------------------------------------------------
log "Writing teacher/teacher-dashboard.html"
backup_if_exists "teacher/teacher-dashboard.html"
cat > "teacher/teacher-dashboard.html" <<'EOF'
<!DOCTYPE html>
<html lang="en" data-theme="light">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Teacher Dashboard — Bored Academy</title>
<link rel="icon" href="../favicon.ico?v=2" sizes="any">
<link rel="stylesheet" href="../assets/css/base.css">
<link rel="stylesheet" href="../assets/css/dashboard.css">
<link rel="stylesheet" href="../assets/css/responsive.css">
<script src="../assets/js/auth/roles.js"></script>
<script src="../assets/js/auth/permissions.js"></script>
<script src="../assets/js/auth/auth.js"></script>
<script src="../assets/js/classroom/classroom.js"></script>
<script src="../assets/js/app/router.js"></script>
<script src="../assets/js/app/theme.js"></script>
</head>
<body class="dash-page">

<script>
  // Auth guard: must be logged in AND a teacher/admin, or send them away.
  (function(){
    if(!window.BoredAuth || !BoredAuth.requireAuth()) return;
    const user = BoredAuth.currentUser();
    const isTeacher = window.BoredRoles && (BoredRoles.isTeacher(user.role) || BoredRoles.isAdmin(user.role));
    if(!isTeacher){
      window.location.href = '../student/student-dashboard.html';
    }
  })();
</script>

<div class="dash-shell">
  <aside class="dash-sidebar" id="shellSidebar">
    <div class="dash-brand">
      <span class="logo"><img src="../assets/img/logo.png" alt="Bored Academy logo" width="28" height="28"></span>
      <h1>Bored Academy</h1>
    </div>
    <nav class="dash-nav">
      <a href="teacher-dashboard.html" class="active"><span class="n-label">Dashboard</span></a>
      <a href="teacher-assignments.html"><span class="n-label">Assignments</span></a>
      <a href="teacher-tests.html"><span class="n-label">Tests</span></a>
      <a href="teacher-gradebook.html"><span class="n-label">Gradebook</span></a>
      <a href="teacher-calendar.html"><span class="n-label">Calendar</span></a>
      <a href="teacher-settings.html"><span class="n-label">Settings</span></a>
    </nav>
  </aside>

  <main class="dash-main">
    <div class="dash-topbar">
      <div class="dash-topbar-right">
        <span class="dash-role-badge" id="roleBadge"></span>
      </div>
    </div>

    <div class="dash-content">
      <div class="dash-welcome">
        <h2>Your classes</h2>
        <p id="planLine"></p>
      </div>

      <section class="block" style="margin-top:1.4em;">
        <h3 class="block-title">Create a class</h3>
        <form id="createClassForm" style="display:flex;gap:.6em;flex-wrap:wrap;align-items:flex-end;">
          <label style="flex:1;min-width:200px;">Class name
            <input type="text" id="className" placeholder="e.g. English Grade 8" required
              style="display:block;width:100%;padding:.55em .7em;border:1px solid var(--line);border-radius:8px;margin-top:.3em;">
          </label>
          <button type="submit" class="welcome-btn">Create class</button>
        </form>
        <div class="auth-error" id="createClassError" style="margin-top:.5em;"></div>
      </section>

      <section class="block" style="margin-top:1.4em;">
        <h3 class="block-title">Your classes</h3>
        <div id="classList" class="dash-grid" style="grid-template-columns:repeat(auto-fill,minmax(260px,1fr));"></div>
        <p id="noClasses" style="color:var(--muted);display:none;">You haven't created a class yet — create one above to get a join code for your students.</p>
      </section>
    </div>
  </main>
</div>

<script>
  const user = BoredAuth.currentUser();
  document.getElementById('roleBadge').textContent = user.role.replace('_', ' ');

  function limitLine(){
    if(!window.BoredPermissions) return '';
    const limit = BoredPermissions.classLimitFor(user.role);
    if(limit.classes === Infinity) return 'Premium plan — unlimited classes and students.';
    const used = BoredClassroom.classesForTeacher(user.email).length;
    return `Free plan — ${used}/${limit.classes} class${limit.classes===1?'':'es'} used, up to ${limit.students} students each.`;
  }
  document.getElementById('planLine').textContent = limitLine();

  function renderClasses(){
    const classes = BoredClassroom.classesForTeacher(user.email);
    const list = document.getElementById('classList');
    document.getElementById('noClasses').style.display = classes.length ? 'none' : '';
    list.innerHTML = classes.map(function(c){
      const count = BoredClassroom.studentsInClass(c.id).length;
      return `
        <div class="stat-card" style="align-items:flex-start;flex-direction:column;gap:.5em;">
          <div style="font-weight:700;font-size:1.05em;">${c.name}</div>
          <div style="font-family:'Courier New',monospace;letter-spacing:.05em;background:var(--paper);border:1px dashed var(--line);border-radius:6px;padding:.3em .6em;">${c.joinCode}</div>
          <div style="color:var(--muted);font-size:.85em;">${count} student${count===1?'':'s'}</div>
          <a href="teacher-class.html?classId=${encodeURIComponent(c.id)}" style="font-size:.85em;">Open class →</a>
        </div>`;
    }).join('');
  }
  renderClasses();

  document.getElementById('createClassForm').addEventListener('submit', function(e){
    e.preventDefault();
    const errEl = document.getElementById('createClassError');
    errEl.textContent = '';
    const name = document.getElementById('className').value.trim();
    if(!name) return;

    if(window.BoredPermissions){
      const limit = BoredPermissions.classLimitFor(user.role);
      const used = BoredClassroom.classesForTeacher(user.email).length;
      if(used >= limit.classes){
        errEl.textContent = 'Free plan is limited to ' + limit.classes + ' class' + (limit.classes===1?'':'es') + '. Upgrade to Premium for unlimited classes.';
        return;
      }
    }

    BoredClassroom.createClass(user.email, name);
    document.getElementById('className').value = '';
    document.getElementById('planLine').textContent = limitLine();
    renderClasses();
  });
</script>
</body>
</html>
EOF
echo "  written"

# --------------------------------------------------------------------------
# Student dashboard
# --------------------------------------------------------------------------
log "Writing student/student-dashboard.html"
backup_if_exists "student/student-dashboard.html"
cat > "student/student-dashboard.html" <<'EOF'
<!DOCTYPE html>
<html lang="en" data-theme="light">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>My Dashboard — Bored Academy</title>
<link rel="icon" href="../favicon.ico?v=2" sizes="any">
<link rel="stylesheet" href="../assets/css/base.css">
<link rel="stylesheet" href="../assets/css/dashboard.css">
<link rel="stylesheet" href="../assets/css/responsive.css">
<script src="../assets/js/auth/roles.js"></script>
<script src="../assets/js/auth/permissions.js"></script>
<script src="../assets/js/auth/auth.js"></script>
<script src="../assets/js/classroom/classroom.js"></script>
<script src="../assets/js/app/router.js"></script>
<script src="../assets/js/app/theme.js"></script>
<script src="../assets/js/data/courses.js"></script>
</head>
<body class="dash-page">

<script>
  (function(){
    if(!window.BoredAuth || !BoredAuth.requireAuth()) return;
    const user = BoredAuth.currentUser();
    const isTeacher = window.BoredRoles && (BoredRoles.isTeacher(user.role) || BoredRoles.isAdmin(user.role));
    if(isTeacher){
      window.location.href = '../teacher/teacher-dashboard.html';
    }
  })();
</script>

<div class="dash-shell">
  <aside class="dash-sidebar" id="shellSidebar">
    <div class="dash-brand">
      <span class="logo"><img src="../assets/img/logo.png" alt="Bored Academy logo" width="28" height="28"></span>
      <h1>Bored Academy</h1>
    </div>
    <nav class="dash-nav">
      <a href="student-dashboard.html" class="active"><span class="n-label">Dashboard</span></a>
      <a href="../courses.html"><span class="n-label">Courses</span></a>
      <a href="student-leaderboard.html"><span class="n-label">Leaderboard</span></a>
      <a href="student-calendar.html"><span class="n-label">Calendar</span></a>
      <a href="student-settings.html"><span class="n-label">Settings</span></a>
    </nav>
  </aside>

  <main class="dash-main">
    <div class="dash-topbar">
      <div class="dash-topbar-right">
        <span class="dash-role-badge" id="roleBadge"></span>
      </div>
    </div>

    <div class="dash-content">
      <div class="dash-welcome">
        <h2 id="welcomeLine"></h2>
        <p>Join a class to unlock everything your teacher assigns, or go Premium for full access to every course.</p>
      </div>

      <section class="block" style="margin-top:1.4em;">
        <h3 class="block-title">Join a class</h3>
        <form id="joinClassForm" style="display:flex;gap:.6em;flex-wrap:wrap;align-items:flex-end;">
          <label style="flex:1;min-width:200px;">Class code
            <input type="text" id="joinCode" placeholder="ABCX-93KD" required
              style="display:block;width:100%;padding:.55em .7em;border:1px solid var(--line);border-radius:8px;margin-top:.3em;">
          </label>
          <button type="submit" class="welcome-btn">Join class</button>
        </form>
        <div class="auth-error" id="joinClassError" style="margin-top:.5em;"></div>
      </section>

      <section class="block" style="margin-top:1.4em;">
        <h3 class="block-title">Your classes</h3>
        <div id="classList" class="dash-grid" style="grid-template-columns:repeat(auto-fill,minmax(220px,1fr));"></div>
        <p id="noClasses" style="color:var(--muted);display:none;">You haven't joined a class yet.</p>
      </section>

      <section class="block" style="margin-top:1.4em;">
        <h3 class="block-title">Courses</h3>
        <div id="courseList" class="dash-grid" style="grid-template-columns:repeat(auto-fill,minmax(240px,1fr));"></div>
      </section>
    </div>
  </main>
</div>

<script>
  const user = BoredAuth.currentUser();
  document.getElementById('roleBadge').textContent = user.role.replace('_', ' ');
  document.getElementById('welcomeLine').textContent = 'Welcome back, ' + (user.name || user.email).split(' ')[0] + '.';

  function renderClasses(){
    const classes = BoredClassroom.classesForStudent(user.email);
    const list = document.getElementById('classList');
    document.getElementById('noClasses').style.display = classes.length ? 'none' : '';
    list.innerHTML = classes.map(function(c){
      return `
        <div class="stat-card" style="align-items:flex-start;flex-direction:column;gap:.4em;">
          <div style="font-weight:700;">${c.name}</div>
          <div style="color:var(--muted);font-size:.8em;">Joined class</div>
        </div>`;
    }).join('');
  }
  renderClasses();

  function isPremium(){
    return !!(window.BoredRoles && BoredRoles.isPremium(user.role));
  }

  function renderCourses(){
    const inClass = BoredClassroom.classesForStudent(user.email).length > 0;
    const list = document.getElementById('courseList');
    list.innerHTML = (window.COURSES || []).map(function(c){
      if(!c.available){
        return `
          <div class="stat-card" style="align-items:flex-start;flex-direction:column;gap:.4em;opacity:.55;">
            <div style="font-size:1.4em;">${c.icon}</div>
            <div style="font-weight:700;">${c.title}</div>
            <div style="color:var(--muted);font-size:.8em;">Coming soon</div>
          </div>`;
      }
      const unlocked = isPremium() || inClass; // course-level badge; per-lesson locking happens inside the course
      return `
        <a href="../${c.url}" style="text-decoration:none;color:inherit;">
          <div class="stat-card" style="align-items:flex-start;flex-direction:column;gap:.4em;">
            <div style="font-size:1.4em;">${c.icon}</div>
            <div style="font-weight:700;">${c.title}</div>
            <div style="color:var(--muted);font-size:.8em;">${c.lessons} lessons · ${unlocked ? 'Full access' : 'First 2 lessons free'}</div>
          </div>
        </a>`;
    }).join('');
  }
  renderCourses();

  document.getElementById('joinClassForm').addEventListener('submit', function(e){
    e.preventDefault();
    const errEl = document.getElementById('joinClassError');
    errEl.textContent = '';
    const code = document.getElementById('joinCode').value.trim();
    if(!code) return;

    const result = BoredClassroom.joinClass(user.email, code);
    if(!result.ok){ errEl.textContent = result.error; return; }

    BoredAuth.addClass(user.email, result.class.id);
    document.getElementById('joinCode').value = '';
    renderClasses();
    renderCourses();
  });
</script>
</body>
</html>
EOF
echo "  written"

log "Done."
echo
echo "Next steps:"
echo "  1. teacher-class.html (linked from 'Open class →') is still a stub"
echo "     from apply_architecture.sh — build it out to show the student"
echo "     roster and let the teacher assign lessons (assignments.js)."
echo "  2. Wire settings.html / a real upgrade button to"
echo "     BoredBilling.startCheckout() -> BoredAuth.setRole() on success."
echo "  3. Consider a 'you're viewing X's account' banner using"
echo "     BoredRoles.isAdmin(user.role) once the admin-code backend exists."
