#!/usr/bin/env bash
# ==========================================================================
# Bored Academy — architecture migration
#
# Run this from the repo root (same folder as index.html).
#   chmod +x apply_architecture.sh
#   ./apply_architecture.sh
#
# What it does:
#   1. Removes the broken "{assets..." junk directory (leftover from a bad
#      cp/mv glob).
#   2. Reorganizes assets/js by feature (app/, auth/, courses/, classroom/,
#      subscriptions/, firebase/, data/) instead of one flat folder.
#   3. Adds new starter modules: roles.js, permissions.js, classroom.js,
#      assignments.js, tests.js, leaderboard.js, calendar.js, gradebook.js,
#      billing.js, access.js, router.js.
#   4. Adds teacher/ and student/ page folders with stub dashboards.
#   5. Updates <script src> paths in existing HTML files so nothing 404s.
#
# It uses `git mv` when the repo is a git checkout so history is preserved,
# and falls back to plain `mv` otherwise. Safe to re-run (skips steps whose
# target already exists).
# ==========================================================================
set -euo pipefail

ROOT="$(pwd)"
JS="assets/js"

log() { printf '\033[1;36m▸ %s\033[0m\n' "$1"; }
skip() { printf '  (skip) %s\n' "$1"; }

MV="mv"
if [ -d .git ] && command -v git >/dev/null 2>&1; then
  MV="git mv"
fi

domove() {
  local src="$1" dst="$2"
  if [ ! -e "$src" ]; then return 0; fi
  if [ -e "$dst" ]; then skip "$dst already exists"; return 0; fi
  mkdir -p "$(dirname "$dst")"
  if [ "$MV" = "git mv" ]; then
    git mv "$src" "$dst" 2>/dev/null || mv "$src" "$dst"
  else
    mv "$src" "$dst"
  fi
}

# --------------------------------------------------------------------------
# 0. Sanity check
# --------------------------------------------------------------------------
if [ ! -f index.html ] || [ ! -d assets ]; then
  echo "Run this from the bored-academy repo root (where index.html lives)." >&2
  exit 1
fi

# --------------------------------------------------------------------------
# 1. Clean up the broken "{assets..." directory from the bad glob
# --------------------------------------------------------------------------
log "Removing broken glob artifact directory"
for junk in "{assets" "{assets/css,assets" ; do
  if [ -d "$junk" ]; then
    rm -rf "$junk"
    echo "  removed: $junk"
  fi
done
# catch-all: any top-level dir literally starting with "{"
find . -maxdepth 1 -type d -name '{*' -exec rm -rf {} + 2>/dev/null || true

# --------------------------------------------------------------------------
# 2. Reorganize assets/js by feature
# --------------------------------------------------------------------------
log "Creating feature folders"
mkdir -p "$JS/app" "$JS/auth" "$JS/courses" "$JS/classroom" \
         "$JS/subscriptions" "$JS/firebase" "$JS/data"

log "Moving existing files into feature folders"
domove "$JS/shell.js"            "$JS/app/shell.js"
domove "$JS/dashboard.js"        "$JS/app/dashboard.js"
domove "$JS/theme.js"            "$JS/app/theme.js"
domove "$JS/icons.js"            "$JS/app/icons.js"

domove "$JS/auth.js"             "$JS/auth/auth.js"

domove "$JS/course-app.js"       "$JS/courses/course-loader.js"
domove "$JS/progress-store.js"   "$JS/courses/progress.js"

domove "$JS/firebase-config.js"  "$JS/firebase/firebase-config.js"
domove "$JS/firebase.js"         "$JS/firebase/firestore.js"

domove "$JS/data/cet4-data.js"      "$JS/data/cet4-data.js"
domove "$JS/data/chemistry-data.js" "$JS/data/chemistry-data.js"
domove "$JS/data/ielts-data.js"     "$JS/data/ielts-data.js"
domove "$JS/data/courses.js"        "$JS/data/courses.js"

# --------------------------------------------------------------------------
# 3. New modules: roles + permissions (auth layer)
# --------------------------------------------------------------------------
if [ ! -f "$JS/auth/roles.js" ]; then
log "Writing $JS/auth/roles.js"
cat > "$JS/auth/roles.js" <<'EOF'
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
EOF
else
  skip "$JS/auth/roles.js"
fi

if [ ! -f "$JS/auth/permissions.js" ]; then
log "Writing $JS/auth/permissions.js"
cat > "$JS/auth/permissions.js" <<'EOF'
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
EOF
else
  skip "$JS/auth/permissions.js"
fi

# --------------------------------------------------------------------------
# 4. New modules: classroom feature
# --------------------------------------------------------------------------
if [ ! -f "$JS/classroom/classroom.js" ]; then
log "Writing $JS/classroom/classroom.js"
cat > "$JS/classroom/classroom.js" <<'EOF'
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
    const id = 'c_' + Date.now().toString(36);
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
EOF
else
  skip "$JS/classroom/classroom.js"
fi

if [ ! -f "$JS/classroom/assignments.js" ]; then
log "Writing $JS/classroom/assignments.js"
cat > "$JS/classroom/assignments.js" <<'EOF'
/* ==========================================================================
   Bored Academy — Assignments
   Teacher assigns a course lesson to a class with unlock/due dates.
   ========================================================================== */
window.BoredAssignments = (function () {
  const KEY = 'boredacademy:assignments';

  function readAll() {
    try { return JSON.parse(localStorage.getItem(KEY) || '{}'); }
    catch (e) { return {}; }
  }
  function writeAll(val) {
    try { localStorage.setItem(KEY, JSON.stringify(val)); } catch (e) {}
  }

  function create(opts) {
    // opts: { classId, courseId, lessonId, unlockDate, dueDate, points, attempts }
    const all = readAll();
    const id = 'a_' + Date.now().toString(36);
    all[id] = Object.assign({ id: id, createdAt: Date.now() }, opts);
    writeAll(all);
    return all[id];
  }

  function forClass(classId) {
    return Object.values(readAll()).filter(function (a) { return a.classId === classId; });
  }

  function isUnlocked(assignment, now) {
    now = now || Date.now();
    return !assignment.unlockDate || new Date(assignment.unlockDate).getTime() <= now;
  }

  function isPastDue(assignment, now) {
    now = now || Date.now();
    return assignment.dueDate && new Date(assignment.dueDate).getTime() < now;
  }

  return { create: create, forClass: forClass, isUnlocked: isUnlocked, isPastDue: isPastDue };
})();
EOF
else
  skip "$JS/classroom/assignments.js"
fi

for f in tests leaderboard calendar gradebook; do
  TARGET="$JS/classroom/$f.js"
  if [ ! -f "$TARGET" ]; then
    log "Writing $TARGET (stub)"
    cat > "$TARGET" <<'EOF'
/* ==========================================================================
   Bored Academy — STUB
   TODO: implement. See architecture notes for the classroom feature.
   Follow the same localStorage-first, Firestore-optional pattern used in
   classroom.js and assignments.js.
   ========================================================================== */
window.BoredSTUB = window.BoredSTUB || {};
EOF
  else
    skip "$TARGET"
  fi
done

# --------------------------------------------------------------------------
# 5. New modules: subscriptions
# --------------------------------------------------------------------------
if [ ! -f "$JS/subscriptions/access.js" ]; then
log "Writing $JS/subscriptions/access.js"
cat > "$JS/subscriptions/access.js" <<'EOF'
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
EOF
else
  skip "$JS/subscriptions/access.js"
fi

if [ ! -f "$JS/subscriptions/billing.js" ]; then
log "Writing $JS/subscriptions/billing.js"
cat > "$JS/subscriptions/billing.js" <<'EOF'
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
EOF
else
  skip "$JS/subscriptions/billing.js"
fi

# --------------------------------------------------------------------------
# 6. App shell: router.js, app.js
# --------------------------------------------------------------------------
if [ ! -f "$JS/app/router.js" ]; then
log "Writing $JS/app/router.js"
cat > "$JS/app/router.js" <<'EOF'
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
EOF
else
  skip "$JS/app/router.js"
fi

if [ ! -f "$JS/app/app.js" ]; then
log "Writing $JS/app/app.js"
cat > "$JS/app/app.js" <<'EOF'
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
EOF
else
  skip "$JS/app/app.js"
fi

# --------------------------------------------------------------------------
# 7. Teacher / student page stubs
# --------------------------------------------------------------------------
log "Creating teacher/ and student/ page stubs"
mkdir -p teacher student

make_stub() {
  local path="$1" title="$2"
  if [ -f "$path" ]; then skip "$path"; return; fi
  cat > "$path" <<EOF
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8" />
<title>${title} — Bored Academy</title>
<link rel="stylesheet" href="../assets/css/base.css" />
<link rel="stylesheet" href="../assets/css/dashboard.css" />
<link rel="stylesheet" href="../assets/css/responsive.css" />
</head>
<body>
<main class="page">
  <h1>${title}</h1>
  <p>TODO: build this view.</p>
</main>

<script src="../assets/js/firebase/firebase-config.js"></script>
<script src="../assets/js/firebase/firestore.js"></script>
<script src="../assets/js/auth/auth.js"></script>
<script src="../assets/js/auth/roles.js"></script>
<script src="../assets/js/auth/permissions.js"></script>
<script src="../assets/js/app/app.js"></script>
<script src="../assets/js/app/router.js"></script>
<script src="../assets/js/app/shell.js"></script>
</body>
</html>
EOF
  echo "  created: $path"
}

make_stub "teacher/teacher-dashboard.html"   "Teacher Dashboard"
make_stub "teacher/teacher-class.html"       "Class Overview"
make_stub "teacher/teacher-assignments.html" "Assignments"
make_stub "teacher/teacher-tests.html"       "Tests"
make_stub "teacher/teacher-gradebook.html"   "Gradebook"
make_stub "teacher/teacher-calendar.html"    "Calendar"
make_stub "teacher/teacher-settings.html"    "Settings"

make_stub "student/student-dashboard.html"   "Student Dashboard"
make_stub "student/student-calendar.html"    "Calendar"
make_stub "student/student-leaderboard.html" "Leaderboard"
make_stub "student/student-settings.html"    "Settings"

# --------------------------------------------------------------------------
# 8. Fix <script src> paths in existing top-level HTML files
# --------------------------------------------------------------------------
log "Rewriting <script src> paths in existing HTML files"

fix_html() {
  local f="$1"
  [ -f "$f" ] || return 0
  sed -i.bak \
    -e "s#assets/js/shell.js#assets/js/app/shell.js#g" \
    -e "s#assets/js/dashboard.js#assets/js/app/dashboard.js#g" \
    -e "s#assets/js/theme.js#assets/js/app/theme.js#g" \
    -e "s#assets/js/icons.js#assets/js/app/icons.js#g" \
    -e "s#assets/js/auth.js#assets/js/auth/auth.js#g" \
    -e "s#assets/js/course-app.js#assets/js/courses/course-loader.js#g" \
    -e "s#assets/js/progress-store.js#assets/js/courses/progress.js#g" \
    -e "s#assets/js/firebase-config.js#assets/js/firebase/firebase-config.js#g" \
    -e "s#assets/js/firebase.js#assets/js/firebase/firestore.js#g" \
    "$f"
  rm -f "$f.bak"
}

for f in *.html courses/*.html; do
  fix_html "$f"
done

log "Done."
echo
echo "Next steps:"
echo "  1. Review the diff (git diff / git status)."
echo "  2. Add auth/roles.js + auth/permissions.js <script> tags to any page"
echo "     that needs role checks (they're only auto-added to the new stubs)."
echo "  3. Start filling in classroom/tests.js, leaderboard.js, calendar.js,"
echo "     gradebook.js — currently stubs."
echo "  4. Move the admin-code check out of client JS and into a backend"
echo "     endpoint before launch (see architecture notes)."
