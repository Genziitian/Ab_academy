"use server";

import { revalidatePath } from "next/cache";
import { requireAdmin } from "@/lib/admin/auth";
import { deleteCommunityMessage, postCommunityMessage } from "@/lib/admin/data";

export async function postAnnouncementAction(formData: FormData) {
  await requireAdmin();

  const courseId = String(formData.get("courseId") ?? "");
  const body = String(formData.get("body") ?? "").trim();
  if (!body) return;

  await postCommunityMessage(courseId, body, formData.get("pinned") !== null);

  revalidatePath(`/admin/communities/${courseId}`);
  revalidatePath("/admin/communities");
}

export async function deleteMessageAction(formData: FormData) {
  await requireAdmin();

  const courseId = String(formData.get("courseId") ?? "");
  await deleteCommunityMessage(courseId, String(formData.get("messageId") ?? ""));

  revalidatePath(`/admin/communities/${courseId}`);
  revalidatePath("/admin/communities");
}
