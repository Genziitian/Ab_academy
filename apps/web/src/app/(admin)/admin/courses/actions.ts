"use server";

import { revalidatePath } from "next/cache";
import { redirect } from "next/navigation";
import { deleteCourse, saveCourse } from "@/lib/admin/data";
import { requireFullAdmin } from "@/lib/admin/auth";

export async function saveCourseAction(formData: FormData) {
  await requireFullAdmin();

  const id = String(formData.get("id") ?? "").trim();
  const subjects = String(formData.get("subjects") ?? "")
    .split(",")
    .map((s) => s.trim())
    .filter(Boolean);
  const teachers = String(formData.get("teachers") ?? "")
    .split(",")
    .map((s) => s.trim())
    .filter(Boolean);

  await saveCourse({
    id: id || undefined,
    title: String(formData.get("title") ?? "").trim(),
    classLevel: Number(formData.get("classLevel") ?? 10),
    board: String(formData.get("board") ?? "Bihar Board"),
    medium: String(formData.get("medium") ?? "Hindi"),
    priceInr: Number(formData.get("priceInr") ?? 0),
    originalPriceInr: Number(formData.get("originalPriceInr") ?? 0),
    subjects,
    teachers,
    description: String(formData.get("description") ?? "").trim(),
    highlights: String(formData.get("highlights") ?? "")
      .split("\n")
      .map((s) => s.trim())
      .filter(Boolean),
    isPublished: formData.get("isPublished") === "on",
  });

  revalidatePath("/admin/courses");
  revalidatePath("/admin");
  revalidatePath("/courses");
  if (id) redirect("/admin/courses");
}

export async function deleteCourseAction(formData: FormData) {
  await requireFullAdmin();
  await deleteCourse(String(formData.get("id") ?? ""));
  revalidatePath("/admin/courses");
  revalidatePath("/admin");
}
