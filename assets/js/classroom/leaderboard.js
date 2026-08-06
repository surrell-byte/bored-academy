/* ==========================================================================
   Bored Academy — Leaderboard
   Ranks students in a class by points earned from graded assignments
   (BoredGrading grades: score out of maxPoints). Supports Daily / Weekly /
   Monthly / All Time windows, keyed off each grade's gradedAt timestamp.
   ========================================================================== */
window.BoredLeaderboard = (function () {
  const DAY_MS = 86400000;

  function windowStart(period, now) {
    now = now || Date.now();
    switch (period) {
      case 'daily':   return now - DAY_MS;
      case 'weekly':  return now - 7 * DAY_MS;
      case 'monthly': return now - 30 * DAY_MS;
      default:        return -Infinity; // all time
    }
  }

  // Returns [{ studentEmail, studentName, points, gradedCount }], sorted
  // descending by points. `period`: 'daily' | 'weekly' | 'monthly' | 'all'.
  function rankingsForClass(classId, period, now) {
    if (!window.BoredGrading) return [];
    now = now || Date.now();
    const since = windowStart(period, now);

    const grades = BoredGrading.gradesForClass(classId)
      .filter(function (g) { return (g.gradedAt || 0) >= since; });

    const byStudent = {};
    grades.forEach(function (g) {
      const key = g.studentEmail;
      if (!byStudent[key]) {
        byStudent[key] = { studentEmail: key, studentName: g.studentName || key, points: 0, gradedCount: 0 };
      }
      // Normalize to a 0-100 scale per grade so a 9/10 quiz and a 45/50 test
      // contribute comparably, then round to whole points.
      const maxPoints = g.maxPoints || 100;
      const score = typeof g.score === 'number' ? g.score : 0;
      const pct = maxPoints > 0 ? score / maxPoints : 0;
      byStudent[key].points += Math.round(pct * 100);
      byStudent[key].gradedCount += 1;
    });

    return Object.values(byStudent).sort(function (a, b) { return b.points - a.points; });
  }

  return { rankingsForClass: rankingsForClass, windowStart: windowStart };
})();
