"use server";

import { revalidatePath } from "next/cache";
import { sendNotification } from "@/lib/admin/data";
import { requireAdmin } from "@/lib/admin/auth";
import type { AudienceKind } from "@/lib/admin/types";

export async function sendNotificationAction(formData: FormData) {
  await requireAdmin();

  const audienceKind = String(formData.get("audienceKind") ?? "all") as AudienceKind;
  const rawValue = String(formData.get("audienceValue") ?? "").trim();

  await sendNotification({
    title: String(formData.get("title") ?? "").trim(),
    body: String(formData.get("body") ?? "").trim(),
    audienceKind,
    audienceValue: audienceKind === "all" ? null : rawValue || null,
    deepLink: String(formData.get("deepLink") ?? "").trim() || null,
    sendPush: formData.get("sendPush") !== null,
  });

  revalidatePath("/admin/notifications");
  revalidatePath("/admin");
}
