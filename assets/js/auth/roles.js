/* ==========================================================================
   Bored Academy — Roles
   Central place that defines every role in the system. Nothing else in the
   app should hardcode a role string — import these constants instead.
   ========================================================================== */
window.BoredRoles = (function () {
  const ROLES = Object.freeze({
    GUEST: 'guest',
    STUDENT_FREE: 'student_free',
    STUDENT_CLASSROOM: 'student_classroom',
    STUDENT_PREMIUM: 'student_premium',
    TEACHER_FREE: 'teacher_free',
    TEACHER_PREMIUM: 'teacher_premium',
    ADMIN: 'admin'
  });

  function isStudent(role) {
    return role === ROLES.STUDENT_FREE ||
           role === ROLES.STUDENT_CLASSROOM ||
           role === ROLES.STUDENT_PREMIUM;
  }

  function isTeacher(role) {
    return role === ROLES.TEACHER_FREE || role === ROLES.TEACHER_PREMIUM;
  }

  function isPremium(role) {
    return role === ROLES.STUDENT_PREMIUM || role === ROLES.TEACHER_PREMIUM;
  }

  function isAdmin(role) {
    return role === ROLES.ADMIN;
  }

  return { ROLES, isStudent, isTeacher, isPremium, isAdmin };
})();
