// Types mirror the Supabase schema so the next slice can swap the mock store
// for real queries without touching the admin UI.

export type AudienceKind = "all" | "class" | "course" | "student";

export type AdminNotification = {
  id: string;
  title: string;
  body: string;
  audienceKind: AudienceKind;
  /** Class level, course id or student name, depending on audienceKind. */
  audienceValue: string | null;
  sentAt: string;
  sentBy: string;
};

export type AdminCourse = {
  id: string;
  title: string;
  classLevel: number;
  board: string;
  medium: string;
  priceInr: number;
  originalPriceInr: number;
  subjects: string[];
  teachers: string[];
  isPublished: boolean;
  enrolledCount: number;
};

export type LiveStatus = "scheduled" | "live" | "ended";

export type AdminSession = {
  id: string;
  title: string;
  courseId: string;
  subject: string;
  teacher: string;
  /** ISO local datetime, e.g. "2026-09-18T18:00". */
  startsAt: string;
  durationMinutes: number;
  status: LiveStatus;
};

export type TicketStatus = "open" | "in_progress" | "resolved" | "closed";

export type AdminTicketMessage = {
  id: string;
  body: string;
  fromSupport: boolean;
  authorName: string;
  at: string;
};

export type AdminTicket = {
  id: string;
  reference: string;
  subject: string;
  category: string;
  status: TicketStatus;
  studentName: string;
  openedAt: string;
  messages: AdminTicketMessage[];
};

// ------------------------------------------------- slice 4: new domains

export type AdminStudent = {
  id: string;
  fullName: string;
  phone: string | null;
  email: string | null;
  classLevel: number | null;
  board: string | null;
  medium: string | null;
  stream: string | null;
  school: string | null;
  role: string;
  enrolledCourses: string[];
  createdAt: string;
};

export type AdminEnrollment = {
  id: string;
  courseId: string;
  courseTitle: string;
  status: string;
  purchasedAt: string;
  expiresAt: string | null;
};

/** A row in the content library: a video recording or a notes PDF. */
export type AdminLesson = {
  id: string;
  title: string;
  lessonType: "LIVE" | "VIDEO" | "PDF" | "TEST" | "ASSIGNMENT";
  chapterId: string;
  chapterTitle: string;
  subjectName: string;
  courseId: string;
  courseTitle: string;
  durationSeconds: number | null;
  videoProvider: string | null;
  videoRef: string | null;
  storagePath: string | null;
  isDemo: boolean;
  isPublished: boolean;
  isDownloadable: boolean;
  resources: AdminResource[];
  sortOrder: number;
};

export type AdminResource = {
  id: string;
  lessonId: string;
  title: string;
  resourceType: string;
  storagePath: string;
  sizeBytes: number | null;
  isDownloadable: boolean;
};

/** A student question under a lecture, as a work queue item. */
export type AdminDoubt = {
  id: string;
  body: string;
  lessonId: string;
  lessonTitle: string;
  courseTitle: string;
  authorName: string;
  isResolved: boolean;
  resolvedBy: string | null;
  createdAt: string;
  replies: AdminDoubtReply[];
};

export type AdminDoubtReply = {
  id: string;
  body: string;
  authorName: string;
  createdAt: string;
  fromStaff: boolean;
};

export type PopupPlacement = "app_launch" | "home" | "course";

export type AdminPopup = {
  id: string;
  title: string;
  body: string;
  imagePath: string | null;
  imageUrl: string | null;
  ctaLabel: string | null;
  ctaUrl: string | null;
  placement: PopupPlacement;
  audienceKind: AudienceKind;
  audienceValue: string | null;
  isActive: boolean;
  startsAt: string;
  endsAt: string | null;
  maxViewsPerStudent: number;
  priority: number;
  /** Impression + click counters from popup_views. */
  viewCount: number;
  clickCount: number;
  createdAt: string;
};

export type PushStatus = "queued" | "sent" | "failed";

export type AdminPushDelivery = {
  status: PushStatus;
  recipients: number;
  delivered: number;
  failed: number;
  error: string | null;
};

/** A slide in the app's course slider (`public.course_banners`). */
export type AdminBanner = {
  id: string;
  title: string;
  subtitle: string | null;
  imagePath: string | null;
  imageUrl: string | null;
  courseId: string | null;
  courseTitle: string | null;
  ctaLabel: string;
  hue: number;
  sortOrder: number;
  isActive: boolean;
  /** ISO local datetime, e.g. "2026-10-12T09:00". */
  startsAt: string;
  endsAt: string | null;
};
