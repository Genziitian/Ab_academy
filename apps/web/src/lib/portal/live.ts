// Real data for the student portal. Every query runs as the signed-in
// student, so row-level security decides what they see. Without Supabase
// (local preview) everything is empty and the pages show empty states —
// there is no sample data.

import "server-only";
import { cache } from "react";
import { courseArt } from "@/lib/courses";
import { createServerClient } from "@/lib/supabase/server";

export type MyCourse = {
  id: string;
  slug: string;
  title: string;
  subjects: string[];
  art: string | null;
  chapters: number;
  lectures: number;
};

export type CurriculumLesson = {
  id: string;
  title: string;
  type: string;
  minutes: number | null;
  isDemo: boolean;
  notes: number;
};

export type CurriculumChapter = { id: string; title: string; subject: string; lessons: CurriculumLesson[] };

type LessonRow = {
  id: string;
  title: string;
  lesson_type: string;
  duration_seconds: number | null;
  is_demo: boolean;
  is_published: boolean;
  sort_order: number;
  lesson_resources?: { id: string }[];
};
type ChapterRow = { id: string; title: string; sort_order: number; lessons: LessonRow[] };
type SubjectRow = { id: string; name: string; sort_order: number; chapters: ChapterRow[] };
type BatchRow = { id: string; is_active: boolean; created_at: string; subjects: SubjectRow[] };

const bySort = <T extends { sort_order: number }>(a: T, b: T) => a.sort_order - b.sort_order;

async function db() {
  return createServerClient();
}

async function uid() {
  const supabase = await db();
  if (!supabase) return null;
  const { data } = await supabase.auth.getUser();
  return data.user?.id ?? null;
}

function pickBatch(batches: BatchRow[] | null | undefined) {
  if (!batches?.length) return null;
  return batches.find((b) => b.is_active) ?? batches[0];
}

function chaptersOf(batch: BatchRow | null): CurriculumChapter[] {
  if (!batch) return [];
  return [...batch.subjects].sort(bySort).flatMap((s) =>
    [...s.chapters].sort(bySort).map((c) => ({
      id: c.id,
      title: c.title,
      subject: s.name,
      lessons: [...c.lessons]
        .filter((l) => l.is_published)
        .sort(bySort)
        .map((l) => ({
          id: l.id,
          title: l.title,
          type: l.lesson_type,
          minutes: l.duration_seconds ? Math.round(l.duration_seconds / 60) : null,
          isDemo: l.is_demo,
          notes: l.lesson_resources?.length ?? 0,
        })),
    })),
  );
}

const TREE =
  "course_batches ( id, is_active, created_at, subjects ( id, name, sort_order, chapters ( id, title, sort_order, lessons ( id, title, lesson_type, duration_seconds, is_demo, is_published, sort_order, lesson_resources ( id ) ) ) ) )";

/** Courses the student is actively enrolled in. */
export const getMyCourses = cache(async (): Promise<MyCourse[]> => {
  const supabase = await db();
  const me = await uid();
  if (!supabase || !me) return [];
  const { data } = await supabase
    .from("enrollments")
    .select(`course_id, status, courses ( id, slug, title, subjects, price_inr, thumbnail_url, ${TREE} )`)
    .eq("student_id", me)
    .eq("status", "active");

  type Row = {
    courses: {
      id: string;
      slug: string;
      title: string;
      subjects: string[] | null;
      price_inr: number;
      thumbnail_url: string | null;
      course_batches: BatchRow[];
    } | null;
  };
  return ((data ?? []) as unknown as Row[])
    .map((r) => r.courses)
    .filter((c): c is NonNullable<Row["courses"]> => Boolean(c))
    .map((c) => {
      const chapters = chaptersOf(pickBatch(c.course_batches));
      return {
        id: c.id,
        slug: c.slug,
        title: c.title,
        subjects: c.subjects ?? [],
        art: c.thumbnail_url ?? courseArt({ subjects: c.subjects ?? [], price: c.price_inr }),
        chapters: chapters.length,
        lectures: chapters.reduce((n, ch) => n + ch.lessons.length, 0),
      };
    });
});

/** One course's curriculum, for an enrolled student. Null if not enrolled. */
export async function getCourseCurriculum(courseId: string) {
  const courses = await getMyCourses();
  const course = courses.find((c) => c.id === courseId);
  if (!course) return null;
  const supabase = await db();
  const { data } = await supabase!.from("courses").select(`id, ${TREE}`).eq("id", courseId).maybeSingle();
  const chapters = chaptersOf(pickBatch((data as unknown as { course_batches: BatchRow[] } | null)?.course_batches));
  return { course, chapters };
}

/** A lesson with its chapter and course, plus the playable video if allowed. */
export async function getLessonForStudent(lessonId: string) {
  const supabase = await db();
  if (!supabase) return null;
  const { data } = await supabase
    .from("lessons")
    .select(
      "id, title, lesson_type, chapter_id, chapters ( id, title, subjects ( name, course_batches ( course_id, courses ( id, title ) ) ) )",
    )
    .eq("id", lessonId)
    .eq("is_published", true)
    .maybeSingle();
  if (!data) return null;
  const chapter = data.chapters as unknown as {
    id: string;
    title: string;
    subjects: { name: string; course_batches: { course_id: string; courses: { id: string; title: string } } };
  };
  const course = chapter.subjects.course_batches.courses;

  // Video ids are not readable directly; this checks enrolment server-side.
  const { data: media, error } = await supabase.rpc("lesson_playback", { p_lesson_id: lessonId });
  const playback = (media as { provider: string | null; video_ref: string | null }[] | null)?.[0] ?? null;

  const curriculum = await getCourseCurriculum(course.id);
  const chapterLessons = curriculum?.chapters.find((c) => c.id === chapter.id)?.lessons ?? [];

  const { data: notes } = await supabase.from("lesson_resources").select("id, title").eq("lesson_id", lessonId);

  return {
    id: data.id as string,
    title: data.title as string,
    chapterTitle: chapter.title,
    subject: chapter.subjects.name,
    course,
    entitled: !error && Boolean(playback),
    youtubeId: playback?.provider === "youtube" ? playback.video_ref : null,
    hasVideo: Boolean(playback?.video_ref),
    chapterLessons,
    notes: (notes ?? []) as { id: string; title: string }[],
  };
}

export type UpcomingClass = { id: string; title: string; startsAt: string; status: string; course: string };

/** Live classes for the student's courses, soonest first. */
export async function getUpcomingClasses(limit = 10): Promise<UpcomingClass[]> {
  const supabase = await db();
  const courses = await getMyCourses();
  if (!supabase || !courses.length) return [];
  const since = new Date(Date.now() - 3 * 3600_000).toISOString();
  const { data } = await supabase
    .from("live_sessions")
    .select("id, title, starts_at, status, course_batches!inner ( course_id, courses ( title ) )")
    .in(
      "course_batches.course_id",
      courses.map((c) => c.id),
    )
    .gte("starts_at", since)
    .order("starts_at")
    .limit(limit);
  return ((data ?? []) as unknown as {
    id: string;
    title: string;
    starts_at: string;
    status: string;
    course_batches: { courses: { title: string } | null };
  }[]).map((s) => ({
    id: s.id,
    title: s.title,
    startsAt: s.starts_at,
    status: s.status,
    course: s.course_batches?.courses?.title ?? "",
  }));
}

export type MyTicket = { id: string; reference: string; subject: string; status: string; updatedAt: string };

export async function getMyTickets(): Promise<MyTicket[]> {
  const supabase = await db();
  const me = await uid();
  if (!supabase || !me) return [];
  const { data } = await supabase
    .from("tickets")
    .select("id, reference, subject, status, updated_at")
    .eq("student_id", me)
    .order("updated_at", { ascending: false })
    .limit(20);
  return ((data ?? []) as { id: string; reference: string; subject: string; status: string; updated_at: string }[]).map(
    (t) => ({ id: t.id, reference: t.reference, subject: t.subject, status: t.status, updatedAt: t.updated_at }),
  );
}
