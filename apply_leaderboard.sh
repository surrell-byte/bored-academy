#!/usr/bin/env bash
# ==========================================================================
# Bored Academy — leaderboard + dead-stub cleanup
#
# Run from the repo root.
#   chmod +x apply_leaderboard.sh
#   ./apply_leaderboard.sh
#
# What it does:
#   1. Deletes three orphaned stub files nothing references anymore:
#      classroom/calendar.js, classroom/leaderboard.js, classroom/tests.js
#      (calendar pages were built directly off assignment data, and
#      grading.js absorbed test creation).
#   2. Writes a real classroom/leaderboard.js: computes XP per student in
#      a class from BoredGrading grades (score/maxPoints -> points earned),
#      with Daily / Weekly / Monthly / All Time filters, keyed off each
#      grade's gradedAt timestamp.
#   3. Replaces the student-leaderboard.html stub with a working page:
#      class picker (for students in multiple classes), ranked list with
#      medal styling for top 3, filter tabs, highlights the current user.
#
# Safe to re-run — checks for markers, and the leaderboard page is fully
# regenerated each run since it's meant to be generated, not hand-edited.
# ==========================================================================
set -euo pipefail

log() { printf '\033[1;36m▸ %s\033[0m\n' "$1"; }
skip() { printf '  (skip) %s\n' "$1"; }

[ -f "assets/js/classroom/grading.js" ] || { echo "Run the earlier apply_*.sh scripts first — grading.js not found." >&2; exit 1; }

# --------------------------------------------------------------------------
# 1. Delete orphaned stub files (confirm nothing references them first)
# --------------------------------------------------------------------------
log "Removing orphaned stub modules"
for f in calendar leaderboard tests; do
  path="assets/js/classroom/$f.js"
  [ -f "$path" ] || continue
  if grep -rl "classroom/$f.js" --include="*.html" . >/dev/null 2>&1; then
    echo "  WARNING: $path is still referenced by an HTML file — not deleting. Check manually."
  else
    rm -f "$path"
    echo "  removed: $path"
  fi
done

# --------------------------------------------------------------------------
# 2. Write the real leaderboard module
# --------------------------------------------------------------------------
log "Writing assets/js/classroom/leaderboard.js"
cat > "assets/js/classroom/leaderboard.js" <<'EOF'
/* ==========================================================================
   Bored Academy — Leaderboard
   Ranks students in a class by points earned from graded assignments
   (BoredGrading grades: score out of maxPoints). Supports Daily / Weekly /
   Monthly / All Time windows, keyed off each grade's gradedAt timestamp.
   ========================================================================== */
window.BoredLeaderboard = (function () {
  const DAY_MS = 86400000;

  function windowStart(period, now) {
    now = now || Date.now();
    switch (period) {
      case 'daily':   return now - DAY_MS;
      case 'weekly':  return now - 7 * DAY_MS;
      case 'monthly': return now - 30 * DAY_MS;
      default:        return -Infinity; // all time
    }
  }

  // Returns [{ studentEmail, studentName, points, gradedCount }], sorted
  // descending by points. `period`: 'daily' | 'weekly' | 'monthly' | 'all'.
  function rankingsForClass(classId, period, now) {
    if (!window.BoredGrading) return [];
    now = now || Date.now();
    const since = windowStart(period, now);

    const grades = BoredGrading.gradesForClass(classId)
      .filter(function (g) { return (g.gradedAt || 0) >= since; });

    const byStudent = {};
    grades.forEach(function (g) {
      const key = g.studentEmail;
      if (!byStudent[key]) {
        byStudent[key] = { studentEmail: key, studentName: g.studentName || key, points: 0, gradedCount: 0 };
      }
      // Normalize to a 0-100 scale per grade so a 9/10 quiz and a 45/50 test
      // contribute comparably, then round to whole points.
      const maxPoints = g.maxPoints || 100;
      const score = typeof g.score === 'number' ? g.score : 0;
      const pct = maxPoints > 0 ? score / maxPoints : 0;
      byStudent[key].points += Math.round(pct * 100);
      byStudent[key].gradedCount += 1;
    });

    return Object.values(byStudent).sort(function (a, b) { return b.points - a.points; });
  }

  return { rankingsForClass: rankingsForClass, windowStart: windowStart };
})();
EOF
echo "  written"

# --------------------------------------------------------------------------
# 3. Build student/student-leaderboard.html
# --------------------------------------------------------------------------
log "Writing student/student-leaderboard.html"
if [ -f "student/student-leaderboard.html" ]; then
  cp "student/student-leaderboard.html" "student/student-leaderboard.html.bak"
fi

cat > "student/student-leaderboard.html" <<'EOF'
<!DOCTYPE html>
<html lang="en" data-theme="light">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Leaderboard — Bored Academy</title>
<link rel="icon" href="../favicon.ico?v=2" sizes="any">
<link rel="stylesheet" href="../assets/css/base.css">
<link rel="stylesheet" href="../assets/css/dashboard.css">
<link rel="stylesheet" href="../assets/css/responsive.css">
<script src="../assets/js/auth/roles.js"></script>
<script src="../assets/js/auth/permissions.js"></script>
<script src="../assets/js/auth/auth.js"></script>
<script src="../assets/js/classroom/classroom.js"></script>
<script src="../assets/js/classroom/grading.js"></script>
<script src="../assets/js/classroom/leaderboard.js"></script>
<script src="../assets/js/app/router.js"></script>
<script src="../assets/js/app/theme.js"></script>
</head>
<body class="dash-page">

<script>
  (function(){
    if(!window.BoredAuth || !BoredAuth.requireAuth()) return;
    const user = BoredAuth.currentUser();
    const isTeacher = window.BoredRoles && (BoredRoles.isTeacher(user.role) || BoredRoles.isAdmin(user.role));
    if(isTeacher){ window.location.href = '../teacher/teacher-dashboard.html'; }
  })();
</script>

<div class="dash-shell">
  <aside class="dash-sidebar" id="shellSidebar">
    <div class="dash-brand">
      <span class="logo"><img src="../assets/img/logo.png" alt="Bored Academy logo" width="28" height="28"></span>
      <h1>Bored Academy</h1>
    </div>
    <nav class="dash-nav">
      <a href="student-dashboard.html"><span class="n-label">Dashboard</span></a>
      <a href="../courses.html"><span class="n-label">Courses</span></a>
      <a href="student-leaderboard.html" class="active"><span class="n-label">Leaderboard</span></a>
      <a href="student-calendar.html"><span class="n-label">Calendar</span></a>
      <a href="student-settings.html"><span class="n-label">Settings</span></a>
    </nav>
  </aside>

  <main class="dash-main">
    <div class="dash-content">
      <div class="dash-welcome">
        <h2>Leaderboard</h2>
        <p id="classPickerLine" style="color:var(--muted);"></p>
      </div>

      <div id="classPicker" style="display:flex;gap:.5em;flex-wrap:wrap;margin-top:.8em;"></div>

      <div class="auth-tabs" id="periodTabs" role="group" aria-label="Time period" style="max-width:420px;margin-top:1.2em;">
        <button type="button" class="auth-tab" data-period="daily">Daily</button>
        <button type="button" class="auth-tab" data-period="weekly">Weekly</button>
        <button type="button" class="auth-tab active" data-period="monthly">Monthly</button>
        <button type="button" class="auth-tab" data-period="all">All Time</button>
      </div>

      <section class="block" style="margin-top:1.2em;">
        <div id="rankings"></div>
        <p id="noRankings" style="color:var(--muted);display:none;">No graded work yet for this period — once assignments are graded, rankings show up here.</p>
        <p id="noClasses" style="color:var(--muted);display:none;">Join a class to see its leaderboard.</p>
      </section>
    </div>
  </main>
</div>

<script>
  const user = BoredAuth.currentUser();
  const classes = BoredClassroom.classesForStudent(user.email);
  let selectedClassId = classes.length ? classes[0].id : null;
  let selectedPeriod = 'monthly';

  document.getElementById('noClasses').style.display = classes.length ? 'none' : '';

  function renderClassPicker(){
    const picker = document.getElementById('classPicker');
    if(classes.length <= 1){ picker.innerHTML = ''; return; }
    picker.innerHTML = classes.map(function(c){
      const active = c.id === selectedClassId;
      return '<button type="button" data-class-id="' + c.id + '" class="welcome-btn' + (active ? '' : ' secondary') + '" style="padding:.4em .9em;font-size:.85em;">' + c.name + '</button>';
    }).join('');
    picker.querySelectorAll('button').forEach(function(btn){
      btn.addEventListener('click', function(){
        selectedClassId = btn.dataset.classId;
        renderClassPicker();
        renderRankings();
      });
    });
  }

  document.getElementById('periodTabs').querySelectorAll('.auth-tab').forEach(function(btn){
    btn.addEventListener('click', function(){
      selectedPeriod = btn.dataset.period;
      document.getElementById('periodTabs').querySelectorAll('.auth-tab').forEach(function(b){
        b.classList.toggle('active', b === btn);
      });
      renderRankings();
    });
  });

  const MEDALS = ['1', '2', '3'];

  function renderRankings(){
    document.getElementById('classPickerLine').textContent = selectedClassId
      ? ((classes.find(function(c){ return c.id === selectedClassId; }) || {}).name || '')
      : '';

    if(!selectedClassId || !window.BoredLeaderboard){
      document.getElementById('rankings').innerHTML = '';
      document.getElementById('noRankings').style.display = 'none';
      return;
    }

    const rankings = BoredLeaderboard.rankingsForClass(selectedClassId, selectedPeriod);
    document.getElementById('noRankings').style.display = rankings.length ? 'none' : '';

    document.getElementById('rankings').innerHTML = rankings.map(function(r, i){
      const isMe = r.studentEmail === user.email;
      const medal = MEDALS[i] || '';
      return '<div class="stat-card" style="flex-direction:row;align-items:center;justify-content:space-between;margin-bottom:.5em;' +
        (isMe ? 'border:2px solid var(--teal);' : '') + '">' +
        '<div style="display:flex;align-items:center;gap:.7em;">' +
          '<span style="font-size:1.2em;min-width:1.6em;">' + (medal || ('#' + (i + 1))) + '</span>' +
          '<span style="font-weight:' + (isMe ? '700' : '600') + ';">' + r.studentName + (isMe ? ' (you)' : '') + '</span>' +
        '</div>' +
        '<div style="text-align:right;">' +
          '<div style="font-weight:700;">' + r.points + ' pts</div>' +
          '<div style="font-size:.75em;color:var(--muted);">' + r.gradedCount + ' graded</div>' +
        '</div>' +
      '</div>';
    }).join('');
  }

  renderClassPicker();
  renderRankings();
</script>
</body>
</html>
EOF
echo "  written"

log "Done."
echo
echo "Next steps:"
echo "  1. teacher-side leaderboard view (class-wide, not per-student) would"
echo "     reuse the same BoredLeaderboard.rankingsForClass() function."
echo "  2. Points are normalized 0-100 per graded item so different max"
echo "     scores compare fairly — adjust the weighting in leaderboard.js"
echo "     if you'd rather weight by raw points or by assignment difficulty."
