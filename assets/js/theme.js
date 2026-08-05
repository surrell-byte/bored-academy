/* ==========================================================================
   Bored Academy — Theme controller
   Themes: light (default, white), dark, notebook (cream + ruled lines).
   Persisted in localStorage under 'boredacademy:theme'.
   ========================================================================== */
(function(){
  const KEY = 'boredacademy:theme';
  const THEMES = [
    { id: 'light',    label: 'Light',    iconName: 'sun' },
    { id: 'dark',     label: 'Dark',     iconName: 'moon' },
    { id: 'notebook', label: 'Notebook', iconName: 'pencil' }
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
      btn.innerHTML = (typeof window.icon === 'function') ? window.icon(t.iconName) : t.label[0];
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
