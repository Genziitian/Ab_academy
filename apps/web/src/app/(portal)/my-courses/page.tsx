import { CourseCards, NoCourses } from "@/components/portal/CourseCards";
import { PortalTopbar } from "@/components/portal/PortalTopbar";
import { getMyCourses } from "@/lib/portal/live";

export const metadata = { title: "My courses" };

export default async function MyCoursesPage() {
  const courses = await getMyCourses();
  return (
    <>
      <PortalTopbar crumb="Your enrolled courses" title="My courses" />
      <div className="px-4 pb-16 pt-6 sm:px-8">{courses.length ? <CourseCards courses={courses} /> : <NoCourses />}</div>
    </>
  );
}
