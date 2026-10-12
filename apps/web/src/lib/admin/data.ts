// The admin console's data layer.
//
// Every function has two paths: a real Supabase query, and — when no project
// is connected — the in-memory mock. That keeps `npm run dev` useful with no
// env vars while the same pages run on live data in production.
//
// Reads go through the request-scoped client so RLS applies as the signed-in
// staff member; the `is_staff()` / `is_admin()` policies in slice 4 are what
// actually authorise each write.

import "server-only";
import { isDemoMode } from "./auth";
import { createServerClient } from "@/lib/supabase/server";
import * as mock from "./mock-store";
import * as mockExtra from "./mock-extra";
import type {
  AdminBanner,
  AdminCourse,
  AdminDoubt,
  AdminLesson,
  AdminNotification,
  AdminPopup,
  AdminSession,
  AdminStudent,
  AdminTicket,
  AudienceKind,
  LiveStatus,
  PopupPlacement,
  TicketStatus,
} from "./types";

async function db() {
  const client = await createServerClient();
  if (!client) throw new Error("Supabase client unavailable");
  return client;
}

/** Supabase returns timestamptz; the UI formats "YYYY-MM-DDTHH:mm" local. */
function toLocalInput(iso: string | null): string {
  if (!iso) return "";
  const d = new Date(iso);
  return new Date(d.getTime() - d.getTimezoneOffset() * 60_000)
    .toISOString()
    .slice(0, 16);
}

const slugify = (v: string) =>
  v.toLowerCase().replace(/[^a-z0-9]+/g, "-").replace(/(^-|-$)/g, "");

// =========================================================== dashboard

export type DashboardCounts = {
  courses: number;
  publishedCourses: number;
  students: number;
  upcomingSessions: number;
  openTickets: number;
  notificationsSent: number;
  openDoubts: number;
  activePopups: number;
  lessons: number;
};

export async function getDashboardCounts(): Promise<DashboardCounts> {
  if (isDemoMode()) {
    return { ...mock.dashboardCounts(), ...mockExtra.extraCounts() };
  }

  const supabase = await db();
  const count = async (
    table: string,
    build?: (q: ReturnType<typeof supabase.from>) => unknown,
  ) => {
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    // "id" rather than "*": students' column grants on some tables (lessons)
    // leave columns out, and "*" would ask for them.
    let q: any = supabase.from(table).select("id", { count: "exact", head: true });
    if (build) q = build(q);
    const { count: n } = await q;
    return n ?? 0;
  };

  const [
    courses,
    publishedCourses,
    students,
    upcomingSessions,
    openTickets,
    notificationsSent,
    openDoubts,
    activePopups,
    lessons,
  ] = await Promise.all([
    count("courses"),
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    count("courses", (q: any) => q.eq("is_published", true)),
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    count("profiles", (q: any) => q.eq("role", "student")),
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    count("live_sessions", (q: any) => q.in("status", ["SCHEDULED", "LIVE"])),
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    count("tickets", (q: any) => q.in("status", ["open", "in_progress"])),
    count("notifications"),
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    count("lesson_comments", (q: any) =>
      q.eq("is_doubt", true).eq("is_resolved", false),
    ),
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    count("popups", (q: any) => q.eq("is_active", true)),
    count("lessons"),
  ]);

  return {
    courses,
    publishedCourses,
    students,
    upcomingSessions,
    openTickets,
    notificationsSent,
    openDoubts,
    activePopups,
    lessons,
  };
}

// ============================================================= courses

export async function listCourses(): Promise<AdminCourse[]> {
  if (isDemoMode()) return mock.listCourses();

  const supabase = await db();
  const { data, error } = await supabase
    .from("courses")
    .select(
      `id, title, class_level, board, language, price_inr, original_price_inr,
       subjects, is_published,
       course_teachers ( teachers ( display_name ) ),
       enrollments ( count )`,
    )
    .order("class_level")
    .order("title");

  if (error) throw new Error(`listCourses: ${error.message}`);

  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  return (data ?? []).map((row: any) => ({
    id: row.id,
    title: row.title,
    classLevel: row.class_level,
    board: row.board,
    medium: row.language,
    priceInr: row.price_inr,
    originalPriceInr: row.original_price_inr ?? 0,
    subjects: row.subjects ?? [],
    teachers: (row.course_teachers ?? [])
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      .map((ct: any) => ct.teachers?.display_name)
      .filter(Boolean),
    isPublished: row.is_published,
    enrolledCount: row.enrollments?.[0]?.count ?? 0,
  }));
}

export async function getCourse(id: string): Promise<AdminCourse | null> {
  if (isDemoMode()) return mock.getCourse(id);
  const all = await listCourses();
  return all.find((c) => c.id === id) ?? null;
}

export async function saveCourse(input: {
  id?: string;
  title: string;
  classLevel: number;
  board: string;
  medium: string;
  priceInr: number;
  originalPriceInr: number;
  subjects: string[];
  teachers: string[];
  isPublished: boolean;
}): Promise<string> {
  if (isDemoMode()) return mock.saveCourse(input);

  const supabase = await db();
  const row = {
    title: input.title,
    class_level: input.classLevel,
    board: input.board,
    language: input.medium,
    price_inr: input.priceInr,
    original_price_inr: input.originalPriceInr || null,
    subjects: input.subjects,
    is_published: input.isPublished,
  };

  if (input.id) {
    const { error } = await supabase.from("courses").update(row).eq("id", input.id);
    if (error) throw new Error(`saveCourse: ${error.message}`);
    await syncCourseTeachers(input.id, input.teachers);
    return input.id;
  }

  const { data, error } = await supabase
    .from("courses")
    .insert({ ...row, slug: slugify(input.title) })
    .select("id")
    .single();
  if (error) throw new Error(`saveCourse: ${error.message}`);

  // Every course needs one batch; the curriculum hangs off it.
  await supabase
    .from("course_batches")
    .insert({ course_id: data.id, name: "Current Batch", is_active: true });

  await syncCourseTeachers(data.id, input.teachers);
  return data.id;
}

/** Teachers are typed as free text in the form; match or create by name. */
async function syncCourseTeachers(courseId: string, names: string[]) {
  const supabase = await db();
  await supabase.from("course_teachers").delete().eq("course_id", courseId);
  if (names.length === 0) return;

  for (const [index, name] of names.entries()) {
    const { data: existing } = await supabase
      .from("teachers")
      .select("id")
      .eq("display_name", name)
      .maybeSingle();

    let teacherId = existing?.id;
    if (!teacherId) {
      const { data: created, error } = await supabase
        .from("teachers")
        .insert({ display_name: name })
        .select("id")
        .single();
      if (error) continue;
      teacherId = created.id;
    }

    await supabase
      .from("course_teachers")
      .insert({ course_id: courseId, teacher_id: teacherId, is_primary: index === 0 });
  }
}

export async function deleteCourse(id: string): Promise<void> {
  if (isDemoMode()) return mock.deleteCourse(id);
  const supabase = await db();
  const { error } = await supabase.from("courses").delete().eq("id", id);
  if (error) throw new Error(`deleteCourse: ${error.message}`);
}

// ============================================================ students

export async function listStudents(
  search?: string,
  classLevel?: number,
): Promise<AdminStudent[]> {
  if (isDemoMode()) return mockExtra.listStudents(search, classLevel);

  const supabase = await db();
  let query = supabase
    .from("profiles")
    .select(
      `id, full_name, phone, email, role, created_at,
       student_profiles ( class_level, board, medium, stream, school ),
       enrollments ( course_id, courses ( title ) )`,
    )
    .eq("role", "student")
    .order("created_at", { ascending: false })
    .limit(200);

  if (search) {
    const q = `%${search}%`;
    query = query.or(`full_name.ilike.${q},phone.ilike.${q},email.ilike.${q}`);
  }

  const { data, error } = await query;
  if (error) throw new Error(`listStudents: ${error.message}`);

  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  const rows = (data ?? []).map((row: any) => {
    const sp = Array.isArray(row.student_profiles)
      ? row.student_profiles[0]
      : row.student_profiles;
    return {
      id: row.id,
      fullName: row.full_name || "—",
      phone: row.phone,
      email: row.email,
      classLevel: sp?.class_level ?? null,
      board: sp?.board ?? null,
      medium: sp?.medium ?? null,
      stream: sp?.stream ?? null,
      school: sp?.school ?? null,
      role: row.role,
      enrolledCourses: (row.enrollments ?? [])
        // eslint-disable-next-line @typescript-eslint/no-explicit-any
        .map((e: any) => e.courses?.title ?? e.course_id)
        .filter(Boolean),
      createdAt: toLocalInput(row.created_at),
    };
  });

  // class_level lives on the joined table, so filter after the fetch.
  return classLevel ? rows.filter((r) => r.classLevel === classLevel) : rows;
}

export async function getStudent(id: string): Promise<AdminStudent | null> {
  if (isDemoMode()) return mockExtra.getStudent(id);
  const rows = await listStudents();
  return rows.find((s) => s.id === id) ?? null;
}

export async function saveStudent(input: {
  id: string;
  fullName: string;
  classLevel: number | null;
  medium: string | null;
  stream: string | null;
  school: string | null;
}): Promise<void> {
  if (isDemoMode()) return mockExtra.saveStudent(input);

  const supabase = await db();
  const { error: pErr } = await supabase
    .from("profiles")
    .update({ full_name: input.fullName })
    .eq("id", input.id);
  if (pErr) throw new Error(`saveStudent: ${pErr.message}`);

  const { error: sErr } = await supabase.from("student_profiles").upsert({
    user_id: input.id,
    class_level: input.classLevel,
    medium: input.medium,
    stream: input.stream,
    school: input.school,
  });
  if (sErr) throw new Error(`saveStudent: ${sErr.message}`);
}

/** Manual enrolment for offline payments and comped access. */
export async function enrollStudent(
  studentId: string,
  courseId: string,
): Promise<void> {
  if (isDemoMode()) return mockExtra.enrollStudent(studentId, courseId);

  const supabase = await db();
  const { data: batch } = await supabase
    .from("course_batches")
    .select("id")
    .eq("course_id", courseId)
    .eq("is_active", true)
    .limit(1)
    .maybeSingle();

  const { error } = await supabase.from("enrollments").upsert(
    {
      student_id: studentId,
      course_id: courseId,
      batch_id: batch?.id ?? null,
      status: "active",
    },
    { onConflict: "student_id,course_id" },
  );
  if (error) throw new Error(`enrollStudent: ${error.message}`);
}

export async function unenrollStudent(
  studentId: string,
  courseId: string,
): Promise<void> {
  if (isDemoMode()) return mockExtra.unenrollStudent(studentId, courseId);
  const supabase = await db();
  const { error } = await supabase
    .from("enrollments")
    .delete()
    .eq("student_id", studentId)
    .eq("course_id", courseId);
  if (error) throw new Error(`unenrollStudent: ${error.message}`);
}

// ===================================== content library (video + notes)

/**
 * Resolves course → batch → subject → chapter, creating what is missing.
 *
 * The schema nests lessons four levels deep, but the admin form asks only for
 * a course, a subject name and a chapter title. This walks that chain so
 * uploading a recording never requires setting up the hierarchy by hand.
 */
async function ensureChapter(
  courseId: string,
  subjectName: string,
  chapterTitle: string,
): Promise<string> {
  const supabase = await db();

  let { data: batch } = await supabase
    .from("course_batches")
    .select("id")
    .eq("course_id", courseId)
    .eq("is_active", true)
    .limit(1)
    .maybeSingle();

  if (!batch) {
    const { data, error } = await supabase
      .from("course_batches")
      .insert({ course_id: courseId, name: "Current Batch", is_active: true })
      .select("id")
      .single();
    if (error) throw new Error(`ensureChapter/batch: ${error.message}`);
    batch = data;
  }

  let { data: subject } = await supabase
    .from("subjects")
    .select("id")
    .eq("batch_id", batch!.id)
    .eq("name", subjectName)
    .maybeSingle();

  if (!subject) {
    const { data, error } = await supabase
      .from("subjects")
      .insert({ batch_id: batch!.id, name: subjectName })
      .select("id")
      .single();
    if (error) throw new Error(`ensureChapter/subject: ${error.message}`);
    subject = data;
  }

  const { data: chapter } = await supabase
    .from("chapters")
    .select("id")
    .eq("subject_id", subject!.id)
    .eq("title", chapterTitle)
    .maybeSingle();

  if (chapter) return chapter.id;

  const { data, error } = await supabase
    .from("chapters")
    .insert({ subject_id: subject!.id, title: chapterTitle })
    .select("id")
    .single();
  if (error) throw new Error(`ensureChapter/chapter: ${error.message}`);
  return data.id;
}

export async function listLessons(courseId?: string): Promise<AdminLesson[]> {
  if (isDemoMode()) return mockExtra.listLessons(courseId);

  const supabase = await db();
  const { data, error } = await supabase
    .from("lessons")
    .select(
      `id, title, lesson_type, sort_order, duration_seconds, video_provider,
       is_demo, is_published, is_downloadable,
       chapter_id,
       chapters ( id, title, subjects ( name, course_batches ( course_id, courses ( id, title ) ) ) ),
       lesson_resources ( id, title, resource_type, storage_path, size_bytes, is_downloadable )`,
    )
    .order("sort_order")
    .limit(500);

  if (error) throw new Error(`listLessons: ${error.message}`);

  // Video ids and storage paths are not selectable directly (migration 6);
  // staff get them through a security-definer function.
  const { data: media, error: mediaError } = await supabase.rpc("staff_lesson_media");
  if (mediaError) throw new Error(`listLessons/media: ${mediaError.message}`);
  const mediaById = new Map<string, { video_ref: string | null; storage_path: string | null }>(
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    (media ?? []).map((m: any) => [m.id, m]),
  );

  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  const rows = (data ?? []).map((row: any) => {
    const chapter = row.chapters;
    const subject = chapter?.subjects;
    const course = subject?.course_batches?.courses;
    return {
      id: row.id,
      title: row.title,
      lessonType: row.lesson_type,
      chapterId: row.chapter_id,
      chapterTitle: chapter?.title ?? "—",
      subjectName: subject?.name ?? "—",
      courseId: course?.id ?? "",
      courseTitle: course?.title ?? "—",
      durationSeconds: row.duration_seconds,
      videoProvider: row.video_provider,
      videoRef: mediaById.get(row.id)?.video_ref ?? null,
      storagePath: mediaById.get(row.id)?.storage_path ?? null,
      isDemo: row.is_demo,
      isPublished: row.is_published,
      isDownloadable: row.is_downloadable,
      sortOrder: row.sort_order,
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      resources: (row.lesson_resources ?? []).map((r: any) => ({
        id: r.id,
        lessonId: row.id,
        title: r.title,
        resourceType: r.resource_type,
        storagePath: r.storage_path,
        sizeBytes: r.size_bytes,
        isDownloadable: r.is_downloadable,
      })),
    };
  });

  return courseId ? rows.filter((r) => r.courseId === courseId) : rows;
}

export async function saveLesson(input: {
  id?: string;
  title: string;
  lessonType: AdminLesson["lessonType"];
  courseId: string;
  subjectName: string;
  chapterTitle: string;
  durationSeconds: number | null;
  videoProvider: string | null;
  videoRef: string | null;
  isPublished: boolean;
  isDemo: boolean;
  isDownloadable: boolean;
}): Promise<string> {
  if (isDemoMode()) return mockExtra.saveLesson(input);

  const supabase = await db();
  const chapterId = await ensureChapter(
    input.courseId,
    input.subjectName,
    input.chapterTitle,
  );

  const row = {
    chapter_id: chapterId,
    title: input.title,
    lesson_type: input.lessonType,
    duration_seconds: input.durationSeconds,
    video_provider: input.videoProvider,
    video_ref: input.videoRef,
    is_published: input.isPublished,
    is_demo: input.isDemo,
    is_downloadable: input.isDownloadable,
  };

  if (input.id) {
    const { error } = await supabase.from("lessons").update(row).eq("id", input.id);
    if (error) throw new Error(`saveLesson: ${error.message}`);
    return input.id;
  }

  const { data, error } = await supabase
    .from("lessons")
    .insert(row)
    .select("id")
    .single();
  if (error) throw new Error(`saveLesson: ${error.message}`);
  return data.id;
}

export async function deleteLesson(id: string): Promise<void> {
  if (isDemoMode()) return mockExtra.deleteLesson(id);
  const supabase = await db();
  const { error } = await supabase.from("lessons").delete().eq("id", id);
  if (error) throw new Error(`deleteLesson: ${error.message}`);
}

export async function addResource(input: {
  lessonId: string;
  title: string;
  storagePath: string;
  sizeBytes: number | null;
}): Promise<void> {
  if (isDemoMode()) return mockExtra.addResource(input);
  const supabase = await db();
  const { error } = await supabase.from("lesson_resources").insert({
    lesson_id: input.lessonId,
    title: input.title,
    resource_type: "PDF",
    storage_path: input.storagePath,
    size_bytes: input.sizeBytes,
  });
  if (error) throw new Error(`addResource: ${error.message}`);
}

export async function deleteResource(
  lessonId: string,
  resourceId: string,
): Promise<void> {
  if (isDemoMode()) return mockExtra.deleteResource(lessonId, resourceId);
  const supabase = await db();
  const { error } = await supabase
    .from("lesson_resources")
    .delete()
    .eq("id", resourceId);
  if (error) throw new Error(`deleteResource: ${error.message}`);
}

/** Saves an uploaded file to a private bucket and returns its storage path. */
export async function uploadToBucket(
  bucket: "lesson-notes" | "lesson-videos" | "popup-images" | "banner-images",
  file: File,
  prefix: string,
): Promise<string> {
  if (isDemoMode()) return `${bucket}/demo/${slugify(file.name)}`;

  const supabase = await db();
  const ext = file.name.split(".").pop() ?? "bin";
  const path = `${prefix}/${Date.now()}-${slugify(file.name.replace(/\.[^.]+$/, ""))}.${ext}`;

  const { error } = await supabase.storage
    .from(bucket)
    .upload(path, file, { contentType: file.type, upsert: false });
  if (error) throw new Error(`upload: ${error.message}`);
  return path;
}

/** Private buckets are read through short-lived signed URLs, never public. */
export async function signedUrl(
  bucket: string,
  path: string,
  seconds = 3600,
): Promise<string | null> {
  if (isDemoMode()) return null;
  const supabase = await db();
  const { data } = await supabase.storage.from(bucket).createSignedUrl(path, seconds);
  return data?.signedUrl ?? null;
}

// ============================================================ schedule

export async function listSessions(): Promise<AdminSession[]> {
  if (isDemoMode()) return mock.listSessions();

  const supabase = await db();
  const { data, error } = await supabase
    .from("live_sessions")
    .select(
      `id, title, starts_at, ends_at, status, provider, youtube_video_id,
       teachers ( display_name ),
       subjects ( name ),
       course_batches ( course_id )`,
    )
    .order("starts_at");

  if (error) throw new Error(`listSessions: ${error.message}`);

  const statusMap: Record<string, LiveStatus> = {
    SCHEDULED: "scheduled",
    LIVE: "live",
    ENDED: "ended",
    RECORDING_PROCESSING: "ended",
    RECORDING_AVAILABLE: "ended",
  };

  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  return (data ?? []).map((row: any) => {
    const starts = new Date(row.starts_at);
    const ends = row.ends_at ? new Date(row.ends_at) : null;
    return {
      id: row.id,
      title: row.title,
      courseId: row.course_batches?.course_id ?? "",
      subject: row.subjects?.name ?? "—",
      teacher: row.teachers?.display_name ?? "—",
      startsAt: toLocalInput(row.starts_at),
      durationMinutes: ends
        ? Math.round((ends.getTime() - starts.getTime()) / 60_000)
        : 60,
      status: statusMap[row.status] ?? "scheduled",
    };
  });
}

export async function saveSession(input: {
  id?: string;
  title: string;
  courseId: string;
  subject: string;
  teacher: string;
  startsAt: string;
  durationMinutes: number;
}): Promise<string> {
  if (isDemoMode()) return mock.saveSession(input);

  const supabase = await db();
  const { data: batch } = await supabase
    .from("course_batches")
    .select("id")
    .eq("course_id", input.courseId)
    .eq("is_active", true)
    .limit(1)
    .maybeSingle();

  if (!batch) throw new Error("saveSession: the course has no active batch");

  const { data: subject } = await supabase
    .from("subjects")
    .select("id")
    .eq("batch_id", batch.id)
    .eq("name", input.subject)
    .maybeSingle();

  const { data: teacher } = await supabase
    .from("teachers")
    .select("id")
    .eq("display_name", input.teacher)
    .maybeSingle();

  const startsAt = new Date(input.startsAt);
  const row = {
    batch_id: batch.id,
    subject_id: subject?.id ?? null,
    teacher_id: teacher?.id ?? null,
    title: input.title,
    starts_at: startsAt.toISOString(),
    ends_at: new Date(
      startsAt.getTime() + input.durationMinutes * 60_000,
    ).toISOString(),
  };

  if (input.id) {
    const { error } = await supabase
      .from("live_sessions")
      .update(row)
      .eq("id", input.id);
    if (error) throw new Error(`saveSession: ${error.message}`);
    return input.id;
  }

  const { data, error } = await supabase
    .from("live_sessions")
    .insert(row)
    .select("id")
    .single();
  if (error) throw new Error(`saveSession: ${error.message}`);
  return data.id;
}

export async function deleteSession(id: string): Promise<void> {
  if (isDemoMode()) return mock.deleteSession(id);
  const supabase = await db();
  const { error } = await supabase.from("live_sessions").delete().eq("id", id);
  if (error) throw new Error(`deleteSession: ${error.message}`);
}

// ========================================================= doubt queue

export async function listDoubts(resolved?: boolean): Promise<AdminDoubt[]> {
  if (isDemoMode()) return mockExtra.listDoubts(resolved);

  const supabase = await db();
  let query = supabase
    .from("lesson_comments")
    .select(
      `id, body, lesson_id, is_doubt, is_resolved, created_at, parent_id,
       profiles:author_id ( full_name ),
       resolver:resolved_by ( full_name ),
       lessons ( title, chapters ( subjects ( course_batches ( courses ( title ) ) ) ) )`,
    )
    .is("parent_id", null)
    .eq("is_doubt", true)
    .order("created_at", { ascending: false })
    .limit(200);

  if (resolved !== undefined) query = query.eq("is_resolved", resolved);

  const { data, error } = await query;
  if (error) throw new Error(`listDoubts: ${error.message}`);

  const ids = (data ?? []).map((d) => d.id);
  const repliesByParent = await fetchDoubtReplies(ids);

  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  return (data ?? []).map((row: any) => ({
    id: row.id,
    body: row.body,
    lessonId: row.lesson_id,
    lessonTitle: row.lessons?.title ?? "—",
    courseTitle:
      row.lessons?.chapters?.subjects?.course_batches?.courses?.title ?? "—",
    authorName: row.profiles?.full_name ?? "Student",
    isResolved: row.is_resolved,
    resolvedBy: row.resolver?.full_name ?? null,
    createdAt: toLocalInput(row.created_at),
    replies: repliesByParent[row.id] ?? [],
  }));
}

async function fetchDoubtReplies(parentIds: string[]) {
  if (parentIds.length === 0) return {};
  const supabase = await db();
  const { data } = await supabase
    .from("lesson_comments")
    .select("id, body, parent_id, created_at, profiles:author_id ( full_name, role )")
    .in("parent_id", parentIds)
    .order("created_at");

  const grouped: Record<string, AdminDoubt["replies"]> = {};
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  for (const row of (data ?? []) as any[]) {
    (grouped[row.parent_id] ??= []).push({
      id: row.id,
      body: row.body,
      authorName: row.profiles?.full_name ?? "Staff",
      createdAt: toLocalInput(row.created_at),
      fromStaff: ["admin", "super_admin", "teacher"].includes(
        row.profiles?.role ?? "",
      ),
    });
  }
  return grouped;
}

export async function replyToDoubt(
  doubtId: string,
  body: string,
): Promise<void> {
  if (isDemoMode()) return mockExtra.replyToDoubt(doubtId, body);

  const supabase = await db();
  const {
    data: { user },
  } = await supabase.auth.getUser();

  const { data: parent } = await supabase
    .from("lesson_comments")
    .select("lesson_id")
    .eq("id", doubtId)
    .single();

  const { error } = await supabase.from("lesson_comments").insert({
    lesson_id: parent?.lesson_id,
    parent_id: doubtId,
    author_id: user?.id,
    body,
  });
  if (error) throw new Error(`replyToDoubt: ${error.message}`);
}

export async function setDoubtResolved(
  doubtId: string,
  resolved: boolean,
): Promise<void> {
  if (isDemoMode()) return mockExtra.setDoubtResolved(doubtId, resolved);

  const supabase = await db();
  const {
    data: { user },
  } = await supabase.auth.getUser();

  const { error } = await supabase
    .from("lesson_comments")
    .update({
      is_resolved: resolved,
      resolved_by: resolved ? user?.id : null,
      resolved_at: resolved ? new Date().toISOString() : null,
    })
    .eq("id", doubtId);
  if (error) throw new Error(`setDoubtResolved: ${error.message}`);
}

// ============================================================= tickets

export async function listTickets(): Promise<AdminTicket[]> {
  if (isDemoMode()) return mock.listTickets();

  const supabase = await db();
  const { data, error } = await supabase
    .from("tickets")
    .select(
      `id, reference, subject, category, status, created_at,
       profiles:student_id ( full_name ),
       ticket_messages ( id, body, from_support, created_at, profiles:author_id ( full_name ) )`,
    )
    .order("created_at", { ascending: false })
    .limit(200);

  if (error) throw new Error(`listTickets: ${error.message}`);
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  return (data ?? []).map(mapTicket as any);
}

// eslint-disable-next-line @typescript-eslint/no-explicit-any
function mapTicket(row: any): AdminTicket {
  return {
    id: row.id,
    reference: row.reference,
    subject: row.subject,
    category: row.category,
    status: row.status,
    studentName: row.profiles?.full_name ?? "Student",
    openedAt: toLocalInput(row.created_at),
    messages: (row.ticket_messages ?? [])
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      .sort((a: any, b: any) => a.created_at.localeCompare(b.created_at))
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      .map((m: any) => ({
        id: m.id,
        body: m.body,
        fromSupport: m.from_support,
        authorName: m.profiles?.full_name ?? (m.from_support ? "Support" : "Student"),
        at: toLocalInput(m.created_at),
      })),
  };
}

export async function getTicket(id: string): Promise<AdminTicket | null> {
  if (isDemoMode()) return mock.getTicket(id);

  const supabase = await db();
  const { data, error } = await supabase
    .from("tickets")
    .select(
      `id, reference, subject, category, status, created_at,
       profiles:student_id ( full_name ),
       ticket_messages ( id, body, from_support, created_at, profiles:author_id ( full_name ) )`,
    )
    .eq("id", id)
    .maybeSingle();

  if (error || !data) return null;
  return mapTicket(data);
}

export async function replyToTicket(
  ticketId: string,
  body: string,
): Promise<void> {
  if (isDemoMode()) return mock.replyToTicket(ticketId, body);

  const supabase = await db();
  const {
    data: { user },
  } = await supabase.auth.getUser();

  const { error } = await supabase.from("ticket_messages").insert({
    ticket_id: ticketId,
    author_id: user?.id,
    body,
    from_support: true,
  });
  if (error) throw new Error(`replyToTicket: ${error.message}`);

  // An open ticket becomes in_progress the moment support answers it.
  await supabase
    .from("tickets")
    .update({ status: "in_progress" })
    .eq("id", ticketId)
    .eq("status", "open");
}

export async function setTicketStatus(
  ticketId: string,
  status: TicketStatus,
): Promise<void> {
  if (isDemoMode()) return mock.setTicketStatus(ticketId, status);
  const supabase = await db();
  const { error } = await supabase
    .from("tickets")
    .update({ status })
    .eq("id", ticketId);
  if (error) throw new Error(`setTicketStatus: ${error.message}`);
}

// ======================================================= notifications

export async function listNotifications(): Promise<AdminNotification[]> {
  if (isDemoMode()) return mock.listNotifications();

  const supabase = await db();
  const { data, error } = await supabase
    .from("notifications")
    .select(
      `id, title, body, audience, audience_class, audience_course_id,
       audience_student_id, sent_at,
       profiles:created_by ( full_name ),
       courses:audience_course_id ( title ),
       student:audience_student_id ( full_name ),
       push_deliveries ( status, recipients, delivered, failed )`,
    )
    .order("sent_at", { ascending: false })
    .limit(100);

  if (error) throw new Error(`listNotifications: ${error.message}`);

  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  return (data ?? []).map((row: any) => ({
    id: row.id,
    title: row.title,
    body: row.body,
    audienceKind: row.audience,
    audienceValue:
      row.audience === "class"
        ? String(row.audience_class)
        : row.audience === "course"
          ? (row.courses?.title ?? row.audience_course_id)
          : row.audience === "student"
            ? (row.student?.full_name ?? row.audience_student_id)
            : null,
    sentAt: toLocalInput(row.sent_at),
    sentBy: row.profiles?.full_name ?? "Admin",
  }));
}

export async function sendNotification(input: {
  title: string;
  body: string;
  audienceKind: AudienceKind;
  audienceValue: string | null;
  deepLink?: string | null;
  sendPush?: boolean;
}): Promise<string> {
  if (isDemoMode()) return mock.sendNotification(input);

  const supabase = await db();
  const {
    data: { user },
  } = await supabase.auth.getUser();

  const { data, error } = await supabase
    .from("notifications")
    .insert({
      title: input.title,
      body: input.body,
      audience: input.audienceKind,
      audience_class:
        input.audienceKind === "class" ? Number(input.audienceValue) : null,
      audience_course_id:
        input.audienceKind === "course" ? input.audienceValue : null,
      audience_student_id:
        input.audienceKind === "student" ? input.audienceValue : null,
      deep_link: input.deepLink ?? null,
      send_push: input.sendPush ?? true,
      created_by: user?.id,
    })
    .select("id")
    .single();

  if (error) throw new Error(`sendNotification: ${error.message}`);

  if (input.sendPush ?? true) await triggerPush(data.id);
  return data.id;
}

/**
 * Hands the notification to the `send-push` Edge Function, which owns the FCM
 * server key and fans out to device_tokens. Failing to reach it must not fail
 * the notification: the in-app record is already written, and the delivery row
 * records the error for retry.
 */
async function triggerPush(notificationId: string): Promise<void> {
  const supabase = await db();
  await supabase
    .from("push_deliveries")
    .insert({ notification_id: notificationId, status: "queued" });

  try {
    const { error } = await supabase.functions.invoke("send-push", {
      body: { notification_id: notificationId },
    });
    if (error) throw error;
  } catch (err) {
    await supabase
      .from("push_deliveries")
      .update({
        status: "failed",
        error: err instanceof Error ? err.message : String(err),
        completed_at: new Date().toISOString(),
      })
      .eq("notification_id", notificationId);
  }
}

// ============================================================== popups

export async function listPopups(): Promise<AdminPopup[]> {
  if (isDemoMode()) return mockExtra.listPopups();

  const supabase = await db();
  const { data, error } = await supabase
    .from("popups")
    .select(
      `id, title, body, image_path, cta_label, cta_url, placement, audience,
       audience_class, audience_course_id, audience_student_id, is_active,
       starts_at, ends_at, max_views_per_student, priority, created_at,
       courses:audience_course_id ( title ),
       popup_views ( view_count, clicked_at )`,
    )
    .order("priority", { ascending: false })
    .order("created_at", { ascending: false });

  if (error) throw new Error(`listPopups: ${error.message}`);

  const publicBase = `${process.env.NEXT_PUBLIC_SUPABASE_URL}/storage/v1/object/public/popup-images/`;

  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  return (data ?? []).map((row: any) => ({
    id: row.id,
    title: row.title,
    body: row.body,
    imagePath: row.image_path,
    imageUrl: row.image_path ? `${publicBase}${row.image_path}` : null,
    ctaLabel: row.cta_label,
    ctaUrl: row.cta_url,
    placement: row.placement,
    audienceKind: row.audience,
    audienceValue:
      row.audience === "class"
        ? String(row.audience_class)
        : row.audience === "course"
          ? (row.courses?.title ?? row.audience_course_id)
          : row.audience === "student"
            ? row.audience_student_id
            : null,
    isActive: row.is_active,
    startsAt: toLocalInput(row.starts_at),
    endsAt: row.ends_at ? toLocalInput(row.ends_at) : null,
    maxViewsPerStudent: row.max_views_per_student,
    priority: row.priority,
    viewCount: (row.popup_views ?? []).reduce(
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      (sum: number, v: any) => sum + (v.view_count ?? 0),
      0,
    ),
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    clickCount: (row.popup_views ?? []).filter((v: any) => v.clicked_at).length,
    createdAt: toLocalInput(row.created_at),
  }));
}

export async function getPopup(id: string): Promise<AdminPopup | null> {
  if (isDemoMode()) return mockExtra.getPopup(id);
  const all = await listPopups();
  return all.find((p) => p.id === id) ?? null;
}

export async function savePopup(input: {
  id?: string;
  title: string;
  body: string;
  imagePath?: string | null;
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
}): Promise<string> {
  if (isDemoMode()) return mockExtra.savePopup(input);

  const supabase = await db();
  const {
    data: { user },
  } = await supabase.auth.getUser();

  const row: Record<string, unknown> = {
    title: input.title,
    body: input.body,
    cta_label: input.ctaLabel,
    cta_url: input.ctaUrl,
    placement: input.placement,
    audience: input.audienceKind,
    audience_class:
      input.audienceKind === "class" ? Number(input.audienceValue) : null,
    audience_course_id:
      input.audienceKind === "course" ? input.audienceValue : null,
    audience_student_id:
      input.audienceKind === "student" ? input.audienceValue : null,
    is_active: input.isActive,
    starts_at: new Date(input.startsAt).toISOString(),
    ends_at: input.endsAt ? new Date(input.endsAt).toISOString() : null,
    max_views_per_student: input.maxViewsPerStudent,
    priority: input.priority,
  };

  // Only overwrite the image when a new one was uploaded.
  if (input.imagePath !== undefined) row.image_path = input.imagePath;

  if (input.id) {
    const { error } = await supabase.from("popups").update(row).eq("id", input.id);
    if (error) throw new Error(`savePopup: ${error.message}`);
    return input.id;
  }

  const { data, error } = await supabase
    .from("popups")
    .insert({ ...row, created_by: user?.id })
    .select("id")
    .single();
  if (error) throw new Error(`savePopup: ${error.message}`);
  return data.id;
}

export async function deletePopup(id: string): Promise<void> {
  if (isDemoMode()) return mockExtra.deletePopup(id);
  const supabase = await db();
  const { error } = await supabase.from("popups").delete().eq("id", id);
  if (error) throw new Error(`deletePopup: ${error.message}`);
}

// ============================================================= banners

export async function listBanners(): Promise<AdminBanner[]> {
  if (isDemoMode()) return mockExtra.listBanners();

  const supabase = await db();
  const { data, error } = await supabase
    .from("course_banners")
    .select(
      `id, title, subtitle, image_path, course_id, cta_label, hue, sort_order,
       is_active, starts_at, ends_at, courses ( title )`,
    )
    .order("sort_order")
    .order("created_at");
  if (error) throw new Error(`listBanners: ${error.message}`);

  const publicBase = `${process.env.NEXT_PUBLIC_SUPABASE_URL}/storage/v1/object/public/banner-images/`;

  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  return (data ?? []).map((row: any) => ({
    id: row.id,
    title: row.title,
    subtitle: row.subtitle,
    imagePath: row.image_path,
    imageUrl: row.image_path ? `${publicBase}${row.image_path}` : null,
    courseId: row.course_id,
    courseTitle: row.courses?.title ?? null,
    ctaLabel: row.cta_label,
    hue: row.hue,
    sortOrder: row.sort_order,
    isActive: row.is_active,
    startsAt: toLocalInput(row.starts_at),
    endsAt: row.ends_at ? toLocalInput(row.ends_at) : null,
  }));
}

export async function saveBanner(input: {
  id?: string;
  title: string;
  subtitle: string | null;
  imagePath?: string | null;
  courseId: string | null;
  ctaLabel: string;
  hue: number;
  sortOrder: number;
  isActive: boolean;
  startsAt: string;
  endsAt: string | null;
}): Promise<string> {
  if (isDemoMode()) {
    const courses = mock.listCourses();
    return mockExtra.saveBanner({
      ...input,
      courseTitle: courses.find((c) => c.id === input.courseId)?.title ?? null,
    });
  }

  const supabase = await db();
  const row: Record<string, unknown> = {
    title: input.title,
    subtitle: input.subtitle,
    course_id: input.courseId,
    cta_label: input.ctaLabel,
    hue: input.hue,
    sort_order: input.sortOrder,
    is_active: input.isActive,
    starts_at: new Date(input.startsAt).toISOString(),
    ends_at: input.endsAt ? new Date(input.endsAt).toISOString() : null,
  };
  // Only overwrite the artwork when a new file was uploaded.
  if (input.imagePath !== undefined) row.image_path = input.imagePath;

  if (input.id) {
    const { error } = await supabase.from("course_banners").update(row).eq("id", input.id);
    if (error) throw new Error(`saveBanner: ${error.message}`);
    return input.id;
  }

  const { data, error } = await supabase.from("course_banners").insert(row).select("id").single();
  if (error) throw new Error(`saveBanner: ${error.message}`);
  return data.id;
}

export async function deleteBanner(id: string): Promise<void> {
  if (isDemoMode()) return mockExtra.deleteBanner(id);
  const supabase = await db();
  const { error } = await supabase.from("course_banners").delete().eq("id", id);
  if (error) throw new Error(`deleteBanner: ${error.message}`);
}
