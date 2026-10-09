// Demo-mode data for the slice 4 domains (students, content library, doubt
// queue, popups, community threads). Same contract as mock-store.ts: writes
// persist for the life of the server process.
//
// With Supabase env vars set, `lib/admin/data.ts` never touches this file.

import { listCourses } from "./mock-store";
import type {
  AdminCommunityMessage,
  AdminDoubt,
  AdminLesson,
  AdminPopup,
  AdminStudent,
  PopupPlacement,
} from "./types";

const localStamp = (daysAgo = 0) => {
  const d = new Date(Date.now() - daysAgo * 86_400_000);
  return new Date(d.getTime() - d.getTimezoneOffset() * 60_000)
    .toISOString()
    .slice(0, 16);
};

let students: AdminStudent[] = [
  {
    id: "s-1",
    fullName: "Rahul Kumar",
    phone: "+919876543210",
    email: "rahul.k@example.in",
    classLevel: 10,
    board: "Bihar Board",
    medium: "Hindi",
    stream: null,
    school: "S.K. High School, Patna",
    role: "student",
    enrolledCourses: ["class-10-complete-batch"],
    createdAt: localStamp(42),
  },
  {
    id: "s-2",
    fullName: "Priya Sharma",
    phone: "+919812345678",
    email: "priya.s@example.in",
    classLevel: 10,
    board: "Bihar Board",
    medium: "English",
    stream: null,
    school: "Notre Dame Academy, Patna",
    role: "student",
    enrolledCourses: ["class-10-complete-batch", "mathematics-board-booster"],
    createdAt: localStamp(30),
  },
  {
    id: "s-3",
    fullName: "Ankit Kumar",
    phone: "+919700112233",
    email: null,
    classLevel: 12,
    board: "Bihar Board",
    medium: "Hindi",
    stream: "Science",
    school: "Govt. Boys High School, Gaya",
    role: "student",
    enrolledCourses: [],
    createdAt: localStamp(2),
  },
  {
    id: "s-4",
    fullName: "Sneha Verma",
    phone: "+919633445566",
    email: "sneha.v@example.in",
    classLevel: 9,
    board: "Bihar Board",
    medium: "Hindi",
    stream: null,
    school: "Rajkiya Madhya Vidyalaya, Muzaffarpur",
    role: "student",
    enrolledCourses: ["mathematics-board-booster"],
    createdAt: localStamp(11),
  },
];

let lessons: AdminLesson[] = [
  {
    id: "l-1",
    title: "Real Numbers — Euclid's division lemma",
    lessonType: "VIDEO",
    chapterId: "ch-1",
    chapterTitle: "Chapter 01 · Real Numbers",
    subjectName: "Mathematics",
    courseId: "class-10-complete-batch",
    courseTitle: "Class 10 Complete Batch",
    durationSeconds: 2940,
    videoProvider: "youtube",
    videoRef: "dQw4w9WgXcQ",
    storagePath: null,
    isDemo: true,
    isPublished: true,
    isDownloadable: false,
    sortOrder: 1,
    resources: [
      {
        id: "r-1",
        lessonId: "l-1",
        title: "Chapter 01 notes",
        resourceType: "PDF",
        storagePath: "lesson-notes/demo/chapter-01.pdf",
        sizeBytes: 1_240_000,
        isDownloadable: true,
      },
    ],
  },
  {
    id: "l-2",
    title: "Polynomials — zeroes and coefficients",
    lessonType: "VIDEO",
    chapterId: "ch-2",
    chapterTitle: "Chapter 02 · Polynomials",
    subjectName: "Mathematics",
    courseId: "class-10-complete-batch",
    courseTitle: "Class 10 Complete Batch",
    durationSeconds: 3180,
    videoProvider: "youtube",
    videoRef: "oHg5SJYRHA0",
    storagePath: null,
    isDemo: false,
    isPublished: true,
    isDownloadable: true,
    sortOrder: 2,
    resources: [],
  },
  {
    id: "l-3",
    title: "Carbon and its Compounds — recording",
    lessonType: "VIDEO",
    chapterId: "ch-3",
    chapterTitle: "Chapter 04 · Carbon and its Compounds",
    subjectName: "Science",
    courseId: "class-10-complete-batch",
    courseTitle: "Class 10 Complete Batch",
    durationSeconds: 4500,
    videoProvider: "storage",
    videoRef: null,
    storagePath: "lesson-videos/demo/carbon.mp4",
    isDemo: false,
    isPublished: false,
    isDownloadable: false,
    sortOrder: 3,
    resources: [
      {
        id: "r-2",
        lessonId: "l-3",
        title: "Carbon compounds — summary sheet",
        resourceType: "PDF",
        storagePath: "lesson-notes/demo/carbon-summary.pdf",
        sizeBytes: 820_000,
        isDownloadable: true,
      },
    ],
  },
];

let doubts: AdminDoubt[] = [
  {
    id: "d-1",
    body: "Sir, in Euclid's lemma why must r be strictly less than b? Please explain again.",
    lessonId: "l-1",
    lessonTitle: "Real Numbers — Euclid's division lemma",
    courseTitle: "Class 10 Complete Batch",
    authorName: "Rahul Kumar",
    isResolved: false,
    resolvedBy: null,
    createdAt: localStamp(1),
    replies: [],
  },
  {
    id: "d-2",
    body: "The audio cuts out around 22 minutes into the polynomials lecture.",
    lessonId: "l-2",
    lessonTitle: "Polynomials — zeroes and coefficients",
    courseTitle: "Class 10 Complete Batch",
    authorName: "Sneha Verma",
    isResolved: true,
    resolvedBy: "Support · Kavita",
    createdAt: localStamp(4),
    replies: [
      {
        id: "dr-1",
        body: "Thanks for flagging — the lecture has been re-uploaded with fixed audio.",
        authorName: "Support · Kavita",
        createdAt: localStamp(3),
        fromStaff: true,
      },
    ],
  },
  {
    id: "d-3",
    body: "Will the doubt session recording be uploaded for the Science chapter?",
    lessonId: "l-3",
    lessonTitle: "Carbon and its Compounds — recording",
    courseTitle: "Class 10 Complete Batch",
    authorName: "Priya Sharma",
    isResolved: false,
    resolvedBy: null,
    createdAt: localStamp(0),
    replies: [],
  },
];

let popups: AdminPopup[] = [
  {
    id: "p-1",
    title: "Board exam crash course — 40% off",
    body: "Revision batch for Class 10 starts Monday. Limited seats.",
    imagePath: null,
    imageUrl: null,
    ctaLabel: "See the batch",
    ctaUrl: "/course/class-10-complete-batch-2027",
    placement: "app_launch",
    audienceKind: "class",
    audienceValue: "10",
    isActive: true,
    startsAt: localStamp(3),
    endsAt: null,
    maxViewsPerStudent: 3,
    priority: 10,
    viewCount: 412,
    clickCount: 87,
    createdAt: localStamp(3),
  },
  {
    id: "p-2",
    title: "App update available",
    body: "Update for offline downloads and a faster video player.",
    imagePath: null,
    imageUrl: null,
    ctaLabel: null,
    ctaUrl: null,
    placement: "home",
    audienceKind: "all",
    audienceValue: null,
    isActive: false,
    startsAt: localStamp(20),
    endsAt: localStamp(10),
    maxViewsPerStudent: 1,
    priority: 0,
    viewCount: 1_903,
    clickCount: 0,
    createdAt: localStamp(20),
  },
];

const communityThreads: Record<string, AdminCommunityMessage[]> = {
  "class-10-complete-batch": [
    {
      id: "cm-1",
      body: "Welcome to the Class 10 batch! Live classes run 6pm Mon–Sat.",
      authorName: "Admin",
      pinned: true,
      createdAt: localStamp(30),
    },
    {
      id: "cm-2",
      body: "Same here. Sir explained it in the doubt session recording.",
      authorName: "Rahul Kumar",
      pinned: false,
      createdAt: localStamp(1),
    },
  ],
  "mathematics-board-booster": [
    {
      id: "cm-3",
      body: "Thank you sir!",
      authorName: "Sneha Verma",
      pinned: false,
      createdAt: localStamp(2),
    },
  ],
};

const slugify = (v: string) =>
  v.toLowerCase().replace(/[^a-z0-9]+/g, "-").replace(/(^-|-$)/g, "");

// -------------------------------------------------------------------- reads

export const listStudents = (search?: string, classLevel?: number) => {
  let rows = [...students];
  if (classLevel) rows = rows.filter((s) => s.classLevel === classLevel);
  if (search) {
    const q = search.toLowerCase();
    rows = rows.filter(
      (s) =>
        s.fullName.toLowerCase().includes(q) ||
        (s.phone ?? "").includes(q) ||
        (s.email ?? "").toLowerCase().includes(q),
    );
  }
  return rows.sort((a, b) => b.createdAt.localeCompare(a.createdAt));
};

export const getStudent = (id: string) =>
  students.find((s) => s.id === id) ?? null;

export const listLessons = (courseId?: string) =>
  [...lessons]
    .filter((l) => !courseId || l.courseId === courseId)
    .sort((a, b) => a.sortOrder - b.sortOrder);

export const listDoubts = (resolved?: boolean) =>
  [...doubts]
    .filter((d) => resolved === undefined || d.isResolved === resolved)
    .sort((a, b) => b.createdAt.localeCompare(a.createdAt));

export const getDoubt = (id: string) => doubts.find((d) => d.id === id) ?? null;

export const listPopups = () =>
  [...popups].sort(
    (a, b) => b.priority - a.priority || b.createdAt.localeCompare(a.createdAt),
  );

export const getPopup = (id: string) => popups.find((p) => p.id === id) ?? null;

export const listCommunityMessages = (courseId: string) =>
  [...(communityThreads[courseId] ?? [])].sort((a, b) =>
    b.createdAt.localeCompare(a.createdAt),
  );

export const extraCounts = () => ({
  students: students.length,
  openDoubts: doubts.filter((d) => !d.isResolved).length,
  activePopups: popups.filter((p) => p.isActive).length,
  lessons: lessons.length,
});

// ------------------------------------------------------------------- writes

export function saveStudent(input: {
  id: string;
  fullName: string;
  classLevel: number | null;
  medium: string | null;
  stream: string | null;
  school: string | null;
}) {
  students = students.map((s) => (s.id === input.id ? { ...s, ...input } : s));
}

export function enrollStudent(studentId: string, courseId: string) {
  students = students.map((s) =>
    s.id === studentId && !s.enrolledCourses.includes(courseId)
      ? { ...s, enrolledCourses: [...s.enrolledCourses, courseId] }
      : s,
  );
}

export function unenrollStudent(studentId: string, courseId: string) {
  students = students.map((s) =>
    s.id === studentId
      ? { ...s, enrolledCourses: s.enrolledCourses.filter((c) => c !== courseId) }
      : s,
  );
}

export function saveLesson(input: {
  id?: string;
  title: string;
  lessonType: AdminLesson["lessonType"];
  courseId: string;
  chapterTitle: string;
  subjectName: string;
  durationSeconds: number | null;
  videoProvider: string | null;
  videoRef: string | null;
  isPublished: boolean;
  isDemo: boolean;
  isDownloadable: boolean;
}) {
  const course = listCourses().find((c) => c.id === input.courseId);
  if (input.id) {
    lessons = lessons.map((l) =>
      l.id === input.id
        ? { ...l, ...input, id: l.id, courseTitle: course?.title ?? l.courseTitle }
        : l,
    );
    return input.id;
  }
  const id = `l-${Date.now()}`;
  lessons = [
    ...lessons,
    {
      ...input,
      id,
      chapterId: `ch-${slugify(input.chapterTitle)}`,
      courseTitle: course?.title ?? "—",
      storagePath: null,
      resources: [],
      sortOrder: lessons.length + 1,
    },
  ];
  return id;
}

export function deleteLesson(id: string) {
  lessons = lessons.filter((l) => l.id !== id);
}

export function addResource(input: {
  lessonId: string;
  title: string;
  storagePath: string;
  sizeBytes: number | null;
}) {
  lessons = lessons.map((l) =>
    l.id === input.lessonId
      ? {
          ...l,
          resources: [
            ...l.resources,
            {
              id: `r-${Date.now()}`,
              lessonId: l.id,
              title: input.title,
              resourceType: "PDF",
              storagePath: input.storagePath,
              sizeBytes: input.sizeBytes,
              isDownloadable: true,
            },
          ],
        }
      : l,
  );
}

export function deleteResource(lessonId: string, resourceId: string) {
  lessons = lessons.map((l) =>
    l.id === lessonId
      ? { ...l, resources: l.resources.filter((r) => r.id !== resourceId) }
      : l,
  );
}

export function replyToDoubt(doubtId: string, body: string) {
  doubts = doubts.map((d) =>
    d.id === doubtId
      ? {
          ...d,
          replies: [
            ...d.replies,
            {
              id: `dr-${Date.now()}`,
              body,
              authorName: "Support · Admin",
              createdAt: localStamp(),
              fromStaff: true,
            },
          ],
        }
      : d,
  );
}

export function setDoubtResolved(doubtId: string, resolved: boolean) {
  doubts = doubts.map((d) =>
    d.id === doubtId
      ? {
          ...d,
          isResolved: resolved,
          resolvedBy: resolved ? "Support · Admin" : null,
        }
      : d,
  );
}

export function savePopup(input: {
  id?: string;
  title: string;
  body: string;
  ctaLabel: string | null;
  ctaUrl: string | null;
  placement: PopupPlacement;
  audienceKind: AdminPopup["audienceKind"];
  audienceValue: string | null;
  isActive: boolean;
  startsAt: string;
  endsAt: string | null;
  maxViewsPerStudent: number;
  priority: number;
}) {
  if (input.id) {
    popups = popups.map((p) => (p.id === input.id ? { ...p, ...input, id: p.id } : p));
    return input.id;
  }
  const id = `p-${Date.now()}`;
  popups = [
    {
      ...input,
      id,
      imagePath: null,
      imageUrl: null,
      viewCount: 0,
      clickCount: 0,
      createdAt: localStamp(),
    },
    ...popups,
  ];
  return id;
}

export function deletePopup(id: string) {
  popups = popups.filter((p) => p.id !== id);
}

export function postCommunityMessage(
  courseId: string,
  body: string,
  pinned: boolean,
) {
  const thread = communityThreads[courseId] ?? (communityThreads[courseId] = []);
  thread.push({
    id: `cm-${Date.now()}`,
    body,
    authorName: "Admin",
    pinned,
    createdAt: localStamp(),
  });
}

export function deleteCommunityMessage(courseId: string, messageId: string) {
  communityThreads[courseId] = (communityThreads[courseId] ?? []).filter(
    (m) => m.id !== messageId,
  );
}
