// Sample data for the web student portal. The mobile app already reads these
// domains from Supabase; until the portal is wired the same way, every page
// renders from here and the portal shows a "sample data" banner.

export type Tone = { bg: string; fg: string };

export const subjectTones: Record<string, Tone> = {
  Physics: { bg: "#e8f0ff", fg: "#2962ff" },
  Chemistry: { bg: "#e8fff6", fg: "#0f8f81" },
  Mathematics: { bg: "#f1ecff", fg: "#6b4fd8" },
  Biology: { bg: "#fff1e8", fg: "#c06a1a" },
  English: { bg: "#ffeef3", fg: "#c23a68" },
};

export function toneFor(subject: string): Tone {
  return subjectTones[subject] ?? { bg: "#f2f3f7", fg: "#4a5872" };
}

export const teachers = [
  { name: "Amit Sir", initials: "AS", subject: "Physics", years: 11 },
  { name: "Neha Ma'am", initials: "NM", subject: "Chemistry", years: 8 },
  { name: "Ravi Sir", initials: "RS", subject: "Mathematics", years: 9 },
];

// ---------------------------------------------------------------- courses

export type LessonKind = "done" | "current" | "live" | "notes";

export type PortalLesson = {
  id: string;
  title: string;
  meta: string;
  kind: LessonKind;
};

export type PortalChapter = {
  title: string;
  done: number;
  total: number;
  note?: string;
  lockedUntil?: string;
  lessons?: PortalLesson[];
};

export type EnrolledCourse = {
  id: string;
  slug: string;
  batch: string;
  title: string;
  pct: number;
  chaptersDone: number;
  chaptersTotal: number;
  next: string;
  lessons: number;
  notes: number;
  live: number;
  validity: string;
  subjects: string[];
};

export const enrolledCourses: EnrolledCourse[] = [
  {
    id: "science-12",
    slug: "class-12-science-crash-course-2027",
    batch: "BIHAR BOARD · 2027 BATCH",
    title: "Class 12 Science Crash Course",
    pct: 42,
    chaptersDone: 12,
    chaptersTotal: 28,
    next: "Next: Physics · Current Electricity",
    lessons: 156,
    notes: 38,
    live: 24,
    validity: "Access until 31 March 2027, including the full board revision series in January.",
    subjects: ["Physics", "Chemistry", "Mathematics", "Biology", "English"],
  },
  {
    id: "maths-booster",
    slug: "class-12-science-crash-course-2027",
    batch: "BIHAR BOARD · 2027 BATCH",
    title: "Mathematics Board Booster",
    pct: 65,
    chaptersDone: 13,
    chaptersTotal: 20,
    next: "Next: Integrals revision",
    lessons: 84,
    notes: 22,
    live: 16,
    validity: "Access until 31 March 2027.",
    subjects: ["Mathematics"],
  },
];

/** The chapter currently being studied, shared by My Courses and the lecture page. */
export const currentChapter: PortalChapter & { number: number; subject: string } = {
  number: 3,
  subject: "Physics",
  title: "Current Electricity",
  done: 2,
  total: 4,
  lessons: [
    { id: "current-electricity-1", title: "Class 1 · Electric Current and Drift Velocity", meta: "Recorded · 32 min", kind: "done" },
    { id: "current-electricity-2", title: "Class 2 · Ohm's Law and Resistivity", meta: "Recorded · 48 min", kind: "done" },
    { id: "current-electricity-3", title: "Class 3 · Kirchhoff's Rules", meta: "Recorded · 52 min · Resume at 38:14", kind: "current" },
    { id: "current-electricity-4", title: "Class 4 · Practice Session", meta: "LIVE · Today 6:00 PM", kind: "live" },
    { id: "current-electricity-notes", title: "Chapter 03 Notes", meta: "PDF · 2.4 MB", kind: "notes" },
  ],
};

export const physicsChapters: PortalChapter[] = [
  { title: "Electric Charges and Fields", done: 5, total: 5 },
  { title: "Electrostatic Potential and Capacitance", done: 5, total: 5 },
  currentChapter,
  { title: "Moving Charges and Magnetism", done: 0, total: 4 },
  { title: "Magnetism and Matter", done: 0, total: 3, note: "0 / 3 lessons · live this week" },
  { title: "Electromagnetic Induction", done: 0, total: 5, lockedUntil: "Unlocks 22 Oct" },
];

// ---------------------------------------------------------------- lecture

export type Lecture = {
  id: string;
  subject: string;
  chapterNumber: number;
  chapterTitle: string;
  title: string;
  teacher: { name: string; initials: string };
  rating: number;
  ratingCount: number;
  position: string;
  duration: string;
  progress: number;
  about: string;
  notes: { title: string; size: string }[];
  comments: {
    author: string;
    initials: string;
    body: string;
    time: string;
    replies: { author: string; initials: string; body: string; time: string }[];
  }[];
};

export const lectures: Record<string, Lecture> = {
  "current-electricity-3": {
    id: "current-electricity-3",
    subject: "Physics",
    chapterNumber: 3,
    chapterTitle: "Current Electricity",
    title: "Kirchhoff's Rules — Class 03",
    teacher: { name: "Amit Sir", initials: "AS" },
    rating: 4.6,
    ratingCount: 128,
    position: "38:14",
    duration: "52:00",
    progress: 73,
    about:
      "Kirchhoff's junction and loop rules, sign conventions, and solving two-loop circuits step by step. Includes four board-pattern numericals from the 2023 and 2024 Bihar Board papers.",
    notes: [
      { title: "Class 03 — worked examples", size: "PDF · 1.8 MB" },
      { title: "Current Electricity — formula sheet", size: "PDF · 1.1 MB" },
    ],
    comments: [
      {
        author: "Priya Sharma",
        initials: "PS",
        body: "Sir, in example 3 why do we take the current direction as clockwise in both loops?",
        time: "2h ago",
        replies: [
          {
            author: "Amit Sir",
            initials: "AS",
            body: "Good question Priya — the direction is only an assumption. If a current comes out negative, it simply flows the other way.",
            time: "1h ago",
          },
        ],
      },
      { author: "Ankit Kumar", initials: "AK", body: "धन्यवाद सर, अब समझ आ गया 🙏", time: "45m ago", replies: [] },
      {
        author: "You",
        initials: "RK",
        body: "Can we get more board-pattern questions on the Wheatstone bridge?",
        time: "20m ago",
        replies: [],
      },
    ],
  },
};

/**
 * A lecture by lesson id. Only Class 03 has full sample content; the other
 * recorded lessons in the chapter reuse it with their own title.
 */
export function getLecture(id: string): Lecture | null {
  if (lectures[id]) return lectures[id];
  const lesson = currentChapter.lessons?.find(
    (l) => l.id === id && (l.kind === "done" || l.kind === "current"),
  );
  if (!lesson) return null;
  const base = lectures["current-electricity-3"];
  const [, name = lesson.title] = lesson.title.split(" · ");
  const number = lesson.title.match(/Class (\d+)/)?.[1] ?? "";
  return {
    ...base,
    id,
    title: `${name} — Class ${number.padStart(2, "0")}`,
    position: "0:00",
    progress: lesson.kind === "done" ? 100 : base.progress,
  };
}

// ---------------------------------------------------------------- live

export type LiveSession = {
  when: string;
  title: string;
  subject: string;
  teacher: string;
  initials: string;
  chapter: string;
  meta: string;
};

export const liveNow = {
  subject: "Physics",
  chapter: "Chapter 03 · Current Electricity",
  title: "Physics — Current Electricity",
  teacher: "Amit Sir",
  initials: "AS",
  time: "Today · 6:00 PM",
  students: 327,
};

/** Today's next session; its countdown targets this hour in local time. */
export const nextUp = { title: "Electrochemistry", teacher: "Neha Ma'am", time: "Today 8:00 PM", hour: 20 };

export const upcomingSessions: LiveSession[] = [
  { when: "Today · 8:00 PM", title: "Electrochemistry", subject: "Chemistry", teacher: "Neha Ma'am", initials: "NM", chapter: "Chapter 02", meta: "327 enrolled" },
  { when: "Tomorrow · 5:00 PM", title: "Integrals — definite integrals", subject: "Mathematics", teacher: "Ravi Sir", initials: "RS", chapter: "Chapter 07", meta: "294 enrolled" },
  { when: "Thursday · 4:00 PM", title: "Reproduction in Organisms", subject: "Biology", teacher: "Neha Ma'am", initials: "NM", chapter: "Chapter 01", meta: "256 enrolled" },
];

export const pastSessions: LiveSession[] = [
  { when: "Yesterday · 6:00 PM", title: "Electrostatic Potential — doubt session", subject: "Physics", teacher: "Amit Sir", initials: "AS", chapter: "Chapter 02", meta: "58 min · 311 attended" },
  { when: "Last week · 5:00 PM", title: "Solutions — colligative properties", subject: "Chemistry", teacher: "Neha Ma'am", initials: "NM", chapter: "Chapter 01", meta: "1 h 04 min · 288 attended" },
];

export const classroom = {
  subject: "Physics",
  title: "Current Electricity",
  teacher: "Amit Sir",
  students: 327,
  slide: { index: 12, total: 24, heading: "Kirchhoff's Rules" },
  points: [
    "Junction rule: Σ I in = Σ I out",
    "Loop rule: Σ ΔV around a closed loop = 0",
    "Wheatstone bridge balances when P/Q = R/S",
  ],
  myNote: "Loop rule = energy conservation; junction rule = charge conservation.",
  chat: [
    { author: "Rahul", initials: "RK", body: "Sir please explain Question 5." },
    { author: "Priya", initials: "PS", body: "Will this come in board exam?" },
    { author: "Amit Sir", initials: "AS", body: "Yes Priya — 3 marks almost every year. Rahul, doing Q5 now.", teacher: true },
    { author: "Ankit", initials: "AK", body: "धन्यवाद सर 🙏" },
  ],
  questions: [
    { author: "Priya", initials: "PS", body: "Does the loop rule hold when there is a capacitor in the circuit?", meta: "Asked by Priya · 12 upvotes" },
    { author: "Rahul", initials: "RK", body: "Sir, will you share today's PDF?", meta: "Answered" },
  ],
};

// ---------------------------------------------------------------- schedule

export type AgendaKind = "live" | "recorded" | "test";

export type AgendaItem = {
  time: string;
  title: string;
  sub: string;
  kind: AgendaKind;
  joinable?: boolean;
};

/** Today's agenda; the calendar marks other days by offset from today. */
export const todayAgenda: AgendaItem[] = [
  { time: "6:00 PM", title: "Physics", sub: "Current Electricity · Amit Sir", kind: "live", joinable: true },
  { time: "8:00 PM", title: "Chemistry", sub: "Electrochemistry · Neha Ma'am", kind: "live" },
  { time: "9:00 PM", title: "Physics Test", sub: "15 questions · 30 min", kind: "test" },
];

export const calendarMarks: { offset: number; kind: AgendaKind; item: AgendaItem }[] = [
  { offset: -5, kind: "recorded", item: { time: "5:00 PM", title: "Physics", sub: "Recorded · 45 min", kind: "recorded" } },
  { offset: -2, kind: "live", item: { time: "6:00 PM", title: "Chemistry", sub: "Solutions · Neha Ma'am", kind: "live" } },
  { offset: 1, kind: "live", item: { time: "5:00 PM", title: "Mathematics", sub: "Integrals · Ravi Sir", kind: "live" } },
  { offset: 2, kind: "recorded", item: { time: "4:00 PM", title: "Biology", sub: "Recorded · 50 min", kind: "recorded" } },
  { offset: 4, kind: "test", item: { time: "11:00 AM", title: "Weekly Test", sub: "20 questions · Chapters 1–3", kind: "test" } },
  { offset: 7, kind: "live", item: { time: "6:00 PM", title: "Physics", sub: "Magnetism · Amit Sir", kind: "live" } },
  { offset: 10, kind: "recorded", item: { time: "5:00 PM", title: "Chemistry", sub: "Recorded · 40 min", kind: "recorded" } },
];

export const dashboardSchedule = [
  { time: "4:00 PM", title: "English Revision", sub: "Recorded · 45 min" },
  { time: "6:00 PM", title: "Physics", sub: "Current Electricity · Amit Sir", live: true },
  { time: "8:00 PM", title: "Chemistry", sub: "Electrochemistry · 52 min" },
];

// ---------------------------------------------------------------- library

export type Material = {
  id: string;
  title: string;
  subject: string;
  size: string;
  updated: string;
};

export const materials: Material[] = [
  { id: "m1", title: "Chapter 02 Notes — Electrochemistry", subject: "Chemistry", size: "PDF · 4.2 MB", updated: "Updated 10 Oct" },
  { id: "m2", title: "Current Electricity — formula sheet", subject: "Physics", size: "PDF · 1.1 MB", updated: "Updated 07 Oct" },
  { id: "m3", title: "Integrals — important questions", subject: "Mathematics", size: "PDF · 1.6 MB", updated: "Updated 05 Oct" },
  { id: "m4", title: "Reproduction in Organisms", subject: "Biology", size: "PDF · 2.8 MB", updated: "—" },
  { id: "m5", title: "English — Letter Writing formats", subject: "English", size: "PDF · 0.8 MB", updated: "—" },
  { id: "m6", title: "Class 03 — worked examples", subject: "Physics", size: "PDF · 1.8 MB", updated: "Updated 06 Oct" },
];

export type DownloadItem = {
  id: string;
  title: string;
  kind: "video" | "pdf";
  meta: string;
  downloading?: boolean;
  progress?: number;
};

export const downloads: DownloadItem[] = [
  { id: "d1", title: "Physics · Kirchhoff's Rules", kind: "video", meta: "52 min · 320 MB" },
  { id: "d2", title: "Chemistry · Electrochemistry", kind: "video", meta: "Downloading · 62% of 280 MB", downloading: true, progress: 62 },
  { id: "d3", title: "Current Electricity — formula sheet", kind: "pdf", meta: "1.1 MB" },
  { id: "d4", title: "Integrals — important questions", kind: "pdf", meta: "1.6 MB" },
];

// ---------------------------------------------------------------- account

export type NotificationKind = "live" | "test" | "recording" | "notes" | "result";

export type PortalNotification = {
  id: string;
  group: "Today" | "Yesterday" | "Earlier";
  title: string;
  body: string;
  kind: NotificationKind;
  time?: string;
  action?: { label: string; href: string };
  unread?: boolean;
};

export const notifications: PortalNotification[] = [
  { id: "n1", group: "Today", title: "Live class starting soon", body: "Physics starts in 5 minutes.", kind: "live", time: "5m", action: { label: "Join Class →", href: "/live/classroom" }, unread: true },
  { id: "n2", group: "Today", title: "Test reminder", body: "Your Physics test is due today.", kind: "test", time: "2h", unread: true },
  { id: "n3", group: "Yesterday", title: "New recording available", body: "Yesterday's Chemistry class recording is now available.", kind: "recording", action: { label: "Watch Now →", href: "/lecture/current-electricity-3" } },
  { id: "n4", group: "Yesterday", title: "New notes uploaded", body: "Chapter 02 notes — Electrochemistry.", kind: "notes" },
  { id: "n5", group: "Earlier", title: "Weekly test result", body: "Physics Weekly Test 06 — you scored 17 / 20.", kind: "result" },
];

export const unreadCount = notifications.filter((n) => n.unread).length;

export type TicketMessage = { body: string; time: string; support?: string };

export type Ticket = {
  reference: string;
  subject: string;
  category: string;
  status: "progress" | "resolved";
  opened: string;
  messages: TicketMessage[];
};

export const tickets: Ticket[] = [
  {
    reference: "ABA-T-1042",
    subject: "Payment deducted but course not unlocked",
    category: "Payment",
    status: "progress",
    opened: "Opened 2 days ago",
    messages: [
      { body: "I paid ₹2,499 by UPI yesterday but the Class 12 Science crash course still shows as locked. The amount has left my account.", time: "2 days ago" },
      { body: "Thanks for writing in Rahul. We can see the payment and are reconciling it with the bank. Your access will be unlocked within 24 hours.", time: "1 day ago", support: "Support · Kavita" },
    ],
  },
  {
    reference: "ABA-T-1017",
    subject: "Video keeps buffering on mobile data",
    category: "Technical",
    status: "resolved",
    opened: "Opened 1 week ago",
    messages: [
      { body: "Lectures buffer constantly on 4G but work on wifi.", time: "1 week ago" },
      { body: "Set Video Quality to 480p under Profile → Learning for mobile data, and download lessons overnight on wifi. Closing this — reopen if it persists.", time: "5 days ago", support: "Support · Manish" },
    ],
  },
];
