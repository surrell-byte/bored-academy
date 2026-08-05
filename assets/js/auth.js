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
