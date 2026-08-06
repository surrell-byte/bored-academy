/* ==========================================================================
   Bored Academy — Permissions
   Single source of truth for "can this user do X". Pages should call these
   functions instead of re-implementing role checks inline.
   ========================================================================== */
window.BoredPermissions = (function () {
  const Roles = window.BoredRoles ? window.BoredRoles.ROLES : {};

  // lesson: { id, courseId, free, assignedTo: [classId,...] }
  // user:   { uid, role, classIds: [...] }
  function canAccessLesson(user, lesson) {
    if (!lesson) return false;
    if (lesson.free) return true; // demo / free lesson
    if (!user) return false; // guest, non-free lesson

    if (window.BoredRoles && window.BoredRoles.isPremium(user.role)) return true;
    if (user.role === Roles.ADMIN) return true;

    const classIds = user.classIds || [];
    const assignedTo = lesson.assignedTo || [];
    return assignedTo.some(function (id) { return classIds.indexOf(id) !== -1; });
  }

  function canManageClass(user, klass) {
    if (!user || !klass) return false;
    if (user.role === Roles.ADMIN) return true;
    return window.BoredRoles.isTeacher(user.role) && klass.teacherId === user.uid;
  }

  function canGrade(user, klass) {
    return canManageClass(user, klass);
  }

  function classLimitFor(role) {
    // Free teacher plan limits, per architecture doc.
    if (role === Roles.TEACHER_FREE) return { classes: 1, students: 20 };
    return { classes: Infinity, students: Infinity };
  }

  return { canAccessLesson, canManageClass, canGrade, classLimitFor };
})();
