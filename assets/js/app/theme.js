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
    const courseToolbar = document.querySelector('.course-toolbar-actions');
    if(courseToolbar){ courseToolbar.appendChild(wrap); }
    else { document.body.appendChild(wrap); }
    setTheme(getTheme());
  }

  if(document.readyState === 'loading'){
    document.addEventListener('DOMContentLoaded', function(){
      mountSwitcher();
      window.setTimeout(function(){
        mountSwitcher();
        const toolbar = document.querySelector('.course-toolbar-actions');
        const switcher = document.querySelector('.theme-switcher');
        if(toolbar && switcher) toolbar.appendChild(switcher);
      }, 50);
    });
  } else {
    mountSwitcher();
    window.setTimeout(function(){
      mountSwitcher();
      const toolbar = document.querySelector('.course-toolbar-actions');
      const switcher = document.querySelector('.theme-switcher');
      if(toolbar && switcher) toolbar.appendChild(switcher);
    }, 50);
  }

  if(typeof MutationObserver !== 'undefined'){
    let placed = false;
    const observer = new MutationObserver(function(){
      const toolbar = document.querySelector('.course-toolbar-actions');
      const switcher = document.querySelector('.theme-switcher');
      if(toolbar && switcher && switcher.parentElement !== toolbar){
        toolbar.appendChild(switcher);
        placed = true;
      } else if(placed){
        observer.disconnect();
      }
    });
    if(document.documentElement) observer.observe(document.documentElement, {childList:true, subtree:true});
  }

  function enablePageTransitions(){
    if(document.documentElement.dataset.transitionsReady === 'true') return;
    document.documentElement.dataset.transitionsReady = 'true';
    document.body.classList.add('page-ready');

    document.addEventListener('click', function(event){
      const link = event.target.closest && event.target.closest('a[href]');
      if(!link || event.defaultPrevented || event.button !== 0 || link.target && link.target !== '_self' || event.metaKey || event.ctrlKey || event.shiftKey || event.altKey || link.hasAttribute('download')) return;
      let url;
      try{ url = new URL(link.href, window.location.href); }
      catch(e){ return; }
      if(url.origin !== window.location.origin || url.pathname === window.location.pathname && url.search === window.location.search && url.hash) return;
      event.preventDefault();
      document.body.classList.remove('page-ready');
      document.body.classList.add('page-leaving');
      window.setTimeout(function(){ window.location.href = url.href; }, 140);
    });

    document.addEventListener('pointerover', function(event){
      const link = event.target.closest && event.target.closest('a[href]');
      if(!link) return;
      let url;
      try{ url = new URL(link.href, window.location.href); }
      catch(e){ return; }
      if(url.origin !== window.location.origin || url.pathname === window.location.pathname && url.search === window.location.search || url.hash) return;
      const alreadyPrefetched = Array.from(document.querySelectorAll('link[rel="prefetch"]')).some(function(item){ return item.href === url.href; });
      if(alreadyPrefetched) return;
      const prefetch = document.createElement('link');
      prefetch.rel = 'prefetch';
      prefetch.href = url.href;
      document.head.appendChild(prefetch);
    });
  }

  if(document.readyState === 'loading') document.addEventListener('DOMContentLoaded', enablePageTransitions);
  else enablePageTransitions();

  window.BoredTheme = { get: getTheme, set: setTheme };
})();
