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
      <a href="../courses.html" class="brand-home" title="Back to courses"><svg class="icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M3 11l9-8 9 8"/><path d="M5 10v10h14V10"/><path d="M9.5 20v-6h5v6"/></svg></a>
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
  if(tab==='home'){ window.location.href = '../courses.html'; return; }
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
