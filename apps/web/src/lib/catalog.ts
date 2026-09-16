import {
  Course,
  CourseClass,
  courses as mockCourses,
  getCourse as getMockCourse,
  getCoursesByClass as getMockByClass,
} from "@/lib/courses";
import { getSupabase, isSupabaseConfigured } from "@/lib/supabase/client";

type TeacherRef = { display_name: string } | { display_name: string }[] | null;

type CourseRow = {
  id: string;
  slug: string;
  title: string;
  description: string;
  board: string;
  class_level: number;
  language: string;
  thumbnail_hue: number;
  price_inr: number;
  original_price_inr: number | null;
  rating: number;
  lessons_count: number;
  highlights: string[] | null;
  subjects: string[] | null;
  is_published: boolean;
  course_teachers?: Array<{
    is_primary: boolean;
    teachers: TeacherRef;
  }>;
  course_batches?: Array<{ name: string }>;
};

function teacherName(ref: TeacherRef): string | null {
  if (!ref) return null;
  if (Array.isArray(ref)) return ref[0]?.display_name ?? null;
  return ref.display_name ?? null;
}

function mapRow(row: CourseRow): Course {
  const primaryTeacher =
    teacherName(
      row.course_teachers?.find((t) => t.is_primary)?.teachers ?? null,
    ) ||
    teacherName(row.course_teachers?.[0]?.teachers ?? null) ||
    "Faculty";

  return {
    id: row.id,
    slug: row.slug,
    title: row.title,
    description: row.description,
    board: row.board,
    classLevel: row.class_level as CourseClass,
    language: row.language,
    thumbnailHue: row.thumbnail_hue,
    price: row.price_inr,
    originalPrice: row.original_price_inr ?? undefined,
    rating: Number(row.rating),
    lessons: row.lessons_count,
    highlights: row.highlights ?? [],
    subjects: row.subjects ?? [],
    teacher: primaryTeacher,
    batch: row.course_batches?.[0]?.name ?? "Current Batch",
    isPublished: row.is_published,
  };
}

const selectFields = `
  id, slug, title, description, board, class_level, language,
  thumbnail_hue, price_inr, original_price_inr, rating, lessons_count,
  highlights, subjects, is_published,
  course_teachers ( is_primary, teachers ( display_name ) ),
  course_batches ( name )
`;

export async function listCourses(classLevel?: number): Promise<Course[]> {
  if (!isSupabaseConfigured()) {
    return getMockByClass(classLevel);
  }

  const supabase = getSupabase();
  if (!supabase) return getMockByClass(classLevel);

  let query = supabase
    .from("courses")
    .select(selectFields)
    .eq("is_published", true)
    .order("class_level")
    .order("title");

  if (classLevel) {
    query = query.eq("class_level", classLevel);
  }

  const { data, error } = await query;
  if (error || !data) {
    console.error("Supabase listCourses failed, using mock:", error?.message);
    return getMockByClass(classLevel);
  }

  return (data as unknown as CourseRow[]).map(mapRow);
}

export async function fetchCourseBySlug(slug: string): Promise<Course | null> {
  if (!isSupabaseConfigured()) {
    return getMockCourse(slug) ?? null;
  }

  const supabase = getSupabase();
  if (!supabase) return getMockCourse(slug) ?? null;

  const { data, error } = await supabase
    .from("courses")
    .select(selectFields)
    .eq("slug", slug)
    .eq("is_published", true)
    .maybeSingle();

  if (error || !data) {
    if (error) {
      console.error("Supabase fetchCourseBySlug failed:", error.message);
    }
    return getMockCourse(slug) ?? null;
  }

  return mapRow(data as unknown as CourseRow);
}

export async function listCourseSlugs(): Promise<string[]> {
  if (!isSupabaseConfigured()) {
    return mockCourses.map((c) => c.slug);
  }

  const supabase = getSupabase();
  if (!supabase) return mockCourses.map((c) => c.slug);

  const { data, error } = await supabase
    .from("courses")
    .select("slug")
    .eq("is_published", true);

  if (error || !data) {
    return mockCourses.map((c) => c.slug);
  }

  return data.map((row) => row.slug as string);
}
