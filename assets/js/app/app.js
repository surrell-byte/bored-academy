/* ==========================================================================
   Bored Academy — App bootstrap
   Small shared init: read the current session and expose it as
   window.BoredApp.currentUser for every page to use.
   ========================================================================== */
window.BoredApp = (function () {
  function currentUser() {
    return window.BoredAuth ? window.BoredAuth.currentUser() : null;
  }
  return { currentUser: currentUser };
})();
