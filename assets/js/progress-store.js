// Shared progress-tracking helpers, backed by localStorage.
// Keys used:
//   boredacademy:pct:<courseId>        -> number (0-100), written by course-app.js
//   boredacademy:progress:<courseId>   -> {lessonId: [answered indices]}
//   boredacademy:visits                -> ["2026-08-01", ...] distinct visit dates
//   boredacademy:activity              -> [{type, text, courseId, ts}, ...] most-recent-first, capped
//   boredacademy:lastLesson:<courseId> -> {lessonId, lessonTitle, unit, index}

window.ProgressStore = {
  todayStr(){
    return new Date().toISOString().slice(0,10);
  },

  recordVisitToday(){
    try{
      const key = 'boredacademy:visits';
      const visits = JSON.parse(localStorage.getItem(key) || '[]');
      const today = this.todayStr();
      if(visits[visits.length-1] !== today){
        visits.push(today);
        localStorage.setItem(key, JSON.stringify(visits.slice(-60)));
      }
    }catch(e){/* storage unavailable */}
  },

  currentStreak(){
    try{
      const visits = JSON.parse(localStorage.getItem('boredacademy:visits') || '[]');
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
    }catch(e){ return 0; }
  },

  logActivity(entry){
    try{
      const key = 'boredacademy:activity';
      const log = JSON.parse(localStorage.getItem(key) || '[]');
      log.unshift({ ...entry, ts: Date.now() });
      localStorage.setItem(key, JSON.stringify(log.slice(0, 20)));
    }catch(e){/* storage unavailable */}
  },

  recentActivity(limit){
    try{
      const log = JSON.parse(localStorage.getItem('boredacademy:activity') || '[]');
      return log.slice(0, limit || 5);
    }catch(e){ return []; }
  },

  setLastLesson(courseId, lesson){
    try{
      localStorage.setItem(`boredacademy:lastLesson:${courseId}`, JSON.stringify(lesson));
    }catch(e){/* storage unavailable */}
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
