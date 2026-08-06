const STUDY_TIPS = [
  "Break difficult topics into smaller pieces. Master one concept at a time.",
  "Teach it back to yourself out loud — if you can explain it, you know it.",
  "Short, frequent study sessions beat one long cram every time.",
  "Get the easy questions done first to build momentum, then tackle the hard ones.",
  "Review yesterday's vocabulary for 2 minutes before starting something new."
];

const ACHIEVEMENT_DEFS = [
  { id:'first-lesson', icon:'sprout', label:'First Lesson\nCompleted', hint:'Complete any 1 lesson.', test:(s)=>s.lessonsCompleted >= 1 },
  { id:'five-day', icon:'flame', label:'Five Day\nStreak', hint:'Visit 5 days in a row.', test:(s)=>s.streak >= 5 },
  { id:'quiz-master', icon:'shield', label:'Quiz Master\n90%+', hint:'Average 90%+ across all quizzes taken.', test:(s)=>s.avgQuizScore >= 90 && s.quizzesTaken > 0 },
  { id:'lab-apprentice', icon:'flask', label:'Lab Apprentice\n3 Lessons', hint:'Complete 3 lessons in any course.', test:(s)=>s.lessonsCompleted >= 3 },
  { id:'bookworm', icon:'book-open', label:'Bookworm\n10 Lessons', hint:'Complete 10 lessons total.', test:(s)=>s.lessonsCompleted >= 10 },
  { id:'multi-course', icon:'folder', label:'Multi-Tasker\n2 Courses', hint:'Make progress in 2+ courses.', test:(s)=>s.activeCourses >= 2 },
  { id:'quiz-taker', icon:'pencil', label:'Quiz Taker\n10 Quizzes', hint:'Answer questions in 10 lesson quizzes.', test:(s)=>s.quizzesTaken >= 10 },
  { id:'two-week', icon:'award', label:'Two Week\nStreak', hint:'Visit 14 days in a row.', test:(s)=>s.streak >= 14 }
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
    <div class="h-icon">${icon(course.svgIcon)}</div>
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
      <div class="g-reward">${icon('trophy')} Reward +100 XP</div>
    </div>
  `;
}

function renderStats(stats){
  const el = document.getElementById('statRow');
  const items = [
    { icon:'book-open', num: stats.activeCourses, label:'Active Course' + (stats.activeCourses===1?'':'s') },
    { icon:'trophy', num: stats.lessonsCompleted, label:'Lessons Completed' },
    { icon:'target', num: stats.quizzesTaken > 0 ? stats.avgQuizScore+'%' : '—', label:'Avg Quiz Score' },
    { icon:'flame', num: stats.streak, label:'Day Streak' }
  ];
  el.innerHTML = items.map(i=>`
    <div class="stat-card">
      <div class="s-icon">${icon(i.icon)}</div>
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
      <div class="a-icon">${icon(i.type==='quiz' ? 'pencil' : 'book-open')}</div>
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
          <div class="c-icon">${icon(c.svgIcon)}</div>
          <h4>${c.title}</h4>
          <div class="c-lessons">${c.blurb}</div>
          <div class="c-action">Coming Soon</div>
        </div>`;
    }
    const pct = getCoursePct(c.id);
    return `
      <a class="course-card" href="courses/${c.id}.html">
        <div class="c-icon">${icon(c.svgIcon)}</div>
        <h4>${c.title}</h4>
        <div class="c-lessons">${c.lessons} Lessons</div>
        <div class="c-bar"><span style="width:${pct}%"></span></div>
        <div class="c-action">${pct>0 ? 'Continue →' : 'Start →'}</div>
      </a>`;
  }).join('');
}

function renderCoursesView(){
  const el = document.getElementById('courseGrid');
  if(!el) return;
  el.innerHTML = window.COURSES.map(c=>{
    if(!c.available){
      return `
        <div class="course-card soon">
          <div class="c-icon">${icon(c.svgIcon)}</div>
          <h4>${c.title}</h4>
          <div class="c-lessons">${c.blurb}</div>
          <div class="c-action">Coming Soon</div>
        </div>`;
    }
    const pct = getCoursePct(c.id);
    return `
      <a class="course-card" href="courses/${c.id}.html">
        <div class="c-icon">${icon(c.svgIcon)}</div>
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
        <div class="b-icon">${icon(a.icon)}</div>
        <span>${a.label.split('\n').join('<br>')}</span>
      </div>`;
  }).join('');
}

function renderTip(){
  const el = document.getElementById('tipCard');
  const dayIndex = new Date().getDate() % STUDY_TIPS.length;
  el.querySelector('.t-icon').innerHTML = icon('lightbulb');
  el.querySelector('p').textContent = STUDY_TIPS[dayIndex];
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
        <span class="pl-status ${done?'done':started?'started':''}">${done?icon('check'):'<span class="pl-dot"></span>'}</span>
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
        <div class="b-icon">${icon(a.icon)}</div>
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
  const searchEl = document.getElementById('vocabSearch');
  if(!grid) return;

  const all = buildVocabIndex();
  const courses = window.COURSES.filter(c=>c.available && COURSE_DATASETS[c.id]);

  const byCourse = {};
  courses.forEach(c=>{
    byCourse[c.id] = {
      title: c.title,
      icon: c.icon,
      words: all.filter(v=>v.courseId === c.id)
    };
  });

  function draw(){
    const term = (searchEl.value || '').trim().toLowerCase();
    let html = '';
    let total = 0;

    courses.forEach(c=>{
      const courseWords = byCourse[c.id].words.filter(v=>{
        if(!term) return true;
        return v.term.toLowerCase().includes(term) || v.def.toLowerCase().includes(term);
      });
      if(courseWords.length === 0) return;
      total += courseWords.length;
      html += `
        <div class="vocab-category">
          <div class="vocab-category-header">
            <span class="vocab-category-icon">${icon(c.svgIcon)}</span>
            <span class="vocab-category-title">${c.title}</span>
            <span class="vocab-category-count">${courseWords.length} words</span>
          </div>
          <div class="vocab-category-grid">
            ${courseWords.slice(0, 100).map(v=>`
              <div class="vocab-card-full">
                <div class="vc-term">${v.term}</div>
                <div class="vc-def">${v.def}</div>
                <div class="vc-meta">Lesson ${v.lessonId}</div>
              </div>`).join('')}
          </div>
        </div>`;
    });

    countEl.textContent = `${total} word${total===1?'':'s'}`;
    grid.innerHTML = html || `<div class="activity-empty">No words match your search.</div>`;
  }

  draw();
  if(searchEl && !searchEl.dataset.wired){
    searchEl.dataset.wired = '1';
    searchEl.addEventListener('input', draw);
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
    <div class="cal-stat"><div class="cs-num">${stats.streak}</div><div class="cs-label">Day Streak ${icon('flame','cs-flame')}</div></div>
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
    const themes = [ ['light','sun','Light'], ['dark','moon','Dark'], ['notebook','pencil','Notebook'] ];
    row.innerHTML = themes.map(([id,ic,label])=>`<button type="button" class="settings-theme-btn" data-theme-id="${id}">${icon(ic)}<span>${label}</span></button>`).join('');
    row.querySelectorAll('button').forEach(btn=>{
      btn.addEventListener('click', ()=>{
        if(window.BoredTheme) BoredTheme.set(btn.dataset.themeId);
        highlightThemeBtn();
      });
    });
  }
  highlightThemeBtn();
}

// BOREDACADEMY_ROLE_SWITCHER
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
    upgradeHtml = '<p class=\"settings-hint\">Admin accounts already have full access.</p>';
  } else if(isPremium){
    upgradeHtml = '<p class=\"settings-hint\">You have Premium access. Every course and game is unlocked.</p>';
  } else {
    const targetRole = isTeacher ? Roles.TEACHER_PREMIUM : Roles.STUDENT_PREMIUM;
    const targetLabel = isTeacher ? 'Premium Teacher' : 'Premium Student';
    upgradeHtml =
      '<p class=\"settings-hint\">Unlock every course, game and AI feature.</p>' +
      '<button class=\"settings-btn\" id=\"upgradeRoleBtn\" data-target-role=\"' + targetRole + '\">Upgrade to ' + targetLabel + '</button>' +
      '<p class=\"settings-hint\" style=\"margin-top:.6em;margin-bottom:0;\">Local/testing switch only — wire a real payment provider in billing.js before launch.</p>';
  }

  card.innerHTML =
    '<h4>Account &amp; role</h4>' +
    '<p class=\"settings-hint\">Signed in as ' + (user.email || '') + '</p>' +
    '<span class=\"dash-role-badge\">' + label + '</span>' +
    '<div style=\"margin-top:1em;\">' + upgradeHtml + '</div>';

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

function renderSettingsStandalone(){
  const container = document.getElementById('settingsContent');
  if(!container) return;

  const savedName = (()=>{ try{ return localStorage.getItem('boredacademy:name') || ''; }catch(e){ return ''; } })();
  const currentTheme = window.BoredTheme ? BoredTheme.get() : 'light';
  const themes = [
    { id:'light',    icon:'sun',     label:'Light' },
    { id:'dark',     icon:'moon',    label:'Dark' },
    { id:'notebook', icon:'pencil',  label:'Notebook' }
  ];

  container.innerHTML = `
    <div class="settings-card">
      <h4>Your name</h4>
      <p class="settings-hint">Used for the "Welcome back" greeting.</p>
      <div class="settings-row">
        <input type="text" id="settingsName" class="settings-input" placeholder="Enter your name" value="${savedName}">
        <button class="settings-btn" id="saveNameBtn">Save</button>
      </div>
    </div>
    <div class="settings-card">
      <h4>Theme</h4>
      <p class="settings-hint">Choose how Bored Academy looks.</p>
      <div class="settings-theme-row" id="settingsThemeRow">
        ${themes.map(t=>`<button type="button" class="settings-theme-btn ${t.id===currentTheme?'active':''}" data-theme-id="${t.id}">${icon(t.icon)}<span>${t.label}</span></button>`).join('')}
      </div>
    </div>
    <div class="settings-card" id="roleCard"></div>
    <div class="settings-card">
      <h4>Reset progress</h4>
      <p class="settings-hint">Clears all saved quiz answers, streaks and activity on this device. This can't be undone.</p>
      <button class="settings-btn danger" id="resetProgressBtn">Reset all progress</button>
    </div>
  `;

  // BOREDACADEMY_ROLE_SWITCHER
  renderRoleCard();

  document.getElementById('saveNameBtn').addEventListener('click', function(){
    const nameEl = document.getElementById('settingsName');
    const name = (nameEl.value || '').trim();
    try{
      if(name) localStorage.setItem('boredacademy:name', name);
      else localStorage.removeItem('boredacademy:name');
    }catch(e){}
  });

  document.querySelectorAll('#settingsThemeRow .settings-theme-btn').forEach(btn=>{
    btn.addEventListener('click', function(){
      if(window.BoredTheme) BoredTheme.set(btn.dataset.themeId);
      document.querySelectorAll('#settingsThemeRow .settings-theme-btn').forEach(b=>b.classList.toggle('active', b.dataset.themeId === btn.dataset.themeId));
    });
  });

  document.getElementById('resetProgressBtn').addEventListener('click', function(){
    if(!confirm('Reset all saved progress, streaks and activity on this device? This cannot be undone.')) return;
    try{
      Object.keys(localStorage).filter(k=>k.startsWith('boredacademy:')).forEach(k=>{
        if(k === 'boredacademy:name' || k === 'boredacademy:theme') return;
        localStorage.removeItem(k);
      });
    }catch(e){}
    location.reload();
  });
}

function renderQuizzesPage(){
  const listEl = document.getElementById('quizList');
  const countEl = document.getElementById('quizCount');
  const searchEl = document.getElementById('quizSearch');
  const filterEl = document.getElementById('quizCourseFilter');
  const backEl = document.getElementById('quizBack');
  if(!listEl) return;

  const available = window.COURSES.filter(c=>c.available && COURSE_DATASETS[c.id]);

  if(backEl) backEl.style.display = (listEl.dataset.selectedCourseId || '') ? '' : 'none';
  if(filterEl) filterEl.style.display = (listEl.dataset.selectedCourseId || '') ? 'none' : '';

  function getSaved(courseId){
    try{ return JSON.parse(localStorage.getItem(`boredacademy:progress:${courseId}`) || '{}'); }catch(e){ return {}; }
  }

  function saveAnswer(courseId, lessonId, qi, oi){
    const saved = getSaved(courseId);
    if(!saved[lessonId]) saved[lessonId] = new Array(COURSE_DATASETS[courseId].find(l=>l.id===lessonId).quiz.length).fill(null);
    saved[lessonId][qi] = oi;
    try{ localStorage.setItem(`boredacademy:progress:${courseId}`, JSON.stringify(saved)); }catch(e){}
    const data = COURSE_DATASETS[courseId];
    const l = data.find(x=>x.id===lessonId);
    const allAnswered = saved[lessonId].every(a=>a!==null);
    if(allAnswered && window.ProgressStore){
      const correct = saved[lessonId].filter((a,idx)=>a===l.quiz[idx].a).length;
      const pct = Math.round((correct/l.quiz.length)*100);
      ProgressStore.logActivity({ type:'quiz', text:`${l.title} Quiz`, detail:`${pct}%`, courseId });
    }
  }

  function isQuizFinished(courseId, lessonId){
    try{ return localStorage.getItem(`boredacademy:quiz-finished:${courseId}:${lessonId}`) === '1'; }
    catch(e){ return false; }
  }

  function renderCourseQuizzes(courseId, searchEl, countEl, listEl){
    const data = COURSE_DATASETS[courseId];
    const course = window.COURSES.find(c=>c.id === courseId);
    const term = (searchEl.value || '').trim().toLowerCase();
    const lessons = (data||[]).filter(l=>l.quiz && l.quiz.length);

    let html = '';
    if(course){
      html += `<div style="margin-bottom:1em;display:flex;align-items:center;gap:.8em;">
        <div style="font-size:1.4em;">${course.icon}</div>
        <div>
          <div style="font-weight:700;font-size:1.1em;">${course.title}</div>
          <div style="color:var(--muted);font-size:.85em;">${lessons.length} quizzes · ${lessons.reduce((s,l)=>s+l.quiz.length,0)} questions</div>
        </div>
      </div>`;
    }

    lessons.forEach(l=>{
      const saved = getSaved(courseId);
      const answeredCount = (saved[l.id]||[]).filter(a=>a!==null).length;
      const totalQ = l.quiz.length;
      const finished = isQuizFinished(courseId, l.id);

      const filteredIndices = term
        ? l.quiz.map((q,i)=>q.q.toLowerCase().includes(term)?i:-1).filter(i=>i!==-1)
        : l.quiz.map((_,i)=>i);

      html += `<div class="quiz-course-card">
        <div class="quiz-course-head">
          <div class="quiz-course-meta">
            <div class="quiz-lesson-title">${l.id} · ${l.title}</div>
            <div class="quiz-progress-row">
              <span class="quiz-progress-text">${answeredCount}/${totalQ} answered</span>
              ${finished ? '<span class="quiz-done-badge">Completed</span>' : ''}
            </div>
          </div>
          ${finished ? '' : `<button class="welcome-btn" onclick="window._finishQuiz('${courseId}','${l.id}')" style="margin-left:auto;">Finish Quiz</button>`}
        </div>
        <div class="quiz-questions">
          ${filteredIndices.map(qi=>{
            const q = l.quiz[qi];
            const chosen = (saved[l.id]||[])[qi];
            const isCorrect = chosen === q.a;
            const isWrong = chosen !== null && chosen !== q.a;
            const showResult = finished;
            return `<div class="quiz-q-card ${showResult?(isCorrect?'correct':(isWrong?'incorrect':'')):''}">
              <div class="quiz-q-text">${qi+1}. ${q.q}</div>
              <div class="quiz-opts">
                ${q.opts.map((o,oi)=>{
                  let cls = 'quiz-opt';
                  if(showResult){
                    if(oi===q.a) cls += ' correct';
                    else if(oi===chosen) cls += ' incorrect';
                  } else if(chosen !== null && oi === chosen){
                    cls += ' selected';
                  }
                  return `<button class="${cls}" ${showResult?'disabled':''} onclick="window._answerQuiz('${courseId}','${l.id}',${qi},${oi})">${o}</button>`;
                }).join('')}
              </div>
            </div>`;
          }).join('')}
        </div>
      </div>`;
    });

    if(!html) html = `<div class="activity-empty">No quizzes match your search.</div>`;
    listEl.className = 'quiz-list';
    listEl.innerHTML = html;
  }

  function render(){
    const selectedCourseId = listEl.dataset.selectedCourseId || null;

    if(selectedCourseId){
      renderCourseQuizzes(selectedCourseId, searchEl, countEl, listEl);
      return;
    }

    const term = (searchEl.value || '').trim().toLowerCase();
    const courseFilter = filterEl ? filterEl.value : 'all';

    const filtered = available.filter(c=>{
      if(courseFilter !== 'all' && c.id !== courseFilter) return false;
      if(!term) return true;
      return c.title.toLowerCase().includes(term);
    });

    countEl.textContent = `${filtered.length} course${filtered.length===1?'':'s'}`;

    listEl.className = 'course-grid';
    listEl.innerHTML = filtered.map(c=>{
      const data = COURSE_DATASETS[c.id];
      const totalQ = (data||[]).reduce((s,l)=>s+l.quiz.length, 0);
      const totalLessons = data ? data.length : 0;
      let totalScore = 0, scoreCount = 0;
      (data||[]).forEach(l=>{
        const saved = getSaved(c.id);
        const answered = (saved[l.id]||[]).filter(a=>a!==null).length;
        if(answered > 0){
          const correct = (saved[l.id]||[]).filter((a,i)=>a===l.quiz[i].a).length;
          totalScore += Math.round((correct/answered)*100);
          scoreCount++;
        }
      });
      const avgScore = scoreCount > 0 ? Math.round(totalScore/scoreCount) : null;
      return `
        <a class="course-card" href="javascript:void(0)" onclick="window._selectQuizCourse('${c.id}')">
          <div class="c-icon">${c.icon}</div>
          <h4>${c.title}</h4>
          <div class="c-lessons">${totalLessons} Lessons · ${totalQ} Questions</div>
          <div class="c-bar"><span style="width:${avgScore !== null ? avgScore : 0}%"></span></div>
          <div class="c-action">${avgScore !== null ? avgScore + '% Average' : 'Start Quizzes →'}</div>
        </a>`;
    }).join('');

    if(filterEl && !filterEl.dataset.wired){
      filterEl.dataset.wired = '1';
      available.forEach(c=>{
        const opt = document.createElement('option');
        opt.value = c.id;
        opt.textContent = c.title;
        filterEl.appendChild(opt);
      });
    }
  }

  window._answerQuiz = function(courseId, lessonId, qi, oi){
    saveAnswer(courseId, lessonId, qi, oi);
    render();
  };

  window._finishQuiz = function(courseId, lessonId){
    try{ localStorage.setItem(`boredacademy:quiz-finished:${courseId}:${lessonId}`, '1'); }catch(e){}
    renderQuizzesPage();
  };

  window._selectQuizCourse = function(courseId){
    const listEl = document.getElementById('quizList');
    if(listEl) listEl.dataset.selectedCourseId = courseId;
    renderQuizzesPage();
  };

  window._backToQuizCourses = function(){
    const listEl = document.getElementById('quizList');
    if(listEl) listEl.dataset.selectedCourseId = '';
    renderQuizzesPage();
  };

  render();
  if(searchEl && !searchEl.dataset.wired){
    searchEl.dataset.wired = '1';
    searchEl.addEventListener('input', render);
  }
  if(filterEl && !filterEl.dataset.wired){
    filterEl.dataset.wired = '1';
    filterEl.addEventListener('change', render);
  }
}

function renderSettingsPage(){
  const standalone = document.getElementById('settingsContent');
  if(standalone) return renderSettingsStandalone();
  return renderSettingsView();
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
  if(heading) heading.textContent = name ? `Welcome back, ${name}!` : 'Welcome back!';
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
   Page entry points — each dedicated HTML page calls exactly one of
   these after the DOM + data scripts are loaded.
   --------------------------------------------------------------------- */
function renderDashboardPage(){
  const stats = buildStats();
  renderHero();
  renderGoal(stats);
  renderStats(stats);
  renderActivity();
  renderCourses();
  renderAchievements(stats);
  renderTip();
}
function renderCoursesPage(){ renderCoursesView(); }
function renderProgressPage(){ renderProgressView(); }
function renderAchievementsPage(){ renderAchievementsView(buildStats()); }
function renderVocabularyPage(){ renderVocabularyView(); }
function renderCalendarPage(){ renderCalendarView(buildStats()); }

window.renderDashboardPage = renderDashboardPage;
window.renderCoursesPage = renderCoursesPage;
window.renderQuizzesPage = renderQuizzesPage;
window.renderProgressPage = renderProgressPage;
window.renderAchievementsPage = renderAchievementsPage;
window.renderVocabularyPage = renderVocabularyPage;
window.renderCalendarPage = renderCalendarPage;
window.renderSettingsPage = renderSettingsPage;
