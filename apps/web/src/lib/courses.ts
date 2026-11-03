export type CourseClass = 9 | 10 | 11 | 12;

export type CurriculumLesson = {
  title: string;
  duration: string;
  hasNotes?: boolean;
};

export type CurriculumChapter = {
  title: string;
  lectures: number;
  notes: number;
  lessons: CurriculumLesson[];
};

export type Course = {
  id?: string;
  slug: string;
  title: string;
  classLevel: CourseClass;
  board: string;
  subjects: string[];
  /** Short stream label shown on thumbnails, e.g. "Science · PCM + PCB". */
  stream?: string;
  teacher: string;
  teacherTitle?: string;
  teacherBio?: string;
  language: string;
  price: number;
  originalPrice?: number;
  rating: number;
  reviewCount?: number;
  lessons: number;
  chapters?: number;
  questions?: number;
  description: string;
  hindiBlurb?: string;
  highlights: string[];
  deliverables?: { title: string; body: string }[];
  curriculum?: CurriculumChapter[];
  /** Which subject the curriculum preview covers, e.g. "Physics". */
  curriculumSubject?: string;
  batch: string;
  validity?: string;
  tagline?: string;
  badge?: string;
  thumbnailHue: number;
  isPublished?: boolean;
  bestseller?: boolean;
};

/** Every crash course runs on the same 90-day board plan. */
export const CRASH_COURSE_DAYS = 90;

export const classes = [
  {
    level: 12 as const,
    title: "Class 12",
    tagline: "Board 2027 crash courses",
  },
  {
    level: 11 as const,
    title: "Class 11",
    tagline: "Build a strong base for Class 12",
  },
];

export const subjectFilters = [
  "Physics",
  "Chemistry",
  "Mathematics",
  "Biology",
  "Accountancy",
  "Business Studies",
  "Economics",
  "History",
  "Political Science",
  "Geography",
];

export const courseFaqs = [
  {
    q: "What is the medium of teaching?",
    a: "Most batches are bilingual (Hindi + English). Check each course page for the exact medium.",
  },
  {
    q: "Can I download lectures?",
    a: "Recordings stay inside your enrolled classroom. Offline download for selected content will roll out based on licensing.",
  },
  {
    q: "When can I watch the lectures?",
    a: "Anytime. Every lecture is recorded, so you can watch, pause and rewatch at your own pace on the website or the app.",
  },
  {
    q: "Will this work for boards beyond Bihar Board?",
    a: "We are launching with Bihar Board first. More boards and domain courses will be added under AB Academy soon.",
  },
  {
    q: "How do refunds work?",
    a: "Refund rules will be published with payments. Until then, contact support before enrolling if you need clarity.",
  },
  {
    q: "Do I get notes and syllabus PDFs?",
    a: "Yes. Enrolled students get chapter notes and syllabus PDFs from the course classroom.",
  },
];

const standardDeliverables = (lectures: number, subjects: string) => [
  {
    title: `${lectures}+ recorded lectures`,
    body: `Every chapter of ${subjects}, recorded so you can learn at your own pace.`,
  },
  {
    title: "90-day board plan",
    body: "Chapter flow mapped to the Bihar Board pattern with weekly revision checkpoints.",
  },
  {
    title: "Practice & OMR-style drills",
    body: "Question banks and practice sets to build exam speed and accuracy.",
  },
  {
    title: "Hand-crafted notes",
    body: "PDF notes and important questions for quick revision before exams.",
  },
  {
    title: "Past paper discussions",
    body: "Walkthroughs of previous patterns so students know what examiners expect.",
  },
  {
    title: "Doubt-clearing support",
    body: "Ask a doubt under any lecture and a teacher replies."
  },
];

const physics12: CurriculumChapter[] = [
  {
    title: "Electric Charges and Fields",
    lectures: 5,
    notes: 2,
    lessons: [
      { title: "Coulomb's Law", duration: "22:10", hasNotes: true },
      { title: "Electric Field Lines", duration: "19:40", hasNotes: true },
      { title: "Gauss's Law", duration: "28:05" },
      { title: "Board Practice Set", duration: "30:40", hasNotes: true },
    ],
  },
  {
    title: "Electrostatic Potential and Capacitance",
    lectures: 5,
    notes: 2,
    lessons: [
      { title: "Potential due to a Point Charge", duration: "21:00", hasNotes: true },
      { title: "Capacitors in Series and Parallel", duration: "26:15" },
    ],
  },
  {
    title: "Current Electricity",
    lectures: 6,
    notes: 3,
    lessons: [
      { title: "Ohm's Law and Resistivity", duration: "20:30", hasNotes: true },
      { title: "Kirchhoff's Rules", duration: "27:00" },
    ],
  },
  {
    title: "Moving Charges and Magnetism",
    lectures: 4,
    notes: 2,
    lessons: [
      { title: "Biot–Savart Law", duration: "23:45", hasNotes: true },
      { title: "Ampere's Circuital Law", duration: "24:10" },
    ],
  },
];

// The three launch courses, matched to the database by slug (see catalog.ts).
// Price, title, description and publishing come from the database; this adds
// the presentation it does not store.
const ajit = {
  teacher: "Ajit Sir",
  teacherTitle: "Physics · Chemistry · Maths",
  teacherBio:
    "One teacher for all three subjects, so concepts connect across Physics, Chemistry and Maths. Ajit Sir records every class and takes every live doubt session himself.",
};

export const courses: Course[] = [
  {
    slug: "class-12-physics-crash-course",
    title: "Class 12 Physics Crash Course",
    classLevel: 12,
    board: "Bihar Board",
    subjects: ["Physics"],
    stream: "Physics",
    ...ajit,
    language: "Hindi + English",
    price: 249,
    rating: 0,
    lessons: 14,
    batch: "Board 2027 Batch",
    validity: "Until 31 March 2027",
    tagline: "14 chapters · Board pattern",
    thumbnailHue: 20,
    description:
      "Every Class 12 Physics chapter as a recorded class, with live doubt sessions, chapter notes and board-pattern questions.",
    highlights: [
      "Recorded class for every chapter",
      "Live doubt sessions with Ajit Sir",
      "Chapter notes PDF",
      "Board-pattern questions",
    ],
    deliverables: standardDeliverables(14, "Physics"),
    curriculum: physics12,
    curriculumSubject: "Physics",
  },
  {
    slug: "class-12-chemistry-crash-course",
    title: "Class 12 Chemistry Crash Course",
    classLevel: 12,
    board: "Bihar Board",
    subjects: ["Chemistry"],
    stream: "Chemistry",
    ...ajit,
    language: "Hindi + English",
    price: 249,
    rating: 0,
    lessons: 10,
    batch: "Board 2027 Batch",
    validity: "Until 31 March 2027",
    tagline: "10 chapters · Board pattern",
    thumbnailHue: 150,
    description:
      "Every Class 12 Chemistry chapter as a recorded class, with live doubt sessions, chapter notes and board-pattern questions.",
    highlights: [
      "Recorded class for every chapter",
      "Live doubt sessions with Ajit Sir",
      "Chapter notes PDF",
      "Board-pattern questions",
    ],
    deliverables: standardDeliverables(10, "Chemistry"),
  },
  {
    slug: "class-12-maths-crash-course",
    title: "Class 12 Maths Crash Course",
    classLevel: 12,
    board: "Bihar Board",
    subjects: ["Mathematics"],
    stream: "Maths",
    ...ajit,
    language: "Hindi + English",
    price: 249,
    rating: 0,
    lessons: 13,
    batch: "Board 2027 Batch",
    validity: "Until 31 March 2027",
    tagline: "13 chapters · Board pattern",
    thumbnailHue: 270,
    description:
      "Every Class 12 Maths chapter as a recorded class, with live doubt sessions, chapter notes and board-pattern questions.",
    highlights: [
      "Recorded class for every chapter",
      "Live doubt sessions with Ajit Sir",
      "Chapter notes PDF",
      "Board-pattern questions",
    ],
    deliverables: standardDeliverables(13, "Maths"),
  },
];

export function getCourse(slug: string) {
  return courses.find((course) => course.slug === slug);
}

export function getCoursesByClass(classLevel?: number) {
  if (!classLevel) return courses;
  return courses.filter((course) => course.classLevel === classLevel);
}

export function formatInr(amount: number) {
  return new Intl.NumberFormat("en-IN", {
    style: "currency",
    currency: "INR",
    maximumFractionDigits: 0,
  }).format(amount);
}

export function discountPercent(price: number, original?: number) {
  if (!original || original <= price) return 0;
  return Math.round(((original - price) / original) * 100);
}

/** CSS gradient used for course thumbnails, derived from the course hue. */
// Warm "Saffron & Ink" thumbnail colours. A course's stored hue picks one, so
// each course keeps a stable colour of its own (same mapping as the app).
const THUMBNAIL_PAIRS = [
  ["#e8742a", "#b4521a"], // saffron
  ["#6b7b3a", "#4a5628"], // olive
  ["#1c7c70", "#0f5a50"], // teal
  ["#3a342d", "#1c1814"], // coal
  ["#7a3e8e", "#55286a"], // plum
  ["#c8573a", "#8f3a22"], // terracotta
];

/** Bundled subject art for single-subject PCM courses and the free demo. */
export function courseArt(course: Pick<Course, "subjects" | "price">): string | null {
  if (course.price === 0) return "/images/courses/demo.png";
  if (course.subjects.length !== 1) return null;
  const s = course.subjects[0].toLowerCase();
  if (s === "physics") return "/images/courses/physics.png";
  if (s === "chemistry") return "/images/courses/chemistry.png";
  if (s === "mathematics" || s === "maths") return "/images/courses/maths.png";
  return null;
}

export function thumbnailGradient(hue: number) {
  const [a, b] = THUMBNAIL_PAIRS[Math.floor((((hue % 360) + 360) % 360) / 60)];
  return `linear-gradient(145deg, ${a}, ${b})`;
}

export function initials(name: string) {
  return name
    .split(/\s+/)
    .filter(Boolean)
    .map((part) => part[0])
    .join("")
    .slice(0, 2)
    .toUpperCase();
}
