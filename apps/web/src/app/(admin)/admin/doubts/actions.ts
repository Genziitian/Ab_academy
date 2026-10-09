"use server";

import { revalidatePath } from "next/cache";
import { requireAdmin } from "@/lib/admin/auth";
import { replyToDoubt, setDoubtResolved } from "@/lib/admin/data";

export async function replyToDoubtAction(formData: FormData) {
  await requireAdmin();

  const id = String(formData.get("doubtId") ?? "");
  const body = String(formData.get("body") ?? "").trim();
  if (!body) return;

  await replyToDoubt(id, body);

  // Answering a doubt closes it; reopen by hand if the student follows up.
  if (formData.get("resolve") !== null) await setDoubtResolved(id, true);

  revalidatePath("/admin/doubts");
  revalidatePath("/admin");
}

export async function setDoubtResolvedAction(formData: FormData) {
  await requireAdmin();
  await setDoubtResolved(
    String(formData.get("doubtId") ?? ""),
    formData.get("resolved") === "true",
  );
  revalidatePath("/admin/doubts");
  revalidatePath("/admin");
}
