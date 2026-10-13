import type {
  AdminCourse,
  AdminNotification,
  AdminSession,
  AdminTicket,
  AudienceKind,
  TicketStatus,
} from "./types";

// In-memory store for the admin console. Writes persist for the life of the
// server process, which is enough for the forms to feel real before Supabase is
// wired up. `lib/courses.ts` holds the public catalog mock the same way.

let courses: AdminCourse[] = [
  {
    id: "class-10-complete-batch",
    courseCode: "ABA-C-K7Q2MX",
    title: "Class 10 Complete Batch",
    classLevel: 10,
    board: "Bihar Board",
    medium: "Hindi",
    priceInr: 2999,
    originalPriceInr: 4999,
    subjects: ["Mathematics", "Science", "Hindi", "English", "Social Science"],
    teachers: ["Amit Sir", "Neha Ma'am"],
    description: "Full Class 10 syllabus with live classes, recordings and notes.",
    highlights: ["Live classes", "Chapter notes"],
    thumbnailUrl: null,
    isPublished: true,
    enrolledCount: 327,
  },
  {
    id: "mathematics-board-booster",
    courseCode: "ABA-C-P4H9TR",
    title: "Mathematics Board Booster",
    classLevel: 10,
    board: "Bihar Board",
    medium: "Hindi",
    priceInr: 1499,
    originalPriceInr: 2499,
    subjects: ["Mathematics"],
    teachers: ["Amit Sir"],
    description: "Board-pattern Mathematics revision with solved papers.",
    highlights: ["Solved board papers"],
    thumbnailUrl: null,
    isPublished: true,
    enrolledCount: 184,
  },
  {
    id: "class-12-science-batch",
    courseCode: "ABA-C-W3N8ZD",
    title: "Class 12 Science Batch",
    classLevel: 12,
    board: "Bihar Board",
    medium: "English",
    priceInr: 3499,
    originalPriceInr: 5499,
    subjects: ["Physics", "Chemistry", "Biology", "Mathematics"],
    teachers: ["Ravi Sir"],
    description: "",
    highlights: [],
    thumbnailUrl: null,
    isPublished: false,
    enrolledCount: 0,
  },
];

let sessions: AdminSession[] = [
  {
    id: "live-quadratic",
    title: "Quadratic Equations",
    courseId: "class-10-complete-batch",
    subject: "Mathematics",
    teacher: "Amit Sir",
    startsAt: "2026-09-17T18:00",
    durationMinutes: 60,
    status: "live",
  },
  {
    id: "live-trigonometry",
    title: "Trigonometry",
    courseId: "mathematics-board-booster",
    subject: "Mathematics",
    teacher: "Amit Sir",
    startsAt: "2026-09-17T20:00",
    durationMinutes: 60,
    status: "scheduled",
  },
  {
    id: "live-carbon",
    title: "Carbon and its Compounds",
    courseId: "class-10-complete-batch",
    subject: "Science",
    teacher: "Neha Ma'am",
    startsAt: "2026-09-18T17:00",
    durationMinutes: 75,
    status: "scheduled",
  },
  {
    id: "live-real-numbers",
    title: "Real Numbers — doubt session",
    courseId: "class-10-complete-batch",
    subject: "Mathematics",
    teacher: "Amit Sir",
    startsAt: "2026-09-16T18:00",
    durationMinutes: 58,
    status: "ended",
  },
];

let notifications: AdminNotification[] = [
  {
    id: "n-1",
    title: "Live class starting soon",
    body: "Mathematics starts in 5 minutes.",
    audienceKind: "course",
    audienceValue: "class-10-complete-batch",
    sentAt: "2026-09-16T17:55",
    sentBy: "Amit Sir",
  },
  {
    id: "n-2",
    title: "Test reminder",
    body: "Your Physics test is due today.",
    audienceKind: "class",
    audienceValue: "10",
    sentAt: "2026-09-16T09:00",
    sentBy: "Admin",
  },
  {
    id: "n-3",
    title: "New notes uploaded",
    body: "Chapter 04 notes — Carbon and its Compounds.",
    audienceKind: "all",
    audienceValue: null,
    sentAt: "2026-09-15T14:20",
    sentBy: "Neha Ma'am",
  },
];

let tickets: AdminTicket[] = [
  {
    id: "t1",
    reference: "ABA-T-1042",
    subject: "Payment deducted but course not unlocked",
    category: "Payment",
    status: "in_progress",
    studentName: "Rahul Kumar",
    openedAt: "2026-09-15T11:20",
    messages: [
      {
        id: "tm1",
        body: "I paid ₹2,999 by UPI yesterday but the Class 10 batch still shows as locked.",
        fromSupport: false,
        authorName: "Rahul Kumar",
        at: "2026-09-15T11:20",
      },
      {
        id: "tm2",
        body: "Thanks for writing in Rahul. We can see the payment and are reconciling it with the bank.",
        fromSupport: true,
        authorName: "Support · Kavita",
        at: "2026-09-16T09:40",
      },
    ],
  },
  {
    id: "t2",
    reference: "ABA-T-1017",
    subject: "Video keeps buffering on mobile data",
    category: "Technical",
    status: "resolved",
    studentName: "Priya Sharma",
    openedAt: "2026-09-10T18:05",
    messages: [
      {
        id: "tm3",
        body: "Lectures buffer constantly on 4G but work on wifi.",
        fromSupport: false,
        authorName: "Priya Sharma",
        at: "2026-09-10T18:05",
      },
      {
        id: "tm4",
        body: "Set Video Quality to 480p for mobile data, and download lessons overnight on wifi.",
        fromSupport: true,
        authorName: "Support · Manish",
        at: "2026-09-12T10:15",
      },
    ],
  },
  {
    id: "t3",
    reference: "ABA-T-1051",
    subject: "Cannot see my course after signing in",
    category: "Account",
    status: "open",
    studentName: "Ankit Kumar",
    openedAt: "2026-09-17T08:10",
    messages: [
      {
        id: "tm5",
        body: "I enrolled yesterday but the course does not appear in my app.",
        fromSupport: false,
        authorName: "Ankit Kumar",
        at: "2026-09-17T08:10",
      },
    ],
  },
];

/** Local "YYYY-MM-DDTHH:mm" — seeded rows use local time, so new rows must too,
 *  otherwise a just-sent notification sorts below older ones. */
const localStamp = () => {
  const now = new Date();
  const offset = now.getTimezoneOffset() * 60_000;
  return new Date(now.getTime() - offset).toISOString().slice(0, 16);
};

const slugify = (value: string) =>
  value
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/(^-|-$)/g, "");

// ------------------------------------------------------------------- reads

export const listCourses = () => [...courses];
export const getCourse = (id: string) => courses.find((c) => c.id === id) ?? null;
export const listSessions = () =>
  [...sessions].sort((a, b) => a.startsAt.localeCompare(b.startsAt));
export const listNotifications = () =>
  [...notifications].sort((a, b) => b.sentAt.localeCompare(a.sentAt));
export const listTickets = () => [...tickets];
export const getTicket = (id: string) => tickets.find((t) => t.id === id) ?? null;


export const dashboardCounts = () => ({
  courses: courses.length,
  publishedCourses: courses.filter((c) => c.isPublished).length,
  students: courses.reduce((sum, c) => sum + c.enrolledCount, 0),
  upcomingSessions: sessions.filter((s) => s.status !== "ended").length,
  openTickets: tickets.filter((t) => t.status === "open" || t.status === "in_progress").length,
  notificationsSent: notifications.length,
});

// ------------------------------------------------------------------ writes

export function saveCourse(
  input: Omit<AdminCourse, "id" | "courseCode" | "enrolledCount" | "thumbnailUrl"> & {
    id?: string;
    thumbnailUrl?: string | null;
  },
) {
  if (input.id) {
    courses = courses.map((c) =>
      c.id === input.id
        ? { ...c, ...input, thumbnailUrl: input.thumbnailUrl ?? c.thumbnailUrl, id: c.id }
        : c,
    );
    return input.id;
  }
  const id = slugify(input.title) || `course-${courses.length + 1}`;
  const courseCode = `ABA-C-${Math.random().toString(36).slice(2, 8).toUpperCase()}`;
  courses = [
    ...courses,
    { ...input, thumbnailUrl: input.thumbnailUrl ?? null, id, courseCode, enrolledCount: 0 },
  ];
  return id;
}

export function deleteCourse(id: string) {
  courses = courses.filter((c) => c.id !== id);
  sessions = sessions.filter((s) => s.courseId !== id);
}

export function saveSession(input: Omit<AdminSession, "id" | "status"> & { id?: string }) {
  if (input.id) {
    sessions = sessions.map((s) => (s.id === input.id ? { ...s, ...input, id: s.id } : s));
    return input.id;
  }
  const id = `${slugify(input.title)}-${sessions.length + 1}`;
  sessions = [...sessions, { ...input, id, status: "scheduled" }];
  return id;
}

export function deleteSession(id: string) {
  sessions = sessions.filter((s) => s.id !== id);
}

export function sendNotification(input: {
  title: string;
  body: string;
  audienceKind: AudienceKind;
  audienceValue: string | null;
}) {
  const id = `n-${Date.now()}`;
  notifications = [
    {
      ...input,
      id,
      sentAt: localStamp(),
      sentBy: "Admin",
    },
    ...notifications,
  ];
  return id;
}

export function replyToTicket(ticketId: string, body: string) {
  tickets = tickets.map((ticket) =>
    ticket.id === ticketId
      ? {
          ...ticket,
          status: ticket.status === "open" ? "in_progress" : ticket.status,
          messages: [
            ...ticket.messages,
            {
              id: `tm-${Date.now()}`,
              body,
              fromSupport: true,
              authorName: "Support · Admin",
              at: localStamp(),
            },
          ],
        }
      : ticket,
  );
}

export function setTicketStatus(ticketId: string, status: TicketStatus) {
  tickets = tickets.map((t) => (t.id === ticketId ? { ...t, status } : t));
}
