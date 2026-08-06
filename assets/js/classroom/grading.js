/* ==========================================================================
   Bored Academy — Grading, Submissions & Tests
   Handles assignment submissions, test creation, and grade storage.
   ========================================================================== */
window.BoredGrading = (function () {
  const SUBMISSIONS_KEY = 'boredacademy:submissions';
  const TESTS_KEY = 'boredacademy:tests';
  const GRADES_KEY = 'boredacademy:grades';

  function readAll(key) {
    try { return JSON.parse(localStorage.getItem(key) || '{}'); }
    catch (e) { return {}; }
  }
  function writeAll(key, val) {
    try { localStorage.setItem(key, JSON.stringify(val)); } catch (e) {}
  }

  // -------- Submissions --------
  function createSubmission(opts) {
    const all = readAll(SUBMISSIONS_KEY);
    const id = 's_' + Date.now().toString(36) + '_' + Math.random().toString(36).slice(2, 8);
    all[id] = Object.assign({ id: id, submittedAt: Date.now(), status: 'submitted', feedback: '', grade: null }, opts);
    writeAll(SUBMISSIONS_KEY, all);
    return all[id];
  }

  function updateSubmission(id, updates) {
    const all = readAll(SUBMISSIONS_KEY);
    if (!all[id]) return null;
    Object.assign(all[id], updates);
    writeAll(SUBMISSIONS_KEY, all);
    return all[id];
  }

  function getSubmission(id) {
    return readAll(SUBMISSIONS_KEY)[id] || null;
  }

  function submissionsForStudent(studentEmail) {
    return Object.values(readAll(SUBMISSIONS_KEY)).filter(function (s) { return s.studentEmail === studentEmail; });
  }

  function submissionsForAssignment(assignmentId) {
    return Object.values(readAll(SUBMISSIONS_KEY)).filter(function (s) { return s.assignmentId === assignmentId; });
  }

  function submissionsForClass(classId) {
    return Object.values(readAll(SUBMISSIONS_KEY)).filter(function (s) { return s.classId === classId; });
  }

  // -------- Tests --------
  function createTest(opts) {
    const all = readAll(TESTS_KEY);
    const id = 't_' + Date.now().toString(36) + '_' + Math.random().toString(36).slice(2, 8);
    all[id] = Object.assign({ id: id, createdAt: Date.now(), questions: opts.questions || [] }, opts);
    writeAll(TESTS_KEY, all);
    return all[id];
  }

  function getTest(id) {
    return readAll(TESTS_KEY)[id] || null;
  }

  function testsForTeacher(teacherEmail) {
    return Object.values(readAll(TESTS_KEY)).filter(function (t) { return t.teacherEmail === teacherEmail; });
  }

  function testsForCourse(courseId) {
    return Object.values(readAll(TESTS_KEY)).filter(function (t) { return t.courseId === courseId; });
  }

  // -------- Grades --------
  function recordGrade(opts) {
    const all = readAll(GRADES_KEY);
    const id = 'g_' + Date.now().toString(36) + '_' + Math.random().toString(36).slice(2, 8);
    all[id] = Object.assign({ id: id, recordedAt: Date.now() }, opts);
    writeAll(GRADES_KEY, all);
    return all[id];
  }

  function updateGrade(id, updates) {
    const all = readAll(GRADES_KEY);
    if (!all[id]) return null;
    Object.assign(all[id], updates);
    writeAll(GRADES_KEY, all);
    return all[id];
  }

  function gradesForStudent(studentEmail) {
    return Object.values(readAll(GRADES_KEY)).filter(function (g) { return g.studentEmail === studentEmail; });
  }

  function gradesForClass(classId) {
    return Object.values(readAll(GRADES_KEY)).filter(function (g) { return g.classId === classId; });
  }

  function gradeForSubmission(submissionId) {
    return Object.values(readAll(GRADES_KEY)).find(function (g) { return g.submissionId === submissionId; }) || null;
  }

  return {
    createSubmission: createSubmission,
    updateSubmission: updateSubmission,
    getSubmission: getSubmission,
    submissionsForStudent: submissionsForStudent,
    submissionsForAssignment: submissionsForAssignment,
    submissionsForClass: submissionsForClass,
    createTest: createTest,
    getTest: getTest,
    testsForTeacher: testsForTeacher,
    testsForCourse: testsForCourse,
    recordGrade: recordGrade,
    updateGrade: updateGrade,
    gradesForStudent: gradesForStudent,
    gradesForClass: gradesForClass,
    gradeForSubmission: gradeForSubmission
  };
})();
