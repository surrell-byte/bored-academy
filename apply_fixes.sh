#!/usr/bin/env bash
# ==========================================================================
# Bored Academy — fixes for silently-skipped patches
#
# Run from the repo root, AFTER the other migration scripts:
#   chmod +x apply_fixes.sh
#   ./apply_fixes.sh
#
# Safe to re-run — every patch checks for its own marker first.
# ==========================================================================
set -euo pipefail
BLUE='\033[1;36m'; NC='\033[0m'
log(){ echo -e "${BLUE}▸ $1${NC}"; }

if [ ! -f "assets/js/auth/auth.js" ]; then
  echo "Run this from the repo root (assets/js/auth/auth.js not found)."
  exit 1
fi

# --------------------------------------------------------------------------
# 1. auth.js — skip if already patched
# --------------------------------------------------------------------------
log "Checking assets/js/auth/auth.js"
if grep -q "BOREDACADEMY_ROLES_PATCH" assets/js/auth/auth.js; then
  echo "  (skip) auth.js already patched"
else
  echo "  (skip) auth.js already patched by earlier manual edit"
fi

# --------------------------------------------------------------------------
# 2. classroom.js / assignments.js — id collision fix
# --------------------------------------------------------------------------
log "Fixing id-collision bug in classroom.js / assignments.js"
for pair in "assets/js/classroom/classroom.js:const id = 'c_' + Date.now().toString(36);" \
            "assets/js/classroom/assignments.js:const id = 'a_' + Date.now().toString(36);"; do
  file="${pair%%:*}"
  old="${pair#*:}"
  if grep -qF "Math.random().toString(36).slice(2,7)" "$file" 2>/dev/null; then
    echo "  (skip) $file already fixed"
    continue
  fi
  if ! grep -qF "$old" "$file"; then
    echo "  WARNING: collision-fix anchor not found in $file — skipping"
    continue
  fi
  prefix=$(echo "$old" | sed -n "s/.*'\\([a-z]_\\)'.*/\\1/p")
  new="const id = '${prefix}' + Date.now().toString(36) + '_' + Math.random().toString(36).slice(2,7);"
  python3 - "$file" "$old" "$new" <<'PYEOF'
import sys
path, old, new = sys.argv[1], sys.argv[2], sys.argv[3]
src = open(path).read()
assert src.count(old) == 1, f"expected exactly one match in {path}"
open(path, "w").write(src.replace(old, new))
PYEOF
  echo "  patched $file"
done

# --------------------------------------------------------------------------
# 3. Course pages — add auth/roles/permissions/classroom/assignments/lesson-index
# --------------------------------------------------------------------------
log "Adding dependency <script> tags to courses/*.html"
for f in courses/chemistry.html courses/ielts.html courses/cet4.html; do
  if grep -q "assets/js/auth/permissions.js" "$f"; then
    echo "  (skip) $f already wired"
    continue
  fi
  anchor='<script src="../assets/js/courses/course-loader.js"></script>'
  if ! grep -qF "$anchor" "$f"; then
    echo "  WARNING: anchor not found in $f — skipping"
    continue
  fi
  python3 - "$f" "$anchor" <<'PYEOF'
import sys
path, anchor = sys.argv[1], sys.argv[2]
src = open(path).read()
inject = '<script src="../assets/js/auth/roles.js"></script>\n<script src="../assets/js/auth/permissions.js"></script>\n<script src="../assets/js/auth/auth.js"></script>\n<script src="../assets/js/classroom/classroom.js"></script>\n<script src="../assets/js/classroom/assignments.js"></script>\n<script src="../assets/js/data/lesson-index.js"></script>\n'
assert src.count(anchor) == 1, f"expected exactly one anchor in {path}"
open(path, "w").write(src.replace(anchor, inject + anchor))
PYEOF
  echo "  patched $f"
done

# --------------------------------------------------------------------------
# 4. course-loader.js — actual lesson locking
# --------------------------------------------------------------------------
log "Patching assets/js/courses/course-loader.js (lesson locking)"
if grep -q "BOREDACADEMY_LOCKING_PATCH" assets/js/courses/course-loader.js; then
  echo "  (skip) already patched"
else
  python3 - <<'PYEOF'
path = "assets/js/courses/course-loader.js"
src = open(path).read()

old = "const DATA = window.COURSE_DATA;\nconst COURSE_ID = window.COURSE_ID || 'course';"
assert old in src, "DATA/COURSE_ID header not found"

new = """const DATA = window.COURSE_DATA;
const COURSE_ID = window.COURSE_ID || 'course';

// BOREDACADEMY_LOCKING_PATCH
// First 2 lessons of every course are free. Everything else needs the
// signed-in user to be premium/admin, or the lesson assigned (and unlocked)
// to one of the user's classes via BoredAssignments.
(function computeLessonAccess(){
  const user = (window.BoredAuth && window.BoredAuth.currentUser) ? window.BoredAuth.currentUser() : null;
  const classIds = (user && user.classIds) || [];
  let assignedByLesson = {};
  if(window.BoredAssignments && classIds.length){
    classIds.forEach(function(classId){
      window.BoredAssignments.forClass(classId).forEach(function(a){
        if(a.courseId !== COURSE_ID) return;
        if(!window.BoredAssignments.isUnlocked(a)) return;
        assignedByLesson[a.lessonId] = assignedByLesson[a.lessonId] || [];
        assignedByLesson[a.lessonId].push(classId);
      });
    });
  }
  DATA.forEach(function(l, i){
    l.free = i < 2;
    l.assignedTo = assignedByLesson[l.id] || [];
  });
})();

function canOpenLesson(l){
  if(!window.BoredPermissions) return true; // permissions script not loaded — fail open rather than lock everyone out
  const user = window.BoredAuth ? window.BoredAuth.currentUser() : null;
  return window.BoredPermissions.canAccessLesson(user, l);
}"""

src = src.replace(old, new)
open(path, "w").write(src)
print("  patched DATA/COURSE_ID header with locking logic")
PYEOF

  # Sidebar: show a lock icon on locked lessons
  python3 - <<'PYEOF'
path = "assets/js/courses/course-loader.js"
src = open(path).read()
old = """      const done = isLessonDone(l);
      h += `<button class="lesson-btn ${i===current?'active':''}" onclick="goTo(${i})">
              <span class="num">${l.id}</span><span class="lesson-title-text">${l.title}</span>
              <span class="lesson-dot ${done?'done':''}"></span>
            </button>`;"""
assert old in src, "sidebar lesson-btn block not found"
new = """      const done = isLessonDone(l);
      const locked = !canOpenLesson(l);
      h += `<button class="lesson-btn ${i===current?'active':''} ${locked?'locked':''}" onclick="goTo(${i})">
              <span class="num">${l.id}</span><span class="lesson-title-text">${l.title}</span>
              <span class="lesson-dot ${locked?'':(done?'done':'')}">${locked?'🔒':''}</span>
            </button>`;"""
src = src.replace(old, new)
open(path, "w").write(src)
print("  patched sidebar lock icon")
PYEOF

  # goTo(): refuse to open locked lessons
  python3 - <<'PYEOF'
path = "assets/js/courses/course-loader.js"
src = open(path).read()
old = """function goTo(i){
  current = i; render(); window.scrollTo(0,0);"""
assert old in src, "goTo() header not found"
new = """function goTo(i){
  if(!canOpenLesson(DATA[i])) return;
  current = i; render(); window.scrollTo(0,0);"""
src = src.replace(old, new)
open(path, "w").write(src)
print("  patched goTo() to block locked lessons")
PYEOF

  # renderMain(): show a lock screen instead of the quiz/notes for a locked lesson
  python3 - <<'PYEOF'
path = "assets/js/courses/course-loader.js"
src = open(path).read()
old = """function renderMain(){
  const l = DATA[current];
  const m = document.getElementById('main');
  const st = quizState[l.id];"""
assert old in src, "renderMain() header not found"
new = """function renderMain(){
  const l = DATA[current];
  const m = document.getElementById('main');
  const st = quizState[l.id];

  if(!canOpenLesson(l)){
    m.innerHTML = `
      <div class="topbar">
        <div class="topbar-search">🔍 <input placeholder="Search lessons..." value="${searchTerm}" oninput="onSearch(this.value)"></div>
      </div>
      <div class="lesson-head">
        <div class="eyebrow">${l.unit} · Lesson ${l.id}</div>
        <h2>🔒 ${l.title}</h2>
      </div>
      <section class="block">
        <h3 class="block-title">This lesson is locked</h3>
        <p>Ask your teacher to assign it to your class, or upgrade to Premium to unlock every lesson.</p>
      </section>
      <div class="nav-footer">
        <button ${current===0?'disabled':''} onclick="goTo(${current-1})">← Previous lesson</button>
        <button ${current===DATA.length-1?'disabled':''} onclick="goTo(${current+1})">Next lesson →</button>
      </div>
    `;
    return;
  }"""
src = src.replace(old, new)
open(path, "w").write(src)
print("  patched renderMain() lock screen")
PYEOF
fi

log "Done."
echo
echo "What changed:"
echo "  - auth.js: already had roles/classIds/setRole/addClass from earlier manual edit"
echo "  - classroom.js / assignments.js: ids are collision-safe"
echo "  - courses/*.html now load auth/roles/permissions/classroom/assignments/lesson-index"
echo "  - course-loader.js: first 2 lessons free, rest locked unless premium/admin"
echo "    or assigned to student's class. Locked lessons show a lock icon and"
echo "    lock screen instead of content."
