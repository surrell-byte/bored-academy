/* ==========================================================================
   Bored Academy — Auth with optional Firestore sync

   Local auth is stored in localStorage so the app still works without a
   network or Firebase project. When Firebase is configured and available,
   user accounts and progress are also synced to Cloud Firestore so data
   survives across devices.

   Configure Firebase in assets/js/firebase-config.js.
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
  function hash(str){
    let h = 0;
    for(let i=0;i<str.length;i++){ h = (h<<5) - h + str.charCodeAt(i); h |= 0; }
    return 'v1_' + h;
  }

  function currentUser(){
    try{ return JSON.parse(localStorage.getItem(SESSION_KEY) || 'null'); }
    catch(e){ return null; }
  }

  function firebaseAvailable(){
    return !!(window.BoredFirebase && window.BoredFirebase.isEnabled && window.BoredFirebase.isEnabled());
  }

  function firebaseDb(){
    if(!firebaseAvailable()) return null;
    return window.BoredFirebase.db;
  }

  // BOREDACADEMY_AUTH_FIX
  function firebaseUserDoc(email, extra){
    if(!firebaseAvailable()) return Promise.resolve();
    const db = window.BoredFirebase.db;
    const user = currentUser();
    const data = {
      name: user?.name || email.split("@")[0],
      email,
      updatedAt: firebase.firestore.FieldValue.serverTimestamp()
    };
    if(extra && extra.role !== undefined) data.role = extra.role;
    if(extra && extra.classIds !== undefined) data.classIds = extra.classIds;
    return db.collection("users").doc(email).set(data, { merge: true }).catch(()=>{});
  }

  function defaultRoleFor(accountType){
    const Roles = window.BoredRoles ? window.BoredRoles.ROLES : {};
    return accountType === 'teacher' ? Roles.TEACHER_FREE : Roles.STUDENT_FREE;
  }

  function signUp(name, email, password, accountType){
    email = (email||'').trim().toLowerCase();
    name = (name||'').trim();
    accountType = accountType === 'teacher' ? 'teacher' : 'student';
    if(!email || !password) return { ok:false, error:'Enter an email and password.' };
    if(password.length < 6) return { ok:false, error:'Password must be at least 6 characters.' };
    const users = readUsers();
    if(users[email]) return { ok:false, error:'An account with that email already exists.' };
    users[email] = {
      name: name || email.split('@')[0],
      passHash: hash(password),
      role: defaultRoleFor(accountType),
      classIds: []
    };
    writeUsers(users);
    const session = { email, name: users[email].name, role: users[email].role, classIds: users[email].classIds };
    try{ localStorage.setItem(SESSION_KEY, JSON.stringify(session)); }catch(e){}
    try{ localStorage.setItem('boredacademy:name', session.name); }catch(e){}
    firebaseUserDoc(email, { role: session.role, classIds: session.classIds });
    return { ok:true, user: session };
  }

  function setRole(email, role){
    email = (email||'').trim().toLowerCase();
    const users = readUsers();
    if(!users[email]) return { ok:false, error:'No such account.' };
    users[email].role = role;
    writeUsers(users);
    const session = currentUser();
    if(session && session.email === email){
      session.role = role;
      try{ localStorage.setItem(SESSION_KEY, JSON.stringify(session)); }catch(e){}
    }
    firebaseUserDoc(email, { role });
    return { ok:true };
  }

  function addClass(email, classId){
    email = (email||'').trim().toLowerCase();
    const users = readUsers();
    if(!users[email]) return { ok:false, error:'No such account.' };
    users[email].classIds = users[email].classIds || [];
    if(users[email].classIds.indexOf(classId) === -1) users[email].classIds.push(classId);
    if(users[email].role === (window.BoredRoles && window.BoredRoles.ROLES.STUDENT_FREE)){
      users[email].role = window.BoredRoles.ROLES.STUDENT_CLASSROOM;
    }
    writeUsers(users);
    const session = currentUser();
    if(session && session.email === email){
      session.classIds = users[email].classIds;
      session.role = users[email].role;
      try{ localStorage.setItem(SESSION_KEY, JSON.stringify(session)); }catch(e){}
    }
    firebaseUserDoc(email, { classIds: users[email].classIds, role: users[email].role });
    return { ok:true };
  }

  function login(email, password){
    email = (email||'').trim().toLowerCase();
    const users = readUsers();
    const record = users[email];
    if(!record || record.passHash !== hash(password||'')){
      return { ok:false, error:'Incorrect email or password.' };
    }
    const session = { email, name: record.name, role: record.role || defaultRoleFor('student'), classIds: record.classIds || [] };
    try{ localStorage.setItem(SESSION_KEY, JSON.stringify(session)); }catch(e){}
    try{ localStorage.setItem('boredacademy:name', session.name); }catch(e){}
    const firestoreUpdate = {};
    if(record.role) firestoreUpdate.role = session.role;
    if(record.classIds) firestoreUpdate.classIds = session.classIds;
    firebaseUserDoc(email, firestoreUpdate);
    return { ok:true, user: session };
  }

  function logout(){
    try{ localStorage.removeItem(SESSION_KEY); }catch(e){}
    try{ localStorage.removeItem('boredacademy:name'); }catch(e){}
  }

  // BOREDACADEMY_REQUIREAUTH_DEPTH_FIX
  // Pages one folder deep (teacher/*.html, student/*.html, courses/*.html)
  // need '../welcome.html', not 'welcome.html' — otherwise a logged-out
  // user hitting one of those pages gets redirected to a 404 in that same
  // subfolder instead of the real welcome page.
  function rootRelative(path){
    const inSubfolder = /\/(teacher|student|courses)\/[^/]*$/.test(window.location.pathname);
    return inSubfolder ? '../' + path : path;
  }

  function requireAuth(){
    if(!currentUser()){
      window.location.href = rootRelative('welcome.html');
      return false;
    }
    return true;
  }

  function markOnboardingDone(){
    try{ localStorage.setItem('boredacademy:onboarding_done', '1'); }catch(e){}
  }
  function needsOnboarding(){
    return !localStorage.getItem('boredacademy:onboarding_done');
  }
  function setTeacherAccess(hasAccess){
    try{ localStorage.setItem('boredacademy:teacher_access', hasAccess ? '1' : '0'); }catch(e){}
  }
  function hasTeacherAccess(){
    return localStorage.getItem('boredacademy:teacher_access') === '1';
  }

  // Keep same-site navigation feeling continuous without delaying form submits,
  // downloads, external links, or modified clicks that users expect browsers
  // to handle normally.
  function enablePageTransitions(){
    document.body.classList.add('page-ready');
    document.addEventListener('click', function(event){
      const link = event.target.closest && event.target.closest('a[href]');
      if(!link || event.defaultPrevented || event.button !== 0 || event.metaKey || event.ctrlKey || event.shiftKey || event.altKey) return;
      if(link.target && link.target !== '_self' || link.hasAttribute('download')) return;
      const url = new URL(link.href, window.location.href);
      if(url.origin !== window.location.origin || url.pathname === window.location.pathname && url.search === window.location.search && url.hash) return;
      event.preventDefault();
      document.body.classList.add('page-leaving');
      window.setTimeout(function(){ window.location.href = url.href; }, 145);
    });
  }
  if(document.readyState === 'loading') document.addEventListener('DOMContentLoaded', enablePageTransitions);
  else enablePageTransitions();

  window.BoredAuth = { currentUser, signUp, login, logout, requireAuth, setRole, addClass, firebaseAvailable, markOnboardingDone, needsOnboarding, setTeacherAccess, hasTeacherAccess, rootRelative };
})();
