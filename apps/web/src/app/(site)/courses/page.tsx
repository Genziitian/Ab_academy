import { CoursesCatalog } from "@/components/CoursesCatalog";
import { listCourses } from "@/lib/catalog";

type CoursesPageProps = {
  searchParams: Promise<{ class?: string }>;
};

export const metadata = {
  title: "Courses",
  description:
    "Explore all batches and courses at Akhand Bharat Academy. Bihar Board Classes 9–12 available now.",
};

export default async function CoursesPage({ searchParams }: CoursesPageProps) {
  const params = await searchParams;
  const classFilter = params.class ? Number(params.class) : undefined;
  const initialClass =
    classFilter === 9 ||
    classFilter === 10 ||
    classFilter === 11 ||
    classFilter === 12
      ? classFilter
      : undefined;

  const courses = await listCourses();

  return (
    <CoursesCatalog initialCourses={courses} initialClass={initialClass} />
  );
}
