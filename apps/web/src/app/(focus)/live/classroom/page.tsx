import { classroom } from "@/lib/portal/data";
import { getStudent } from "@/lib/portal/student";
import { Classroom } from "./Classroom";

export const metadata = {
  title: "Live Classroom",
  robots: { index: false, follow: false },
};

export default async function LiveClassroomPage() {
  const student = await getStudent();
  return <Classroom data={classroom} studentInitials={student.initials} />;
}
