/* ==========================================================================
   Bored Academy — Router
   After login, send the user to the right dashboard based on role instead
   of every page independently guessing.
   ========================================================================== */
// BOREDACADEMY_ROUTER_FIX
window.BoredRouter = (function () {
  function dashboardFor(user) {
    if (!user) return 'welcome.html';
    if (window.BoredAuth && BoredAuth.needsOnboarding()) {
      const isTeacher = window.BoredRoles && (BoredRoles.isTeacher(user.role) || BoredRoles.isAdmin(user.role));
      return isTeacher ? 'teacher/teacher-access.html' : 'student/student-join-class.html';
    }
    if (window.BoredRoles && window.BoredRoles.isTeacher(user.role)) return 'teacher/teacher-dashboard.html';
    if (window.BoredRoles && window.BoredRoles.isAdmin(user.role)) return 'teacher/teacher-dashboard.html';
    return 'student/student-dashboard.html';
  }

  function goToDashboard(user) {
    const dest = dashboardFor(user);
    window.location.href = dest;
  }

  return { dashboardFor: dashboardFor, goToDashboard: goToDashboard };
})();
