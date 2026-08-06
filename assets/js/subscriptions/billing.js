/* ==========================================================================
   Bored Academy — Billing
   Placeholder for wiring up a real payment provider (Stripe, etc).
   Do NOT ship a client-side "upgrade" toggle to production — role changes
   after a real payment must be granted by a backend/webhook.
   ========================================================================== */
window.BoredBilling = (function () {
  function startCheckout(plan) {
    console.warn('BoredBilling.startCheckout is a stub. Wire up a real provider before launch.', plan);
  }
  return { startCheckout: startCheckout };
})();
