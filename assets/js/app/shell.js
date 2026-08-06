/* ==========================================================================
   Bored Academy — Shared dashboard shell (sidebar, topbar, phone bottom nav)
   Every top-level page (index/progress/achievements/vocabulary/calendar/
   settings) mounts this instead of duplicating the nav markup. Each page
   sets window.CURRENT_TAB before this script runs so the right item is
   highlighted.
   ========================================================================== */
(function(){
  const NAV_ITEMS = [
    { tab:'dashboard',    href:'index.html',        icon:'home',        label:'Dashboard' },
    { tab:'courses',      href:'courses.html',      icon:'book-open',   label:'Courses' },
    { tab:'quizzes',      href:'quizzes.html',      icon:'help-circle', label:'Quizzes' },
    { tab:'progress',     href:'progress.html',     icon:'trending-up', label:'Progress' },
    { tab:'achievements', href:'achievements.html', icon:'trophy',      label:'Achievements' },
    { tab:'vocabulary',   href:'vocabulary.html',   icon:'bookmark',    label:'Vocabulary' },
    { tab:'calendar',     href:'calendar.html',     icon:'calendar',    label:'Calendar' },
    { tab:'settings',     href:'settings.html',     icon:'settings',    label:'Settings' }
  ];
  // The phone bottom nav only has room for a few items; "Courses" isn't
  // included since it's just an anchor within the dashboard.
  const PHONE_NAV_TABS = ['dashboard','courses','quizzes','progress','achievements','settings'];
  const PHONE_NAV_LABELS = { dashboard:'Home', courses:'Courses', quizzes:'Quizzes', progress:'Progress', achievements:'Achv.', settings:'More' };

  function renderSidebar(activeTab){
    const el = document.getElementById('shellSidebar');
    if(!el) return;
    el.innerHTML = `
      <div class="dash-brand">
        <span class="logo"><img src="assets/img/logo.webp" alt="Bored Academy logo" width="28" height="28"></span>
        <h1>Bored Academy</h1>
      </div>
      <nav class="dash-nav">
        ${NAV_ITEMS.map(n=>`
          <a href="${n.href}" data-nav="${n.tab}" class="${n.tab===activeTab?'active':''}">
            <span class="n-icon">${icon(n.icon)}</span><span class="n-label">${n.label}</span>
          </a>`).join('')}
      </nav>`;
  }

  function renderTopbar(){
    const el = document.getElementById('shellTopbar');
    if(!el) return;
    el.innerHTML = `
      <div class="dash-search">${icon('search')} Search lessons, topics, vocabulary…</div>
      <div class="dash-topbar-right">
        <span class="dash-role-badge" id="roleBadge">Student</span>
        <span class="dash-bell">${icon('bell')}</span>
        <span class="dash-avatar" id="logoutBtn" title="Sign out" role="button" tabindex="0">${icon('user')}</span>
      </div>`;
    const logoutBtn = document.getElementById('logoutBtn');
    if(logoutBtn){
      logoutBtn.addEventListener('click', function(){
        if(confirm('Sign out of Bored Academy?')){
          if(window.BoredAuth) BoredAuth.logout();
          window.location.href = 'welcome.html';
        }
      });
    }
  }

  function renderPhoneNav(activeTab){
    const el = document.getElementById('shellPhoneNav');
    if(!el) return;
    el.innerHTML = PHONE_NAV_TABS.map(tab=>{
      const item = NAV_ITEMS.find(n=>n.tab===tab);
      return `<a href="${item.href}" data-nav="${tab}" class="${tab===activeTab?'active':''}">
        <span class="bn-icon">${icon(item.icon)}</span>${PHONE_NAV_LABELS[tab]}
      </a>`;
    }).join('');
  }

  function mountShell(){
    const activeTab = window.CURRENT_TAB || 'dashboard';
    if(window.ProgressStore) ProgressStore.recordVisitToday();
    renderSidebar(activeTab);
    renderTopbar();
    renderPhoneNav(activeTab);
  }

  if(document.readyState === 'loading'){
    document.addEventListener('DOMContentLoaded', mountShell);
  } else {
    mountShell();
  }
})();