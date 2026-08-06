/* ==========================================================================
   Bored Academy — Assignments
   Teacher assigns a course lesson to a class with unlock/due dates.
   ========================================================================== */
window.BoredAssignments = (function () {
  const KEY = 'boredacademy:assignments';

  function readAll() {
    try { return JSON.parse(localStorage.getItem(KEY) || '{}'); }
    catch (e) { return {}; }
  }
  function writeAll(val) {
    try { localStorage.setItem(KEY, JSON.stringify(val)); } catch (e) {}
  }

  function create(opts) {
    // opts: { classId, courseId, lessonId, unlockDate, dueDate, points, attempts }
    const all = readAll();
    // Random suffix avoids id collisions when two records are created
    // within the same millisecond (Date.now() alone is not unique enough).
    const id = 'a_' + Date.now().toString(36) + '_' + Math.random().toString(36).slice(2, 8);
    all[id] = Object.assign({ id: id, createdAt: Date.now() }, opts);
    writeAll(all);
    return all[id];
  }

  function forClass(classId) {
    return Object.values(readAll()).filter(function (a) { return a.classId === classId; });
  }

  function isUnlocked(assignment, now) {
    now = now || Date.now();
    return !assignment.unlockDate || new Date(assignment.unlockDate).getTime() <= now;
  }

  function isPastDue(assignment, now) {
    now = now || Date.now();
    return assignment.dueDate && new Date(assignment.dueDate).getTime() < now;
  }

  return { create: create, forClass: forClass, isUnlocked: isUnlocked, isPastDue: isPastDue };
})();
