import { PortalTopbar } from "@/components/portal/PortalTopbar";
import { enrolledCourses, materials } from "@/lib/portal/data";
import { MaterialsTable } from "./MaterialsTable";

export const metadata = { title: "Study Materials" };

export default function StudyMaterialsPage() {
  const subjects = [...new Set(enrolledCourses.flatMap((c) => c.subjects))];
  return (
    <>
      <PortalTopbar title="Study Materials" />
      <MaterialsTable items={materials} subjects={subjects} />
    </>
  );
}
