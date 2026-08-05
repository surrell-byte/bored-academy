#!/usr/bin/env bash
set -euo pipefail
# Run this from your project root: /Users/russell/Downloads/bored-academy-1-1
# Adds working Progress / Achievements / Vocabulary / Calendar / Settings views
# to the dashboard (index.html), and wires the CET-4 course into stats.
ROOT="$(pwd)"
echo "Applying dashboard views into: $ROOT"

# 1. index.html — new view containers + nav wiring + cet4-data.js include
cat > index.html <<'INDEX_EOF'
<!DOCTYPE html>
<html lang="en" data-theme="light">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Bored Academy — Dashboard</title>
<link rel="icon" href="favicon.ico">
<link rel="stylesheet" href="assets/css/dashboard.css">
<script src="assets/js/theme.js"></script>
</head>
<body class="dash-page">

<div class="dash-shell">
  <aside class="dash-sidebar">
    <div class="dash-brand">
      <span class="logo"><svg class="icon" style="width:1.5em;height:1.5em" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round"><path d="M2 8l10-4 10 4-10 4-10-4z"/><path d="M6 10.2v4.8c0 1.5 3 3 6 3s6-1.5 6-3v-4.8"/><path d="M22 8v5.5"/></svg></span>
      <h1>Bored Academy</h1>
    </div>
    <nav class="dash-nav">
      <a href="index.html" data-nav="dashboard"><span class="n-icon"><svg class="icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M3 11l9-8 9 8"/><path d="M5 10v10h14V10"/><path d="M9.5 20v-6h5v6"/></svg></span><span class="n-label">Dashboard</span></a>
      <a href="#courses-section" data-nav="courses" onclick="return goToView(event,'dashboard','courses-section')"><span class="n-icon"><svg class="icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M12 6.5c-2-1.8-5-1.8-8-.9v13c3-.9 6-.9 8 .9 2-1.8 5-1.8 8-.9v-13c-3-.9-6-.9-8 .9z"/><path d="M12 6.5v13"/></svg></span><span class="n-label">Courses</span></a>
      <a href="#" data-nav="progress" onclick="return goToView(event,'progress')"><span class="n-icon"><svg class="icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><polyline points="3 17 9.5 10.5 13.5 14.5 21 6.5"/><polyline points="14.5 6.5 21 6.5 21 13"/></svg></span><span class="n-label">Progress</span></a>
      <a href="#" data-nav="achievements" onclick="return goToView(event,'achievements')"><span class="n-icon"><svg class="icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M8 4h8v4.2a4 4 0 0 1-8 0V4z"/><path d="M8 5H5.5a2 2 0 0 0 2 3"/><path d="M16 5h2.5a2 2 0 0 1-2 3"/><path d="M10 13.2v2.8h4v-2.8"/><path d="M9 20h6"/><path d="M12 16v4"/></svg></span><span class="n-label">Achievements</span></a>
      <a href="#" data-nav="vocabulary" onclick="return goToView(event,'vocabulary')"><span class="n-icon"><svg class="icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M6 3h12v18l-6-4.2L6 21V3z"/></svg></span><span class="n-label">Vocabulary</span></a>
      <a href="#" data-nav="calendar" onclick="return goToView(event,'calendar')"><span class="n-icon"><svg class="icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><rect x="3" y="5" width="18" height="16" rx="2"/><path d="M3 9.5h18"/><path d="M8 3v4"/><path d="M16 3v4"/></svg></span><span class="n-label">Calendar</span></a>
      <a href="#" data-nav="settings" onclick="return goToView(event,'settings')"><span class="n-icon"><svg class="icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><circle cx="12" cy="12" r="3"/><path d="M12 2.5v3M12 18.5v3M3.8 6.3l2.2 2.1M18 15.6l2.2 2.1M2.5 12h3M18.5 12h3M3.8 17.7l2.2-2.1M18 8.4l2.2-2.1"/></svg></span><span class="n-label">Settings</span></a>
    </nav>
  </aside>

  <main class="dash-main">
    <div class="dash-topbar">
      <div class="dash-search"><svg class="icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><circle cx="11" cy="11" r="7"/><line x1="21" y1="21" x2="16.2" y2="16.2"/></svg> Search lessons, topics, vocabulary…</div>
      <div class="dash-topbar-right">
        <span class="dash-role-badge" id="roleBadge">Student</span>
        <span class="dash-bell"><svg class="icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M18 8a6 6 0 0 0-12 0c0 7-3 9-3 9h18s-3-2-3-9"/><path d="M10 21a2 2 0 0 0 4 0"/></svg></span>
        <span class="dash-avatar"><svg class="icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><circle cx="12" cy="8" r="4"/><path d="M4 21c0-4 4-6 8-6s8 2 8 6"/></svg></span>
      </div>
    </div>

    <div class="dash-content">
      <div id="view-dashboard" class="dash-view">
      <div class="dash-welcome">
        <h2 id="welcomeHeading">Welcome back! 👋</h2>
        <p>Ready to continue your learning journey?</p>
      </div>

      <div class="dash-grid">
        <div class="dash-col-main">
          <div class="hero-card" id="heroCard"></div>

          <div>
            <div class="dash-section-head"><h3>Your Progress Overview</h3></div>
            <div class="stat-row" id="statRow"></div>
          </div>

          <div id="courses-section">
            <div class="dash-section-head"><h3>Your Courses</h3></div>
            <div class="course-grid" id="courseGrid"></div>
          </div>

          <div>
            <div class="dash-section-head"><h3>Achievements</h3></div>
            <div class="achv-card"><div class="achv-row" id="achvRow"></div></div>
          </div>
        </div>

        <div class="dash-col-side">
          <div class="goal-card" id="goalCard"></div>

          <div>
            <div class="dash-section-head"><h3>Recent Activity</h3></div>
            <div class="activity-card"><div id="activityList"></div></div>
          </div>

          <div class="tip-card" id="tipCard">
            <div class="t-icon">💡</div>
            <div><h4>Study Tip of the Day</h4><p></p></div>
          </div>
        </div>
      </div>
      </div>

      <div id="view-progress" class="dash-view" style="display:none">
        <div class="dash-welcome"><h2>Progress</h2><p>How you're doing in every course, lesson by lesson.</p></div>
        <div id="progressCourseList" class="progress-course-list"></div>
      </div>

      <div id="view-achievements" class="dash-view" style="display:none">
        <div class="dash-welcome"><h2>Achievements</h2><p>Badges you've earned (and ones still waiting to be unlocked).</p></div>
        <div class="achv-card"><div class="achv-grid" id="achvGridFull"></div></div>
      </div>

      <div id="view-vocabulary" class="dash-view" style="display:none">
        <div class="dash-welcome"><h2>Vocabulary</h2><p>Every word taught across your courses, in one searchable list.</p></div>
        <div class="vocab-toolbar">
          <input type="text" id="vocabSearch" class="vocab-search-input" placeholder="Search vocabulary…">
          <select id="vocabCourseFilter" class="vocab-filter-select"></select>
        </div>
        <div id="vocabCount" class="vocab-count"></div>
        <div class="vocab-grid-full" id="vocabGridFull"></div>
      </div>

      <div id="view-calendar" class="dash-view" style="display:none">
        <div class="dash-welcome"><h2>Calendar</h2><p>Your study activity over the last 12 weeks.</p></div>
        <div class="calendar-card">
          <div class="calendar-summary" id="calendarSummary"></div>
          <div class="calendar-heatmap" id="calendarHeatmap"></div>
        </div>
      </div>

      <div id="view-settings" class="dash-view" style="display:none">
        <div class="dash-welcome"><h2>Settings</h2><p>Personalize Bored Academy and manage your local data.</p></div>
        <div class="settings-card">
          <h4>Your name</h4>
          <p class="settings-hint">Used for the "Welcome back" greeting.</p>
          <div class="settings-row">
            <input type="text" id="settingsName" class="settings-input" placeholder="Enter your name">
            <button class="settings-btn" onclick="saveSettingsName()">Save</button>
          </div>
        </div>
        <div class="settings-card">
          <h4>Theme</h4>
          <p class="settings-hint">Choose how Bored Academy looks.</p>
          <div class="settings-theme-row" id="settingsThemeRow"></div>
        </div>
        <div class="settings-card">
          <h4>Reset progress</h4>
          <p class="settings-hint">Clears all saved quiz answers, streaks and activity on this device. This can't be undone.</p>
          <button class="settings-btn danger" onclick="resetAllProgress()">Reset all progress</button>
        </div>
      </div>
    </div>
  </main>
</div>

<nav class="phone-bottom-nav">
  <a href="index.html" data-nav="dashboard"><span class="bn-icon"><svg class="icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M3 11l9-8 9 8"/><path d="M5 10v10h14V10"/><path d="M9.5 20v-6h5v6"/></svg></span>Home</a>
  <a href="#courses-section" data-nav="courses" onclick="return goToView(event,'dashboard','courses-section')"><span class="bn-icon"><svg class="icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M12 6.5c-2-1.8-5-1.8-8-.9v13c3-.9 6-.9 8 .9 2-1.8 5-1.8 8-.9v-13c-3-.9-6-.9-8 .9z"/><path d="M12 6.5v13"/></svg></span>Courses</a>
  <a href="#" data-nav="progress" onclick="return goToView(event,'progress')"><span class="bn-icon"><svg class="icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><polyline points="3 17 9.5 10.5 13.5 14.5 21 6.5"/><polyline points="14.5 6.5 21 6.5 21 13"/></svg></span>Progress</a>
  <a href="#" data-nav="achievements" onclick="return goToView(event,'achievements')"><span class="bn-icon"><svg class="icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M8 4h8v4.2a4 4 0 0 1-8 0V4z"/><path d="M8 5H5.5a2 2 0 0 0 2 3"/><path d="M16 5h2.5a2 2 0 0 1-2 3"/><path d="M10 13.2v2.8h4v-2.8"/><path d="M9 20h6"/><path d="M12 16v4"/></svg></span>Achv.</a>
  <a href="#" data-nav="more" onclick="return goToView(event,'settings')"><span class="bn-icon"><svg class="icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><line x1="3" y1="6.5" x2="21" y2="6.5"/><line x1="3" y1="12" x2="21" y2="12"/><line x1="3" y1="17.5" x2="21" y2="17.5"/></svg></span>More</a>
</nav>

<script src="assets/js/icons.js"></script>
<script src="assets/js/data/courses.js"></script>
<script src="assets/js/progress-store.js"></script>
<script src="assets/js/data/chemistry-data.js"></script>
<script>
  // chemistry-data.js sets window.COURSE_DATA; alias it so future course
  // data files can each set their own COURSE_DATA on their own page without
  // clobbering this one.
  window.COURSE_DATA_CHEMISTRY = window.COURSE_DATA;
</script>
<script src="assets/js/data/ielts-data.js"></script>
<script>
  window.COURSE_DATA_IELTS = window.COURSE_DATA;
</script>
<script src="assets/js/data/cet4-data.js"></script>
<script>
  window.COURSE_DATA_CET4 = window.COURSE_DATA;
  (function personalizeName(){
    try{
      const name = localStorage.getItem('boredacademy:name');
      if(name) document.getElementById('welcomeHeading').textContent = `Welcome back, ${name}! 👋`;
    }catch(e){}
  })();
</script>
<script src="assets/js/dashboard.js"></script>
</body>
</html>
INDEX_EOF

# 2. assets/js/dashboard.js — view switching + Progress/Achievements/Vocabulary/Calendar/Settings renderers
cat > assets/js/dashboard.js <<'DASH_JS_EOF'
const STUDY_TIPS = [
  "Break difficult topics into smaller pieces. Master one concept at a time.",
  "Teach it back to yourself out loud — if you can explain it, you know it.",
  "Short, frequent study sessions beat one long cram every time.",
  "Get the easy questions done first to build momentum, then tackle the hard ones.",
  "Review yesterday's vocabulary for 2 minutes before starting something new."
];

const ACHIEVEMENT_DEFS = [
  { id:'first-lesson', icon:'🌱', label:'First Lesson\nCompleted', hint:'Complete any 1 lesson.', test:(s)=>s.lessonsCompleted >= 1 },
  { id:'five-day', icon:'🔥', label:'Five Day\nStreak', hint:'Visit 5 days in a row.', test:(s)=>s.streak >= 5 },
  { id:'quiz-master', icon:'🛡️', label:'Quiz Master\n90%+', hint:'Average 90%+ across all quizzes taken.', test:(s)=>s.avgQuizScore >= 90 && s.quizzesTaken > 0 },
  { id:'lab-apprentice', icon:'🧪', label:'Lab Apprentice\n3 Lessons', hint:'Complete 3 lessons in any course.', test:(s)=>s.lessonsCompleted >= 3 },
  { id:'bookworm', icon:'📚', label:'Bookworm\n10 Lessons', hint:'Complete 10 lessons total.', test:(s)=>s.lessonsCompleted >= 10 },
  { id:'multi-course', icon:'🗂️', label:'Multi-Tasker\n2 Courses', hint:'Make progress in 2+ courses.', test:(s)=>s.activeCourses >= 2 },
  { id:'quiz-taker', icon:'📝', label:'Quiz Taker\n10 Quizzes', hint:'Answer questions in 10 lesson quizzes.', test:(s)=>s.quizzesTaken >= 10 },
  { id:'two-week', icon:'🏅', label:'Two Week\nStreak', hint:'Visit 14 days in a row.', test:(s)=>s.streak >= 14 }
];

function getCoursePct(courseId){
  try{ return parseInt(localStorage.getItem(`boredacademy:pct:${courseId}`) || '0', 10); }
  catch(e){ return 0; }
}

// Maps courseId -> that course's lesson dataset, for every course that ships
// lesson data on the hub page. Add an entry here whenever a new course data
// file is loaded on index.html.
const COURSE_DATASETS = {
  chemistry: window.COURSE_DATA_CHEMISTRY,
  ielts: window.COURSE_DATA_IELTS,
  cet4: window.COURSE_DATA_CET4
};

function computeCourseStats(courseId){
  const data = COURSE_DATASETS[courseId];
  if(!data) return { lessonsCompleted:0, quizzesTaken:0, correctAnswers:0, totalAnswered:0 };
  let saved = {};
  try{ saved = JSON.parse(localStorage.getItem(`boredacademy:progress:${courseId}`) || '{}'); }catch(e){}
  let lessonsCompleted = 0, correctAnswers = 0, totalAnswered = 0, quizzesTaken = 0;
  data.forEach(lesson=>{
    const answered = saved[lesson.id];
    if(!answered) return;
    const answeredCount = answered.filter(a=>a!==null).length;
    if(answeredCount === 0) return;
    quizzesTaken++;
    answered.forEach((a,i)=>{
      if(a===null) return;
      totalAnswered++;
      if(lesson.quiz[i] && a === lesson.quiz[i].a) correctAnswers++;
    });
    if(answeredCount === lesson.quiz.length) lessonsCompleted++;
  });
  return { lessonsCompleted, quizzesTaken, correctAnswers, totalAnswered };
}

function computeAllCourseStats(){
  const totals = { lessonsCompleted:0, quizzesTaken:0, correctAnswers:0, totalAnswered:0 };
  Object.keys(COURSE_DATASETS).forEach(courseId=>{
    const s = computeCourseStats(courseId);
    totals.lessonsCompleted += s.lessonsCompleted;
    totals.quizzesTaken += s.quizzesTaken;
    totals.correctAnswers += s.correctAnswers;
    totals.totalAnswered += s.totalAnswered;
  });
  return totals;
}

function buildStats(){
  const courses = window.COURSES.filter(c=>c.available);
  const activeCourses = courses.filter(c=>getCoursePct(c.id) > 0).length;
  const totals = computeAllCourseStats();
  const avgQuizScore = totals.totalAnswered > 0 ? Math.round((totals.correctAnswers/totals.totalAnswered)*100) : 0;
  const streak = window.ProgressStore ? ProgressStore.currentStreak() : 0;
  return {
    activeCourses,
    lessonsCompleted: totals.lessonsCompleted,
    avgQuizScore,
    quizzesTaken: totals.quizzesTaken,
    streak
  };
}

// Picks whichever available course was studied most recently, using the
// activity log (which carries timestamps) to break ties across courses.
function mostRecentCourseId(){
  const available = window.COURSES.filter(c=>c.available).map(c=>c.id);
  if(!window.ProgressStore) return available[0];
  const activity = ProgressStore.recentActivity(20).find(a=>a.courseId && available.includes(a.courseId));
  if(activity) return activity.courseId;
  return available.find(id=>ProgressStore.getLastLesson(id)) || available[0];
}

function renderHero(){
  const el = document.getElementById('heroCard');
  const courseId = mostRecentCourseId();
  const last = window.ProgressStore ? ProgressStore.getLastLesson(courseId) : null;
  const course = window.COURSES.find(c=>c.id===courseId);
  if(!last || !course){
    el.className = 'hero-card empty';
    el.innerHTML = `<h3>Ready to start learning?</h3><p class="h-sub">Pick a course below to begin your first lesson.</p>`;
    return;
  }
  const pct = getCoursePct(courseId);
  el.className = 'hero-card';
  el.innerHTML = `
    <div class="h-icon">${course.icon}</div>
    <div class="h-body">
      <div class="h-eyebrow">Continue Learning</div>
      <h3>${last.unit ? last.unit.replace(/^(Unit|Module) \d+\s*[—-]\s*/,'') : course.title}</h3>
      <div class="h-sub">Lesson ${last.lessonId} · ${last.lessonTitle}</div>
      <div class="h-bar"><span style="width:${pct}%"></span></div>
      <div class="h-pct">${pct}% complete</div>
    </div>
    <a class="h-resume" href="courses/${course.id}.html">Resume Lesson</a>
  `;
}

function renderGoal(stats){
  const el = document.getElementById('goalCard');
  const done = stats.lessonsCompleted > 0 ? 100 : Math.min(90, stats.quizzesTaken * 30);
  el.innerHTML = `
    <div class="g-ring" style="--g:${done}"><span>${done}%</span></div>
    <div>
      <h4>Today's Goal</h4>
      <p>Complete one lesson</p>
      <div class="g-reward">🏆 Reward +100 XP</div>
    </div>
  `;
}

function renderStats(stats){
  const el = document.getElementById('statRow');
  const items = [
    { icon:'📖', num: stats.activeCourses, label:'Active Course' + (stats.activeCourses===1?'':'s') },
    { icon:'🏆', num: stats.lessonsCompleted, label:'Lessons Completed' },
    { icon:'🎯', num: stats.quizzesTaken > 0 ? stats.avgQuizScore+'%' : '—', label:'Avg Quiz Score' },
    { icon:'🔥', num: stats.streak, label:'Day Streak' }
  ];
  el.innerHTML = items.map(i=>`
    <div class="stat-card">
      <div class="s-icon">${i.icon}</div>
      <div><div class="s-num">${i.num}</div><div class="s-label">${i.label}</div></div>
    </div>`).join('');
}

function renderActivity(){
  const el = document.getElementById('activityList');
  const items = window.ProgressStore ? ProgressStore.recentActivity(4) : [];
  if(items.length === 0){
    el.innerHTML = `<div class="activity-empty">No activity yet — start a lesson to see it here.</div>`;
    return;
  }
  el.innerHTML = items.map(i=>`
    <div class="activity-item">
      <div class="a-icon">${i.type==='quiz' ? '📝' : '📘'}</div>
      <div class="a-text">${i.text}${i.detail ? ` <span class="a-detail">${i.detail}</span>` : ''}</div>
      <div class="a-time">${ProgressStore.timeAgo(i.ts)}</div>
    </div>`).join('');
}

function renderCourses(){
  const el = document.getElementById('courseGrid');
  el.innerHTML = window.COURSES.map(c=>{
    if(!c.available){
      return `
        <div class="course-card soon">
          <div class="c-icon">${c.icon}</div>
          <h4>${c.title}</h4>
          <div class="c-lessons">${c.blurb}</div>
          <div class="c-action">Coming Soon</div>
        </div>`;
    }
    const pct = getCoursePct(c.id);
    return `
      <a class="course-card" href="${c.url}">
        <div class="c-icon">${c.icon}</div>
        <h4>${c.title}</h4>
        <div class="c-lessons">${c.lessons} Lessons</div>
        <div class="c-bar"><span style="width:${pct}%"></span></div>
        <div class="c-action">${pct>0 ? 'Continue →' : 'Start →'}</div>
      </a>`;
  }).join('');
}

function renderAchievements(stats){
  const el = document.getElementById('achvRow');
  el.innerHTML = ACHIEVEMENT_DEFS.map(a=>{
    const unlocked = a.test(stats);
    return `
      <div class="achv-badge ${unlocked?'':'locked'}">
        <div class="b-icon">${a.icon}</div>
        <span>${a.label.split('\n').join('<br>')}</span>
      </div>`;
  }).join('');
}

function renderTip(){
  const el = document.getElementById('tipCard');
  const dayIndex = new Date().getDate() % STUDY_TIPS.length;
  el.querySelector('p').textContent = STUDY_TIPS[dayIndex];
}

function setActiveNav(view){
  document.querySelectorAll('.dash-nav a, .phone-bottom-nav a').forEach(a=>{
    a.classList.toggle('active', a.dataset.nav === view);
  });
}

/* ---------------------------------------------------------------------
   Progress view — per-course breakdown, lesson-by-lesson
   --------------------------------------------------------------------- */
function renderProgressView(){
  const el = document.getElementById('progressCourseList');
  if(!el) return;
  const courses = window.COURSES.filter(c=>c.available);
  if(courses.length === 0){
    el.innerHTML = `<div class="activity-empty">No courses available yet.</div>`;
    return;
  }
  el.innerHTML = courses.map(c=>{
    const data = COURSE_DATASETS[c.id];
    const pct = getCoursePct(c.id);
    const stats = computeCourseStats(c.id);
    const totalLessons = data ? data.length : c.lessons;
    const accuracy = stats.totalAnswered > 0 ? Math.round((stats.correctAnswers/stats.totalAnswered)*100) : null;
    const lessonRows = (data || []).map(l=>{
      let saved = {};
      try{ saved = JSON.parse(localStorage.getItem(`boredacademy:progress:${c.id}`) || '{}'); }catch(e){}
      const answered = saved[l.id] || [];
      const answeredCount = answered.filter(a=>a!==null).length;
      const done = answeredCount === l.quiz.length && answeredCount > 0;
      const started = answeredCount > 0 && !done;
      return `<div class="progress-lesson-row">
        <span class="pl-status ${done?'done':started?'started':''}">${done?'✔':started?'●':'○'}</span>
        <span class="pl-title">${l.id} · ${l.title}</span>
        <span class="pl-count">${answeredCount}/${l.quiz.length}</span>
      </div>`;
    }).join('');
    return `
      <div class="progress-course-card">
        <div class="pc-head">
          <div class="pc-icon">${c.icon}</div>
          <div class="pc-head-body">
            <h4>${c.title}</h4>
            <div class="pc-sub">${totalLessons} lessons ${accuracy!==null?`· ${accuracy}% avg quiz score`:''}</div>
          </div>
          <div class="pc-pct">${pct}%</div>
        </div>
        <div class="c-bar"><span style="width:${pct}%"></span></div>
        <div class="progress-lesson-list">${lessonRows || '<div class="activity-empty">No lesson data yet.</div>'}</div>
      </div>`;
  }).join('');
}

/* ---------------------------------------------------------------------
   Achievements view — full grid with locked/unlocked + hints
   --------------------------------------------------------------------- */
function renderAchievementsView(stats){
  const el = document.getElementById('achvGridFull');
  if(!el) return;
  el.innerHTML = ACHIEVEMENT_DEFS.map(a=>{
    const unlocked = a.test(stats);
    return `
      <div class="achv-badge-full ${unlocked?'':'locked'}">
        <div class="b-icon">${a.icon}</div>
        <div class="b-body">
          <span class="b-label">${a.label.split('\n').join(' ')}</span>
          <span class="b-hint">${unlocked ? 'Unlocked' : a.hint}</span>
        </div>
      </div>`;
  }).join('');
}

/* ---------------------------------------------------------------------
   Vocabulary view — merges every lesson's vocab list across courses
   --------------------------------------------------------------------- */
function buildVocabIndex(){
  const items = [];
  window.COURSES.filter(c=>c.available).forEach(c=>{
    const data = COURSE_DATASETS[c.id];
    if(!data) return;
    data.forEach(l=>{
      (l.vocab||[]).forEach(([term,def])=>{
        items.push({ term, def, courseId:c.id, courseTitle:c.title, courseIcon:c.icon, lessonId:l.id, lessonTitle:l.title });
      });
    });
  });
  return items;
}

function renderVocabularyView(){
  const grid = document.getElementById('vocabGridFull');
  const countEl = document.getElementById('vocabCount');
  const filterEl = document.getElementById('vocabCourseFilter');
  if(!grid) return;
  const all = buildVocabIndex();

  if(filterEl && filterEl.options.length === 0){
    const courses = window.COURSES.filter(c=>c.available && COURSE_DATASETS[c.id]);
    filterEl.innerHTML = `<option value="">All courses</option>` +
      courses.map(c=>`<option value="${c.id}">${c.title}</option>`).join('');
  }

  function draw(){
    const term = (document.getElementById('vocabSearch').value || '').trim().toLowerCase();
    const courseFilter = filterEl ? filterEl.value : '';
    const filtered = all.filter(v=>{
      if(courseFilter && v.courseId !== courseFilter) return false;
      if(!term) return true;
      return v.term.toLowerCase().includes(term) || v.def.toLowerCase().includes(term);
    });
    countEl.textContent = `${filtered.length} word${filtered.length===1?'':'s'}`;
    grid.innerHTML = filtered.slice(0, 300).map(v=>`
      <div class="vocab-card-full">
        <div class="vc-term">${v.term}</div>
        <div class="vc-def">${v.def}</div>
        <div class="vc-meta">${v.courseIcon} ${v.courseTitle} · Lesson ${v.lessonId}</div>
      </div>`).join('') || `<div class="activity-empty">No words match your search.</div>`;
  }
  draw();
  const searchEl = document.getElementById('vocabSearch');
  if(searchEl && !searchEl.dataset.wired){
    searchEl.dataset.wired = '1';
    searchEl.addEventListener('input', draw);
  }
  if(filterEl && !filterEl.dataset.wired){
    filterEl.dataset.wired = '1';
    filterEl.addEventListener('change', draw);
  }
}

/* ---------------------------------------------------------------------
   Calendar view — visit heatmap (last 12 weeks) built from ProgressStore
   --------------------------------------------------------------------- */
function renderCalendarView(stats){
  const summaryEl = document.getElementById('calendarSummary');
  const mapEl = document.getElementById('calendarHeatmap');
  if(!mapEl) return;
  let visits = [];
  try{ visits = JSON.parse(localStorage.getItem('boredacademy:visits') || '[]'); }catch(e){}
  const visitSet = new Set(visits);

  const days = [];
  const today = new Date();
  for(let i = 83; i >= 0; i--){
    const d = new Date(today);
    d.setDate(d.getDate() - i);
    days.push(d.toISOString().slice(0,10));
  }
  // Pad so the grid starts on a Sunday for clean weekly columns.
  const firstDow = new Date(days[0]).getDay();
  const padded = new Array(firstDow).fill(null).concat(days);

  const weekCols = Math.ceil(padded.length / 7);
  mapEl.style.gridTemplateColumns = `repeat(${weekCols}, 1fr)`;
  mapEl.innerHTML = padded.map(d=>{
    if(!d) return `<span class="cal-cell empty"></span>`;
    const active = visitSet.has(d);
    const isToday = d === today.toISOString().slice(0,10);
    return `<span class="cal-cell ${active?'active':''} ${isToday?'today':''}" title="${d}${active?' · studied':''}"></span>`;
  }).join('');

  summaryEl.innerHTML = `
    <div class="cal-stat"><div class="cs-num">${stats.streak}</div><div class="cs-label">Day Streak 🔥</div></div>
    <div class="cal-stat"><div class="cs-num">${visits.length}</div><div class="cs-label">Total Days Studied</div></div>
    <div class="cal-stat"><div class="cs-num">${days.filter(d=>visitSet.has(d)).length}</div><div class="cs-label">Active in Last 12 Weeks</div></div>
  `;
}

/* ---------------------------------------------------------------------
   Settings view — name, theme, reset
   --------------------------------------------------------------------- */
function renderSettingsView(){
  const nameEl = document.getElementById('settingsName');
  if(nameEl){
    try{ nameEl.value = localStorage.getItem('boredacademy:name') || ''; }catch(e){}
  }
  const row = document.getElementById('settingsThemeRow');
  if(row && !row.dataset.wired){
    row.dataset.wired = '1';
    const themes = [ ['light','☀ Light'], ['dark','☾ Dark'], ['notebook','≡ Notebook'] ];
    row.innerHTML = themes.map(([id,label])=>`<button type="button" class="settings-theme-btn" data-theme-id="${id}">${label}</button>`).join('');
    row.querySelectorAll('button').forEach(btn=>{
      btn.addEventListener('click', ()=>{
        if(window.BoredTheme) BoredTheme.set(btn.dataset.themeId);
        highlightThemeBtn();
      });
    });
  }
  highlightThemeBtn();
}
function highlightThemeBtn(){
  const current = window.BoredTheme ? BoredTheme.get() : 'light';
  document.querySelectorAll('.settings-theme-btn').forEach(btn=>{
    btn.classList.toggle('active', btn.dataset.themeId === current);
  });
}
function saveSettingsName(){
  const nameEl = document.getElementById('settingsName');
  const name = (nameEl.value || '').trim();
  try{
    if(name) localStorage.setItem('boredacademy:name', name);
    else localStorage.removeItem('boredacademy:name');
  }catch(e){}
  const heading = document.getElementById('welcomeHeading');
  if(heading) heading.textContent = name ? `Welcome back, ${name}! 👋` : 'Welcome back! 👋';
}
function resetAllProgress(){
  if(!confirm('Reset all saved progress, streaks and activity on this device? This cannot be undone.')) return;
  try{
    Object.keys(localStorage).filter(k=>k.startsWith('boredacademy:')).forEach(k=>{
      if(k === 'boredacademy:name' || k === 'boredacademy:theme') return; // keep personalization
      localStorage.removeItem(k);
    });
  }catch(e){}
  location.reload();
}

/* ---------------------------------------------------------------------
   View switching
   --------------------------------------------------------------------- */
const VIEWS = ['dashboard','progress','achievements','vocabulary','calendar','settings'];
let currentView = 'dashboard';

function switchView(view){
  if(!VIEWS.includes(view)) view = 'dashboard';
  currentView = view;
  VIEWS.forEach(v=>{
    const el = document.getElementById(`view-${v}`);
    if(el) el.style.display = (v === view) ? '' : 'none';
  });
  setActiveNav(view === 'dashboard' ? 'dashboard' : view);
  const stats = buildStats();
  if(view === 'progress') renderProgressView();
  if(view === 'achievements') renderAchievementsView(stats);
  if(view === 'vocabulary') renderVocabularyView();
  if(view === 'calendar') renderCalendarView(stats);
  if(view === 'settings') renderSettingsView();
  window.scrollTo({top:0, behavior:'instant' in window ? 'instant' : 'auto'});
}

// Called from nav link onclick="return goToView(event,'progress')" etc.
// scrollToId (optional) scrolls to an element within the dashboard view
// after switching, used by the Courses link (#courses-section).
function goToView(event, view, scrollToId){
  if(event) event.preventDefault();
  switchView(view);
  if(scrollToId){
    setTimeout(()=>{
      const el = document.getElementById(scrollToId);
      if(el) el.scrollIntoView({behavior:'smooth', block:'start'});
    }, 30);
  }
  return false;
}
window.goToView = goToView;

function renderDashboard(){
  if(window.ProgressStore) ProgressStore.recordVisitToday();
  const stats = buildStats();
  renderHero();
  renderGoal(stats);
  renderStats(stats);
  renderActivity();
  renderCourses();
  renderAchievements(stats);
  renderTip();
  switchView('dashboard');
}

renderDashboard();
DASH_JS_EOF

# 3. assets/css/dashboard.css — styles for the new views
cat > assets/css/dashboard.css <<'DASH_CSS_EOF'
/* ==========================================================================
   Bored Academy — Dashboard (hub) page
   ========================================================================== */
:root{
  --teal:#1f6f6b;
  --teal-dark:#134a47;
  --teal-darker:#0d3634;
  --flame:#c1552c;
  --flame-soft:#f0d9c9;
  --gold:#c99a2e;
  --good:#2f7a4d;
  --good-soft:#dcefe0;
  --bad:#b0402f;

  --paper:#ffffff;
  --ink:#1f2d2b;
  --line:#dcdad2;
  --card:#ffffff;
  --bg-image:none;
  --bg-size:auto;
}
html[data-theme="notebook"]{
  --paper:#f6f3ea;
  --ink:#1f2d2b;
  --line:#c9c0a8;
  --card:#fffdf7;
  --bg-image:
    radial-gradient(rgba(0,0,0,.02) 1px, transparent 1px),
    linear-gradient(var(--line) 1px, transparent 1px);
  --bg-size:3px 3px, 100% 2.3em;
}
html[data-theme="dark"]{
  --paper:#141b1c;
  --ink:#e7ece9;
  --line:#2c3638;
  --card:#1b2426;
  --good-soft:#1e332a;
  --flame-soft:#3a2a20;
  --bg-image:none;
  --bg-size:auto;
}
*{box-sizing:border-box;}
body.dash-page{
  margin:0;font-family:'Iowan Old Style','Georgia',serif;
  background:var(--paper);color:var(--ink);
  background-image:var(--bg-image);
  background-size:var(--bg-size);
  transition:background .25s ease,color .25s ease;
}
html[data-theme="dark"] .dash-topbar{background:var(--card);border-color:var(--line);}
html[data-theme="dark"] .dash-search{background:var(--paper);border-color:var(--line);color:#9fb0ac;}
html[data-theme="dark"] .course-card.soon{opacity:.45;}

.dash-shell{display:grid;grid-template-columns:260px minmax(0,1fr);min-height:100vh;}

/* ---------- Sidebar ---------- */
.dash-sidebar{
  background:linear-gradient(180deg,var(--teal-dark),var(--teal-darker));
  color:#eef3ee;position:sticky;top:0;height:100vh;overflow-y:auto;
  padding:1.3em 0 2em;z-index:50;
}
.dash-brand{display:flex;align-items:center;gap:.6em;padding:0 1.2em 1.1em;border-bottom:1px solid rgba(255,255,255,.15);margin-bottom:.7em;}
.dash-brand .logo{font-size:1.6em;}
.dash-brand h1{font-size:1.05em;margin:0;line-height:1.15;}
.dash-nav{display:flex;flex-direction:column;gap:2px;padding:0 .7em;}
.dash-nav a{
  display:flex;align-items:center;gap:.7em;color:#dfeae6;text-decoration:none;
  padding:.65em .9em;border-radius:10px;font-size:.92em;transition:background .18s ease,transform .18s ease;
}
.dash-nav a:hover{background:rgba(255,255,255,.08);transform:translateX(3px);}
.dash-nav a.active{background:var(--teal);color:#fff;font-weight:600;box-shadow:inset 4px 0 var(--gold);}
.dash-nav .n-icon{width:1.3em;display:flex;align-items:center;justify-content:center;}
.icon{width:1.15em;height:1.15em;flex-shrink:0;}
.dash-nav .n-label{display:inline;}

/* ---------- Topbar ---------- */
.dash-main{padding:0 0 4em;}
.dash-topbar{
  display:flex;align-items:center;gap:1em;justify-content:space-between;
  padding:1.1em 1.8em;background:var(--card);border-bottom:1px solid var(--line);
  position:sticky;top:0;z-index:40;
}
.dash-search{
  flex:1;max-width:460px;display:flex;align-items:center;gap:.5em;
  background:var(--paper);border:1px solid var(--line);border-radius:999px;
  padding:.55em 1.1em;color:#7a7566;font-size:.9em;
}
.dash-topbar-right{display:flex;align-items:center;gap:.9em;flex-shrink:0;}
.dash-role-badge{
  background:var(--teal-dark);color:#fff;border-radius:999px;padding:.4em .9em;
  font-family:'Courier New',monospace;font-size:.72em;letter-spacing:.05em;
}
.dash-bell{font-size:1.15em;}
.dash-avatar{
  width:34px;height:34px;border-radius:50%;background:var(--flame-soft);
  display:flex;align-items:center;justify-content:center;font-size:1.1em;
}

.dash-content{padding:1.6em 1.8em 0;max-width:1400px;}
.dash-welcome h2{margin:0 0 .15em;font-size:1.7rem;}
.dash-welcome p{margin:0;color:#5a6864;}

/* ---------- Layout grid: main column + side column ---------- */
.dash-grid{display:grid;grid-template-columns:minmax(0,1fr) 320px;gap:1.4em;margin-top:1.4em;align-items:start;}
.dash-col-main{display:flex;flex-direction:column;gap:1.4em;min-width:0;}
.dash-col-side{display:flex;flex-direction:column;gap:1.4em;}

/* ---------- Continue Learning hero ---------- */
.hero-card{
  background:linear-gradient(135deg,var(--teal-dark),var(--teal-darker));
  color:#fff;border-radius:18px;padding:1.5em 1.7em;
  display:flex;gap:1.3em;align-items:center;position:relative;overflow:hidden;
  box-shadow:0 14px 30px rgba(13,54,52,.25);
}
.hero-card .h-icon{
  font-size:2.6em;width:76px;height:76px;flex-shrink:0;border-radius:16px;
  background:rgba(255,255,255,.1);display:flex;align-items:center;justify-content:center;
}
.hero-card .h-body{flex:1;min-width:0;}
.hero-card .h-eyebrow{
  font-family:'Courier New',monospace;font-size:.7em;letter-spacing:.1em;
  text-transform:uppercase;color:#9fc4bf;margin-bottom:.3em;
}
.hero-card h3{margin:0 0 .15em;font-size:1.4em;}
.hero-card .h-sub{font-size:.85em;color:#c9dbd6;margin-bottom:.7em;}
.hero-card .h-bar{height:8px;background:rgba(255,255,255,.15);border-radius:999px;overflow:hidden;max-width:340px;}
.hero-card .h-bar span{display:block;height:100%;background:linear-gradient(90deg,var(--gold),var(--flame));}
.hero-card .h-pct{font-family:'Courier New',monospace;font-size:.78em;color:#c9dbd6;margin-top:.3em;}
.hero-card .h-resume{
  flex-shrink:0;background:var(--gold);color:#1f2d2b;border:none;font-weight:700;
  padding:.7em 1.3em;border-radius:10px;cursor:pointer;font-family:Georgia,serif;
  text-decoration:none;display:inline-block;
}
.hero-card .h-next{flex-shrink:0;font-size:.78em;color:#c9dbd6;max-width:180px;}
.hero-card .h-next b{display:block;color:#fff;font-size:.95em;margin-bottom:.3em;font-family:Georgia,serif;}
.hero-card .h-next ul{margin:0;padding-left:1.1em;}
.hero-card.empty{align-items:center;justify-content:center;text-align:center;flex-direction:column;padding:2.2em;}

/* ---------- Today's goal ---------- */
.goal-card{
  background:var(--card);border:1px solid var(--line);border-radius:16px;
  padding:1.2em 1.3em;display:flex;align-items:center;gap:1em;
}
.goal-card .g-ring{
  width:56px;height:56px;border-radius:50%;flex-shrink:0;
  background:conic-gradient(var(--flame) calc(var(--g,40)*1%), var(--line) 0);
  display:flex;align-items:center;justify-content:center;
}
.goal-card .g-ring span{
  width:42px;height:42px;border-radius:50%;background:var(--card);
  display:flex;align-items:center;justify-content:center;font-size:.72em;font-weight:700;color:var(--flame);
}
.goal-card h4{margin:0 0 .15em;font-size:.95em;}
.goal-card p{margin:0;font-size:.8em;color:#5a6864;}
.goal-card .g-reward{font-family:'Courier New',monospace;font-size:.72em;color:var(--gold);margin-top:.25em;}

/* ---------- Progress overview stats ---------- */
.stat-row{display:grid;grid-template-columns:repeat(4,1fr);gap:.9em;}
.stat-card{
  background:var(--card);border:1px solid var(--line);border-radius:14px;
  padding:1em 1.1em;display:flex;align-items:center;gap:.7em;
}
.stat-card .s-icon{
  width:38px;height:38px;border-radius:10px;background:var(--flame-soft);
  display:flex;align-items:center;justify-content:center;font-size:1.1em;flex-shrink:0;
}
.stat-card .s-num{font-size:1.3em;font-weight:700;line-height:1.1;}
.stat-card .s-label{font-size:.72em;color:#5a6864;line-height:1.2;}

/* ---------- Section headers ---------- */
.dash-section-head{display:flex;align-items:center;justify-content:space-between;margin-bottom:.7em;}
.dash-section-head h3{margin:0;font-size:1.05em;}
.dash-section-head a{font-size:.78em;color:var(--teal-dark);text-decoration:none;font-family:'Courier New',monospace;}

/* ---------- Recent activity ---------- */
.activity-card{background:var(--card);border:1px solid var(--line);border-radius:16px;padding:1.2em 1.3em;}
.activity-item{display:flex;gap:.7em;padding:.6em 0;border-bottom:1px dashed var(--line);}
.activity-item:last-child{border-bottom:none;}
.activity-item .a-icon{
  width:30px;height:30px;border-radius:8px;background:var(--flame-soft);
  display:flex;align-items:center;justify-content:center;font-size:.9em;flex-shrink:0;
}
.activity-item .a-text{font-size:.84em;line-height:1.3;flex:1;min-width:0;}
.activity-item .a-detail{color:var(--good);font-weight:600;}
.activity-item .a-time{font-size:.68em;color:#9aa39f;white-space:nowrap;}
.activity-empty{font-size:.85em;color:#5a6864;padding:.6em 0;}

/* ---------- Course grid ---------- */
.course-grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(230px,1fr));gap:1em;}
.course-card{
  background:var(--card);border:1px solid var(--line);border-radius:14px;
  padding:1.1em 1.1em 1em;display:flex;flex-direction:column;gap:.5em;
  text-decoration:none;color:inherit;position:relative;
}
.course-card .c-icon{
  width:38px;height:38px;border-radius:10px;background:var(--flame-soft);
  display:flex;align-items:center;justify-content:center;font-size:1.15em;
}
.course-card h4{margin:.2em 0 0;font-size:.98em;}
.course-card .c-lessons{font-size:.74em;color:#5a6864;}
.course-card .c-bar{height:5px;background:var(--line);border-radius:999px;overflow:hidden;margin-top:.2em;}
.course-card .c-bar span{display:block;height:100%;background:var(--good);}
.course-card .c-action{
  margin-top:.3em;font-size:.78em;font-weight:600;color:var(--teal-dark);
}
.course-card.soon{opacity:.6;}
.course-card.soon .c-action{color:#9aa39f;}

/* ---------- Achievements ---------- */
.achv-card{background:var(--card);border:1px solid var(--line);border-radius:16px;padding:1.2em 1.3em;}
.achv-row{display:flex;gap:1em;overflow-x:auto;padding-bottom:.2em;}
.achv-badge{
  flex-shrink:0;width:84px;display:flex;flex-direction:column;align-items:center;gap:.4em;
  text-align:center;
}
.achv-badge .b-icon{
  width:52px;height:52px;border-radius:14px;display:flex;align-items:center;justify-content:center;
  font-size:1.5em;background:var(--good-soft);
}
.achv-badge.locked .b-icon{background:var(--paper);filter:grayscale(1);opacity:.5;}
.achv-badge span{font-size:.68em;color:#5a6864;line-height:1.2;}

/* ---------- Study tip ---------- */
.tip-card{
  background:var(--flame-soft);border-radius:16px;padding:1.2em 1.3em;
  display:flex;align-items:center;gap:1em;
}
.tip-card .t-icon{font-size:1.8em;flex-shrink:0;}
.tip-card h4{margin:0 0 .2em;font-size:.9em;color:var(--flame);}
.tip-card p{margin:0;font-size:.84em;color:#4a4136;line-height:1.35;}

/* ---------- Dashboard view switching ---------- */
.dash-view{animation:fadeIn .18s ease;}
@keyframes fadeIn{from{opacity:0}to{opacity:1}}

/* ---------- Progress view ---------- */
.progress-course-list{display:flex;flex-direction:column;gap:1em;}
.progress-course-card{background:var(--card);border:1px solid var(--line);border-radius:16px;padding:1.2em 1.3em;}
.pc-head{display:flex;align-items:center;gap:.8em;margin-bottom:.6em;}
.pc-icon{width:38px;height:38px;border-radius:10px;background:var(--flame-soft);display:flex;align-items:center;justify-content:center;font-size:1.15em;flex-shrink:0;}
.pc-head-body{flex:1;min-width:0;}
.pc-head-body h4{margin:0;font-size:1em;}
.pc-sub{font-size:.76em;color:#5a6864;}
.pc-pct{font-family:'Courier New',monospace;font-weight:700;color:var(--teal-dark);}
.progress-lesson-list{margin-top:.9em;display:flex;flex-direction:column;gap:2px;}
.progress-lesson-row{display:flex;align-items:center;gap:.6em;padding:.4em .2em;font-size:.82em;border-bottom:1px dashed var(--line);}
.progress-lesson-row:last-child{border-bottom:none;}
.pl-status{width:1.2em;text-align:center;color:#9aa39f;flex-shrink:0;}
.pl-status.done{color:var(--good);}
.pl-status.started{color:var(--gold);}
.pl-title{flex:1;min-width:0;}
.pl-count{font-family:'Courier New',monospace;font-size:.85em;color:#5a6864;flex-shrink:0;}

/* ---------- Achievements view (full grid) ---------- */
.achv-grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(230px,1fr));gap:1em;}
.achv-badge-full{
  display:flex;align-items:center;gap:.8em;padding:.7em;border-radius:12px;border:1px solid var(--line);
}
.achv-badge-full .b-icon{width:48px;height:48px;border-radius:12px;display:flex;align-items:center;justify-content:center;font-size:1.4em;background:var(--good-soft);flex-shrink:0;}
.achv-badge-full.locked .b-icon{background:var(--paper);filter:grayscale(1);opacity:.5;}
.achv-badge-full .b-body{min-width:0;}
.achv-badge-full .b-label{display:block;font-size:.86em;font-weight:600;}
.achv-badge-full .b-hint{display:block;font-size:.72em;color:#5a6864;margin-top:.1em;}
.achv-badge-full:not(.locked) .b-hint{color:var(--good);font-weight:600;}

/* ---------- Vocabulary view ---------- */
.vocab-toolbar{display:flex;gap:.7em;margin-bottom:.6em;flex-wrap:wrap;}
.vocab-search-input,.vocab-filter-select{
  font-family:Georgia,serif;font-size:.9em;padding:.6em .9em;border-radius:10px;
  border:1px solid var(--line);background:var(--card);color:var(--ink);
}
.vocab-search-input{flex:1;min-width:200px;}
.vocab-count{font-size:.78em;color:#5a6864;margin-bottom:.7em;font-family:'Courier New',monospace;}
.vocab-grid-full{display:grid;grid-template-columns:repeat(auto-fill,minmax(200px,1fr));gap:.8em;}
.vocab-card-full{background:var(--card);border:1px solid var(--line);border-radius:12px;padding:.8em .9em;}
.vc-term{font-weight:700;font-size:.95em;margin-bottom:.15em;}
.vc-def{font-size:.82em;color:#4a4136;margin-bottom:.4em;}
.vc-meta{font-size:.68em;color:#9aa39f;}

/* ---------- Calendar view ---------- */
.calendar-card{background:var(--card);border:1px solid var(--line);border-radius:16px;padding:1.3em;}
.calendar-summary{display:flex;gap:1.6em;margin-bottom:1.2em;flex-wrap:wrap;}
.cal-stat{text-align:left;}
.cs-num{font-size:1.5em;font-weight:700;line-height:1.1;}
.cs-label{font-size:.74em;color:#5a6864;}
.calendar-heatmap{display:grid;grid-template-columns:repeat(12,1fr);grid-auto-flow:column;grid-template-rows:repeat(7,1fr);gap:4px;max-width:620px;}
.cal-cell{width:100%;aspect-ratio:1;border-radius:3px;background:var(--line);}
.cal-cell.empty{background:transparent;}
.cal-cell.active{background:var(--good);}
.cal-cell.today{outline:2px solid var(--flame);outline-offset:1px;}

/* ---------- Settings view ---------- */
.settings-card{background:var(--card);border:1px solid var(--line);border-radius:16px;padding:1.2em 1.3em;margin-bottom:1em;max-width:520px;}
.settings-card h4{margin:0 0 .2em;}
.settings-hint{margin:0 0 .8em;font-size:.8em;color:#5a6864;}
.settings-row{display:flex;gap:.6em;}
.settings-input{
  flex:1;font-family:Georgia,serif;font-size:.9em;padding:.6em .9em;border-radius:10px;
  border:1px solid var(--line);background:var(--paper);color:var(--ink);
}
.settings-btn{
  font-family:Georgia,serif;font-size:.85em;font-weight:700;padding:.6em 1.1em;border-radius:10px;
  border:none;background:var(--teal);color:#fff;cursor:pointer;
}
.settings-btn.danger{background:var(--bad);}
.settings-theme-row{display:flex;gap:.6em;}
.settings-theme-btn{
  font-family:Georgia,serif;font-size:.85em;padding:.6em 1.1em;border-radius:10px;
  border:1px solid var(--line);background:var(--paper);color:var(--ink);cursor:pointer;
}
.settings-theme-btn.active{background:var(--teal);color:#fff;border-color:var(--teal);}

/* =========================== TABLET: 481–900px =========================== */
@media(min-width:481px) and (max-width:900px){
  .dash-shell{grid-template-columns:78px minmax(0,1fr);}
  .dash-grid{grid-template-columns:1fr;}
  .dash-content{padding:1.3em 1.2em 0;}
  .dash-topbar{padding:1em 1.2em;}
  .dash-search{max-width:none;}
  .stat-row{grid-template-columns:repeat(2,1fr);}
  .hero-card{flex-wrap:wrap;}
  .hero-card .h-next{display:none;}
  .dash-brand h1{display:none;}
  .dash-brand{justify-content:center;padding:0 0 1em;}
  .dash-nav{padding:0 .5em;}
  .dash-nav a{justify-content:center;padding:.75em;}
  .dash-nav .n-label{display:none;}
}

/* =========================== PHONE: <=480px =========================== */
@media(max-width:480px){
  body.dash-page{padding-bottom:64px;}
  .dash-shell{display:block;}
  .dash-sidebar{display:none;}
  .dash-topbar{padding:.9em 1em;}
  .dash-search{display:none;}
  .dash-content{padding:1.1em .9em 0;}
  .dash-welcome h2{font-size:1.3rem;}
  .dash-grid{grid-template-columns:1fr;gap:1em;}
  .hero-card{flex-direction:column;align-items:flex-start;padding:1.2em 1.3em;}
  .hero-card .h-icon{width:56px;height:56px;font-size:2em;}
  .hero-card .h-next{display:none;}
  .hero-card .h-resume{width:100%;text-align:center;}
  .stat-row{grid-template-columns:repeat(2,1fr);}
  .course-grid{grid-template-columns:1fr;}
  .achv-row{gap:.7em;}
  .achv-badge{width:70px;}
  .achv-badge .b-icon{width:44px;height:44px;font-size:1.2em;}

  .phone-bottom-nav{
    display:flex;position:fixed;left:0;right:0;bottom:0;z-index:60;
    background:var(--teal-darker);border-top:1px solid rgba(255,255,255,.08);
    padding:6px 4px calc(6px + env(safe-area-inset-bottom));justify-content:space-between;
  }
  .phone-bottom-nav a{
    flex:1;text-decoration:none;background:none;border:none;color:#c9dbd6;
    display:flex;flex-direction:column;align-items:center;gap:2px;
    font-family:Georgia,serif;font-size:.64em;padding:.35em 0;border-radius:10px;
  }
  .phone-bottom-nav a .bn-icon{display:flex;align-items:center;justify-content:center;}
  .phone-bottom-nav a .bn-icon .icon{width:1.3em;height:1.3em;}
  .phone-bottom-nav a.active{color:#fff;background:rgba(255,255,255,.08);}
}
@media(min-width:481px){
  .phone-bottom-nav{display:none;}
}

DASH_CSS_EOF

echo "Done. Updated files:"
echo "  index.html (Progress/Achievements/Vocabulary/Calendar/Settings views + cet4-data.js)"
echo "  assets/js/dashboard.js (view switching + renderers, cet4 registered in stats)"
echo "  assets/css/dashboard.css (styles for the new views)"
echo "Open index.html and click Progress / Achievements / Vocabulary / Calendar / Settings in the sidebar."
