import { notFound } from "next/navigation";
import { PortalTopbar } from "@/components/portal/PortalTopbar";
import { currentChapter, enrolledCourses, getLecture } from "@/lib/portal/data";
import { getStudent } from "@/lib/portal/student";
import { LectureView } from "./LectureView";

export async function generateMetadata({ params }: { params: Promise<{ lessonId: string }> }) {
  const { lessonId } = await params;
  return { title: getLecture(lessonId)?.title ?? "Lecture" };
}

export default async function LecturePage({
  params,
}: {
  params: Promise<{ lessonId: string }>;
}) {
  const { lessonId } = await params;
  const lecture = getLecture(lessonId);
  if (!lecture) notFound();
  const student = await getStudent();

  const lessons = currentChapter.lessons ?? [];

  return (
    <>
      <PortalTopbar
        title={`${lecture.chapterTitle} · ${lecture.title.split(" — ")[1] ?? lecture.title}`}
        crumb={`My Courses › ${enrolledCourses[0].title} › ${lecture.subject}`}
      />
      <LectureView
        lecture={lecture}
        playlist={lessons}
        chapterLabel={`${currentChapter.title} · ${currentChapter.done} / ${currentChapter.total} lessons`}
        studentInitials={student.initials}
      />
    </>
  );
}
