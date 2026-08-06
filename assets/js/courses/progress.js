// Shared progress-tracking helpers, backed by localStorage.
// When Firebase is configured, data is also synced to Cloud Firestore
// under `users/{email}/...` so progress survives across devices.
// Keys used:
//   boredacademy:pct:<courseId>        -> number (0-100), written by course-app.js
//   boredacademy:progress:<courseId>   -> {lessonId: [answered indices]}
//   boredacademy:visits                -> ["2026-08-01", ...] distinct visit dates
//   boredacademy:activity              -> [{type, text, courseId, ts}, ...] most-recent-first, capped
//   boredacademy:lastLesson:<courseId> -> {lessonId, lessonTitle, unit, index}

window.ProgressStore = (function(){
  let firebaseDb = null;
  let firebaseEmail = null;

  function available(){
    return !!(firebaseDb && firebaseEmail);
  }

  function setFirebase(db, email){
    firebaseDb = db;
    firebaseEmail = email;
  }

  function todayStr(){
    return new Date().toISOString().slice(0,10);
  }

  function readVisits(){
    try{ return JSON.parse(localStorage.getItem('boredacademy:visits') || '[]'); }
    catch(e){ return []; }
  }
  function writeVisits(visits){
    try{ localStorage.setItem('boredacademy:visits', JSON.stringify(visits.slice(-60))); }catch(e){}
  }
  function readActivity(){
    try{ return JSON.parse(localStorage.getItem('boredacademy:activity') || '[]'); }
    catch(e){ return []; }
  }
  function writeActivity(log){
    try{ localStorage.setItem('boredacademy:activity', JSON.stringify(log.slice(0, 20))); }catch(e){}
  }
  function readProgress(courseId){
    try{ return JSON.parse(localStorage.getItem(`boredacademy:progress:${courseId}`) || '{}'); }
    catch(e){ return {}; }
  }
  function writeProgress(courseId, data){
    try{ localStorage.setItem(`boredacademy:progress:${courseId}`, JSON.stringify(data)); }catch(e){}
    syncProgress(courseId);
  }

  function firestoreSet(path, data){
    if(!available()) return Promise.resolve();
    return firebaseDb.collection(...path).doc(path[path.length-1]).set(data, { merge: true }).catch(()=>{});
  }

  function syncVisits(){
    if(!available()) return;
    const visits = readVisits();
    firestoreSet(["users", firebaseEmail, "visits", "_"], { dates: visits, updatedAt: new Date().toISOString() });
  }

  function syncActivity(){
    if(!available()) return;
    const log = readActivity();
    firestoreSet(["users", firebaseEmail, "activity", "_"], { entries: log, updatedAt: new Date().toISOString() });
  }

  function syncProgress(courseId){
    if(!available()) return;
    const data = readProgress(courseId);
    firestoreSet(["users", firebaseEmail, "progress", courseId], { answers: data, updatedAt: new Date().toISOString() });
  }

  function setProgress(courseId, data){
    writeProgress(courseId, data);
  }

  function syncLastLesson(courseId, lesson){
    if(!available() || !lesson) return;
    firestoreSet(["users", firebaseEmail, "lastLesson", courseId], { ...lesson, updatedAt: new Date().toISOString() });
  }

  return {
    setFirebase,
    _firebaseReady(boredFirebase){
      if(!boredFirebase || !boredFirebase.isEnabled || !boredFirebase.isEnabled()) return;
      const user = (window.BoredAuth && BoredAuth.currentUser()) || null;
      if(!user) return;
      setFirebase(boredFirebase.db, user.email);
      syncVisits();
      syncActivity();
      Object.keys(readProgress()).forEach(syncProgress);
    },

    todayStr,
    recordVisitToday(){
      const visits = readVisits();
      const today = this.todayStr();
      if(visits[visits.length-1] !== today){
        visits.push(today);
        writeVisits(visits);
        syncVisits();
      }
    },
    currentStreak(){
      const visits = readVisits();
      if(visits.length === 0) return 0;
      let streak = 1;
      let cursor = new Date(visits[visits.length-1]);
      for(let i = visits.length-2; i >= 0; i--){
        const prev = new Date(visits[i]);
        const diffDays = Math.round((cursor - prev) / 86400000);
        if(diffDays === 1){ streak++; cursor = prev; }
        else if(diffDays === 0){ continue; }
        else break;
      }
      return streak;
    },
    logActivity(entry){
      const log = readActivity();
      log.unshift({ ...entry, ts: Date.now() });
      writeActivity(log);
      syncActivity();
    },
    recentActivity(limit){
      return readActivity().slice(0, limit || 5);
    },
    setLastLesson(courseId, lesson){
      try{ localStorage.setItem(`boredacademy:lastLesson:${courseId}`, JSON.stringify(lesson)); }catch(e){}
      syncLastLesson(courseId, lesson);
    },
    getLastLesson(courseId){
      try{
        const v = localStorage.getItem(`boredacademy:lastLesson:${courseId}`);
        return v ? JSON.parse(v) : null;
      }catch(e){ return null; }
    },
    timeAgo(ts){
      const diffMs = Date.now() - ts;
      const mins = Math.round(diffMs / 60000);
      if(mins < 1) return 'just now';
      if(mins < 60) return `${mins}m ago`;
      const hrs = Math.round(mins / 60);
      if(hrs < 24) return `${hrs}h ago`;
      const days = Math.round(hrs / 24);
      return `${days}d ago`;
    }
  };
})();
