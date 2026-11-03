// Content for the home page. Edit here; courses and prices come from the
// database (Admin → Courses), everything else on the landing page lives below.

/** Classes start on this day. Shown in the announcement bar and hero. */
export const BATCH_START = new Date("2026-11-16T00:00:00+05:30");
export const BATCH_START_LABEL = "16 November";

/** Bihar Board Class 12 exams — expected first week of February 2027. */
export const EXAM_DATE = new Date("2027-02-01T09:30:00+05:30");

export const TEACHER = {
  name: "Ajit Sir",
  subjects: "Physics · Chemistry · Maths",
  years: 10,
  bio: "One teacher for all three subjects, so concepts connect across Physics, Chemistry and Maths. Ajit Sir records every class and takes every live doubt session himself.",
  /** Put a portrait at apps/web/public/images/ajit-sir.jpg and set this. */
  photo: "/images/ajit-sir.jpg" as string | null,
};

export const CONTACT = {
  address: ["Moldiyar Tola, near Gayatri Bhawan", "Mokama, Bihar 803302"],
  email: "support@abacademy.in",
  site: "abacademy.in",
};

/**
 * Whether the notes library is open. Off shows "Notes are coming soon"; set
 * NEXT_PUBLIC_NOTES_LIVE=true once the PDFs are uploaded in Admin → Content.
 */
export const NOTES_LIVE = process.env.NEXT_PUBLIC_NOTES_LIVE === "true";

/** Google Play listing. Every "Get it on Google Play" button hides until set. */
export const PLAY_STORE_URL = process.env.NEXT_PUBLIC_PLAY_STORE_URL ?? "";

export type SubjectKey = "Physics" | "Chemistry" | "Maths";

/** Class 12 Bihar Board chapters, in syllabus order. */
export const SYLLABUS: Record<SubjectKey, string[]> = {
  Physics: [
    "Electric Charges & Fields",
    "Electrostatic Potential",
    "Current Electricity",
    "Moving Charges & Magnetism",
    "Magnetism & Matter",
    "Electromagnetic Induction",
    "Alternating Current",
    "Electromagnetic Waves",
    "Ray Optics",
    "Wave Optics",
    "Dual Nature of Matter",
    "Atoms",
    "Nuclei",
    "Semiconductors",
  ],
  Chemistry: [
    "Solutions",
    "Electrochemistry",
    "Chemical Kinetics",
    "d- & f-Block Elements",
    "Coordination Compounds",
    "Haloalkanes & Haloarenes",
    "Alcohols, Phenols & Ethers",
    "Aldehydes & Ketones",
    "Amines",
    "Biomolecules",
  ],
  Maths: [
    "Relations & Functions",
    "Inverse Trigonometry",
    "Matrices",
    "Determinants",
    "Continuity & Differentiability",
    "Applications of Derivatives",
    "Integrals",
    "Applications of Integrals",
    "Differential Equations",
    "Vectors",
    "3D Geometry",
    "Linear Programming",
    "Probability",
  ],
};

export const TOTAL_CHAPTERS = Object.values(SYLLABUS).reduce((n, ch) => n + ch.length, 0);

/** The landing page's subject name for a course subject ("Mathematics" → "Maths"). */
export function subjectKey(subject: string): SubjectKey | null {
  if (subject === "Physics") return "Physics";
  if (subject === "Chemistry") return "Chemistry";
  if (subject === "Mathematics" || subject === "Maths") return "Maths";
  return null;
}

export const FEATURES = [
  ["Recorded classes", "Every chapter as a recorded class. Pause, rewind and rewatch as often as you need."],
  ["Live doubt sessions", "Bring your questions to live sessions with Ajit Sir and get them solved on the spot."],
  ["Chapter notes", "A notes PDF for every chapter, readable on the website and in the app."],
  ["Board-pattern tests", "Practice questions in Bihar Board pattern so the exam has no surprises."],
] as const;

export const FAQS = [
  ["Is it in Hindi or Hinglish?", "You choose. Every course is taught in Hindi or in Hinglish (Hindi with English terms) — pick your language when you enroll."],
  ["When do classes start?", "Monday, 16 November 2026. Enrol before then and the first classes are waiting in your account on day one."],
  ["Are classes live or recorded?", "Classes are recorded so you can watch at your own time and rewatch anytime. Doubts are solved live in regular doubt sessions."],
  ["Where do I ask doubts?", "Under each lecture. Your question goes to the teacher’s doubt queue and you get a notification when it is answered."],
  ["How do I pay?", "UPI, cards or netbanking through Razorpay. The course unlocks on your account as soon as payment goes through."],
  ["Can I study on my phone?", "Yes. The app uses the same account as the website. Sign in with Google and your courses, notes and doubt sessions are there."],
  ["How much does a course cost?", "Each subject is a separate crash course. Take Physics, Chemistry or Maths on its own, or all three."],
  ["Is anything free?", "A free demo course and chapter notes. Create an account, no payment needed."],
] as const;

export const FREE_NOTES = [
  { subject: "Physics", title: "Electric Charges & Fields" },
  { subject: "Chemistry", title: "Solutions" },
  { subject: "Maths", title: "Matrices" },
  { subject: "Physics", title: "Current Electricity" },
];

export const FOUNDERS = [
  { name: "Ajit Sir", role: "Founder", photo: "/images/ajit-sir.jpg" as string | null },
  { name: "Sriram", role: "Co-founder & Developer", photo: null as string | null },
];

/**
 * Social profiles for the footer. An icon shows only once its link is set.
 * WhatsApp falls back to NEXT_PUBLIC_WHATSAPP_NUMBER (see lib/support.ts).
 */
export const SOCIAL_LINKS = {
  youtube: "",
  instagram: "",
  whatsapp: "",
  linkedin: "",
};

/**
 * Real board results and student quotes. Each section stays hidden while its
 * list is empty — add entries only with the student's permission.
 */
export const RESULTS: { score: string; name: string; meta: string }[] = [];
/**
 * Real student reviews only. The scrolling reviews strip on the home page
 * stays hidden while this is empty. `rating` (1–5) shows stars when given.
 * Example: { text: "…", name: "Priya K.", meta: "Class 12 · Physics", rating: 5 }
 */
export const QUOTES: { text: string; name: string; meta: string; rating?: number }[] = [];

/** Screenshot of the app's home screen, shown in "The app" section. */
export const APP_SCREENSHOT = "/images/app-home.png";

/** Whether the batch has begun (server time). */
export function batchStarted() {
  return Date.now() >= BATCH_START.getTime();
}
