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
  batch: string;
  tagline?: string;
  badge?: string;
  thumbnailHue: number;
  isPublished?: boolean;
  bestseller?: boolean;
};

export const classes = [
  {
    level: 9 as const,
    title: "Class 9",
    tagline: "Strong foundations for the years ahead",
  },
  {
    level: 10 as const,
    title: "Class 10",
    tagline: "Board preparation with live guidance",
  },
  {
    level: 11 as const,
    title: "Class 11",
    tagline: "Stream-ready Science, Commerce & Arts",
  },
  {
    level: 12 as const,
    title: "Class 12",
    tagline: "Board + entrance focused batches",
  },
];

export const subjectFilters = [
  "Mathematics",
  "Science",
  "Social Science",
  "Hindi",
  "English",
  "Accountancy",
  "Business Studies",
  "Economics",
  "Physics",
  "Chemistry",
  "Biology",
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

const mathCurriculum: CurriculumChapter[] = [
  {
    title: "Real Numbers",
    lectures: 4,
    notes: 2,
    lessons: [
      { title: "Introduction", duration: "18:20", hasNotes: true },
      { title: "Euclid’s Division Lemma", duration: "24:10", hasNotes: true },
      { title: "Fundamental Theorem of Arithmetic", duration: "22:05" },
      { title: "Board Practice Set", duration: "30:40", hasNotes: true },
    ],
  },
  {
    title: "Polynomials",
    lectures: 5,
    notes: 2,
    lessons: [
      { title: "Zeros of a Polynomial", duration: "20:00", hasNotes: true },
      { title: "Division Algorithm", duration: "26:15" },
    ],
  },
  {
    title: "Pair of Linear Equations",
    lectures: 6,
    notes: 3,
    lessons: [
      { title: "Graphical Method", duration: "21:30", hasNotes: true },
      { title: "Substitution & Elimination", duration: "28:00" },
    ],
  },
  {
    title: "Quadratic Equations",
    lectures: 5,
    notes: 2,
    lessons: [
      { title: "Standard Form", duration: "19:45", hasNotes: true },
      { title: "Nature of Roots", duration: "23:10" },
    ],
  },
];

export const courses: Course[] = [
  {
    slug: "class-10-complete-batch-2027",
    title: "Class 10 Complete Batch 2027",
    classLevel: 10,
    board: "Bihar Board",
    subjects: ["Mathematics", "Science", "Hindi", "English", "Social Science"],
    teacher: "Faculty Team",
    teacherTitle: "Multi-subject mentors",
    teacherBio:
      "A coordinated faculty team covering all core Class 10 subjects with live classes, notes and revision plans.",
    language: "Hindi + English",
    price: 1999,
    originalPrice: 3499,
    rating: 4.8,
    reviewCount: 1260,
    lessons: 120,
    chapters: 48,
    questions: 2500,
    batch: "2027 Board Batch",
    tagline: "All 5 core subjects · Full syllabus",
    badge: "Bestseller",
    thumbnailHue: 214,
    bestseller: true,
    hindiBlurb:
      "कक्षा 10 के सभी विषयों की लाइव कक्षाएँ, रिकॉर्डिंग और नोट्स — एक ही बैच में।",
    description:
      "A complete Class 10 programme with live classes, recordings, notes and chapter-wise practice — currently aligned to Bihar Board.",
    highlights: [
      "Live classes with expert teachers",
      "Recorded lectures you can revise anytime",
      "PDF notes for every chapter",
      "Weekly doubt support and scheduled tests",
    ],
    deliverables: [
      {
        title: "120+ Live Interactive Lectures",
        body: "Scheduled live classes across all core subjects with recordings attached to each chapter.",
      },
      {
        title: "Board-aligned syllabus coverage",
        body: "Chapter flow mapped to the Class 10 board pattern with revision checkpoints.",
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
    ],
    curriculum: mathCurriculum,
  },
  {
    slug: "class-10-mathematics",
    title: "Class 10 Mathematics Complete Batch",
    classLevel: 10,
    board: "Bihar Board",
    subjects: ["Mathematics"],
    teacher: "Amit Sir",
    teacherTitle: "M.Sc. Mathematics · Lead Mentor",
    teacherBio:
      "Amit Sir focuses on concept clarity and board-oriented problem solving for Class 10 Mathematics.",
    language: "Hindi",
    price: 799,
    originalPrice: 1299,
    rating: 4.9,
    reviewCount: 842,
    lessons: 48,
    chapters: 18,
    questions: 1200,
    batch: "2027 Board Batch",
    tagline: "Full Mathematics syllabus",
    badge: "Full Syllabus",
    thumbnailHue: 198,
    hindiBlurb:
      "रियल नंबर्स से प्रॉबेबिलिटी तक — बोर्ड पैटर्न पर आधारित गणित बैच।",
    description:
      "Focused Mathematics batch covering Real Numbers to Probability with board-oriented problem solving.",
    highlights: [
      "Chapter-wise live + recorded classes",
      "Important questions for board exams",
      "Formula sheets and PDF notes",
      "Progress tracking per chapter",
    ],
    deliverables: [
      {
        title: "48+ live & recorded lectures",
        body: "Every chapter taught live with recordings for revision.",
      },
      {
        title: "NCERT + board practice",
        body: "Textbook flow plus exam-style numericals.",
      },
      {
        title: "Formula banks & notes",
        body: "Printable PDFs for last-minute revision.",
      },
      {
        title: "Weekly practice sets",
        body: "Timed practice to improve accuracy.",
      },
      {
        title: "Doubt desk",
        body: "Raise questions in live chat and classroom Q&A.",
      },
      {
        title: "Mobile + web access",
        body: "Learn on website now; Flutter app coming next.",
      },
    ],
    curriculum: mathCurriculum,
  },
  {
    slug: "class-10-science",
    title: "Class 10 Science",
    classLevel: 10,
    board: "Bihar Board",
    subjects: ["Physics", "Chemistry", "Biology", "Science"],
    teacher: "Priya Ma'am",
    teacherTitle: "Science Faculty",
    teacherBio:
      "Priya Ma'am teaches Physics, Chemistry and Biology with diagrams, numericals and board-focused revision.",
    language: "Hindi + English",
    price: 899,
    originalPrice: 1499,
    rating: 4.7,
    reviewCount: 610,
    lessons: 56,
    chapters: 16,
    questions: 900,
    batch: "2027 Board Batch",
    tagline: "Physics · Chemistry · Biology",
    badge: "Popular",
    thumbnailHue: 162,
    description:
      "Physics, Chemistry and Biology taught in a simple, exam-focused way with diagrams, notes and revision classes.",
    highlights: [
      "Concept-first teaching",
      "Diagram practice and numericals",
      "Chapter notes and PYQ discussions",
      "Live revision before exams",
    ],
    deliverables: [
      {
        title: "56+ science lectures",
        body: "Balanced coverage across Physics, Chemistry and Biology.",
      },
      {
        title: "Diagram & numerical drills",
        body: "Practice that matches board marking patterns.",
      },
      {
        title: "Chapter notes",
        body: "Clean PDFs for each unit.",
      },
      {
        title: "PYQ discussions",
        body: "Previous year themes explained in class.",
      },
      {
        title: "Live revision weeks",
        body: "Focused revision before exams.",
      },
      {
        title: "Doubt support",
        body: "Ask questions during live sessions.",
      },
    ],
    curriculum: [
      {
        title: "Chemical Reactions",
        lectures: 4,
        notes: 2,
        lessons: [
          { title: "Types of Reactions", duration: "22:00", hasNotes: true },
          { title: "Balancing Equations", duration: "18:40" },
        ],
      },
      {
        title: "Life Processes",
        lectures: 5,
        notes: 2,
        lessons: [
          { title: "Nutrition", duration: "25:10", hasNotes: true },
          { title: "Respiration", duration: "21:00" },
        ],
      },
    ],
  },
  {
    slug: "class-9-foundation",
    title: "Class 9 Foundation Batch",
    classLevel: 9,
    board: "Bihar Board",
    subjects: ["Mathematics", "Science", "English", "Hindi"],
    teacher: "Faculty Team",
    teacherTitle: "Foundation Mentors",
    language: "Hindi",
    price: 1499,
    originalPrice: 2499,
    rating: 4.6,
    reviewCount: 320,
    lessons: 90,
    chapters: 36,
    questions: 1500,
    batch: "2026–27 Session",
    tagline: "Foundation for Class 10",
    thumbnailHue: 250,
    description:
      "Build Class 9 foundations early so Class 10 feels manageable and confident.",
    highlights: [
      "Daily live classes for core subjects",
      "Recordings for missed sessions",
      "Homework worksheets and notes",
      "Clear weekly learning plan",
    ],
    deliverables: [
      {
        title: "90+ foundation classes",
        body: "Steady weekly rhythm across core subjects.",
      },
      {
        title: "Worksheets & notes",
        body: "Practice sheets after every major topic.",
      },
      {
        title: "Recorded backup",
        body: "Never miss a concept if you skip a live class.",
      },
      {
        title: "Weekly plan",
        body: "Students always know what to study next.",
      },
      {
        title: "Mentor check-ins",
        body: "Progress nudges through the classroom.",
      },
      {
        title: "Affordable pricing",
        body: "Designed for long-term foundation building.",
      },
    ],
  },
  {
    slug: "class-12-science-complete",
    title: "Class 12 Science Complete",
    classLevel: 12,
    board: "Bihar Board",
    subjects: ["Physics", "Chemistry", "Mathematics", "Biology"],
    teacher: "Senior Faculty",
    teacherTitle: "PCM / PCB Mentors",
    language: "English + Hindi",
    price: 3999,
    originalPrice: 5999,
    rating: 4.8,
    reviewCount: 540,
    lessons: 160,
    chapters: 40,
    questions: 3000,
    batch: "2027 Board Batch",
    tagline: "Board + entrance oriented",
    badge: "Advanced",
    thumbnailHue: 28,
    description:
      "Full Class 12 Science batch with board + entrance oriented practice.",
    highlights: [
      "Subject specialists for PCM/PCB",
      "Board pattern tests",
      "Notes and formula banks",
      "Live doubt sessions",
    ],
    deliverables: [
      {
        title: "160+ specialist lectures",
        body: "Deep coverage for board and entrance readiness.",
      },
      {
        title: "Formula banks",
        body: "Quick-reference sheets for Physics and Chemistry.",
      },
      {
        title: "Board pattern tests",
        body: "Timed assessments before exams.",
      },
      {
        title: "Live doubts",
        body: "Ask mentors during live windows.",
      },
      {
        title: "Chapter recordings",
        body: "Revise any topic on demand.",
      },
      {
        title: "Notes PDFs",
        body: "Downloadable study material per unit.",
      },
    ],
  },
  {
    slug: "class-11-commerce",
    title: "Class 11 Commerce Starter",
    classLevel: 11,
    board: "Bihar Board",
    subjects: ["Accountancy", "Business Studies", "Economics"],
    teacher: "Ravi Sir",
    teacherTitle: "Commerce Faculty",
    language: "Hindi",
    price: 1799,
    originalPrice: 2799,
    rating: 4.5,
    reviewCount: 210,
    lessons: 72,
    chapters: 24,
    questions: 800,
    batch: "2026–27 Session",
    tagline: "Accountancy · BST · Economics",
    thumbnailHue: 320,
    description:
      "Clear Accountancy, BST and Economics concepts with aligned lessons and notes.",
    highlights: [
      "Concept + numerical practice",
      "Chapter-wise recordings",
      "Study notes in Hindi",
      "Scheduled live classes",
    ],
    deliverables: [
      {
        title: "72+ commerce lectures",
        body: "Steady coverage of Accountancy, BST and Economics.",
      },
      {
        title: "Numerical practice",
        body: "Accountancy drills with worked examples.",
      },
      {
        title: "Hindi notes",
        body: "Clear notes for bilingual comfort.",
      },
      {
        title: "Live schedule",
        body: "Predictable weekly live classes.",
      },
      {
        title: "Recordings",
        body: "Catch up anytime from My Courses.",
      },
      {
        title: "Mentor support",
        body: "Doubt help during live sessions.",
      },
    ],
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
