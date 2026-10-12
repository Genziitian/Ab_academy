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
    q: "Are live classes mandatory?",
    a: "No. You can join live or watch the recording later from the same chapter.",
  },
  {
    q: "Will this work for boards beyond Bihar Board?",
    a: "We are launching with Bihar Board first. More boards and domain courses will be added under Akhand Bharat Academy soon.",
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
    title: `${lectures}+ live crash-course lectures`,
    body: `Daily live classes across ${subjects} with recordings for every chapter.`,
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
    body: "Ask doubts during live sessions and through classroom Q&A.",
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

const accountancy12: CurriculumChapter[] = [
  {
    title: "Partnership Fundamentals",
    lectures: 5,
    notes: 2,
    lessons: [
      { title: "Partnership Deed", duration: "21:30", hasNotes: true },
      { title: "Interest on Capital", duration: "25:10" },
    ],
  },
  {
    title: "Admission of a Partner",
    lectures: 6,
    notes: 2,
    lessons: [
      { title: "Goodwill Valuation", duration: "28:40", hasNotes: true },
      { title: "Revaluation Account", duration: "24:00" },
    ],
  },
  {
    title: "Company Accounts — Shares",
    lectures: 5,
    notes: 2,
    lessons: [
      { title: "Issue of Shares", duration: "26:20", hasNotes: true },
      { title: "Forfeiture and Reissue", duration: "29:05" },
    ],
  },
];

const history12: CurriculumChapter[] = [
  {
    title: "Bricks, Beads and Bones",
    lectures: 4,
    notes: 2,
    lessons: [
      { title: "The Harappan Civilisation", duration: "24:30", hasNotes: true },
      { title: "Map Work — Harappan Sites", duration: "18:15", hasNotes: true },
    ],
  },
  {
    title: "Kings, Farmers and Towns",
    lectures: 4,
    notes: 1,
    lessons: [
      { title: "Mauryan Empire", duration: "22:40", hasNotes: true },
      { title: "Answer-writing Practice", duration: "26:00" },
    ],
  },
];

const physics11: CurriculumChapter[] = [
  {
    title: "Units and Measurements",
    lectures: 3,
    notes: 1,
    lessons: [
      { title: "SI Units and Dimensions", duration: "20:10", hasNotes: true },
      { title: "Errors in Measurement", duration: "18:30" },
    ],
  },
  {
    title: "Motion in a Straight Line",
    lectures: 4,
    notes: 2,
    lessons: [
      { title: "Equations of Motion", duration: "24:00", hasNotes: true },
      { title: "Graphs and Numericals", duration: "27:20" },
    ],
  },
  {
    title: "Laws of Motion",
    lectures: 5,
    notes: 2,
    lessons: [
      { title: "Newton's Laws", duration: "23:50", hasNotes: true },
      { title: "Friction", duration: "21:15" },
    ],
  },
];

const accountancy11: CurriculumChapter[] = [
  {
    title: "Journal and Ledger",
    lectures: 4,
    notes: 2,
    lessons: [
      { title: "Rules of Debit and Credit", duration: "22:00", hasNotes: true },
      { title: "Posting to Ledger", duration: "25:30" },
    ],
  },
  {
    title: "Trial Balance",
    lectures: 3,
    notes: 1,
    lessons: [
      { title: "Preparing a Trial Balance", duration: "23:40", hasNotes: true },
    ],
  },
];

export const courses: Course[] = [
  {
    slug: "class-12-science-crash-course-2027",
    title: "Class 12 Science Crash Course 2027",
    classLevel: 12,
    board: "Bihar Board",
    subjects: ["Physics", "Chemistry", "Mathematics", "Biology"],
    stream: "Science · PCM + PCB",
    teacher: "Senior Faculty",
    teacherTitle: "PCM / PCB Mentors",
    teacherBio:
      "Subject specialists for Physics, Chemistry, Mathematics and Biology, teaching to the Bihar Board Class 12 pattern.",
    language: "Hindi + English",
    price: 2499,
    originalPrice: 4999,
    rating: 4.8,
    reviewCount: 1260,
    lessons: 120,
    questions: 3000,
    batch: "2027 Board Batch",
    validity: "Until 31 March 2027",
    tagline: "PCM + PCB · 90-day plan",
    badge: "Bestseller",
    thumbnailHue: 214,
    bestseller: true,
    hindiBlurb:
      "कक्षा 12 विज्ञान — 90 दिनों में पूरा सिलेबस, लाइव कक्षाएँ, रिकॉर्डिंग और नोट्स।",
    description:
      "Complete Class 12 Science revision in 90 days with live classes, chapter recordings, notes and board-pattern tests.",
    highlights: [
      "Live classes with expert teachers",
      "Recorded lectures you can revise anytime",
      "PDF notes for every chapter",
      "Weekly board-pattern tests",
    ],
    deliverables: standardDeliverables(
      120,
      "Physics, Chemistry, Maths and Biology",
    ),
    curriculum: physics12,
    curriculumSubject: "Physics",
  },
  {
    slug: "class-12-physics-crash-course",
    title: "Class 12 Physics Crash Course",
    classLevel: 12,
    board: "Bihar Board",
    subjects: ["Physics"],
    stream: "Physics",
    teacher: "Amit Sir",
    teacherTitle: "M.Sc. Physics · Lead Mentor",
    teacherBio:
      "Amit Sir focuses on concept clarity, derivations and numericals in the Bihar Board Class 12 pattern.",
    language: "Hindi",
    price: 999,
    originalPrice: 1799,
    rating: 4.9,
    reviewCount: 842,
    lessons: 48,
    questions: 1200,
    batch: "2027 Board Batch",
    validity: "Until 31 March 2027",
    tagline: "Full Physics syllabus",
    badge: "Top rated",
    thumbnailHue: 198,
    hindiBlurb:
      "इलेक्ट्रोस्टैटिक्स से सेमीकंडक्टर तक — बोर्ड पैटर्न पर आधारित भौतिकी क्रैश कोर्स।",
    description:
      "Electrostatics to Semiconductors with numericals, derivations and important board questions.",
    highlights: [
      "Chapter-wise live + recorded classes",
      "Important questions for board exams",
      "Formula sheets and PDF notes",
      "Progress tracking per chapter",
    ],
    deliverables: standardDeliverables(48, "every Physics chapter"),
    curriculum: physics12,
    curriculumSubject: "Physics",
  },
  {
    slug: "class-12-commerce-crash-course",
    title: "Class 12 Commerce Crash Course",
    classLevel: 12,
    board: "Bihar Board",
    subjects: ["Accountancy", "Business Studies", "Economics"],
    stream: "Commerce",
    teacher: "Ravi Sir",
    teacherTitle: "Commerce Faculty",
    teacherBio:
      "Ravi Sir teaches Accountancy, Business Studies and Economics with solved board papers and numerical drills.",
    language: "Hindi",
    price: 1999,
    originalPrice: 3499,
    rating: 4.7,
    reviewCount: 540,
    lessons: 90,
    questions: 1800,
    batch: "2027 Board Batch",
    validity: "Until 31 March 2027",
    tagline: "Accountancy · BST · Economics",
    badge: "Popular",
    thumbnailHue: 320,
    hindiBlurb:
      "कक्षा 12 वाणिज्य — लेखाशास्त्र, व्यवसाय अध्ययन और अर्थशास्त्र की तेज़ रिवीजन।",
    description:
      "Fast revision of Accountancy, Business Studies and Economics with solved board papers.",
    highlights: [
      "Numerical practice for Accountancy",
      "Chapter-wise recordings",
      "Study notes in Hindi",
      "Solved board papers",
    ],
    deliverables: standardDeliverables(
      90,
      "Accountancy, Business Studies and Economics",
    ),
    curriculum: accountancy12,
    curriculumSubject: "Accountancy",
  },
  {
    slug: "class-12-arts-crash-course",
    title: "Class 12 Arts Crash Course",
    classLevel: 12,
    board: "Bihar Board",
    subjects: ["History", "Political Science", "Geography"],
    stream: "Arts",
    teacher: "Faculty Team",
    teacherTitle: "Humanities Mentors",
    teacherBio:
      "A humanities team covering History, Political Science and Geography with map work and answer-writing practice.",
    language: "Hindi",
    price: 1799,
    originalPrice: 2999,
    rating: 4.6,
    reviewCount: 310,
    lessons: 80,
    questions: 1400,
    batch: "2027 Board Batch",
    validity: "Until 31 March 2027",
    tagline: "History · Pol. Science · Geography",
    badge: "New",
    thumbnailHue: 28,
    hindiBlurb:
      "कक्षा 12 कला — अध्याय सारांश, मानचित्र कार्य और उत्तर-लेखन अभ्यास।",
    description:
      "Chapter summaries, map work and answer-writing practice for Class 12 Arts boards.",
    highlights: [
      "Chapter summaries",
      "Map work practice",
      "Answer-writing sessions",
      "Hindi notes",
    ],
    deliverables: standardDeliverables(
      80,
      "History, Political Science and Geography",
    ),
    curriculum: history12,
    curriculumSubject: "History",
  },
  {
    slug: "class-11-science-crash-course",
    title: "Class 11 Science Crash Course",
    classLevel: 11,
    board: "Bihar Board",
    subjects: ["Physics", "Chemistry", "Mathematics", "Biology"],
    stream: "Science · PCM + PCB",
    teacher: "Neha Ma'am",
    teacherTitle: "Science Faculty",
    teacherBio:
      "Neha Ma'am builds Class 11 Science foundations so Class 12 and entrance prep feel manageable.",
    language: "Hindi + English",
    price: 1999,
    originalPrice: 3499,
    rating: 4.7,
    reviewCount: 420,
    lessons: 100,
    questions: 2200,
    batch: "2026–27 Session",
    validity: "Until 31 March 2027",
    tagline: "PCM + PCB · Strong base",
    badge: "Foundation",
    thumbnailHue: 162,
    hindiBlurb:
      "कक्षा 11 विज्ञान — कक्षा 12 और प्रवेश परीक्षा के लिए मज़बूत आधार।",
    description:
      "Cover Class 11 Science quickly so Class 12 and entrance prep feel manageable.",
    highlights: [
      "Concept-first teaching",
      "Numerical practice",
      "Chapter notes",
      "Live doubt sessions",
    ],
    deliverables: standardDeliverables(
      100,
      "Physics, Chemistry, Maths and Biology",
    ),
    curriculum: physics11,
    curriculumSubject: "Physics",
  },
  {
    slug: "class-11-commerce-crash-course",
    title: "Class 11 Commerce Crash Course",
    classLevel: 11,
    board: "Bihar Board",
    subjects: ["Accountancy", "Business Studies", "Economics"],
    stream: "Commerce",
    teacher: "Ravi Sir",
    teacherTitle: "Commerce Faculty",
    teacherBio:
      "Ravi Sir makes Class 11 Commerce concepts clear with numerical practice and Hindi notes.",
    language: "Hindi",
    price: 1499,
    originalPrice: 2499,
    rating: 4.5,
    reviewCount: 210,
    lessons: 72,
    questions: 900,
    batch: "2026–27 Session",
    validity: "Until 31 March 2027",
    tagline: "Accountancy · BST · Economics",
    badge: "New",
    thumbnailHue: 250,
    hindiBlurb:
      "कक्षा 11 वाणिज्य — संख्यात्मक अभ्यास और हिंदी नोट्स के साथ।",
    description:
      "Clear Class 11 Commerce concepts with numerical practice and Hindi notes.",
    highlights: [
      "Concept + numerical practice",
      "Chapter-wise recordings",
      "Study notes in Hindi",
      "Scheduled live classes",
    ],
    deliverables: standardDeliverables(
      72,
      "Accountancy, Business Studies and Economics",
    ),
    curriculum: accountancy11,
    curriculumSubject: "Accountancy",
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
export function thumbnailGradient(hue: number) {
  return `linear-gradient(145deg, hsl(${hue} 70% 48%), hsl(${hue + 22} 65% 34%))`;
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
