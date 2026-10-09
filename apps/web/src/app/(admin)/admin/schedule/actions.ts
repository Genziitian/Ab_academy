"use server";

import { revalidatePath } from "next/cache";
import { deleteSession, saveSession } from "@/lib/admin/data";
import { requireAdmin } from "@/lib/admin/auth";

export async function saveSessionAction(formData: FormData) {
  await requireAdmin();

  await saveSession({
    title: String(formData.get("title") ?? "").trim(),
    courseId: String(formData.get("courseId") ?? ""),
    subject: String(formData.get("subject") ?? "").trim(),
    teacher: String(formData.get("teacher") ?? "").trim(),
    startsAt: String(formData.get("startsAt") ?? ""),
    durationMinutes: Number(formData.get("durationMinutes") ?? 60),
  });
  revalidatePath("/admin/schedule");
  revalidatePath("/admin");
}

export async function deleteSessionAction(formData: FormData) {
  await requireAdmin();
  await deleteSession(String(formData.get("id") ?? ""));
  revalidatePath("/admin/schedule");
  revalidatePath("/admin");
}
