/* ==========================================================================
   Bored Academy — Router
   After login, send the user to the right dashboard based on role instead
   of every page independently guessing.
   ========================================================================== */
window.BoredRouter = (function () {
  function dashboardFor(user) {
    if (!user) return 'welcome.html';
    if (window.BoredRoles && window.BoredRoles.isTeacher(user.role)) return 'teacher/teacher-dashboard.html';
    if (user.role === (window.BoredRoles && window.BoredRoles.ROLES.ADMIN)) return 'teacher/teacher-dashboard.html';
    return 'student/student-dashboard.html';
  }

  function goToDashboard(user) {
    const dest = dashboardFor(user);
    window.location.href = dest;
  }

  return { dashboardFor: dashboardFor, goToDashboard: goToDashboard };
})();
