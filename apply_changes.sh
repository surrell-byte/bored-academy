#!/usr/bin/env bash
set -euo pipefail
# Bored Academy -- apply script
# Run from INSIDE your bored-academy-1-1 project folder:
#   cd /Users/russell/Downloads/bored-academy-1-1
#   bash apply_changes.sh
if [ ! -f index.html ]; then
  echo "Run this from inside your bored-academy-1-1 folder (index.html not found here)."
  exit 1
fi
mkdir -p assets/js assets/css courses

cat > "assets/js/theme.js" << 'BORED_EOF_MARKER'
/* ==========================================================================
   Bored Academy — Theme controller
   Themes: light (default, white), dark, notebook (cream + ruled lines).
   Persisted in localStorage under 'boredacademy:theme'.
   ========================================================================== */
(function(){
  const KEY = 'boredacademy:theme';
  const THEMES = [
    { id: 'light',    label: 'Light',    glyph: '☀' },
    { id: 'dark',     label: 'Dark',     glyph: '☾' },
    { id: 'notebook', label: 'Notebook', glyph: '≡' }
  ];

  function getTheme(){
    try{ return localStorage.getItem(KEY) || 'light'; }catch(e){ return 'light'; }
  }
  function setTheme(id){
    document.documentElement.setAttribute('data-theme', id);
    try{ localStorage.setItem(KEY, id); }catch(e){}
    document.querySelectorAll('.theme-switcher button').forEach(btn=>{
      btn.classList.toggle('active', btn.dataset.theme === id);
    });
  }

  // Apply immediately (theme.js should be loaded in <head> to avoid flash)
  setTheme(getTheme());

  function mountSwitcher(){
    // The dashboard (index.html) has its own theme control inside
    // Settings, so skip the floating global widget there to avoid a
    // second, awkwardly-placed switcher on the page.
    if(document.body && document.body.classList.contains('dash-page')) return;
    if(document.querySelector('.theme-switcher')) return;
    const wrap = document.createElement('div');
    wrap.className = 'theme-switcher';
    wrap.setAttribute('role','group');
    wrap.setAttribute('aria-label','Theme');
    THEMES.forEach(t=>{
      const btn = document.createElement('button');
      btn.type = 'button';
      btn.dataset.theme = t.id;
      btn.title = t.label + ' theme';
      btn.textContent = t.glyph;
      btn.addEventListener('click', ()=> setTheme(t.id));
      wrap.appendChild(btn);
    });
    document.body.appendChild(wrap);
    setTheme(getTheme());
  }

  if(document.readyState === 'loading'){
    document.addEventListener('DOMContentLoaded', mountSwitcher);
  } else {
    mountSwitcher();
  }

  window.BoredTheme = { get: getTheme, set: setTheme };
})();
BORED_EOF_MARKER

cat > "assets/js/auth.js" << 'BORED_EOF_MARKER'
/* ==========================================================================
   Bored Academy — Auth (local demo implementation)

   IMPORTANT: This stores accounts in localStorage on the user's own
   browser. It is NOT secure and is NOT a substitute for a real backend —
   it's here so the welcome/login flow works end-to-end today.

   When you're ready to wire up real accounts (e.g. Firebase Auth):
     1. Load the Firebase SDK + your firebaseConfig on welcome/auth/index.
     2. Replace the body of signUp / login / logout / currentUser below
        with calls to firebase.auth() (createUserWithEmailAndPassword,
        signInWithEmailAndPassword, signOut, onAuthStateChanged).
     3. Everything else (welcome.html, auth.html, index.html's guard
        script) calls only the BoredAuth.* functions, so no other file
        needs to change.
   ========================================================================== */
(function(){
  const USERS_KEY = 'boredacademy:users';
  const SESSION_KEY = 'boredacademy:session';

  function readUsers(){
    try{ return JSON.parse(localStorage.getItem(USERS_KEY) || '{}'); }
    catch(e){ return {}; }
  }
  function writeUsers(users){
    try{ localStorage.setItem(USERS_KEY, JSON.stringify(users)); }catch(e){}
  }
  // Not real cryptographic hashing — just obfuscation so passwords aren't
  // sitting in localStorage in plain text. Do not treat as secure.
  function hash(str){
    let h = 0;
    for(let i=0;i<str.length;i++){ h = (h<<5) - h + str.charCodeAt(i); h |= 0; }
    return 'v1_' + h;
  }

  function currentUser(){
    try{ return JSON.parse(localStorage.getItem(SESSION_KEY) || 'null'); }
    catch(e){ return null; }
  }

  function signUp(name, email, password){
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
  }

  function login(email, password){
    email = (email||'').trim().toLowerCase();
    const users = readUsers();
    const record = users[email];
    if(!record || record.passHash !== hash(password||'')){
      return { ok:false, error:'Incorrect email or password.' };
    }
    const session = { email, name: record.name };
    try{ localStorage.setItem(SESSION_KEY, JSON.stringify(session)); }catch(e){}
    try{ localStorage.setItem('boredacademy:name', session.name); }catch(e){}
    return { ok:true, user: session };
  }

  function logout(){
    try{ localStorage.removeItem(SESSION_KEY); }catch(e){}
  }

  // Redirects to the welcome/auth flow if nobody is logged in. Call this
  // at the very top of any page that requires a session (e.g. index.html).
  function requireAuth(){
    if(!currentUser()){
      window.location.href = 'welcome.html';
      return false;
    }
    return true;
  }

  window.BoredAuth = { currentUser, signUp, login, logout, requireAuth };
})();
BORED_EOF_MARKER

cat > "index.html" << 'BORED_EOF_MARKER'
<!DOCTYPE html>
<html lang="en" data-theme="light">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Bored Academy — Dashboard</title>
<link rel="icon" href="favicon.ico?v=2" sizes="any">
<link rel="icon" type="image/png" href="assets/img/favicon.png?v=2">
<link rel="apple-touch-icon" href="assets/img/favicon.png?v=2">
<link rel="stylesheet" href="assets/css/dashboard.css">
<script src="assets/js/auth.js"></script>
<script>
  // Bounce to the welcome/login flow if nobody's signed in yet.
  if(window.BoredAuth) BoredAuth.requireAuth();
</script>
<script src="assets/js/theme.js"></script>
</head>
<body class="dash-page">

<div class="dash-shell">
  <aside class="dash-sidebar">
    <div class="dash-brand">
      <span class="logo"><img src="assets/img/logo.png" alt="Bored Academy logo" width="28" height="28"></span>
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
        <span class="dash-avatar" id="logoutBtn" title="Sign out" role="button" tabindex="0"><svg class="icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><circle cx="12" cy="8" r="4"/><path d="M4 21c0-4 4-6 8-6s8 2 8 6"/></svg></span>
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
      const user = window.BoredAuth ? BoredAuth.currentUser() : null;
      const name = (user && user.name) || localStorage.getItem('boredacademy:name');
      if(name) document.getElementById('welcomeHeading').textContent = `Welcome back, ${name}! 👋`;
    }catch(e){}
  })();
  document.getElementById('logoutBtn').addEventListener('click', function(){
    if(confirm('Sign out of Bored Academy?')){
      if(window.BoredAuth) BoredAuth.logout();
      window.location.href = 'welcome.html';
    }
  });
</script>
<script src="assets/js/dashboard.js"></script>
</body>
</html>
BORED_EOF_MARKER

cat > "assets/js/course-app.js" << 'BORED_EOF_MARKER'
const DATA = window.COURSE_DATA;
const COURSE_ID = window.COURSE_ID || 'course';
const PROGRESS_KEY = `boredacademy:progress:${COURSE_ID}`;

let current = 0;
let searchTerm = '';
const quizState = {}; // id -> {answered:[]}
DATA.forEach(l => quizState[l.id] = { answered: new Array(l.quiz.length).fill(null) });

(function loadProgress(){
  try{
    const saved = JSON.parse(localStorage.getItem(PROGRESS_KEY) || '{}');
    Object.keys(saved).forEach(id=>{
      if(quizState[id]) quizState[id].answered = saved[id];
    });
  }catch(e){ /* ignore corrupt/local-storage-unavailable state */ }
})();

function saveProgress(){
  try{
    const out = {};
    Object.keys(quizState).forEach(id => out[id] = quizState[id].answered);
    localStorage.setItem(PROGRESS_KEY, JSON.stringify(out));
    const stats = totalStats();
    localStorage.setItem(`boredacademy:pct:${COURSE_ID}`, String(stats.pct));
  }catch(e){ /* storage unavailable — progress just won't persist */ }
}

const UNIT_ICONS = {
  "Unit 1 — Introduction to Chemistry":"🧪",
  "Unit 2 — States of Matter":"💧",
  "Unit 3 — Atomic Structure":"⚛️",
  "Module 1 — Building Fluency Foundations":"🗣️",
  "Module 2 — Expanding Your Vocabulary":"📚",
  "Module 3 — Mastering IELTS Speaking Part 2":"🎯",
  "Module 1 — Building the Foundation":"🧱",
  "Module 2 — Listening Mastery":"🎧"
};

function toggleSidebar(){
  document.getElementById('sidebar').classList.toggle('open');
  document.getElementById('scrim').classList.toggle('show');
}

function isLessonDone(l){
  const st = quizState[l.id];
  return st.answered.every(a=>a!==null) && st.answered.length>0;
}

function totalStats(){
  const totalQ = DATA.reduce((s,l)=>s+l.quiz.length,0);
  const answered = Object.values(quizState).reduce((s,st)=>s+st.answered.filter(a=>a!==null).length,0);
  const lessonsDone = DATA.filter(isLessonDone).length;
  return {totalQ, answered, lessonsDone, pct: Math.round((lessonsDone/DATA.length)*100)};
}

function renderSidebar(){
  const sb = document.getElementById('sidebar');
  const units = [...new Set(DATA.map(d=>d.unit))];
  const term = searchTerm.trim().toLowerCase();
  const meta = window.COURSE_META || {eyebrow:'Notebook', title:'Course'};
  let h = `<div class="brand">
      <a href="../index.html" class="brand-home" title="Back to dashboard"><img src="../assets/img/logo.png" alt="Bored Academy" width="26" height="26"></a>
      <div><div class="eyebrow">${meta.eyebrow}</div><h1>${meta.title}</h1></div>
    </div>`;
  const stats = totalStats();
  h += `<div class="sidebar-progress"><span style="width:${stats.pct}%"></span></div>
        <div class="progress-note">${stats.pct}% COMPLETE · ${stats.answered}/${stats.totalQ} QUESTIONS ANSWERED</div>`;
  units.forEach(u=>{
    const lessonsInUnit = DATA.filter(l=>l.unit===u && (!term || l.title.toLowerCase().includes(term) || l.id.includes(term)));
    if(term && lessonsInUnit.length===0) return;
    h += `<div class="unit-group"><div class="unit-label">${UNIT_ICONS[u]||'📘'} <span class="label-text">${u}</span></div>`;
    DATA.forEach((l,i)=>{
      if(l.unit!==u) return;
      if(term && !(l.title.toLowerCase().includes(term) || l.id.includes(term))) return;
      const done = isLessonDone(l);
      h += `<button class="lesson-btn ${i===current?'active':''}" onclick="goTo(${i})">
              <span class="num">${l.id}</span><span class="lesson-title-text">${l.title}</span>
              <span class="lesson-dot ${done?'done':''}"></span>
            </button>`;
    });
    h += `</div>`;
  });
  sb.innerHTML = h;
}

function goTo(i){
  current = i; render(); window.scrollTo(0,0);
  document.getElementById('sidebar').classList.remove('open');
  document.getElementById('scrim').classList.remove('show');
  const l = DATA[i];
  if(window.ProgressStore){
    ProgressStore.setLastLesson(COURSE_ID, { lessonId: l.id, lessonTitle: l.title, unit: l.unit, index: i, courseTitle: (window.COURSE_META||{}).title || COURSE_ID });
  }
}

function toggleFlash(el){ el.classList.toggle('flipped'); }

function onSearch(v){ searchTerm = v; renderSidebar(); }

function estimateMinutes(l){
  const words = l.html.replace(/<[^>]+>/g,' ').split(/\s+/).length;
  return Math.max(8, Math.round(words/140) + l.quiz.length*2);
}

function renderMain(){
  const l = DATA[current];
  const m = document.getElementById('main');
  const st = quizState[l.id];

  let vocabHtml = l.vocab.map(([term,def])=>`
    <div class="flash" onclick="toggleFlash(this)">
      <div class="flash-inner">
        <div class="flash-face flash-front">${term}<span class="hint">tap to reveal</span></div>
        <div class="flash-face flash-back">${def}</div>
      </div>
    </div>`).join('');

  let quizHtml = l.quiz.map((q,qi)=>{
    const chosen = st.answered[qi];
    let opts = q.opts.map((o,oi)=>{
      let cls='quiz-opt';
      if(chosen!==null){
        if(oi===q.a) cls+=' correct';
        else if(oi===chosen) cls+=' incorrect';
      }
      return `<button class="${cls}" ${chosen!==null?'disabled':''} onclick="answer('${l.id}',${qi},${oi})">${o}</button>`;
    }).join('');
    return `<div class="quiz-q"><div class="qtext">${qi+1}. ${q.q}</div>${opts}</div>`;
  }).join('');

  const scored = st.answered.filter(a=>a!==null).length;
  const correct = st.answered.filter((a,i)=>a===l.quiz[i].a).length;
  const stats = totalStats();
  const mins = estimateMinutes(l);

  m.innerHTML = `
    <div class="topbar">
      <div class="topbar-search">🔍 <input placeholder="Search lessons..." value="${searchTerm}" oninput="onSearch(this.value)"></div>
      <div class="topbar-stats">
        <span>Progress <span class="stat-num">${stats.pct}%</span></span>
        <span class="topbar-pill">📚 ${DATA.length} lessons</span>
        <span class="topbar-pill">✅ ${stats.lessonsDone} done</span>
      </div>
    </div>

    <div class="lesson-head">
      <div class="eyebrow">${l.unit} · Lesson ${l.id}</div>
      <h2>${l.title}</h2>
      <div class="lesson-meta">
        <span class="m-item">⏱ <b>${mins} min</b></span>
        <span class="m-item">🧪 <b>${l.vocab.length}</b> key terms</span>
        <span class="m-item">❓ <b>${l.quiz.length}</b> questions</span>
        <span class="m-item">🎯 <b>${l.objectives.length}</b> objectives</span>
      </div>
    </div>

    <section class="block">
      <h3 class="block-title">Learning Objectives</h3>
      <ul class="obj-list">${l.objectives.map(o=>`<li>${o}</li>`).join('')}</ul>
    </section>

    <section class="block">
      <h3 class="block-title">Success Criteria</h3>
      <div class="success-box">${l.success.map(s=>`<div class="row"><span class="tick">✓</span>${s}</div>`).join('')}</div>
    </section>

    <section class="block">
      <h3 class="block-title">Key Vocabulary <span style="font-size:.6em;color:#888;font-weight:normal;">(tap to flip)</span></h3>
      <div class="vocab-grid">${vocabHtml}</div>
    </section>

    <section class="block">
      <h3 class="block-title">Lesson Notes</h3>
      ${l.html}
    </section>

    <section class="block quiz-section" id="quizSection">
      <h3 class="block-title">Check Your Understanding</h3>
      ${quizHtml}
    </section>

    <div class="nav-footer">
      <button ${current===0?'disabled':''} onclick="goTo(${current-1})">← Previous lesson</button>
      <button ${current===DATA.length-1?'disabled':''} onclick="goTo(${current+1})">Next lesson →</button>
    </div>

    ${scored>0 ? `
    <div class="floating-score">
      <div class="fs-top">
        <span class="fs-pct">${Math.round((correct/scored)*100)}%</span>
        <span class="fs-label">${correct===scored?'EXCELLENT':correct/scored>=0.6?'GOOD JOB':'KEEP GOING'}</span>
      </div>
      <div class="fs-bar"><span style="width:${(scored/l.quiz.length)*100}%"></span></div>
      <div class="fs-sub">
        <span>${correct} / ${l.quiz.length} correct</span>
        <button class="reset-btn" onclick="resetQuiz('${l.id}')">Reset</button>
      </div>
    </div>` : ''}
  `;
}

function answer(id, qi, oi){
  quizState[id].answered[qi] = oi;
  saveProgress();
  const l = DATA.find(x=>x.id===id);
  const q = l.quiz[qi];
  if(window.ProgressStore){
    const allAnswered = quizState[id].answered.every(a=>a!==null);
    if(allAnswered){
      const correct = quizState[id].answered.filter((a,idx)=>a===l.quiz[idx].a).length;
      const pct = Math.round((correct/l.quiz.length)*100);
      ProgressStore.logActivity({ type:'quiz', text:`${l.title} Quiz`, detail:`${pct}%`, courseId: COURSE_ID });
    }
  }
  render();
}
function resetQuiz(id){
  quizState[id].answered = new Array(DATA.find(l=>l.id===id).quiz.length).fill(null);
  saveProgress();
  render();
}

function renderStudyPanel(){
  const panel = document.getElementById('studyPanel');
  if(!panel) return;
  const l = DATA[current];
  const st = quizState[l.id];
  const answeredCount = st.answered.filter(a=>a!==null).length;
  panel.innerHTML = `
    <h3>On This Page</h3>
    <ul>${l.objectives.slice(0,4).map(o=>`<li>${o}</li>`).join('')}</ul>
    <h3>Key Vocabulary</h3>
    ${l.vocab.slice(0,6).map(([t,d])=>`<div class="sp-vocab"><b>${t}</b><span>${d.length>46?d.slice(0,46)+'…':d}</span></div>`).join('')}
    <h3>Quick Quiz</h3>
    <div class="sp-quiz-mini">${answeredCount}/${l.quiz.length} questions answered in this lesson.</div>
  `;
}

function setBottomNavActive(tab){
  document.querySelectorAll('.bottom-nav button').forEach(b=>b.classList.toggle('active', b.dataset.tab===tab));
}

function bottomNavAction(tab){
  setBottomNavActive(tab);
  if(tab==='home'){ window.location.href = '../index.html'; return; }
  if(tab==='lessons'){ toggleSidebar(); return; }
  if(tab==='quiz'){
    document.querySelector('.quiz-section')?.scrollIntoView({behavior:'smooth'});
    return;
  }
  if(tab==='progress'){
    document.querySelector('.floating-score')?.scrollIntoView({behavior:'smooth'});
    return;
  }
}

function render(){
  renderSidebar();
  renderMain();
  renderStudyPanel();
  setBottomNavActive('lessons');
}
if(window.ProgressStore){
  ProgressStore.recordVisitToday();
  if(!ProgressStore.getLastLesson(COURSE_ID) && DATA[current]){
    const l = DATA[current];
    ProgressStore.setLastLesson(COURSE_ID, { lessonId: l.id, lessonTitle: l.title, unit: l.unit, index: current, courseTitle: (window.COURSE_META||{}).title || COURSE_ID });
  }
}
render();
BORED_EOF_MARKER

cat > "assets/css/base.css" << 'BORED_EOF_MARKER'
:root{
  --teal:#1f6f6b;
  --teal-dark:#134a47;
  --teal-darker:#0d3634;
  --flame:#c1552c;
  --flame-soft:#f0d9c9;
  --gold:#c99a2e;
  --good:#2f7a4d;
  --bad:#b0402f;

  /* light theme (default) */
  --paper:#ffffff;
  --ink:#1f2d2b;
  --line:#dcdad2;
  --card:#ffffff;
  --bg-image:none;
  --bg-size:auto;
  --muted:#5c6b64;
  --placeholder:#7a7362;
}

/* notebook theme: cream paper + ruled lines */
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

/* dark theme */
html[data-theme="dark"]{
  --paper:#141b1c;
  --ink:#e7ece9;
  --line:#2c3638;
  --card:#1b2426;
  --flame-soft:#3a2a20;
  --bg-image:none;
  --bg-size:auto;
  --muted:#9fb0ac;
  --placeholder:#9fb0ac;
}

*{box-sizing:border-box;}
html{scroll-behavior:smooth;}
body{
  margin:0;
  font-family:'Iowan Old Style','Georgia',serif;
  background:var(--paper);
  color:var(--ink);
  background-image:var(--bg-image);
  background-size:var(--bg-size);
  background-position: 0 0, 0 0;
  transition:background .25s ease,color .25s ease;
}
.app{display:flex;min-height:100vh;align-items:flex-start;}

/* ---------- Sidebar ---------- */
.sidebar{
  width:280px;flex-shrink:0;
  background:linear-gradient(180deg,var(--teal-dark),var(--teal-darker));
  color:#eef3ee;
  padding:1.5em 0 3em;
  position:sticky;top:0;height:100vh;overflow-y:auto;
  z-index:50;
  transition:left .35s ease;
}
.sidebar::-webkit-scrollbar{width:6px;}
.sidebar::-webkit-scrollbar-thumb{background:rgba(255,255,255,.15);border-radius:3px;}
.brand{
  display:flex;align-items:center;gap:.7em;
  padding:0 1.3em 1.2em;
  border-bottom:1px solid rgba(255,255,255,.15);
  margin-bottom:.8em;
}
.brand-home{flex-shrink:0;display:flex;border-radius:8px;opacity:.9;transition:opacity .15s;}
.brand-home:hover{opacity:1;}
.brand-home img{width:26px;height:26px;border-radius:6px;display:block;}
.brand .eyebrow{
  font-family:'Courier New',monospace;
  font-size:.68em;letter-spacing:.18em;
  color:var(--gold);text-transform:uppercase;
}
.brand h1{
  font-size:1.35em;margin:.25em 0 0;font-weight:600;
  font-family:Georgia,serif;line-height:1.2;
}
.unit-group{margin-bottom:.4em;}
.unit-label{
  font-family:'Courier New',monospace;
  font-size:.7em;letter-spacing:.12em;
  color:#9fc4bf;text-transform:uppercase;
  padding:.9em 1.3em .3em;
}
.lesson-btn{
  display:flex;align-items:center;gap:.55em;
  width:calc(100% - 24px);text-align:left;
  background:none;border:none;color:#e4ede9;
  padding:.6em 1em;margin:4px 12px;
  font-family:Georgia,serif;font-size:.92em;
  cursor:pointer;border-radius:10px;
  line-height:1.3;transition:transform .22s ease,background .22s ease;
}
.lesson-btn .icon{font-size:1.05em;flex-shrink:0;opacity:.85;}
.lesson-btn:hover{background:rgba(255,255,255,.09);transform:translateX(6px);}
.lesson-btn.active{
  background:var(--teal);color:#fff;font-weight:600;
  box-shadow:inset 4px 0 var(--gold), 0 8px 18px rgba(0,0,0,.25);
  transform:translateX(2px);
}
.lesson-btn .num{
  font-family:'Courier New',monospace;color:var(--gold);
  font-size:.85em;margin-right:.15em;flex-shrink:0;
}
.lesson-btn.active .num{color:#ffe9b8;}
.lesson-dot{
  width:6px;height:6px;border-radius:50%;flex-shrink:0;
  background:rgba(255,255,255,.25);margin-left:auto;
}
.lesson-dot.done{background:var(--gold);}

.progress-note{
  font-family:'Courier New',monospace;font-size:.72em;
  color:#9fc4bf;padding:0 1.3em;margin-top:.4em;
}
.sidebar-progress{
  margin:.6em 1.3em 0;height:6px;background:rgba(255,255,255,.12);
  border-radius:99px;overflow:hidden;
}
.sidebar-progress span{
  display:block;height:100%;
  background:linear-gradient(90deg,var(--gold),var(--flame));
  transition:width .4s ease;
}

.sidebar-toggle{
  display:none;
  position:fixed;top:16px;left:16px;z-index:60;
  background:var(--teal-dark);color:#fff;border:none;
  width:42px;height:42px;border-radius:10px;
  align-items:center;justify-content:center;
  cursor:pointer;box-shadow:0 4px 14px rgba(0,0,0,.25);
}
.sidebar-toggle .icon{width:1.3em;height:1.3em;}

/* ---------- Icons (shared) ---------- */
.icon{width:1.15em;height:1.15em;flex-shrink:0;}
.sidebar-scrim{display:none;}

/* ---------- Main ---------- */
main{
  flex:1;max-width:1300px;width:100%;margin:auto;
  padding:48px 64px 120px;
}

.topbar{
  display:flex;justify-content:space-between;align-items:center;
  gap:20px;
  padding:16px 26px;
  margin-bottom:34px;
  background:rgba(255,255,255,.8);
  border:1px solid rgba(0,0,0,.06);
  border-radius:16px;
  box-shadow:0 3px 15px rgba(0,0,0,.06);
  backdrop-filter:blur(6px);
}
.topbar-search{
  display:flex;align-items:center;gap:.5em;
  flex:1;max-width:340px;
  background:var(--paper);border:1px solid var(--line);
  border-radius:10px;padding:.5em .9em;
  font-size:.9em;color:var(--placeholder);
}
.topbar-search input{
  border:none;background:none;outline:none;
  font-family:Georgia,serif;font-size:1em;color:var(--ink);width:100%;
}
.topbar-stats{
  display:flex;align-items:center;gap:22px;
  font-family:'Courier New',monospace;font-size:.78em;
  color:var(--teal-dark);letter-spacing:.02em;
}
.topbar-stats .stat-num{font-weight:700;color:var(--flame);font-size:1.05em;font-family:Georgia,serif;}
.topbar-pill{
  display:flex;align-items:center;gap:6px;
  background:var(--flame-soft);color:var(--flame);
  padding:.35em .8em;border-radius:99px;font-size:.8em;font-weight:600;
}

.lesson-head{
  animation:fadeUp .45s ease;
}
.lesson-head .eyebrow{
  font-family:'Courier New',monospace;font-size:.78em;
  letter-spacing:.18em;color:var(--flame);text-transform:uppercase;
}
.lesson-head h2{
  font-size:3rem;letter-spacing:-1px;
  margin:.18em 0 .12em;line-height:1.08;
  border-bottom:3px solid var(--ink);padding-bottom:.3em;
}
.lesson-meta{
  display:flex;flex-wrap:wrap;gap:26px;
  margin:20px 0 6px;
  font-size:.92rem;color:var(--muted);
}
.lesson-meta .m-item{display:flex;align-items:center;gap:.4em;}
.lesson-meta .m-item b{color:var(--teal-dark);}

section.block{
  background:rgba(255,255,255,.75);
  border:1px solid rgba(0,0,0,.08);
  border-radius:14px;
  padding:32px 34px;
  box-shadow:0 2px 8px rgba(0,0,0,.05);
  backdrop-filter:blur(6px);
  margin:34px 0;
  animation:fadeUp .5s ease;
}
h3.block-title{
  font-size:1.45rem;font-weight:700;color:var(--teal-dark);
  border-bottom:1px solid var(--line);
  padding-bottom:.35em;margin:0 0 20px;
  display:flex;align-items:center;gap:.5em;
}
h3.block-title:before{
  content:"§";color:var(--flame);font-weight:700;
}
ul.obj-list{margin:0;padding-left:1.3em;line-height:1.9;}
ul.obj-list li{margin-bottom:.5em;}

.success-box{display:grid;gap:12px;}
.success-box .row{
  display:flex;align-items:flex-start;gap:12px;
  padding:14px 16px;background:#f7fcfa;border-radius:10px;
  border:1px solid rgba(47,122,77,.15);
}
.success-box .row .tick{
  flex-shrink:0;width:22px;height:22px;border-radius:50%;
  background:var(--good);color:#fff;display:flex;align-items:center;justify-content:center;
  font-size:.75em;font-weight:700;
}

/* vocab flashcards */
.vocab-grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(210px,1fr));gap:1.1em;}
.flash{
  perspective:1000px;height:120px;cursor:pointer;
  transition:transform .3s ease;
}
.flash:hover{transform:translateY(-6px);}
.flash-inner{
  position:relative;width:100%;height:100%;
  transition:transform .5s;transform-style:preserve-3d;
}
.flash.flipped .flash-inner{transform:rotateY(180deg);}
.flash-face{
  position:absolute;inset:0;backface-visibility:hidden;
  border-radius:16px;padding:.9em;
  display:flex;flex-direction:column;align-items:center;justify-content:center;
  text-align:center;font-size:.92em;line-height:1.35;
  box-shadow:0 12px 24px rgba(0,0,0,.12);
}
.flash-front{
  background:linear-gradient(160deg,var(--teal),var(--teal-dark));color:#fff;font-weight:600;font-size:1.08em;
  border:1px solid var(--teal-dark);
}
.flash-front .hint{
  font-family:'Courier New',monospace;font-size:.6em;letter-spacing:.1em;
  opacity:.7;margin-top:.5em;font-weight:400;text-transform:uppercase;
}
.flash-back{
  background:var(--card);border:1px solid var(--teal);
  color:var(--ink);transform:rotateY(180deg);
}

/* prose content blocks */
.content-body{font-size:1.08rem;line-height:1.9;}
.content-body p{margin:.8em 0;}
.content-body ul{padding-left:1.3em;line-height:1.85;}
.content-body h4{margin-top:1.6em;margin-bottom:.6em;color:var(--teal-dark);font-size:1.1em;}
.content-body strong{color:var(--teal-dark);}
.example-box{
  background:var(--flame-soft);border-left:4px solid var(--flame);
  padding:.9em 1.2em;margin:1em 0;border-radius:8px;font-size:.97em;line-height:1.7;
}

table.data-table{
  border-collapse:separate;border-spacing:0;width:100%;margin:1em 0;font-size:.95em;
  border-radius:14px;overflow:hidden;
  box-shadow:0 8px 20px rgba(0,0,0,.08);
}
table.data-table th, table.data-table td{
  padding:14px 16px;text-align:left;border-bottom:1px solid rgba(0,0,0,.06);
}
table.data-table th{background:var(--teal);color:#fff;font-weight:700;}
table.data-table tr:last-child td{border-bottom:none;}
table.data-table tr:nth-child(even) td{background:rgba(31,111,107,.045);}
table.data-table tbody tr:hover td{background:#f5faf9;}

.misconceptions{display:grid;gap:6px;margin-top:1em;}
.misconceptions .row{margin:0;padding:.6em .8em;border-radius:8px;font-size:.93em;}
.misconceptions .wrong{background:#f6dcd6;border-left:4px solid var(--bad);}
.misconceptions .right{background:#dcefe0;border-left:4px solid var(--good);}

/* quiz */
.quiz-q{
  background:var(--card);border:1px solid var(--line);
  border-radius:12px;padding:1.2em 1.3em;margin-bottom:1.1em;
  box-shadow:0 2px 6px rgba(0,0,0,.04);
}
.quiz-q .qtext{font-weight:700;margin-bottom:.7em;font-size:1.02em;}
.quiz-opt{
  display:block;width:100%;text-align:left;
  background:var(--paper);border:1px solid var(--line);
  border-radius:8px;padding:.6em .9em;margin-bottom:.45em;
  cursor:pointer;font-family:Georgia,serif;font-size:.96em;
  transition:.18s;
}
.quiz-opt:hover{border-color:var(--teal);transform:translateX(3px);}
.quiz-opt.correct{background:#dcefe0;border-color:var(--good);font-weight:600;}
.quiz-opt.incorrect{background:#f6dcd6;border-color:var(--bad);}
.quiz-opt[disabled]{cursor:default;}
.quiz-opt[disabled]:hover{transform:none;}

.reset-btn{
  background:var(--flame);color:#fff;border:none;padding:.45em .9em;
  border-radius:8px;cursor:pointer;font-family:Georgia,serif;font-size:.9em;
}

.nav-footer{
  display:flex;justify-content:space-between;margin-top:3em;
  border-top:2px solid var(--ink);padding-top:1.2em;
}
.nav-footer button{
  background:var(--teal-dark);color:#fff;border:none;
  padding:.7em 1.3em;border-radius:10px;cursor:pointer;
  font-family:Georgia,serif;font-size:.92em;transition:.2s;
}
.nav-footer button:hover:not(:disabled){transform:translateY(-2px);box-shadow:0 6px 14px rgba(0,0,0,.15);}
.nav-footer button:disabled{opacity:.35;cursor:default;}

/* floating quiz score widget */
.floating-score{
  position:fixed;right:30px;bottom:30px;width:240px;
  background:var(--teal-darker);color:#fff;
  border-radius:18px;padding:18px 20px;
  box-shadow:0 20px 50px rgba(0,0,0,.28);
  z-index:40;
  font-family:Georgia,serif;
  animation:fadeUp .4s ease;
}
.floating-score .fs-top{display:flex;justify-content:space-between;align-items:baseline;}
.floating-score .fs-pct{font-size:1.9em;font-weight:700;color:var(--gold);}
.floating-score .fs-label{font-size:.78em;opacity:.8;font-family:'Courier New',monospace;letter-spacing:.05em;}
.floating-score .fs-bar{height:6px;background:rgba(255,255,255,.15);border-radius:99px;margin:10px 0 8px;overflow:hidden;}
.floating-score .fs-bar span{display:block;height:100%;background:linear-gradient(90deg,var(--gold),var(--flame));transition:width .4s ease;}
.floating-score .fs-sub{font-size:.82em;opacity:.85;display:flex;justify-content:space-between;align-items:center;}
.floating-score .reset-btn{padding:.3em .7em;font-size:.85em;}

/* ---------- Dark theme surface overrides ---------- */
html[data-theme="dark"] .topbar{
  background:rgba(27,36,38,.85);border-color:rgba(255,255,255,.08);
}
html[data-theme="dark"] section.block,
html[data-theme="dark"] .lesson-head{
  background:rgba(27,36,38,.75);border-color:rgba(255,255,255,.08);
}
html[data-theme="dark"] .topbar-search{
  background:var(--paper);border-color:var(--line);color:#9fb0ac;
}
html[data-theme="dark"] .success-box .row{
  background:rgba(47,122,77,.12);border-color:rgba(47,122,77,.3);
}
html[data-theme="dark"] .quiz-opt{background:var(--paper);color:var(--ink);}
html[data-theme="dark"] .misconceptions .wrong{background:rgba(176,64,47,.18);}
html[data-theme="dark"] .misconceptions .right{background:rgba(47,122,77,.18);}

/* ---------- Theme switcher control ---------- */
.theme-switcher{
  position:fixed;right:24px;top:24px;z-index:70;
  display:flex;gap:4px;background:var(--card);border:1px solid var(--line);
  padding:5px;border-radius:12px;box-shadow:0 8px 20px rgba(0,0,0,.15);
}
.theme-switcher button{
  border:none;background:none;cursor:pointer;
  width:34px;height:34px;border-radius:8px;
  display:flex;align-items:center;justify-content:center;
  font-size:1.05em;color:var(--ink);opacity:.55;transition:.15s;
}
.theme-switcher button:hover{opacity:1;background:rgba(0,0,0,.06);}
.theme-switcher button.active{opacity:1;background:var(--teal);color:#fff;}

@keyframes fadeUp{
  from{opacity:0;transform:translateY(22px);}
  to{opacity:1;transform:none;}
}
BORED_EOF_MARKER

cat > "assets/css/dashboard.css" << 'BORED_EOF_MARKER'
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

  --muted:#5a6864;
  --muted-2:#4a4136;
  --muted-3:#8b948f;
  --placeholder:#7a7566;
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

  /* Lighter, warmer muted tones so secondary text stays readable
     (WCAG AA) against the dark card/paper backgrounds. */
  --muted:#9fb0ac;
  --muted-2:#d9cdb8;
  --muted-3:#7c8b87;
  --placeholder:#9fb0ac;
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
.dash-brand .logo{display:flex;flex-shrink:0;}
.dash-brand .logo img{width:28px;height:28px;border-radius:7px;display:block;}
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
  padding:.55em 1.1em;color:var(--placeholder);font-size:.9em;
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
  cursor:pointer;transition:filter .15s ease;
}
.dash-avatar:hover{filter:brightness(.92);}

.dash-content{padding:1.6em 1.8em 0;max-width:1400px;}
.dash-welcome h2{margin:0 0 .15em;font-size:1.7rem;}
.dash-welcome p{margin:0;color:var(--muted);}

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
.goal-card p{margin:0;font-size:.8em;color:var(--muted);}
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
.stat-card .s-label{font-size:.72em;color:var(--muted);line-height:1.2;}

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
.activity-item .a-time{font-size:.68em;color:var(--muted-3);white-space:nowrap;}
.activity-empty{font-size:.85em;color:var(--muted);padding:.6em 0;}

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
.course-card .c-lessons{font-size:.74em;color:var(--muted);}
.course-card .c-bar{height:5px;background:var(--line);border-radius:999px;overflow:hidden;margin-top:.2em;}
.course-card .c-bar span{display:block;height:100%;background:var(--good);}
.course-card .c-action{
  margin-top:.3em;font-size:.78em;font-weight:600;color:var(--teal-dark);
}
.course-card.soon{opacity:.6;}
.course-card.soon .c-action{color:var(--muted-3);}

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
.achv-badge span{font-size:.68em;color:var(--muted);line-height:1.2;}

/* ---------- Study tip ---------- */
.tip-card{
  background:var(--flame-soft);border-radius:16px;padding:1.2em 1.3em;
  display:flex;align-items:center;gap:1em;
}
.tip-card .t-icon{font-size:1.8em;flex-shrink:0;}
.tip-card h4{margin:0 0 .2em;font-size:.9em;color:var(--flame);}
.tip-card p{margin:0;font-size:.84em;color:var(--muted-2);line-height:1.35;}

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
.pc-sub{font-size:.76em;color:var(--muted);}
.pc-pct{font-family:'Courier New',monospace;font-weight:700;color:var(--teal-dark);}
.progress-lesson-list{margin-top:.9em;display:flex;flex-direction:column;gap:2px;}
.progress-lesson-row{display:flex;align-items:center;gap:.6em;padding:.4em .2em;font-size:.82em;border-bottom:1px dashed var(--line);}
.progress-lesson-row:last-child{border-bottom:none;}
.pl-status{width:1.2em;text-align:center;color:var(--muted-3);flex-shrink:0;}
.pl-status.done{color:var(--good);}
.pl-status.started{color:var(--gold);}
.pl-title{flex:1;min-width:0;}
.pl-count{font-family:'Courier New',monospace;font-size:.85em;color:var(--muted);flex-shrink:0;}

/* ---------- Achievements view (full grid) ---------- */
.achv-grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(230px,1fr));gap:1em;}
.achv-badge-full{
  display:flex;align-items:center;gap:.8em;padding:.7em;border-radius:12px;border:1px solid var(--line);
}
.achv-badge-full .b-icon{width:48px;height:48px;border-radius:12px;display:flex;align-items:center;justify-content:center;font-size:1.4em;background:var(--good-soft);flex-shrink:0;}
.achv-badge-full.locked .b-icon{background:var(--paper);filter:grayscale(1);opacity:.5;}
.achv-badge-full .b-body{min-width:0;}
.achv-badge-full .b-label{display:block;font-size:.86em;font-weight:600;}
.achv-badge-full .b-hint{display:block;font-size:.72em;color:var(--muted);margin-top:.1em;}
.achv-badge-full:not(.locked) .b-hint{color:var(--good);font-weight:600;}

/* ---------- Vocabulary view ---------- */
.vocab-toolbar{display:flex;gap:.7em;margin-bottom:.6em;flex-wrap:wrap;}
.vocab-search-input,.vocab-filter-select{
  font-family:Georgia,serif;font-size:.9em;padding:.6em .9em;border-radius:10px;
  border:1px solid var(--line);background:var(--card);color:var(--ink);
}
.vocab-search-input{flex:1;min-width:200px;}
.vocab-count{font-size:.78em;color:var(--muted);margin-bottom:.7em;font-family:'Courier New',monospace;}
.vocab-grid-full{display:grid;grid-template-columns:repeat(auto-fill,minmax(200px,1fr));gap:.8em;}
.vocab-card-full{background:var(--card);border:1px solid var(--line);border-radius:12px;padding:.8em .9em;}
.vc-term{font-weight:700;font-size:.95em;margin-bottom:.15em;}
.vc-def{font-size:.82em;color:var(--muted-2);margin-bottom:.4em;}
.vc-meta{font-size:.68em;color:var(--muted-3);}

/* ---------- Calendar view ---------- */
.calendar-card{background:var(--card);border:1px solid var(--line);border-radius:16px;padding:1.3em;}
.calendar-summary{display:flex;gap:1.6em;margin-bottom:1.2em;flex-wrap:wrap;}
.cal-stat{text-align:left;}
.cs-num{font-size:1.5em;font-weight:700;line-height:1.1;}
.cs-label{font-size:.74em;color:var(--muted);}
.calendar-heatmap{display:grid;grid-template-columns:repeat(12,1fr);grid-auto-flow:column;grid-template-rows:repeat(7,1fr);gap:4px;max-width:620px;}
.cal-cell{width:100%;aspect-ratio:1;border-radius:3px;background:var(--line);}
.cal-cell.empty{background:transparent;}
.cal-cell.active{background:var(--good);}
.cal-cell.today{outline:2px solid var(--flame);outline-offset:1px;}

/* ---------- Settings view ---------- */
.settings-card{background:var(--card);border:1px solid var(--line);border-radius:16px;padding:1.2em 1.3em;margin-bottom:1em;max-width:520px;}
.settings-card h4{margin:0 0 .2em;}
.settings-hint{margin:0 0 .8em;font-size:.8em;color:var(--muted);}
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

BORED_EOF_MARKER

cat > "assets/css/welcome.css" << 'BORED_EOF_MARKER'
/* ==========================================================================
   Bored Academy — Welcome & Auth pages
   Reuses the CSS variables defined in dashboard.css (load that file first).
   ========================================================================== */

.welcome-page{min-height:100vh;}

/* ---------- Shared topbar ---------- */
.welcome-topbar{
  display:flex;align-items:center;justify-content:space-between;
  padding:1.2em 2em;border-bottom:1px solid var(--line);
}
.welcome-brand{
  display:flex;align-items:center;gap:.6em;font-weight:700;font-size:1.15em;
  color:var(--ink);text-decoration:none;font-family:Georgia,serif;
}
.welcome-brand img{border-radius:7px;display:block;}
.welcome-topbar-actions{display:flex;align-items:center;gap:.9em;}

/* ---------- Buttons ---------- */
.welcome-btn{
  display:inline-flex;align-items:center;justify-content:center;
  background:var(--teal);color:#fff;text-decoration:none;font-weight:600;
  padding:.65em 1.3em;border-radius:10px;font-size:.92em;
  border:none;cursor:pointer;transition:filter .15s ease;
}
.welcome-btn:hover{filter:brightness(1.08);}
.welcome-btn.large{padding:.85em 1.7em;font-size:1em;}
.welcome-btn.full{width:100%;padding:.8em 1.3em;font-size:1em;margin-top:.4em;}
.welcome-link-btn{
  color:var(--ink);text-decoration:none;font-weight:600;font-size:.92em;
  padding:.65em .4em;
}
.welcome-link-btn.large{font-size:1em;}
.welcome-link-btn:hover{color:var(--teal);}

/* ---------- Hero ---------- */
.welcome-hero{
  display:flex;align-items:center;gap:3em;
  max-width:1200px;margin:0 auto;padding:5em 2em 4em;
}
.welcome-hero-copy{flex:1;max-width:560px;}
.welcome-eyebrow{
  display:inline-block;font-family:'Courier New',monospace;font-size:.72em;
  letter-spacing:.14em;text-transform:uppercase;color:var(--flame);
  background:var(--flame-soft);padding:.4em .8em;border-radius:999px;
  margin-bottom:1em;
}
.welcome-hero h1{
  font-family:Georgia,serif;font-size:2.6em;line-height:1.12;margin:0 0 .6em;
  color:var(--ink);
}
.welcome-hero-copy p{
  font-size:1.05em;line-height:1.55;color:var(--muted);margin:0 0 1.6em;
}
.welcome-cta-row{display:flex;align-items:center;gap:.6em;flex-wrap:wrap;}
.welcome-hero-art{
  flex-shrink:0;width:260px;height:260px;border-radius:28px;
  background:var(--card);border:1px solid var(--line);
  display:flex;align-items:center;justify-content:center;
  box-shadow:0 12px 30px rgba(0,0,0,.08);
}
.welcome-hero-art img{width:170px;height:170px;object-fit:contain;}

/* ---------- Feature strip ---------- */
.welcome-features{
  max-width:1200px;margin:0 auto;padding:1em 2em 5em;
  display:grid;grid-template-columns:repeat(3,1fr);gap:1.4em;
}
.welcome-feature{
  background:var(--card);border:1px solid var(--line);border-radius:16px;
  padding:1.6em 1.5em;
}
.wf-icon{font-size:1.8em;margin-bottom:.5em;}
.welcome-feature h3{margin:0 0 .35em;font-size:1.05em;font-family:Georgia,serif;color:var(--ink);}
.welcome-feature p{margin:0;font-size:.88em;color:var(--muted);line-height:1.5;}

.welcome-footer{
  text-align:center;padding:2em;color:var(--muted-3,var(--muted));font-size:.82em;
  border-top:1px solid var(--line);
}

/* ---------- Auth card ---------- */
.auth-shell{
  min-height:calc(100vh - 76px);display:flex;align-items:center;justify-content:center;
  padding:2em;
}
.auth-card{
  width:100%;max-width:420px;background:var(--card);border:1px solid var(--line);
  border-radius:18px;padding:2em 2.2em 1.6em;box-shadow:0 12px 30px rgba(0,0,0,.06);
}
.auth-tabs{display:flex;gap:.4em;margin-bottom:1.4em;background:var(--paper);border:1px solid var(--line);border-radius:12px;padding:4px;}
.auth-tab{
  flex:1;border:none;background:none;padding:.6em 0;border-radius:9px;
  font-weight:600;font-size:.88em;color:var(--muted);cursor:pointer;transition:.15s;
}
.auth-tab.active{background:var(--teal);color:#fff;}
.auth-form h2{margin:0 0 .2em;font-family:Georgia,serif;font-size:1.35em;color:var(--ink);}
.auth-hint{margin:0 0 1.2em;color:var(--muted);font-size:.88em;}
.auth-form label{
  display:block;font-size:.82em;font-weight:600;color:var(--ink);margin-bottom:.9em;
}
.auth-form input{
  display:block;width:100%;margin-top:.35em;padding:.65em .8em;
  border:1px solid var(--line);border-radius:9px;background:var(--paper);
  color:var(--ink);font-size:.95em;font-family:inherit;
}
.auth-form input:focus{outline:2px solid var(--teal);outline-offset:1px;}
.auth-field-hint{display:block;font-weight:400;color:var(--muted-3,var(--muted));font-size:.85em;margin-top:.3em;}
.auth-error{
  min-height:1.4em;color:var(--bad);font-size:.85em;margin:-.3em 0 .4em;
}
.auth-fineprint{
  margin:1.4em 0 0;text-align:center;font-size:.76em;color:var(--muted-3,var(--muted));line-height:1.4;
}

@media (max-width: 760px){
  .welcome-hero{flex-direction:column;padding-top:2.5em;text-align:center;}
  .welcome-hero-copy{max-width:100%;}
  .welcome-cta-row{justify-content:center;}
  .welcome-hero h1{font-size:2.1em;}
  .welcome-features{grid-template-columns:1fr;}
}
BORED_EOF_MARKER

cat > "welcome.html" << 'BORED_EOF_MARKER'
<!DOCTYPE html>
<html lang="en" data-theme="light">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Bored Academy — Learn Smarter. Get Bored Less.</title>
<link rel="icon" href="favicon.ico?v=2" sizes="any">
<link rel="icon" type="image/png" href="assets/img/favicon.png?v=2">
<link rel="apple-touch-icon" href="assets/img/favicon.png?v=2">
<link rel="stylesheet" href="assets/css/dashboard.css">
<link rel="stylesheet" href="assets/css/welcome.css">
<script src="assets/js/auth.js"></script>
<script src="assets/js/theme.js"></script>
</head>
<body class="dash-page welcome-page">

<script>
  // Already signed in? Skip straight to the dashboard.
  if(window.BoredAuth && BoredAuth.currentUser()){
    window.location.href = 'index.html';
  }
</script>

<header class="welcome-topbar">
  <div class="welcome-brand">
    <img src="assets/img/logo.png" alt="Bored Academy logo" width="30" height="30">
    <span>Bored Academy</span>
  </div>
  <div class="welcome-topbar-actions">
    <a class="welcome-link-btn" href="auth.html?mode=login">Log in</a>
    <a class="welcome-btn" href="auth.html?mode=signup">Get Started</a>
  </div>
</header>

<main class="welcome-hero">
  <div class="welcome-hero-copy">
    <span class="welcome-eyebrow">Free · No ads · Learn at your own pace</span>
    <h1>Learn smarter.<br>Get bored less.</h1>
    <p>Bite-sized lessons, quizzes, and vocabulary across Chemistry, IELTS Speaking, CET-4 and more — with progress tracking, streaks and achievements that keep you coming back.</p>
    <div class="welcome-cta-row">
      <a class="welcome-btn large" href="auth.html?mode=signup">Create a free account</a>
      <a class="welcome-link-btn large" href="auth.html?mode=login">I already have an account</a>
    </div>
  </div>
  <div class="welcome-hero-art" aria-hidden="true">
    <img src="assets/img/logo.png" alt="">
  </div>
</main>

<section class="welcome-features">
  <div class="welcome-feature">
    <div class="wf-icon">📚</div>
    <h3>Structured courses</h3>
    <p>Unit-by-unit lessons with built-in quizzes so you know exactly what you've mastered.</p>
  </div>
  <div class="welcome-feature">
    <div class="wf-icon">🔥</div>
    <h3>Streaks &amp; achievements</h3>
    <p>Daily streaks, badges and a study calendar to keep your momentum going.</p>
  </div>
  <div class="welcome-feature">
    <div class="wf-icon">🎯</div>
    <h3>Progress that's actually visible</h3>
    <p>A real dashboard — not just a percentage bar — showing what to study next.</p>
  </div>
</section>

<footer class="welcome-footer">
  <span>© <span id="year"></span> Bored Academy</span>
</footer>

<script>document.getElementById('year').textContent = new Date().getFullYear();</script>
</body>
</html>
BORED_EOF_MARKER

cat > "auth.html" << 'BORED_EOF_MARKER'
<!DOCTYPE html>
<html lang="en" data-theme="light">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Sign in — Bored Academy</title>
<link rel="icon" href="favicon.ico?v=2" sizes="any">
<link rel="icon" type="image/png" href="assets/img/favicon.png?v=2">
<link rel="apple-touch-icon" href="assets/img/favicon.png?v=2">
<link rel="stylesheet" href="assets/css/dashboard.css">
<link rel="stylesheet" href="assets/css/welcome.css">
<script src="assets/js/auth.js"></script>
<script src="assets/js/theme.js"></script>
</head>
<body class="dash-page welcome-page">

<script>
  if(window.BoredAuth && BoredAuth.currentUser()){
    window.location.href = 'index.html';
  }
</script>

<header class="welcome-topbar">
  <a class="welcome-brand" href="welcome.html">
    <img src="assets/img/logo.png" alt="Bored Academy logo" width="30" height="30">
    <span>Bored Academy</span>
  </a>
</header>

<main class="auth-shell">
  <div class="auth-card">
    <div class="auth-tabs">
      <button type="button" class="auth-tab" data-tab="login">Log In</button>
      <button type="button" class="auth-tab" data-tab="signup">Sign Up</button>
    </div>

    <form id="loginForm" class="auth-form">
      <h2>Welcome back</h2>
      <p class="auth-hint">Log in to pick up right where you left off.</p>
      <label>Email
        <input type="email" id="loginEmail" required autocomplete="email">
      </label>
      <label>Password
        <input type="password" id="loginPassword" required autocomplete="current-password">
      </label>
      <div class="auth-error" id="loginError"></div>
      <button type="submit" class="welcome-btn full">Log In</button>
    </form>

    <form id="signupForm" class="auth-form" style="display:none">
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
    </form>

    <p class="auth-fineprint">
      This runs entirely in your browser — your account is stored on this device only, not on a server.
    </p>
  </div>
</main>

<script>
  const loginForm = document.getElementById('loginForm');
  const signupForm = document.getElementById('signupForm');
  const tabs = document.querySelectorAll('.auth-tab');

  function showTab(name){
    tabs.forEach(t=>t.classList.toggle('active', t.dataset.tab===name));
    loginForm.style.display = name==='login' ? '' : 'none';
    signupForm.style.display = name==='signup' ? '' : 'none';
  }
  tabs.forEach(t=> t.addEventListener('click', ()=> showTab(t.dataset.tab)));

  const params = new URLSearchParams(location.search);
  showTab(params.get('mode') === 'signup' ? 'signup' : 'login');

  loginForm.addEventListener('submit', function(e){
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
</script>
</body>
</html>
BORED_EOF_MARKER

cat > "courses/chemistry.html" << 'BORED_EOF_MARKER'
<!DOCTYPE html>
<html lang="en" data-theme="light">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Intro to Chemistry — Bored Academy</title>
<link rel="icon" href="../favicon.ico?v=2" sizes="any">
<link rel="icon" type="image/png" href="../assets/img/favicon.png?v=2">
<link rel="apple-touch-icon" href="../assets/img/favicon.png?v=2">
<link rel="stylesheet" href="../assets/css/base.css">
<link rel="stylesheet" href="../assets/css/responsive.css">
<script src="../assets/js/theme.js"></script>
</head>
<body>
<button class="sidebar-toggle" id="sidebarToggle" onclick="toggleSidebar()"></button>
<div class="sidebar-scrim" id="scrim" onclick="toggleSidebar()"></div>
<div class="app">
  <aside class="sidebar" id="sidebar"></aside>
  <main id="main"></main>
  <aside class="study-panel" id="studyPanel"></aside>
</div>

<nav class="bottom-nav">
  <button data-tab="home" onclick="bottomNavAction('home')"><span class="bn-icon"></span>Home</button>
  <button data-tab="lessons" onclick="bottomNavAction('lessons')"><span class="bn-icon"></span>Lessons</button>
  <button data-tab="quiz" onclick="bottomNavAction('quiz')"><span class="bn-icon"></span>Quiz</button>
  <button data-tab="progress" onclick="bottomNavAction('progress')"><span class="bn-icon"></span>Progress</button>
  <button data-tab="more" onclick="bottomNavAction('lessons')"><span class="bn-icon"></span>More</button>
</nav>

<script>
  window.COURSE_ID = "chemistry";
  window.COURSE_META = { eyebrow: "Lab Notebook", title: "Intro to Chemistry" };
</script>
<script src="../assets/js/icons.js"></script>
<script src="../assets/js/data/chemistry-data.js"></script>
<script src="../assets/js/progress-store.js"></script>
<script src="../assets/js/course-app.js"></script>
<script>
  document.getElementById('sidebarToggle').innerHTML = icon('menu');
  document.querySelectorAll('.bottom-nav .bn-icon').forEach((el, i)=>{
    const map = ['home','book-open','help-circle','trending-up','more-horizontal'];
    el.innerHTML = icon(map[i]);
  });
</script>
</body>
</html>
BORED_EOF_MARKER

cat > "courses/ielts.html" << 'BORED_EOF_MARKER'
<!DOCTYPE html>
<html lang="en" data-theme="light">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>IELTS Speaking — Bored Academy</title>
<link rel="icon" href="../favicon.ico?v=2" sizes="any">
<link rel="icon" type="image/png" href="../assets/img/favicon.png?v=2">
<link rel="apple-touch-icon" href="../assets/img/favicon.png?v=2">
<link rel="stylesheet" href="../assets/css/base.css">
<link rel="stylesheet" href="../assets/css/responsive.css">
<script src="../assets/js/theme.js"></script>
</head>
<body>
<button class="sidebar-toggle" id="sidebarToggle" onclick="toggleSidebar()"></button>
<div class="sidebar-scrim" id="scrim" onclick="toggleSidebar()"></div>
<div class="app">
  <aside class="sidebar" id="sidebar"></aside>
  <main id="main"></main>
  <aside class="study-panel" id="studyPanel"></aside>
</div>

<nav class="bottom-nav">
  <button data-tab="home" onclick="bottomNavAction('home')"><span class="bn-icon"></span>Home</button>
  <button data-tab="lessons" onclick="bottomNavAction('lessons')"><span class="bn-icon"></span>Lessons</button>
  <button data-tab="quiz" onclick="bottomNavAction('quiz')"><span class="bn-icon"></span>Quiz</button>
  <button data-tab="progress" onclick="bottomNavAction('progress')"><span class="bn-icon"></span>Progress</button>
  <button data-tab="more" onclick="bottomNavAction('lessons')"><span class="bn-icon"></span>More</button>
</nav>

<script>
  window.COURSE_ID = "ielts";
  window.COURSE_META = { eyebrow: "Speaking Coach", title: "IELTS Speaking" };
</script>
<script src="../assets/js/icons.js"></script>
<script src="../assets/js/data/ielts-data.js"></script>
<script src="../assets/js/progress-store.js"></script>
<script src="../assets/js/course-app.js"></script>
<script>
  document.getElementById('sidebarToggle').innerHTML = icon('menu');
  document.querySelectorAll('.bottom-nav .bn-icon').forEach((el, i)=>{
    const map = ['home','book-open','help-circle','trending-up','more-horizontal'];
    el.innerHTML = icon(map[i]);
  });
</script>
</body>
</html>
BORED_EOF_MARKER

cat > "courses/cet4.html" << 'BORED_EOF_MARKER'
<!DOCTYPE html>
<html lang="en" data-theme="light">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>CET-4 Master Course — Bored Academy</title>
<link rel="icon" href="../favicon.ico?v=2" sizes="any">
<link rel="icon" type="image/png" href="../assets/img/favicon.png?v=2">
<link rel="apple-touch-icon" href="../assets/img/favicon.png?v=2">
<link rel="stylesheet" href="../assets/css/base.css">
<link rel="stylesheet" href="../assets/css/responsive.css">
<script src="../assets/js/theme.js"></script>
</head>
<body>
<button class="sidebar-toggle" id="sidebarToggle" onclick="toggleSidebar()"></button>
<div class="sidebar-scrim" id="scrim" onclick="toggleSidebar()"></div>
<div class="app">
  <aside class="sidebar" id="sidebar"></aside>
  <main id="main"></main>
  <aside class="study-panel" id="studyPanel"></aside>
</div>

<nav class="bottom-nav">
  <button data-tab="home" onclick="bottomNavAction('home')"><span class="bn-icon"></span>Home</button>
  <button data-tab="lessons" onclick="bottomNavAction('lessons')"><span class="bn-icon"></span>Lessons</button>
  <button data-tab="quiz" onclick="bottomNavAction('quiz')"><span class="bn-icon"></span>Quiz</button>
  <button data-tab="progress" onclick="bottomNavAction('progress')"><span class="bn-icon"></span>Progress</button>
  <button data-tab="more" onclick="bottomNavAction('lessons')"><span class="bn-icon"></span>More</button>
</nav>

<script>
  window.COURSE_ID = "cet4";
  window.COURSE_META = { eyebrow: "Exam Prep", title: "CET-4 Master Course" };
</script>
<script src="../assets/js/icons.js"></script>
<script src="../assets/js/data/cet4-data.js"></script>
<script src="../assets/js/progress-store.js"></script>
<script src="../assets/js/course-app.js"></script>
<script>
  document.getElementById('sidebarToggle').innerHTML = icon('menu');
  document.querySelectorAll('.bottom-nav .bn-icon').forEach((el, i)=>{
    const map = ['home','book-open','help-circle','trending-up','more-horizontal'];
    el.innerHTML = icon(map[i]);
  });
</script>
</body>
</html>
BORED_EOF_MARKER

echo "Done. Updated/added files:"
echo "  - assets/js/theme.js"
echo "  - assets/js/auth.js"
echo "  - index.html"
echo "  - assets/js/course-app.js"
echo "  - assets/css/base.css"
echo "  - assets/css/dashboard.css"
echo "  - assets/css/welcome.css"
echo "  - welcome.html"
echo "  - auth.html"
echo "  - courses/chemistry.html"
echo "  - courses/ielts.html"
echo "  - courses/cet4.html"
echo
echo "New pages: welcome.html (landing) and auth.html (login/signup)."
echo "Open welcome.html in your browser to try the new flow."
