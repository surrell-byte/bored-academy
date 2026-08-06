#!/usr/bin/env bash
# ==========================================================================
# Bored Academy — student-facing assignments ("My Work")
#
# Run AFTER apply_architecture.sh, apply_roles_and_locking.sh,
# apply_signup_flow.sh, apply_dashboards.sh, and apply_teacher_class.sh,
# from the repo root.
#   chmod +x apply_student_assignments.sh
#   ./apply_student_assignments.sh
#
# What it does:
#   Adds a "My Work" section to student/student-dashboard.html that pulls
#   every assignment across every class the student is in (via
#   BoredAssignments.forClass for each of their classIds), and shows:
#     - lesson title (from lesson-index.js) + course name
#     - status: Locked (not open yet) / Due <date> / Overdue / No due date
#     - a direct link into the right course page, landing on that lesson
#       via a #lesson=<id> URL hash that course-loader.js is taught to read
#   Sorted so overdue work bubbles to the top, then soonest-due, then no
#   due date, then locked/not-yet-open.
#
# Also patches course-loader.js to jump to the lesson named in the URL hash
# (e.g. chemistry.html#lesson=1.5) on load, so the "Open lesson" link from
# the dashboard actually lands on the assigned lesson instead of lesson 1.
#
# Safe to re-run — checks for markers before patching.
# ==========================================================================
set -euo pipefail

log() { printf '\033[1;36m▸ %s\033[0m\n' "$1"; }
skip() { printf '  (skip) %s\n' "$1"; }

DASH="student/student-dashboard.html"
LOADER="assets/js/courses/course-loader.js"

[ -f "$DASH" ]   || { echo "Run apply_dashboards.sh first." >&2; exit 1; }
[ -f "$LOADER" ] || { echo "Run apply_architecture.sh + apply_roles_and_locking.sh first." >&2; exit 1; }

# --------------------------------------------------------------------------
# 1. course-loader.js: jump to #lesson=<id> from the URL on load
# --------------------------------------------------------------------------
if grep -q 'BOREDACADEMY_HASH_JUMP_PATCH' "$LOADER"; then
  skip "$LOADER already patched for hash jump"
else
  log "Patching $LOADER (jump to lesson via #lesson=<id>)"
  python3 - "$LOADER" <<'PYEOF'
import sys
path = sys.argv[1]
src = open(path).read()

anchor = "let current = 0;"
if anchor not in src:
    print("WARNING: anchor 'let current = 0;' not found, aborting.", file=sys.stderr)
    sys.exit(1)

patch = """let current = 0;

// BOREDACADEMY_HASH_JUMP_PATCH
// Supports links like chemistry.html#lesson=1.5 (used by the student
// dashboard's "Open lesson" links) by jumping straight to that lesson.
(function jumpToHashLesson(){
  const m = /lesson=([^&]+)/.exec(window.location.hash || '');
  if(!m) return;
  const idx = DATA.findIndex(l => l.id === decodeURIComponent(m[1]));
  if(idx !== -1) current = idx;
})();"""

src = src.replace(anchor, patch, 1)
open(path, 'w').write(src)
print("  patched hash-jump")
PYEOF
fi

# --------------------------------------------------------------------------
# 2. student-dashboard.html: add "My Work" section
# --------------------------------------------------------------------------
if grep -q 'BOREDACADEMY_MY_WORK_PATCH' "$DASH"; then
  skip "$DASH already has My Work section"
else
  log "Patching $DASH (My Work section)"
  python3 - "$DASH" <<'PYEOF'
import sys
path = sys.argv[1]
src = open(path).read()

# --- 2a. add script deps: assignments.js + lesson-index.js ---------------
old_scripts = '<script src="../assets/js/classroom/classroom.js"></script>\n<script src="../assets/js/app/router.js"></script>'
new_scripts = ('<script src="../assets/js/classroom/classroom.js"></script>\n'
               '<script src="../assets/js/classroom/assignments.js"></script>\n'
               '<script src="../assets/js/data/lesson-index.js"></script>\n'
               '<script src="../assets/js/app/router.js"></script>')
if old_scripts not in src:
    print("ERROR: expected script block not found, aborting.", file=sys.stderr)
    sys.exit(1)
src = src.replace(old_scripts, new_scripts, 1)

# --- 2b. insert "My Work" section before "Your classes" section ----------
anchor = '''      <section class="block" style="margin-top:1.4em;">
        <h3 class="block-title">Your classes</h3>'''

my_work_section = '''      <!-- BOREDACADEMY_MY_WORK_PATCH -->
      <section class="block" style="margin-top:1.4em;">
        <h3 class="block-title">My Work</h3>
        <div id="myWork"></div>
        <p id="noWork" style="color:var(--muted);display:none;">Nothing assigned yet — once your teacher assigns a lesson, it'll show up here.</p>
      </section>

      <section class="block" style="margin-top:1.4em;">
        <h3 class="block-title">Your classes</h3>'''

if anchor not in src:
    print("ERROR: 'Your classes' section anchor not found, aborting.", file=sys.stderr)
    sys.exit(1)
src = src.replace(anchor, my_work_section, 1)

# --- 2c. add the render logic right after renderClasses() definition -----
anchor2 = "\n  renderClasses();\n"
if src.count(anchor2) != 1:
    print("ERROR: expected exactly one top-level 'renderClasses();' call, aborting.", file=sys.stderr)
    sys.exit(1)

my_work_script = '''
  renderClasses();

  function renderMyWork(){
    const classes = BoredClassroom.classesForStudent(user.email);
    const now = Date.now();
    const LESSON_INDEX = window.LESSON_INDEX || {};
    const COURSES_BY_ID = {};
    (window.COURSES || []).forEach(function(c){ COURSES_BY_ID[c.id] = c; });

    let items = [];
    classes.forEach(function(klass){
      (BoredAssignments.forClass(klass.id) || []).forEach(function(a){
        const course = COURSES_BY_ID[a.courseId];
        const lesson = (LESSON_INDEX[a.courseId] || []).find(function(l){ return l.id === a.lessonId; });
        const unlocked = BoredAssignments.isUnlocked(a, now);
        const overdue = unlocked && BoredAssignments.isPastDue(a, now);
        items.push({
          assignment: a,
          className: klass.name,
          courseTitle: course ? course.title : a.courseId,
          courseUrl: course ? course.url : null,
          lessonTitle: lesson ? lesson.title : a.lessonId,
          unlocked: unlocked,
          overdue: overdue
        });
      });
    });

    // Sort: overdue first, then soonest due date, then no due date, then locked.
    items.sort(function(a, b){
      function rank(it){
        if(!it.unlocked) return 3;
        if(it.overdue) return 0;
        if(it.assignment.dueDate) return 1;
        return 2;
      }
      const r = rank(a) - rank(b);
      if(r !== 0) return r;
      const da = a.assignment.dueDate ? new Date(a.assignment.dueDate).getTime() : Infinity;
      const db = b.assignment.dueDate ? new Date(b.assignment.dueDate).getTime() : Infinity;
      return da - db;
    });

    document.getElementById('noWork').style.display = items.length ? 'none' : '';
    document.getElementById('myWork').innerHTML = items.map(function(it){
      let statusLabel, statusColor;
      if(!it.unlocked){ statusLabel = 'Opens ' + it.assignment.unlockDate; statusColor = 'var(--muted)'; }
      else if(it.overdue){ statusLabel = 'Overdue — was due ' + it.assignment.dueDate; statusColor = '#c0392b'; }
      else if(it.assignment.dueDate){ statusLabel = 'Due ' + it.assignment.dueDate; statusColor = 'var(--teal)'; }
      else { statusLabel = 'No due date'; statusColor = 'var(--muted)'; }

      const openLink = it.unlocked && it.courseUrl
        ? '<a href="../' + it.courseUrl + '#lesson=' + encodeURIComponent(it.assignment.lessonId) + '">Open lesson →</a>'
        : '<span style="color:var(--muted);">Locked</span>';

      return '<div class="stat-card" style="align-items:flex-start;flex-direction:column;gap:.35em;margin-bottom:.6em;">' +
        '<div style="font-weight:700;">' + it.lessonTitle + '</div>' +
        '<div style="color:var(--muted);font-size:.85em;">' + it.courseTitle + ' · ' + it.className + '</div>' +
        '<div style="font-size:.85em;color:' + statusColor + ';">' + statusLabel + (it.assignment.points ? ' · ' + it.assignment.points + ' pts' : '') + '</div>' +
        '<div style="font-size:.85em;">' + openLink + '</div>' +
      '</div>';
    }).join('');
  }
  renderMyWork();'''

src = src.replace(anchor2, my_work_script, 1)

# --- 2d. refresh My Work immediately after a successful class join -------
old_join_tail = """    BoredAuth.addClass(user.email, result.class.id);
    document.getElementById('joinCode').value = '';
    renderClasses();
    renderCourses();
  });"""
new_join_tail = """    BoredAuth.addClass(user.email, result.class.id);
    document.getElementById('joinCode').value = '';
    renderClasses();
    renderCourses();
    renderMyWork();
  });"""
if old_join_tail in src:
    src = src.replace(old_join_tail, new_join_tail, 1)
else:
    print("  NOTE: join-handler tail not found in expected form — My Work will still update on next page load.", file=sys.stderr)

open(path, 'w').write(src)
print("  patched My Work section + renderMyWork()")
PYEOF
fi

log "Done."
echo
echo "Next steps:"
echo "  1. When a student submits a quiz for an assigned lesson, that score"
echo "     should feed classroom/gradebook.js — still a stub."
echo "  2. teacher-gradebook.html is the natural next build: show submitted"
echo "     scores per student per assignment, pulling from progress-store.js"
echo "     for quiz results plus gradebook.js for anything manually graded."
echo "  3. student-calendar.html could reuse this same assignment list,"
echo "     grouped by date, once classroom/calendar.js is filled in."
