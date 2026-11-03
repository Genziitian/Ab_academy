import { redirect } from "next/navigation";

// Lectures and notes are now managed inside each course.
export default function AdminContentPage() {
  redirect("/admin/courses");
}
