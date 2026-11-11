import { CourseCards, NoCourses } from "@/components/portal/CourseCards";
import { PortalTopbar } from "@/components/portal/PortalTopbar";
import { getT } from "@/lib/i18n/server";
import { getMyCourses } from "@/lib/portal/live";

export const metadata = { title: "My courses" };

export default async function MyCoursesPage() {
  const [courses, { t, locale }] = await Promise.all([getMyCourses(), getT()]);
  return (
    <>
      <PortalTopbar title={t.portal.myCourses} lead={t.portal.myCoursesLead} />
      <div className="px-4 pb-16 pt-6 sm:px-8">{courses.length ? <CourseCards courses={courses} t={t} locale={locale} /> : <NoCourses t={t} />}</div>
    </>
  );
}
