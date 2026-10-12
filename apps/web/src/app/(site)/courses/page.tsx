import { CoursesCatalog } from "@/components/CoursesCatalog";
import { listCourses } from "@/lib/catalog";

type CoursesPageProps = {
  searchParams: Promise<{ class?: string }>;
};

export const metadata = {
  title: "Courses",
  description:
    "Class 11 & 12 crash courses for Bihar Board — Science, Commerce and Arts with live classes, recordings and notes.",
};

export default async function CoursesPage({ searchParams }: CoursesPageProps) {
  const params = await searchParams;
  const classFilter = Number(params.class);
  const initialClass = classFilter === 11 || classFilter === 12 ? classFilter : undefined;

  const courses = await listCourses();

  return <CoursesCatalog initialCourses={courses} initialClass={initialClass} />;
}
