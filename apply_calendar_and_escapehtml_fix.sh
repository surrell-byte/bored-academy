#!/usr/bin/env bash
# apply_calendar_and_escapehtml_fix.sh
#
# 1) Wires tests into the teacher/student calendar (previously only showed
#    assignment due dates). Tests are linked to a class via an assignment
#    record whose lessonId points at the test id, so the calendar now checks
#    BoredGrading.getTest(a.lessonId) and renders it as a Test entry instead
#    of an Assignment entry.
# 2) Deletes assets/js/classroom/calendar.js and tests.js -- both were dead,
#    unreferenced stub files; the real calendar/tests logic lives inline in
#    the HTML pages and in grading.js.
# 3) IMPORTANT: fixes a pre-existing syntax error found while doing (1) --
#    escapeHtml() in 8 pages had a doubled backslash ('\\'' instead of
#    '\'') in its character map. That's a parse-time SyntaxError, which
#    breaks the ENTIRE inline <script> block on page load in a browser --
#    not just apostrophe handling. Affected: teacher-assignments,
#    teacher-gradebook, teacher-calendar, teacher-tests, student-calendar,
#    student-gradebook, student-tests, student-assignments.
#
# Idempotent: safe to re-run.
set -euo pipefail
cd "$(dirname "$0")"

mkdir -p "$(dirname "teacher/teacher-calendar.html")"
cat > "teacher/teacher-calendar.html" << 'BORED_EOF'
<!DOCTYPE html>
<html lang="en" data-theme="light">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Calendar — Bored Academy</title>
  <link rel="icon" href="../favicon.webp?v=2" sizes="any">
  <link rel="icon" type="image/webp" href="../assets/img/favicon.webp?v=2">
  <link rel="apple-touch-icon" href="../assets/img/favicon.webp?v=2">
  <link rel="stylesheet" href="../assets/css/base.css">
  <link rel="stylesheet" href="../assets/css/dashboard.css">
  <link rel="stylesheet" href="../assets/css/responsive.css">
  <script src="../assets/js/firebase/firebase-config.js"></script>
  <script src="../assets/js/firebase/firestore.js"></script>
  <script src="../assets/js/auth/auth.js"></script>
  <script src="../assets/js/auth/roles.js"></script>
  <script src="../assets/js/auth/permissions.js"></script>
  <script src="../assets/js/classroom/classroom.js"></script>
  <script src="../assets/js/classroom/assignments.js"></script>
  <script src="../assets/js/classroom/grading.js"></script>
  <script src="../assets/js/data/lesson-index.js"></script>
  <script src="../assets/js/app/router.js"></script>
  <script src="../assets/js/app/shell.js"></script>
</head>
<body class="dash-page">

<script>
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
      <span class="logo"><img src="../assets/img/logo.webp" alt="Bored Academy logo" width="28" height="28"></span>
      <h1>Bored Academy</h1>
    </div>
    <nav class="dash-nav">
      <a href="teacher-dashboard.html"><span class="n-label">Dashboard</span></a>
      <a href="teacher-assignments.html"><span class="n-label">Assignments</span></a>
      <a href="teacher-tests.html"><span class="n-label">Tests</span></a>
      <a href="teacher-gradebook.html"><span class="n-label">Gradebook</span></a>
      <a href="teacher-leaderboard.html"><span class="n-label">Leaderboard</span></a>
      <a href="teacher-calendar.html" class="active"><span class="n-label">Calendar</span></a>
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
        <h2>Calendar</h2>
        <p>Due dates for assignments and tests across all your classes.</p>
      </div>

      <section class="block" style="margin-top:1.4em;">
        <h3 class="block-title">Upcoming due dates</h3>
        <div id="calendarList"></div>
        <p id="noCalendar" style="color:var(--muted);display:none;">Nothing scheduled yet.</p>
      </section>
    </div>
  </main>
</div>

<script>
  const user = BoredAuth.currentUser();
  document.getElementById('roleBadge').textContent = user.role.replace('_', ' ');
  const COURSES = window.COURSES || [];
  const LESSON_INDEX = window.LESSON_INDEX || {};

  function escapeHtml(str){
    return String(str).replace(/[&<>"']/g, function(m){ return ({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;','\'':'&#39;'})[m]; });
  }

  function renderCalendar(){
    const classes = BoredClassroom.classesForTeacher(user.email);
    const now = new Date();
    now.setHours(0,0,0,0);
    let items = [];
    classes.forEach(function(klass){
      (BoredAssignments.forClass(klass.id) || []).forEach(function(a){
        const course = COURSES.find(function(c){ return c.id === a.courseId; });
        const test = window.BoredGrading ? BoredGrading.getTest(a.lessonId) : null;
        const lesson = test ? null : (LESSON_INDEX[a.courseId] || []).find(function(l){ return l.id === a.lessonId; });
        const due = a.dueDate ? new Date(a.dueDate) : null;
        if(due && due >= now){
          items.push({
            type: test ? 'test' : 'assignment',
            dueDate: a.dueDate,
            courseTitle: course ? course.title : a.courseId,
            itemTitle: test ? (test.title || 'Untitled test') : (lesson ? lesson.title : a.lessonId),
            className: klass.name,
            points: test ? (test.totalPoints || 100) : a.points
          });
        }
      });
    });
    items.sort(function(a,b){ return new Date(a.dueDate) - new Date(b.dueDate); });
    document.getElementById('noCalendar').style.display = items.length ? 'none' : '';
    document.getElementById('calendarList').innerHTML = items.map(function(it){
      const due = new Date(it.dueDate);
      const dueStr = due.toLocaleDateString(undefined, { month: 'short', day: 'numeric', year: 'numeric' });
      const kindLabel = it.type === 'test' ? 'Test' : 'Assignment';
      const kindColor = it.type === 'test' ? 'var(--gold)' : 'var(--teal)';
      return '<div class="stat-card" style="align-items:flex-start;flex-direction:column;gap:.4em;margin-bottom:.6em;">' +
        '<div style="font-weight:700;">' + escapeHtml(it.itemTitle) + ' <span style="font-weight:600;font-size:.75em;color:' + kindColor + ';">· ' + kindLabel + '</span></div>' +
        '<div style="color:var(--muted);font-size:.85em;">' + escapeHtml(it.courseTitle) + ' · ' + escapeHtml(it.className) + '</div>' +
        '<div style="font-size:.85em;color:var(--teal);">Due: ' + dueStr + (it.points ? ' · ' + it.points + ' pts' : '') + '</div>' +
      '</div>';
    }).join('');
  }
  renderCalendar();
</script>

</body>
</html>
BORED_EOF

mkdir -p "$(dirname "student/student-calendar.html")"
cat > "student/student-calendar.html" << 'BORED_EOF'
<!DOCTYPE html>
<html lang="en" data-theme="light">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Calendar — Bored Academy</title>
  <link rel="icon" href="../favicon.webp?v=2" sizes="any">
  <link rel="icon" type="image/webp" href="../assets/img/favicon.webp?v=2">
  <link rel="apple-touch-icon" href="../assets/img/favicon.webp?v=2">
  <link rel="stylesheet" href="../assets/css/base.css">
  <link rel="stylesheet" href="../assets/css/dashboard.css">
  <link rel="stylesheet" href="../assets/css/responsive.css">
  <script src="../assets/js/firebase/firebase-config.js"></script>
  <script src="../assets/js/firebase/firestore.js"></script>
  <script src="../assets/js/auth/auth.js"></script>
  <script src="../assets/js/auth/roles.js"></script>
  <script src="../assets/js/auth/permissions.js"></script>
  <script src="../assets/js/classroom/classroom.js"></script>
  <script src="../assets/js/classroom/assignments.js"></script>
  <script src="../assets/js/classroom/grading.js"></script>
  <script src="../assets/js/data/lesson-index.js"></script>
  <script src="../assets/js/app/router.js"></script>
  <script src="../assets/js/app/shell.js"></script>
</head>
<body class="dash-page">

<script>
  (function(){
    if(!window.BoredAuth || !BoredAuth.requireAuth()) return;
    const user = BoredAuth.currentUser();
    const isTeacher = window.BoredRoles && (BoredRoles.isTeacher(user.role) || BoredRoles.isAdmin(user.role));
    if(isTeacher){
      window.location.href = '../teacher/teacher-calendar.html';
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
      <a href="student-calendar.html" class="active"><span class="n-label">Calendar</span></a>
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
        <h2>Calendar</h2>
        <p>Upcoming assignment and test due dates across your classes.</p>
      </div>

      <section class="block" style="margin-top:1.4em;">
        <h3 class="block-title">Upcoming</h3>
        <div id="calendarList"></div>
        <p id="noCalendar" style="color:var(--muted);display:none;">Nothing upcoming.</p>
      </section>
    </div>
  </main>
</div>

<script>
  const user = BoredAuth.currentUser();
  document.getElementById('roleBadge').textContent = user.role.replace('_', ' ');
  const COURSES = window.COURSES || [];
  const LESSON_INDEX = window.LESSON_INDEX || {};

  function escapeHtml(str){
    return String(str).replace(/[&<>"']/g, function(m){ return ({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;','\'':'&#39;'})[m]; });
  }

  function renderCalendar(){
    const classes = BoredClassroom.classesForStudent(user.email);
    const now = new Date();
    now.setHours(0,0,0,0);
    let items = [];
    classes.forEach(function(klass){
      (BoredAssignments.forClass(klass.id) || []).forEach(function(a){
        const course = COURSES.find(function(c){ return c.id === a.courseId; });
        const test = window.BoredGrading ? BoredGrading.getTest(a.lessonId) : null;
        const lesson = test ? null : (LESSON_INDEX[a.courseId] || []).find(function(l){ return l.id === a.lessonId; });
        const due = a.dueDate ? new Date(a.dueDate) : null;
        if(due && due >= now){
          items.push({
            type: test ? 'test' : 'assignment',
            dueDate: a.dueDate,
            courseTitle: course ? course.title : a.courseId,
            itemTitle: test ? (test.title || 'Untitled test') : (lesson ? lesson.title : a.lessonId),
            className: klass.name,
            points: test ? (test.totalPoints || 100) : a.points,
            lessonId: a.lessonId,
            courseId: a.courseId
          });
        }
      });
    });
    items.sort(function(a,b){ return new Date(a.dueDate) - new Date(b.dueDate); });
    document.getElementById('noCalendar').style.display = items.length ? 'none' : '';
    document.getElementById('calendarList').innerHTML = items.map(function(it){
      const due = new Date(it.dueDate);
      const dueStr = due.toLocaleDateString(undefined, { month: 'short', day: 'numeric', year: 'numeric' });
      const kindLabel = it.type === 'test' ? 'Test' : 'Assignment';
      const kindColor = it.type === 'test' ? 'var(--gold)' : 'var(--teal)';
      const courseUrl = COURSES.find(function(c){ return c.id === it.courseId; });
      const actionLink = it.type === 'test'
        ? '<a href="student-tests.html" style="color:var(--teal);">Take test →</a>'
        : (courseUrl && courseUrl.url
          ? '<a href="../' + courseUrl.url + '#lesson=' + encodeURIComponent(it.lessonId) + '" style="color:var(--teal);">Open lesson →</a>'
          : '<span style="color:var(--muted);">Locked</span>');
      return '<div class="stat-card" style="align-items:flex-start;flex-direction:column;gap:.4em;margin-bottom:.6em;">' +
        '<div style="font-weight:700;">' + escapeHtml(it.itemTitle) + ' <span style="font-weight:600;font-size:.75em;color:' + kindColor + ';">· ' + kindLabel + '</span></div>' +
        '<div style="color:var(--muted);font-size:.85em;">' + escapeHtml(it.courseTitle) + ' · ' + escapeHtml(it.className) + '</div>' +
        '<div style="font-size:.85em;color:var(--teal);">Due: ' + dueStr + (it.points ? ' · ' + it.points + ' pts' : '') + '</div>' +
        '<div style="font-size:.85em;">' + actionLink + '</div>' +
      '</div>';
    }).join('');
  }
  renderCalendar();
</script>

</body>
</html>
BORED_EOF

mkdir -p "$(dirname "teacher/teacher-assignments.html")"
cat > "teacher/teacher-assignments.html" << 'BORED_EOF'
<!DOCTYPE html>
<html lang="en" data-theme="light">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Assignments — Bored Academy</title>
  <link rel="icon" href="../favicon.webp?v=2" sizes="any">
  <link rel="icon" type="image/webp" href="../assets/img/favicon.webp?v=2">
  <link rel="apple-touch-icon" href="../assets/img/favicon.webp?v=2">
  <link rel="stylesheet" href="../assets/css/base.css">
  <link rel="stylesheet" href="../assets/css/dashboard.css">
  <link rel="stylesheet" href="../assets/css/responsive.css">
  <script src="../assets/js/firebase/firebase-config.js"></script>
  <script src="../assets/js/firebase/firestore.js"></script>
  <script src="../assets/js/auth/auth.js"></script>
  <script src="../assets/js/auth/roles.js"></script>
  <script src="../assets/js/auth/permissions.js"></script>
  <script src="../assets/js/classroom/classroom.js"></script>
  <script src="../assets/js/classroom/assignments.js"></script>
  <script src="../assets/js/classroom/grading.js"></script>
  <script src="../assets/js/data/lesson-index.js"></script>
  <script src="../assets/js/app/router.js"></script>
  <script src="../assets/js/app/shell.js"></script>
</head>
<body class="dash-page">

<script>
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
      <span class="logo"><img src="../assets/img/logo.webp" alt="Bored Academy logo" width="28" height="28"></span>
      <h1>Bored Academy</h1>
    </div>
    <nav class="dash-nav">
      <a href="teacher-dashboard.html"><span class="n-label">Dashboard</span></a>
      <a href="teacher-assignments.html" class="active"><span class="n-label">Assignments</span></a>
      <a href="teacher-tests.html"><span class="n-label">Tests</span></a>
      <a href="teacher-gradebook.html"><span class="n-label">Gradebook</span></a>
      <a href="teacher-leaderboard.html"><span class="n-label">Leaderboard</span></a>
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
        <h2>Assignments</h2>
        <p id="planLine"></p>
      </div>

      <section class="block" style="margin-top:1.4em;">
        <h3 class="block-title">Create assignment</h3>
        <form id="createAssignmentForm" style="display:flex;flex-direction:column;gap:1em;">
          <div style="display:grid;grid-template-columns:1fr 1fr;gap:1em;">
            <label>Class
              <select id="assignmentClass" required style="display:block;width:100%;padding:.55em .7em;border:1px solid var(--line);border-radius:8px;margin-top:.3em;background:var(--paper);color:var(--ink);">
                <option value="">Select a class</option>
              </select>
            </label>
            <label>Course
              <select id="assignmentCourse" required style="display:block;width:100%;padding:.55em .7em;border:1px solid var(--line);border-radius:8px;margin-top:.3em;background:var(--paper);color:var(--ink);">
                <option value="">Select a course</option>
              </select>
            </label>
          </div>

          <label>Lesson
            <select id="assignmentLesson" required disabled style="display:block;width:100%;padding:.55em .7em;border:1px solid var(--line);border-radius:8px;margin-top:.3em;background:var(--paper);color:var(--ink);">
              <option value="">Select a course first</option>
            </select>
          </label>

          <div style="display:grid;grid-template-columns:1fr 1fr 1fr;gap:1em;">
            <label>Unlock date (optional)
              <input type="date" id="assignmentUnlock" style="display:block;width:100%;padding:.55em .7em;border:1px solid var(--line);border-radius:8px;margin-top:.3em;">
            </label>
            <label>Due date (optional)
              <input type="date" id="assignmentDue" style="display:block;width:100%;padding:.55em .7em;border:1px solid var(--line);border-radius:8px;margin-top:.3em;">
            </label>
            <label>Points (optional)
              <input type="number" id="assignmentPoints" min="0" placeholder="e.g. 10" style="display:block;width:100%;padding:.55em .7em;border:1px solid var(--line);border-radius:8px;margin-top:.3em;">
            </label>
          </div>

          <div class="auth-error" id="assignmentError" style="min-height:1.4em;"></div>
          <button type="submit" class="welcome-btn">Create assignment</button>
        </form>
      </section>

      <section class="block" style="margin-top:2em;">
        <h3 class="block-title">Existing assignments</h3>
        <div id="assignmentList"></div>
        <p id="noAssignments" style="color:var(--muted);display:none;">No assignments yet. Create one above to get started.</p>
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

  const classSelect = document.getElementById('assignmentClass');
  const courseSelect = document.getElementById('assignmentCourse');
  const lessonSelect = document.getElementById('assignmentLesson');
  const COURSES = window.COURSES || [];
  const LESSON_INDEX = window.LESSON_INDEX || {};

  function renderClasses(){
    const classes = BoredClassroom.classesForTeacher(user.email);
    classSelect.innerHTML = '<option value="">Select a class</option>' +
      classes.map(function(c){
        return '<option value="' + c.id + '">' + escapeHtml(c.name) + '</option>';
      }).join('');
  }
  renderClasses();

  function renderCourses(){
    courseSelect.innerHTML = '<option value="">Select a course</option>' +
      COURSES.filter(function(c){ return c.available; }).map(function(c){
        return '<option value="' + c.id + '">' + c.icon + ' ' + escapeHtml(c.title) + '</option>';
      }).join('');
  }
  renderCourses();

  courseSelect.addEventListener('change', function(){
    const courseId = courseSelect.value;
    lessonSelect.innerHTML = '';
    if(!courseId){
      lessonSelect.disabled = true;
      lessonSelect.innerHTML = '<option value="">Select a course first</option>';
      return;
    }
    const lessons = LESSON_INDEX[courseId] || [];
    lessonSelect.disabled = lessons.length === 0;
    lessonSelect.innerHTML = '<option value="">Select a lesson</option>' +
      lessons.map(function(l){
        return '<option value="' + l.id + '">' + escapeHtml(l.title) + '</option>';
      }).join('');
  });

  document.getElementById('createAssignmentForm').addEventListener('submit', function(e){
    e.preventDefault();
    const errEl = document.getElementById('assignmentError');
    errEl.textContent = '';
    const classId = classSelect.value;
    const courseId = courseSelect.value;
    const lessonId = lessonSelect.value;
    if(!classId || !courseId || !lessonId){
      errEl.textContent = 'Please select a class, course, and lesson.';
      return;
    }
    const unlockDate = document.getElementById('assignmentUnlock').value || null;
    const dueDate = document.getElementById('assignmentDue').value || null;
    const points = parseInt(document.getElementById('assignmentPoints').value, 10) || 0;
    BoredAssignments.create({ classId: classId, courseId: courseId, lessonId: lessonId, unlockDate: unlockDate, dueDate: dueDate, points: points });
    document.getElementById('assignmentUnlock').value = '';
    document.getElementById('assignmentDue').value = '';
    document.getElementById('assignmentPoints').value = '';
  renderAssignments();

  window._gradeSubmission = function(submissionId, maxPoints){
    const submission = BoredGrading.getSubmission(submissionId);
    if(!submission) return;
    const existing = BoredGrading.gradeForSubmission(submissionId);
    const currentScore = existing ? existing.score : '';
    const currentFeedback = existing ? existing.feedback : '';

    const html = '<div id="gradeModal" style="position:fixed;inset:0;background:rgba(0,0,0,.5);display:flex;align-items:center;justify-content:center;z-index:100;padding:1em;">' +
      '<div style="background:var(--card);border:1px solid var(--line);border-radius:18px;padding:1.5em 1.7em;max-width:500px;width:100%;">' +
        '<h3 style="margin:0 0 .5em;font-family:Georgia,serif;">Grade submission</h3>' +
        '<p style="color:var(--muted);font-size:.85em;margin:0 0 1em;">Student: ' + escapeHtml(submission.studentName || submission.studentEmail) + '</p>' +
        '<div style="max-height:150px;overflow-y:auto;background:var(--paper);padding:.7em;border-radius:8px;border:1px solid var(--line);font-size:.85em;margin-bottom:1em;white-space:pre-wrap;">' + escapeHtml(submission.text || '(no text)') + '</div>' +
        '<label>Score (max ' + maxPoints + ')<br><input type="number" id="gradeScore" min="0" max="' + maxPoints + '" value="' + (currentScore !== null ? currentScore : '') + '" required style="display:block;width:100%;padding:.55em;border:1px solid var(--line);border-radius:8px;margin-top:.3em;"></label>' +
        '<label style="margin-top:1em;">Feedback<br><textarea id="gradeFeedback" style="width:100%;min-height:80px;padding:.55em;border:1px solid var(--line);border-radius:8px;margin-top:.3em;font-family:Georgia,serif;">' + escapeHtml(currentFeedback) + '</textarea></label>' +
        '<div class="auth-error" id="gradeError" style="min-height:1.4em;"></div>' +
        '<div style="display:flex;gap:.6em;margin-top:1em;flex-wrap:wrap;">' +
          '<button class="welcome-btn" id="saveGradeBtn">Save grade</button>' +
          '<button class="welcome-link-btn" id="cancelGradeBtn">Cancel</button>' +
        '</div>' +
      '</div>' +
    '</div>';

    const modal = document.createElement('div');
    modal.innerHTML = html;
    document.body.appendChild(modal);

    document.getElementById('cancelGradeBtn').addEventListener('click', function(){
      document.body.removeChild(modal);
    });

    document.getElementById('saveGradeBtn').addEventListener('click', function(){
      const errEl = document.getElementById('gradeError');
      errEl.textContent = '';
      const scoreVal = parseInt(document.getElementById('gradeScore').value, 10);
      const feedbackVal = document.getElementById('gradeFeedback').value.trim();
      if(isNaN(scoreVal) || scoreVal < 0 || scoreVal > maxPoints){
        errEl.textContent = 'Please enter a valid score between 0 and ' + maxPoints + '.';
        return;
      }
      if(existing){
        BoredGrading.updateGrade(existing.id, { score: scoreVal, maxPoints: maxPoints, feedback: feedbackVal, gradedAt: Date.now() });
      } else {
        BoredGrading.recordGrade({ submissionId: submissionId, studentEmail: submission.studentEmail, studentName: submission.studentName, classId: submission.classId, assignmentId: submission.assignmentId, score: scoreVal, maxPoints: maxPoints, feedback: feedbackVal });
      }
      document.body.removeChild(modal);
      renderAssignments();
    });
  };
  });

  function escapeHtml(str){
    return String(str).replace(/[&<>"']/g, function(m){ return ({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;','\'':'&#39;'})[m]; });
  }

  function renderAssignments(){
    const classes = BoredClassroom.classesForTeacher(user.email);
    let items = [];
    classes.forEach(function(klass){
      (BoredAssignments.forClass(klass.id) || []).forEach(function(a){
        const course = COURSES.find(function(c){ return c.id === a.courseId; });
        const lesson = (LESSON_INDEX[a.courseId] || []).find(function(l){ return l.id === a.lessonId; });
        const submissions = BoredGrading.submissionsForAssignment(a.id);
        const gradedCount = submissions.filter(function(s){ return s.status === 'submitted' && s.grade !== null; }).length;
        items.push({
          id: a.id,
          className: klass.name,
          classId: klass.id,
          courseTitle: course ? course.title : a.courseId,
          lessonTitle: lesson ? lesson.title : a.lessonId,
          unlockDate: a.unlockDate,
          dueDate: a.dueDate,
          points: a.points,
          submissions: submissions,
          gradedCount: gradedCount,
          totalStudents: BoredClassroom.studentsInClass(klass.id).length
        });
      });
    });
    items.sort(function(a,b){ return b.id.localeCompare(a.id); });
    document.getElementById('noAssignments').style.display = items.length ? 'none' : '';
    document.getElementById('assignmentList').innerHTML = items.map(function(it){
      const submissionsHtml = (it.submissions || []).map(function(s){
        const grade = BoredGrading.gradeForSubmission(s.id);
        const gradeStatus = grade
          ? '<span style="color:var(--good);font-weight:600;">Graded: ' + grade.score + '/' + grade.maxPoints + '</span>'
          : '<span style="color:var(--teal);">Pending</span>';
        return '<div style="display:flex;align-items:flex-start;gap:.6em;padding:.5em .6em;border-top:1px dashed var(--line);">' +
          '<div style="flex:1;min-width:0;">' +
            '<div style="font-weight:600;font-size:.85em;">' + escapeHtml(s.studentName || s.studentEmail) + '</div>' +
            '<div style="font-size:.8em;color:var(--muted);max-height:60px;overflow-y:auto;white-space:pre-wrap;">' + escapeHtml(s.text || '(no text)') + '</div>' +
          '</div>' +
          '<div style="flex-shrink:0;text-align:right;">' +
            '<div style="font-size:.78em;">' + gradeStatus + '</div>' +
            '<button class="welcome-btn" style="margin-top:.3em;padding:.35em .7em;font-size:.78em;" onclick="window._gradeSubmission(\'' + s.id + '\', ' + (it.points || 100) + ')">Grade</button>' +
          '</div>' +
        '</div>';
      }).join('');

      return '<div class="stat-card" style="align-items:flex-start;flex-direction:column;gap:.4em;margin-bottom:.6em;">' +
        '<div style="font-weight:700;">' + escapeHtml(it.lessonTitle) + '</div>' +
        '<div style="color:var(--muted);font-size:.85em;">' + escapeHtml(it.courseTitle) + ' · ' + escapeHtml(it.className) + ' · ' + it.gradedCount + '/' + (it.submissions || []).length + ' graded</div>' +
        (it.unlockDate ? '<div style="font-size:.82em;">Unlocks: ' + escapeHtml(it.unlockDate) + '</div>' : '') +
        (it.dueDate ? '<div style="font-size:.82em;">Due: ' + escapeHtml(it.dueDate) + '</div>' : '') +
        (it.points ? '<div style="font-size:.82em;">' + it.points + ' pts</div>' : '') +
        (submissionsHtml ? '<div style="margin-top:.4em;width:100%;">' + submissionsHtml + '</div>' : '<div style="font-size:.82em;color:var(--muted);">No submissions yet</div>') +
      '</div>';
    }).join('');
  }
  renderAssignments();
</script>

</body>
</html>
BORED_EOF

mkdir -p "$(dirname "teacher/teacher-gradebook.html")"
cat > "teacher/teacher-gradebook.html" << 'BORED_EOF'
<!DOCTYPE html>
<html lang="en" data-theme="light">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Gradebook — Bored Academy</title>
  <link rel="icon" href="../favicon.webp?v=2" sizes="any">
  <link rel="icon" type="image/webp" href="../assets/img/favicon.webp?v=2">
  <link rel="apple-touch-icon" href="../assets/img/favicon.webp?v=2">
  <link rel="stylesheet" href="../assets/css/base.css">
  <link rel="stylesheet" href="../assets/css/dashboard.css">
  <link rel="stylesheet" href="../assets/css/responsive.css">
  <script src="../assets/js/firebase/firebase-config.js"></script>
  <script src="../assets/js/firebase/firestore.js"></script>
  <script src="../assets/js/auth/auth.js"></script>
  <script src="../assets/js/auth/roles.js"></script>
  <script src="../assets/js/auth/permissions.js"></script>
  <script src="../assets/js/classroom/classroom.js"></script>
  <script src="../assets/js/classroom/assignments.js"></script>
  <script src="../assets/js/classroom/grading.js"></script>
  <script src="../assets/js/data/lesson-index.js"></script>
  <script src="../assets/js/app/router.js"></script>
  <script src="../assets/js/app/shell.js"></script>
</head>
<body class="dash-page">

<script>
  (function(){
    if(!window.BoredAuth || !BoredAuth.requireAuth()) return;
    const user = BoredAuth.currentUser();
    const isTeacher = window.BoredRoles && (BoredRoles.isTeacher(user.role) || BoredRoles.isAdmin(user.role));
    if(!isTeacher){
      window.location.href = '../student/student-gradebook.html';
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
      <a href="teacher-gradebook.html" class="active"><span class="n-label">Gradebook</span></a>
      <a href="teacher-leaderboard.html"><span class="n-label">Leaderboard</span></a>
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
        <h2>Gradebook</h2>
        <p>Grade student submissions and view class performance.</p>
      </div>

      <section class="block" style="margin-top:1.4em;">
        <h3 class="block-title">Select class</h3>
        <select id="gradeClassSelect" style="display:block;width:100%;max-width:320px;padding:.55em .7em;border:1px solid var(--line);border-radius:8px;background:var(--paper);color:var(--ink);margin-bottom:1em;">
          <option value="">All classes</option>
        </select>
        <div id="gradebookContent"></div>
        <p id="noGrades" style="color:var(--muted);display:none;">No submissions yet.</p>
      </section>
    </div>
  </main>
</div>

<script>
  const user = BoredAuth.currentUser();
  document.getElementById('roleBadge').textContent = user.role.replace('_', ' ');
  const COURSES = window.COURSES || [];
  const LESSON_INDEX = window.LESSON_INDEX || {};

  function escapeHtml(str){
    return String(str).replace(/[&<>"']/g, function(m){ return ({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;','\'':'&#39;'})[m]; });
  }

  const classes = BoredClassroom.classesForTeacher(user.email);
  const classSelect = document.getElementById('gradeClassSelect');
  classes.forEach(function(c){
    const opt = document.createElement('option');
    opt.value = c.id;
    opt.textContent = c.name;
    classSelect.appendChild(opt);
  });

  function renderGradebook(){
    const selectedClass = classSelect.value;
    let submissions = BoredGrading.submissionsForClass(selectedClass || '__all__');
    if(!selectedClass){
      submissions = [];
      classes.forEach(function(c){
        submissions = submissions.concat(BoredGrading.submissionsForClass(c.id));
      });
    }

    submissions = submissions.filter(function(s){ return s.status === 'submitted'; });
    submissions.sort(function(a,b){ return b.submittedAt - a.submittedAt; });

    document.getElementById('noGrades').style.display = submissions.length ? 'none' : '';
    document.getElementById('gradebookContent').innerHTML = submissions.map(function(s){
      const assignment = findAssignment(s.assignmentId);
      const course = assignment ? (COURSES.find(function(c){ return c.id === assignment.courseId; }) || {}) : {};
      const lesson = assignment ? (LESSON_INDEX[assignment.courseId] || []).find(function(l){ return l.id === assignment.lessonId; }) : {};
      const grade = BoredGrading.gradeForSubmission(s.id);
      const maxPoints = grade ? grade.maxPoints : (s.points || 100);
      const score = grade ? grade.score : null;
      const feedback = grade ? grade.feedback : '';

      return '<div class="stat-card" style="align-items:flex-start;flex-direction:column;gap:.4em;margin-bottom:.6em;">' +
        '<div style="font-weight:700;">' + escapeHtml(s.studentName || s.studentEmail) + '</div>' +
        '<div style="color:var(--muted);font-size:.85em;">' + escapeHtml(lesson.title || s.assignmentId) + ' · ' + escapeHtml(course.title || '') + '</div>' +
        '<div style="font-size:.85em;">Submitted ' + new Date(s.submittedAt).toLocaleString() + '</div>' +
        '<div style="font-size:.85em;max-height:100px;overflow-y:auto;background:var(--paper);padding:.5em;border-radius:8px;border:1px solid var(--line);white-space:pre-wrap;font-size:.82em;">' + escapeHtml(s.text || '(no text)') + '</div>' +
        (score !== null
          ? '<div style="font-size:.9em;font-weight:700;color:var(--good);">Grade: ' + score + '/' + maxPoints + '</div>' +
            (feedback ? '<div style="font-size:.82em;color:var(--muted);">Feedback: ' + escapeHtml(feedback) + '</div>' : '')
          : '<div style="font-size:.85em;color:var(--teal);">Not yet graded</div>') +
        '<div style="display:flex;gap:.6em;margin-top:.3em;flex-wrap:wrap;">' +
          '<button class="welcome-btn" onclick="window._openGrade(\'' + s.id + '\', ' + maxPoints + ')">Grade</button>' +
        '</div>' +
      '</div>';
    }).join('');
  }

  window._openGrade = function(submissionId, maxPoints){
    const submission = BoredGrading.getSubmission(submissionId);
    if(!submission) return;
    const existing = BoredGrading.gradeForSubmission(submissionId);
    const currentScore = existing ? existing.score : '';
    const currentFeedback = existing ? existing.feedback : '';

    const html = '<div id="gradeModal" style="position:fixed;inset:0;background:rgba(0,0,0,.5);display:flex;align-items:center;justify-content:center;z-index:100;padding:1em;">' +
      '<div style="background:var(--card);border:1px solid var(--line);border-radius:18px;padding:1.5em 1.7em;max-width:500px;width:100%;">' +
        '<h3 style="margin:0 0 .5em;font-family:Georgia,serif;">Grade submission</h3>' +
        '<p style="color:var(--muted);font-size:.85em;margin:0 0 1em;">Student: ' + escapeHtml(submission.studentName || submission.studentEmail) + '</p>' +
        '<label>Score (max ' + maxPoints + ')<br><input type="number" id="gradeScore" min="0" max="' + maxPoints + '" value="' + (currentScore !== null ? currentScore : '') + '" required style="display:block;width:100%;padding:.55em;border:1px solid var(--line);border-radius:8px;margin-top:.3em;"></label>' +
        '<label style="margin-top:1em;">Feedback<br><textarea id="gradeFeedback" style="width:100%;min-height:80px;padding:.55em;border:1px solid var(--line);border-radius:8px;margin-top:.3em;font-family:Georgia,serif;">' + escapeHtml(currentFeedback) + '</textarea></label>' +
        '<div class="auth-error" id="gradeError" style="min-height:1.4em;"></div>' +
        '<div style="display:flex;gap:.6em;margin-top:1em;flex-wrap:wrap;">' +
          '<button class="welcome-btn" id="saveGradeBtn">Save grade</button>' +
          '<button class="welcome-link-btn" id="cancelGradeBtn">Cancel</button>' +
        '</div>' +
      '</div>' +
    '</div>';

    const modal = document.createElement('div');
    modal.innerHTML = html;
    document.body.appendChild(modal);

    document.getElementById('cancelGradeBtn').addEventListener('click', function(){
      document.body.removeChild(modal);
    });

    document.getElementById('saveGradeBtn').addEventListener('click', function(){
      const errEl = document.getElementById('gradeError');
      errEl.textContent = '';
      const scoreVal = parseInt(document.getElementById('gradeScore').value, 10);
      const feedbackVal = document.getElementById('gradeFeedback').value.trim();
      if(isNaN(scoreVal) || scoreVal < 0 || scoreVal > maxPoints){
        errEl.textContent = 'Please enter a valid score between 0 and ' + maxPoints + '.';
        return;
      }
      if(existing){
        BoredGrading.updateGrade(existing.id, { score: scoreVal, maxPoints: maxPoints, feedback: feedbackVal, gradedAt: Date.now() });
      } else {
        BoredGrading.recordGrade({ submissionId: submissionId, studentEmail: submission.studentEmail, studentName: submission.studentName, classId: submission.classId, assignmentId: submission.assignmentId, score: scoreVal, maxPoints: maxPoints, feedback: feedbackVal });
      }
      document.body.removeChild(modal);
      renderGradebook();
    });
  };

  function findAssignment(assignmentId){
    for(let i=0;i<classes.length;i++){
      const found = (BoredAssignments.forClass(classes[i].id) || []).find(function(a){ return a.id === assignmentId; });
      if(found) return found;
    }
    return null;
  }

  classSelect.addEventListener('change', renderGradebook);
  renderGradebook();
</script>

</body>
</html>
BORED_EOF

mkdir -p "$(dirname "teacher/teacher-tests.html")"
cat > "teacher/teacher-tests.html" << 'BORED_EOF'
<!DOCTYPE html>
<html lang="en" data-theme="light">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Tests — Bored Academy</title>
  <link rel="icon" href="../favicon.webp?v=2" sizes="any">
  <link rel="icon" type="image/webp" href="../assets/img/favicon.webp?v=2">
  <link rel="apple-touch-icon" href="../assets/img/favicon.webp?v=2">
  <link rel="stylesheet" href="../assets/css/base.css">
  <link rel="stylesheet" href="../assets/css/dashboard.css">
  <link rel="stylesheet" href="../assets/css/responsive.css">
  <script src="../assets/js/firebase/firebase-config.js"></script>
  <script src="../assets/js/firebase/firestore.js"></script>
  <script src="../assets/js/auth/auth.js"></script>
  <script src="../assets/js/auth/roles.js"></script>
  <script src="../assets/js/auth/permissions.js"></script>
  <script src="../assets/js/classroom/classroom.js"></script>
  <script src="../assets/js/classroom/assignments.js"></script>
  <script src="../assets/js/classroom/grading.js"></script>
  <script src="../assets/js/data/lesson-index.js"></script>
  <script src="../assets/js/app/router.js"></script>
  <script src="../assets/js/app/shell.js"></script>
</head>
<body class="dash-page">

<script>
  (function(){
    if(!window.BoredAuth || !BoredAuth.requireAuth()) return;
    const user = BoredAuth.currentUser();
    const isTeacher = window.BoredRoles && (BoredRoles.isTeacher(user.role) || BoredRoles.isAdmin(user.role));
    if(!isTeacher){
      window.location.href = '../student/student-tests.html';
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
      <a href="teacher-tests.html" class="active"><span class="n-label">Tests</span></a>
      <a href="teacher-gradebook.html"><span class="n-label">Gradebook</span></a>
      <a href="teacher-leaderboard.html"><span class="n-label">Leaderboard</span></a>
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
        <h2>Tests</h2>
        <p id="planLine"></p>
      </div>

      <section class="block" style="margin-top:1.4em;">
        <h3 class="block-title">Create test</h3>
        <form id="createTestForm" style="display:flex;flex-direction:column;gap:1em;">
          <label>Test title
            <input type="text" id="testTitle" placeholder="e.g. Module 3 Quiz" required style="display:block;width:100%;padding:.55em .7em;border:1px solid var(--line);border-radius:8px;margin-top:.3em;">
          </label>
          <div style="display:grid;grid-template-columns:1fr 1fr;gap:1em;">
            <label>Course
              <select id="testCourse" required style="display:block;width:100%;padding:.55em .7em;border:1px solid var(--line);border-radius:8px;margin-top:.3em;background:var(--paper);color:var(--ink);">
                <option value="">Select a course</option>
              </select>
            </label>
            <label>Total points
              <input type="number" id="testPoints" min="1" value="100" required style="display:block;width:100%;padding:.55em .7em;border:1px solid var(--line);border-radius:8px;margin-top:.3em;">
            </label>
          </div>

          <div id="testQuestionsEditor">
            <p style="font-weight:600;margin:0 0 .5em;">Questions</p>
            <div id="questionsList"></div>
            <button type="button" class="welcome-link-btn" id="addQuestionBtn" style="margin-top:.6em;">+ Add question</button>
          </div>

          <div class="auth-error" id="testError" style="min-height:1.4em;"></div>
          <button type="submit" class="welcome-btn">Create test</button>
        </form>
      </section>

      <section class="block" style="margin-top:2em;">
        <h3 class="block-title">Your tests</h3>
        <div id="testList"></div>
        <p id="noTests" style="color:var(--muted);display:none;">No tests yet. Create one above to get started.</p>
      </section>
    </div>
  </main>
</div>

<script>
  const user = BoredAuth.currentUser();
  document.getElementById('roleBadge').textContent = user.role.replace('_', ' ');
  const COURSES = window.COURSES || [];
  const LESSON_INDEX = window.LESSON_INDEX || {};

  function limitLine(){
    if(!window.BoredPermissions) return '';
    const limit = BoredPermissions.classLimitFor(user.role);
    if(limit.classes === Infinity) return 'Premium plan — unlimited classes and students.';
    const used = BoredClassroom.classesForTeacher(user.email).length;
    return `Free plan — ${used}/${limit.classes} class${limit.classes===1?'':'es'} used.`;
  }
  document.getElementById('planLine').textContent = limitLine();

  function escapeHtml(str){
    return String(str).replace(/[&<>"']/g, function(m){ return ({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;','\'':'&#39;'})[m]; });
  }

  const courseSelect = document.getElementById('testCourse');
  COURSES.filter(function(c){ return c.available; }).forEach(function(c){
    const opt = document.createElement('option');
    opt.value = c.id;
    opt.textContent = c.icon + ' ' + c.title;
    courseSelect.appendChild(opt);
  });

  let questionCount = 0;
  function addQuestionEditor(){
    const idx = questionCount++;
    const div = document.createElement('div');
    div.style.cssText = 'padding:.8em;border:1px solid var(--line);border-radius:12px;margin-bottom:.6em;background:var(--paper);';
    div.innerHTML =
      '<label>Question ' + (idx+1) + '<br><input type="text" class="q-text" required style="width:100%;padding:.5em;border:1px solid var(--line);border-radius:8px;margin-top:.3em;"></label>' +
      '<div style="margin-top:.5em;">' +
        '<label style="font-size:.82em;font-weight:600;">Option A <input type="radio" name="correct_' + idx + '" value="0" checked style="margin-left:.3em;"></label><br>' +
        '<input type="text" class="q-opt" data-q="' + idx + '" data-o="0" placeholder="Option A" required style="width:100%;padding:.45em;border:1px solid var(--line);border-radius:8px;margin:.2em 0;">' +
        '<label style="font-size:.82em;font-weight:600;">Option B <input type="radio" name="correct_' + idx + '" value="1" style="margin-left:.3em;"></label><br>' +
        '<input type="text" class="q-opt" data-q="' + idx + '" data-o="1" placeholder="Option B" required style="width:100%;padding:.45em;border:1px solid var(--line);border-radius:8px;margin:.2em 0;">' +
        '<label style="font-size:.82em;font-weight:600;">Option C <input type="radio" name="correct_' + idx + '" value="2" style="margin-left:.3em;"></label><br>' +
        '<input type="text" class="q-opt" data-q="' + idx + '" data-o="2" placeholder="Option C" required style="width:100%;padding:.45em;border:1px solid var(--line);border-radius:8px;margin:.2em 0;">' +
        '<label style="font-size:.82em;font-weight:600;">Option D <input type="radio" name="correct_' + idx + '" value="3" style="margin-left:.3em;"></label><br>' +
        '<input type="text" class="q-opt" data-q="' + idx + '" data-o="3" placeholder="Option D" required style="width:100%;padding:.45em;border:1px solid var(--line);border-radius:8px;margin:.2em 0;">' +
      '</div>' +
      '<button type="button" class="welcome-link-btn remove-q" style="color:var(--bad);font-size:.82em;">Remove question</button>';
    document.getElementById('questionsList').appendChild(div);
    div.querySelector('.remove-q').addEventListener('click', function(){
      div.remove();
    });
  }

  document.getElementById('addQuestionBtn').addEventListener('click', addQuestionEditor);
  addQuestionEditor();
  addQuestionEditor();

  document.getElementById('createTestForm').addEventListener('submit', function(e){
    e.preventDefault();
    const errEl = document.getElementById('testError');
    errEl.textContent = '';
    const title = document.getElementById('testTitle').value.trim();
    const courseId = courseSelect.value;
    const totalPoints = parseInt(document.getElementById('testPoints').value, 10) || 100;
    if(!title){ errEl.textContent = 'Please enter a test title.'; return; }
    if(!courseId){ errEl.textContent = 'Please select a course.'; return; }

    const qTexts = document.querySelectorAll('.q-text');
    const questions = [];
    let valid = true;
    qTexts.forEach(function(qText, i){
      const opts = [];
      document.querySelectorAll('.q-opt[data-q="' + i + '"]').forEach(function(optInput){
        opts.push(optInput.value.trim());
      });
      const correct = document.querySelector('input[name="correct_' + i + '"]:checked');
      if(!qText.value.trim() || opts.some(function(o){ return !o; })){
        valid = false;
        return;
      }
      questions.push({ question: qText.value.trim(), options: opts, correct: correct ? parseInt(correct.value, 10) : 0 });
    });

    if(!valid || !questions.length){
      errEl.textContent = 'Please fill in all questions and options.';
      return;
    }

    BoredGrading.createTest({ teacherEmail: user.email, title: title, courseId: courseId, totalPoints: totalPoints, questions: questions });
    document.getElementById('createTestForm').reset();
    document.getElementById('questionsList').innerHTML = '';
    questionCount = 0;
    addQuestionEditor();
    addQuestionEditor();
    renderTests();
  });

  function renderTests(){
    const tests = BoredGrading.testsForTeacher(user.email);
    document.getElementById('noTests').style.display = tests.length ? 'none' : '';
    document.getElementById('testList').innerHTML = tests.map(function(t){
      const course = COURSES.find(function(c){ return c.id === t.courseId; });
      return '<div class="stat-card" style="align-items:flex-start;flex-direction:column;gap:.4em;margin-bottom:.6em;">' +
        '<div style="font-weight:700;">' + escapeHtml(t.title) + '</div>' +
        '<div style="color:var(--muted);font-size:.85em;">' + (course ? course.icon + ' ' + escapeHtml(course.title) : t.courseId) + ' · ' + (t.questions || []).length + ' questions · ' + (t.totalPoints || 100) + ' pts</div>' +
        '<div style="font-size:.82em;color:var(--muted);">Created ' + new Date(t.createdAt).toLocaleDateString() + '</div>' +
      '</div>';
    }).join('');
  }
  renderTests();
</script>

</body>
</html>
BORED_EOF

mkdir -p "$(dirname "student/student-gradebook.html")"
cat > "student/student-gradebook.html" << 'BORED_EOF'
<!DOCTYPE html>
<html lang="en" data-theme="light">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Gradebook — Bored Academy</title>
  <link rel="icon" href="../favicon.webp?v=2" sizes="any">
  <link rel="icon" type="image/webp" href="../assets/img/favicon.webp?v=2">
  <link rel="apple-touch-icon" href="../assets/img/favicon.webp?v=2">
  <link rel="stylesheet" href="../assets/css/base.css">
  <link rel="stylesheet" href="../assets/css/dashboard.css">
  <link rel="stylesheet" href="../assets/css/responsive.css">
  <script src="../assets/js/firebase/firebase-config.js"></script>
  <script src="../assets/js/firebase/firestore.js"></script>
  <script src="../assets/js/auth/auth.js"></script>
  <script src="../assets/js/auth/roles.js"></script>
  <script src="../assets/js/auth/permissions.js"></script>
  <script src="../assets/js/classroom/classroom.js"></script>
  <script src="../assets/js/classroom/assignments.js"></script>
  <script src="../assets/js/classroom/grading.js"></script>
  <script src="../assets/js/data/lesson-index.js"></script>
  <script src="../assets/js/app/router.js"></script>
  <script src="../assets/js/app/shell.js"></script>
</head>
<body class="dash-page">

<script>
  (function(){
    if(!window.BoredAuth || !BoredAuth.requireAuth()) return;
    const user = BoredAuth.currentUser();
    const isTeacher = window.BoredRoles && (BoredRoles.isTeacher(user.role) || BoredRoles.isAdmin(user.role));
    if(isTeacher){
      window.location.href = '../teacher/teacher-gradebook.html';
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
        <h2>My grades</h2>
        <p>Grades for assignments and tests across your classes.</p>
      </div>

      <section class="block" style="margin-top:1.4em;">
        <h3 class="block-title">Grade history</h3>
        <div id="gradeList"></div>
        <p id="noGrades" style="color:var(--muted);display:none;">No grades yet. Submit assignments and tests to see your scores here.</p>
      </section>
    </div>
  </main>
</div>

<script>
  const user = BoredAuth.currentUser();
  document.getElementById('roleBadge').textContent = user.role.replace('_', ' ');
  const COURSES = window.COURSES || [];
  const LESSON_INDEX = window.LESSON_INDEX || {};

  function escapeHtml(str){
    return String(str).replace(/[&<>"']/g, function(m){ return ({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;','\'':'&#39;'})[m]; });
  }

  function renderGrades(){
    const grades = BoredGrading.gradesForStudent(user.email);
    const submissions = BoredGrading.submissionsForStudent(user.email);

    document.getElementById('noGrades').style.display = (grades.length || submissions.length) ? 'none' : '';

    let html = '';
    submissions.forEach(function(s){
      const grade = BoredGrading.gradeForSubmission(s.id);
      const assignment = findAssignment(s.assignmentId);
      const course = assignment ? (COURSES.find(function(c){ return c.id === assignment.courseId; }) || {}) : {};
      const lesson = assignment ? (LESSON_INDEX[assignment.courseId] || []).find(function(l){ return l.id === assignment.lessonId; }) : {};
      const score = grade ? grade.score : s.grade;
      const maxPoints = grade ? grade.maxPoints : (s.points || 100);
      const pct = score !== null && maxPoints ? Math.round((score / maxPoints) * 100) : null;
      const color = pct === null ? 'var(--muted)' : (pct >= 80 ? 'var(--good)' : (pct >= 60 ? 'var(--gold)' : 'var(--bad)'));

      html += '<div class="stat-card" style="align-items:flex-start;flex-direction:column;gap:.35em;margin-bottom:.6em;">' +
        '<div style="font-weight:700;">' + escapeHtml(lesson.title || s.assignmentId) + '</div>' +
        '<div style="color:var(--muted);font-size:.85em;">' + escapeHtml(course.title || s.classId) + ' · Submitted ' + new Date(s.submittedAt).toLocaleDateString() + '</div>' +
        (score !== null
          ? '<div style="font-size:.9em;font-weight:700;color:' + color + ';">Score: ' + score + '/' + maxPoints + ' (' + pct + '%)' + (grade && grade.feedback ? '<div style="font-size:.82em;color:var(--muted);margin-top:.2em;font-weight:400;">Feedback: ' + escapeHtml(grade.feedback) + '</div>' : '') + '</div>'
          : '<div style="font-size:.85em;color:var(--teal);">Awaiting grade</div>') +
      '</div>';
    });

    document.getElementById('gradeList').innerHTML = html || '';
  }

  function findAssignment(assignmentId){
    const classes = BoredClassroom.classesForStudent(user.email);
    for(let i=0;i<classes.length;i++){
      const found = (BoredAssignments.forClass(classes[i].id) || []).find(function(a){ return a.id === assignmentId; });
      if(found) return found;
    }
    return null;
  }

  renderGrades();
</script>

</body>
</html>
BORED_EOF

mkdir -p "$(dirname "student/student-tests.html")"
cat > "student/student-tests.html" << 'BORED_EOF'
<!DOCTYPE html>
<html lang="en" data-theme="light">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Tests — Bored Academy</title>
  <link rel="icon" href="../favicon.webp?v=2" sizes="any">
  <link rel="icon" type="image/webp" href="../assets/img/favicon.webp?v=2">
  <link rel="apple-touch-icon" href="../assets/img/favicon.webp?v=2">
  <link rel="stylesheet" href="../assets/css/base.css">
  <link rel="stylesheet" href="../assets/css/dashboard.css">
  <link rel="stylesheet" href="../assets/css/responsive.css">
  <script src="../assets/js/firebase/firebase-config.js"></script>
  <script src="../assets/js/firebase/firestore.js"></script>
  <script src="../assets/js/auth/auth.js"></script>
  <script src="../assets/js/auth/roles.js"></script>
  <script src="../assets/js/auth/permissions.js"></script>
  <script src="../assets/js/classroom/classroom.js"></script>
  <script src="../assets/js/classroom/grading.js"></script>
  <script src="../assets/js/data/lesson-index.js"></script>
  <script src="../assets/js/app/router.js"></script>
  <script src="../assets/js/app/shell.js"></script>
</head>
<body class="dash-page">

<script>
  (function(){
    if(!window.BoredAuth || !BoredAuth.requireAuth()) return;
    const user = BoredAuth.currentUser();
    const isTeacher = window.BoredRoles && (BoredRoles.isTeacher(user.role) || BoredRoles.isAdmin(user.role));
    if(isTeacher){
      window.location.href = '../teacher/teacher-tests.html';
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
        <h2>My tests</h2>
        <p>Take tests assigned by your teacher.</p>
      </div>

      <section class="block" style="margin-top:1.4em;">
        <h3 class="block-title">Available tests</h3>
        <div id="testList"></div>
        <p id="noTests" style="color:var(--muted);display:none;">No tests assigned yet.</p>
      </section>
    </div>
  </main>
</div>

<script>
  const user = BoredAuth.currentUser();
  document.getElementById('roleBadge').textContent = user.role.replace('_', ' ');
  const COURSES = window.COURSES || [];

  function escapeHtml(str){
    return String(str).replace(/[&<>"']/g, function(m){ return ({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;','\'':'&#39;'})[m]; });
  }

  function renderTests(){
    const classes = BoredClassroom.classesForStudent(user.email);
    const allTests = [];
    classes.forEach(function(klass){
      const assignments = BoredAssignments.forClass(klass.id) || [];
      assignments.forEach(function(a){
        const test = BoredGrading.getTest(a.lessonId);
        if(test){
          const existing = (BoredGrading.submissionsForAssignment(a.id) || []).find(function(s){ return s.studentEmail === user.email; });
          allTests.push({
            id: test.id,
            assignmentId: a.id,
            title: test.title || 'Untitled test',
            courseId: test.courseId || a.courseId,
            courseTitle: (COURSES.find(function(c){ return c.id === test.courseId; }) || {}).title || test.courseId,
            className: klass.name,
            questions: test.questions || [],
            submitted: existing && existing.status === 'submitted',
            grade: existing ? existing.grade : null,
            points: test.totalPoints || test.questions.length * 10
          });
        }
      });
    });

    document.getElementById('noTests').style.display = allTests.length ? 'none' : '';
    document.getElementById('testList').innerHTML = allTests.map(function(it){
      let actionHtml;
      if(it.submitted){
        const gradeText = it.grade !== null ? 'Grade: ' + it.grade + '/' + it.points : 'Submitted · Awaiting grade';
        const gradeColor = it.grade !== null ? 'var(--good)' : 'var(--teal)';
        actionHtml = '<span style="color:' + gradeColor + ';font-weight:600;">' + gradeText + '</span>';
      } else {
        actionHtml = '<button class="welcome-btn" onclick="window._openTest(\'' + it.assignmentId + '\', \'' + escapeHtml(it.id) + '\')">Take test</button>';
      }

      return '<div class="stat-card" style="align-items:flex-start;flex-direction:column;gap:.4em;margin-bottom:.6em;">' +
        '<div style="font-weight:700;">' + escapeHtml(it.title) + '</div>' +
        '<div style="color:var(--muted);font-size:.85em;">' + escapeHtml(it.courseTitle) + ' · ' + escapeHtml(it.className) + ' · ' + it.questions.length + ' questions</div>' +
        '<div style="font-size:.85em;">' + actionHtml + '</div>' +
      '</div>';
    }).join('');
  }

  window._openTest = function(assignmentId, testId){
    const test = BoredGrading.getTest(testId);
    if(!test) return;
    const questions = test.questions || [];
    if(!questions.length){
      alert('This test has no questions yet.');
      return;
    }

    const existing = (BoredGrading.submissionsForAssignment(assignmentId) || []).find(function(s){ return s.studentEmail === user.email; });
    if(existing && existing.status === 'submitted'){
      alert('You have already submitted this test.');
      return;
    }

    const html = '<div id="testModal" style="position:fixed;inset:0;background:rgba(0,0,0,.5);display:flex;align-items:center;justify-content:center;z-index:100;padding:1em;">' +
      '<div style="background:var(--card);border:1px solid var(--line);border-radius:18px;padding:1.5em 1.7em;max-width:700px;width:100%;max-height:90vh;overflow-y:auto;">' +
        '<h3 style="margin:0 0 .5em;font-family:Georgia,serif;">' + escapeHtml(test.title || 'Test') + '</h3>' +
        '<p style="color:var(--muted);font-size:.85em;margin:0 0 1em;">Answer all questions, then submit.</p>' +
        '<div id="testQuestions">' +
          questions.map(function(q, i){
            return '<div style="margin-bottom:1.2em;padding:.8em;border:1px solid var(--line);border-radius:12px;">' +
              '<p style="font-weight:700;margin:0 0 .6em;">' + (i+1) + '. ' + escapeHtml(q.question) + '</p>' +
              (q.options || []).map(function(opt, oi){
                return '<label style="display:flex;align-items:center;gap:.5em;padding:.4em .6em;border-radius:8px;cursor:pointer;font-size:.92em;">' +
                  '<input type="radio" name="q' + i + '" value="' + oi + '" style="accent-color:var(--teal);"> ' + escapeHtml(opt) +
                '</label>';
              }).join('') +
            '</div>';
          }).join('') +
        '</div>' +
        '<div class="auth-error" id="testError" style="min-height:1.4em;"></div>' +
        '<div style="display:flex;gap:.6em;margin-top:1em;flex-wrap:wrap;">' +
          '<button class="welcome-btn" id="submitTestBtn">Submit test</button>' +
          '<button class="welcome-link-btn" id="cancelTestBtn">Cancel</button>' +
        '</div>' +
      '</div>' +
    '</div>';

    const modal = document.createElement('div');
    modal.innerHTML = html;
    document.body.appendChild(modal);

    document.getElementById('cancelTestBtn').addEventListener('click', function(){
      document.body.removeChild(modal);
    });

    document.getElementById('submitTestBtn').addEventListener('click', function(){
      const errEl = document.getElementById('testError');
      errEl.textContent = '';
      let answered = 0;
      let correct = 0;
      questions.forEach(function(q, i){
        const selected = document.querySelector('input[name="q' + i + '"]:checked');
        if(selected){
          answered++;
          const answerIdx = parseInt(selected.value, 10);
          if(answerIdx === q.correct){
            correct++;
          }
        }
      });
      if(answered < questions.length){
        errEl.textContent = 'Please answer all questions before submitting.';
        return;
      }
      const score = Math.round((correct / questions.length) * 100);
      if(existing){
        BoredGrading.updateSubmission(existing.id, { answers: correct + '/' + questions.length, grade: score, status: 'submitted', submittedAt: Date.now() });
      } else {
        BoredGrading.createSubmission({ assignmentId: assignmentId, classId: '', studentEmail: user.email, studentName: user.name, answers: correct + '/' + questions.length, grade: score, status: 'submitted', points: test.totalPoints || questions.length * 10 });
      }
      document.body.removeChild(modal);
      renderTests();
    });
  };

  renderTests();
</script>

</body>
</html>
BORED_EOF

mkdir -p "$(dirname "student/student-assignments.html")"
cat > "student/student-assignments.html" << 'BORED_EOF'
<!DOCTYPE html>
<html lang="en" data-theme="light">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Assignments — Bored Academy</title>
  <link rel="icon" href="../favicon.webp?v=2" sizes="any">
  <link rel="icon" type="image/webp" href="../assets/img/favicon.webp?v=2">
  <link rel="apple-touch-icon" href="../assets/img/favicon.webp?v=2">
  <link rel="stylesheet" href="../assets/css/base.css">
  <link rel="stylesheet" href="../assets/css/dashboard.css">
  <link rel="stylesheet" href="../assets/css/responsive.css">
  <script src="../assets/js/firebase/firebase-config.js"></script>
  <script src="../assets/js/firebase/firestore.js"></script>
  <script src="../assets/js/auth/auth.js"></script>
  <script src="../assets/js/auth/roles.js"></script>
  <script src="../assets/js/auth/permissions.js"></script>
  <script src="../assets/js/classroom/classroom.js"></script>
  <script src="../assets/js/classroom/assignments.js"></script>
  <script src="../assets/js/classroom/grading.js"></script>
  <script src="../assets/js/data/lesson-index.js"></script>
  <script src="../assets/js/app/router.js"></script>
  <script src="../assets/js/app/shell.js"></script>
</head>
<body class="dash-page">

<script>
  (function(){
    if(!window.BoredAuth || !BoredAuth.requireAuth()) return;
    const user = BoredAuth.currentUser();
    const isTeacher = window.BoredRoles && (BoredRoles.isTeacher(user.role) || BoredRoles.isAdmin(user.role));
    if(isTeacher){
      window.location.href = '../teacher/teacher-assignments.html';
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
        <h2>My assignments</h2>
        <p>View and submit your assigned work.</p>
      </div>

      <section class="block" style="margin-top:1.4em;">
        <h3 class="block-title">Assigned work</h3>
        <div id="assignmentList"></div>
        <p id="noAssignments" style="color:var(--muted);display:none;">No assignments yet. Join a class to get started.</p>
      </section>
    </div>
  </main>
</div>

<script>
  const user = BoredAuth.currentUser();
  document.getElementById('roleBadge').textContent = user.role.replace('_', ' ');
  const COURSES = window.COURSES || [];
  const LESSON_INDEX = window.LESSON_INDEX || {};

  function escapeHtml(str){
    return String(str).replace(/[&<>"']/g, function(m){ return ({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;','\'':'&#39;'})[m]; });
  }

  function renderAssignments(){
    const classes = BoredClassroom.classesForStudent(user.email);
    const now = Date.now();
    let items = [];
    classes.forEach(function(klass){
      (BoredAssignments.forClass(klass.id) || []).forEach(function(a){
        const course = COURSES.find(function(c){ return c.id === a.courseId; });
        const lesson = (LESSON_INDEX[a.courseId] || []).find(function(l){ return l.id === a.lessonId; });
        const unlocked = BoredAssignments.isUnlocked(a, now);
        const submission = (BoredGrading.submissionsForAssignment(a.id) || []).find(function(s){ return s.studentEmail === user.email; });
        items.push({
          id: a.id,
          className: klass.name,
          classId: klass.id,
          courseTitle: course ? course.title : a.courseId,
          lessonTitle: lesson ? lesson.title : a.lessonId,
          courseUrl: course ? course.url : null,
          lessonId: a.lessonId,
          unlockDate: a.unlockDate,
          dueDate: a.dueDate,
          points: a.points,
          unlocked: unlocked,
          submission: submission
        });
      });
    });

    items.sort(function(a,b){
      function rank(it){
        if(!it.unlocked) return 3;
        if(it.submission && it.submission.status === 'submitted') return 2;
        if(it.dueDate) return 1;
        return 0;
      }
      return rank(a) - rank(b);
    });

    document.getElementById('noAssignments').style.display = items.length ? 'none' : '';
    document.getElementById('assignmentList').innerHTML = items.map(function(it){
      const unlocked = it.unlocked;
      const submission = it.submission;
      let statusLabel, statusColor, actionHtml;

      if(!unlocked){
        statusLabel = 'Opens ' + it.unlockDate;
        statusColor = 'var(--muted)';
        actionHtml = '<span style="color:var(--muted);">Locked</span>';
      } else if(submission && submission.status === 'submitted'){
        statusLabel = 'Submitted' + (submission.grade !== null ? ' · Graded: ' + submission.grade + '/' + (it.points || 100) : ' · Pending grade');
        statusColor = submission.grade !== null ? 'var(--good)' : 'var(--teal)';
        actionHtml = submission.grade !== null
          ? '<span style="color:var(--good);font-weight:600;">Grade: ' + submission.grade + '/' + (it.points || 100) + '</span>' +
            (submission.feedback ? '<div style="font-size:.85em;color:var(--muted);margin-top:.3em;">Feedback: ' + escapeHtml(submission.feedback) + '</div>' : '')
          : '<span style="color:var(--teal);">Awaiting grade</span>';
      } else if(submission && submission.status === 'draft'){
        statusLabel = 'Draft saved';
        statusColor = 'var(--gold)';
        actionHtml = '<button class="welcome-btn" onclick="window._openSubmit(\'' + it.id + '\')">Submit assignment</button>';
      } else {
        statusLabel = it.dueDate ? 'Due ' + it.dueDate : 'No due date';
        statusColor = 'var(--teal)';
        const courseUrl = it.courseUrl
          ? '<a href="../' + it.courseUrl + '#lesson=' + encodeURIComponent(it.lessonId) + '" style="color:var(--teal);font-size:.85em;margin-right:.6em;">Open lesson →</a>'
          : '';
        actionHtml = courseUrl + '<button class="welcome-btn" onclick="window._openSubmit(\'' + it.id + '\')">Submit work</button>';
      }

      return '<div class="stat-card" style="align-items:flex-start;flex-direction:column;gap:.4em;margin-bottom:.6em;">' +
        '<div style="font-weight:700;">' + escapeHtml(it.lessonTitle) + '</div>' +
        '<div style="color:var(--muted);font-size:.85em;">' + escapeHtml(it.courseTitle) + ' · ' + escapeHtml(it.className) + '</div>' +
        '<div style="font-size:.85em;color:' + statusColor + ';">' + statusLabel + (it.points ? ' · ' + it.points + ' pts' : '') + '</div>' +
        '<div style="font-size:.85em;margin-top:.2em;">' + actionHtml + '</div>' +
      '</div>';
    }).join('');
  }

  window._openSubmit = function(assignmentId){
    const assignment = null;
    const classes = BoredClassroom.classesForStudent(user.email);
    let found = null;
    classes.forEach(function(klass){
      (BoredAssignments.forClass(klass.id) || []).forEach(function(a){
        if(a.id === assignmentId) found = a;
      });
    });
    if(!found) return;

    const existing = (BoredGrading.submissionsForAssignment(assignmentId) || []).find(function(s){ return s.studentEmail === user.email; });
    const draftText = existing ? existing.text : '';

    const html = '<div id="submitModal" style="position:fixed;inset:0;background:rgba(0,0,0,.5);display:flex;align-items:center;justify-content:center;z-index:100;padding:1em;">' +
      '<div style="background:var(--card);border:1px solid var(--line);border-radius:18px;padding:1.5em 1.7em;max-width:600px;width:100%;max-height:90vh;overflow-y:auto;">' +
        '<h3 style="margin:0 0 .5em;font-family:Georgia,serif;">Submit assignment</h3>' +
        '<p style="color:var(--muted);font-size:.85em;margin:0 0 1em;">Write your answer or paste your work below. You can save as draft or submit for grading.</p>' +
        '<textarea id="submissionText" style="width:100%;min-height:200px;padding:.7em;border:1px solid var(--line);border-radius:10px;background:var(--paper);color:var(--ink);font-family:Georgia,serif;font-size:.95em;resize:vertical;">' + escapeHtml(draftText) + '</textarea>' +
        '<div style="display:flex;gap:.6em;margin-top:1em;flex-wrap:wrap;">' +
          '<button class="welcome-btn" id="submitBtn">Submit for grading</button>' +
          '<button class="welcome-link-btn" id="draftBtn">Save draft</button>' +
          '<button class="welcome-link-btn" id="cancelBtn" style="color:var(--bad);">Cancel</button>' +
        '</div>' +
        '<div class="auth-error" id="submitError" style="min-height:1.4em;"></div>' +
      '</div>' +
    '</div>';

    const modal = document.createElement('div');
    modal.innerHTML = html;
    document.body.appendChild(modal);

    document.getElementById('cancelBtn').addEventListener('click', function(){
      document.body.removeChild(modal);
    });

    document.getElementById('draftBtn').addEventListener('click', function(){
      const text = document.getElementById('submissionText').value.trim();
      if(!text){
        document.getElementById('submitError').textContent = 'Please write something before saving.';
        return;
      }
      if(existing){
        BoredGrading.updateSubmission(existing.id, { text: text, status: 'draft', updatedAt: Date.now() });
      } else {
        BoredGrading.createSubmission({ assignmentId: assignmentId, classId: found.classId, studentEmail: user.email, studentName: user.name, text: text, status: 'draft', points: found.points || 100 });
      }
      document.body.removeChild(modal);
      renderAssignments();
    });

    document.getElementById('submitBtn').addEventListener('click', function(){
      const text = document.getElementById('submissionText').value.trim();
      if(!text){
        document.getElementById('submitError').textContent = 'Please write your answer before submitting.';
        return;
      }
      if(existing){
        BoredGrading.updateSubmission(existing.id, { text: text, status: 'submitted', submittedAt: Date.now(), updatedAt: Date.now() });
      } else {
        BoredGrading.createSubmission({ assignmentId: assignmentId, classId: found.classId, studentEmail: user.email, studentName: user.name, text: text, status: 'submitted', points: found.points || 100 });
      }
      document.body.removeChild(modal);
      renderAssignments();
    });
  };

  renderAssignments();
</script>

</body>
</html>
BORED_EOF

rm -f "assets/js/classroom/calendar.js"
rm -f "assets/js/classroom/tests.js"

echo "Applied: tests-in-calendar, dead stub cleanup, escapeHtml syntax fix (8 pages)."
