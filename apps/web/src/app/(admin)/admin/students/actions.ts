"use server";

import { revalidatePath } from "next/cache";
import { requireAdmin, requireFullAdmin } from "@/lib/admin/auth";
import { enrollStudent, saveStudent, unenrollStudent } from "@/lib/admin/data";

export async function saveStudentAction(formData: FormData) {
  await requireAdmin();

  const classLevel = Number(formData.get("classLevel") ?? 0);
  await saveStudent({
    id: String(formData.get("id") ?? ""),
    fullName: String(formData.get("fullName") ?? "").trim(),
    classLevel: classLevel >= 9 && classLevel <= 12 ? classLevel : null,
    medium: String(formData.get("medium") ?? "") || null,
    stream: String(formData.get("stream") ?? "").trim() || null,
    school: String(formData.get("school") ?? "").trim() || null,
  });

  revalidatePath("/admin/students");
}

/** Manual enrolment covers offline payments and comped access. */
export async function enrollAction(formData: FormData) {
  await requireFullAdmin();
  await enrollStudent(
    String(formData.get("studentId") ?? ""),
    String(formData.get("courseId") ?? ""),
  );
  revalidatePath("/admin/students");
  revalidatePath("/admin");
}

export async function unenrollAction(formData: FormData) {
  await requireFullAdmin();
  await unenrollStudent(
    String(formData.get("studentId") ?? ""),
    String(formData.get("courseId") ?? ""),
  );
  revalidatePath("/admin/students");
  revalidatePath("/admin");
}
