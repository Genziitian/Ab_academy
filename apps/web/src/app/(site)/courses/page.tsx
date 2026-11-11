import { CoursesCatalog } from "@/components/CoursesCatalog";
import { listCourses } from "@/lib/catalog";
import { getT } from "@/lib/i18n/server";

export const metadata = {
  title: "Courses",
  description: "Class 12 crash courses for Bihar Board — recorded lectures, live doubt sessions, notes and board-pattern practice.",
};

export default async function CoursesPage({ searchParams }: { searchParams: Promise<{ subject?: string }> }) {
  const [{ subject }, courses, { t, locale }] = await Promise.all([searchParams, listCourses(), getT()]);
  const valid = subject && courses.some((c) => c.subjects.includes(subject)) ? subject : null;
  return <CoursesCatalog courses={courses} subject={valid} t={t} locale={locale} />;
}
