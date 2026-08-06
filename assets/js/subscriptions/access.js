/* ==========================================================================
   Bored Academy — Access
   Thin wrapper so pages ask "does this user have premium access" without
   caring how billing is implemented underneath.
   ========================================================================== */
window.BoredAccess = (function () {
  function hasPremium(user) {
    return !!(user && window.BoredRoles && window.BoredRoles.isPremium(user.role));
  }
  return { hasPremium: hasPremium };
})();
