import { PortalTopbar } from "@/components/portal/PortalTopbar";
import { enrolledCourses } from "@/lib/portal/data";
import { MyCourses } from "./MyCourses";

export const metadata = { title: "My Courses" };

export default async function MyCoursesPage({
  searchParams,
}: {
  searchParams: Promise<{ course?: string }>;
}) {
  const { course } = await searchParams;
  const index = Math.max(
    0,
    enrolledCourses.findIndex((c) => c.id === course),
  );

  return (
    <>
      <PortalTopbar title="My Courses" />
      <MyCourses courses={enrolledCourses} initialCourse={index} />
    </>
  );
}
