// Master list of courses on offer. Each course with `available:true` and a
// `url` links to its own course page under /courses/. Courses without a url
// render as "Coming Soon" cards on the hub.
window.COURSES = [
  {
    id: "chemistry",
    icon: "flask",
    svgIcon: "flask",
    title: "Introduction to Chemistry",
    blurb: "Matter, atomic structure, states of matter and lab safety.",
    lessons: 20,
    available: true,
    url: "courses/chemistry.html"
  },
  {
    id: "ielts",
    icon: "mic",
    svgIcon: "mic",
    title: "IELTS Speaking (Band 5.5 → 7.5)",
    blurb: "Fluency formulas, vocabulary upgrades, grammar and Part 2 cue-card strategy.",
    lessons: 10,
    available: true,
    url: "courses/ielts.html"
  },
  {
    id: "cet4",
    icon: "pencil",
    svgIcon: "pencil",
    title: "CET-4 Master Course",
    blurb: "12-week exam prep: grammar, listening, reading, writing and translation for the CET-4.",
    lessons: 8,
    available: true,
    url: "courses/cet4.html"
  },
  {
    id: "physics",
    icon: "zap",
    svgIcon: "zap",
    title: "Physics",
    blurb: "Forces, motion, energy and electricity.",
    lessons: 0,
    available: false
  },
  {
    id: "maths",
    icon: "ruler",
    svgIcon: "ruler",
    title: "Mathematics",
    blurb: "Algebra, geometry, statistics and problem solving.",
    lessons: 0,
    available: false
  },
  {
    id: "geography",
    icon: "globe",
    svgIcon: "globe",
    title: "Geography",
    blurb: "Maps, climate, ecosystems and human geography.",
    lessons: 0,
    available: false
  },
  {
    id: "computer-science",
    icon: "monitor",
    svgIcon: "monitor",
    title: "Computer Science",
    blurb: "Algorithms, data structures and programming fundamentals.",
    lessons: 0,
    available: false
  }
];
