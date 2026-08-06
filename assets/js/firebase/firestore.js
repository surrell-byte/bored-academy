/* ==========================================================================
   Bored Academy — Firebase loader + Firestore helpers

   Loads the Firebase Compat SDK from CDN and initializes the app if
   `window.FIREBASE_CONFIG` contains valid-looking values. Exposes
   `window.BoredFirebase` so the rest of the app can use auth/db without
   caring whether Firebase is actually configured.

   If Firebase is not configured or fails to initialize, `isEnabled()` will
   return false and the app will continue using its existing localStorage
   auth/progress implementation.
   ========================================================================== */
(function(){
  const CONFIG = window.FIREBASE_CONFIG || {};
  const hasConfig = CONFIG.apiKey && CONFIG.projectId && CONFIG.apiKey !== "YOUR_API_KEY" && CONFIG.projectId !== "YOUR_PROJECT_ID";

  if(!hasConfig){
    window.BoredFirebase = { isEnabled: ()=> false };
    return;
  }

  const SDK_URL = "https://www.gstatic.com/firebasejs/10.12.0/firebase-app-compat.js";
  const AUTH_URL = "https://www.gstatic.com/firebasejs/10.12.0/firebase-auth-compat.js";
  const FIRESTORE_URL = "https://www.gstatic.com/firebasejs/10.12.0/firebase-firestore-compat.js";

  let loaded = 0;
  const total = 3;

  function checkReady(){
    if(loaded < total) return;
    try{
      firebase.initializeApp(CONFIG);
      const auth = firebase.auth();
      const db = firebase.firestore();
      window.BoredFirebase = {
        isEnabled: ()=> true,
        auth,
        db,
        config: CONFIG
      };
      notifyProgressStore();
    }catch(e){
      console.warn("BoredAcademy: Firebase init failed — falling back to localStorage.", e);
      window.BoredFirebase = { isEnabled: ()=> false };
    }
  }

  function notifyProgressStore(){
    const tryNotify = ()=>{
      if(window.ProgressStore && window.ProgressStore._firebaseReady){
        window.ProgressStore._firebaseReady(window.BoredFirebase);
      }else{
        setTimeout(tryNotify, 50);
      }
    };
    tryNotify();
  }

  function loadScript(url){
    return new Promise((resolve, reject)=>{
      const s = document.createElement("script");
      s.src = url;
      s.crossOrigin = "anonymous";
      s.onload = ()=>{ loaded++; resolve(); checkReady(); };
      s.onerror = ()=>{ console.warn("BoredAcademy: failed to load Firebase script:", url); loaded++; resolve(); checkReady(); };
      document.head.appendChild(s);
    });
  }

  if(window.firebase && firebase.app){
    loaded = total;
    checkReady();
    return;
  }

  loadScript(SDK_URL).then(()=> loadScript(AUTH_URL)).then(()=> loadScript(FIRESTORE_URL)).catch(()=>{
    window.BoredFirebase = { isEnabled: ()=> false };
  });
})();
