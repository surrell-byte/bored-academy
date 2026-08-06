/* ==========================================================================
   Bored Academy — Classroom
   Create classes, generate join codes, and join a class by code.
   Local-first (localStorage) with an optional Firestore sync hook so this
   keeps working before Firebase is wired up.
   ========================================================================== */
window.BoredClassroom = (function () {
  const CLASSES_KEY = 'boredacademy:classes';
  const MEMBERSHIP_KEY = 'boredacademy:class_students';

  function readAll(key) {
    try { return JSON.parse(localStorage.getItem(key) || '{}'); }
    catch (e) { return {}; }
  }
  function writeAll(key, val) {
    try { localStorage.setItem(key, JSON.stringify(val)); } catch (e) {}
  }

  function makeJoinCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    let code = '';
    for (let i = 0; i < 8; i++) {
      if (i === 4) code += '-';
      code += chars[Math.floor(Math.random() * chars.length)];
    }
    return code;
  }

  function createClass(teacherId, name) {
    const classes = readAll(CLASSES_KEY);
    // Random suffix avoids id collisions when two records are created
    // within the same millisecond (Date.now() alone is not unique enough).
    const id = 'c_' + Date.now().toString(36) + '_' + Math.random().toString(36).slice(2, 8);
    classes[id] = {
      id: id,
      teacherId: teacherId,
      name: name,
      joinCode: makeJoinCode(),
      createdAt: Date.now()
    };
    writeAll(CLASSES_KEY, classes);
    return classes[id];
  }

  function findByJoinCode(code) {
    const classes = readAll(CLASSES_KEY);
    return Object.values(classes).find(function (c) {
      return c.joinCode.toUpperCase() === String(code).toUpperCase();
    }) || null;
  }

  function joinClass(studentId, code) {
    const klass = findByJoinCode(code);
    if (!klass) return { ok: false, error: 'Invalid class code.' };

    const membership = readAll(MEMBERSHIP_KEY);
    membership[klass.id] = membership[klass.id] || [];
    if (membership[klass.id].indexOf(studentId) === -1) {
      membership[klass.id].push(studentId);
    }
    writeAll(MEMBERSHIP_KEY, membership);
    return { ok: true, class: klass };
  }

  function classesForTeacher(teacherId) {
    const classes = readAll(CLASSES_KEY);
    return Object.values(classes).filter(function (c) { return c.teacherId === teacherId; });
  }

  function classesForStudent(studentId) {
    const membership = readAll(MEMBERSHIP_KEY);
    const classes = readAll(CLASSES_KEY);
    return Object.keys(membership)
      .filter(function (classId) { return membership[classId].indexOf(studentId) !== -1; })
      .map(function (classId) { return classes[classId]; })
      .filter(Boolean);
  }

  function studentsInClass(classId) {
    const membership = readAll(MEMBERSHIP_KEY);
    return membership[classId] || [];
  }

  return {
    createClass: createClass,
    findByJoinCode: findByJoinCode,
    joinClass: joinClass,
    classesForTeacher: classesForTeacher,
    classesForStudent: classesForStudent,
    studentsInClass: studentsInClass
  };
})();
