"use server";

import { revalidatePath } from "next/cache";
import { requireSuperAdmin } from "@/lib/admin/auth";
import { createServerClient } from "@/lib/supabase/server";

/**
 * Approve (carry out) or reject a deletion request. The database function
 * checks again that the caller is a super admin, so this cannot be bypassed.
 */
export async function processDeletion(formData: FormData) {
  await requireSuperAdmin();
  const id = String(formData.get("id") ?? "");
  const approve = formData.get("decision") === "approve";
  const note = String(formData.get("note") ?? "").slice(0, 500);
  const supabase = await createServerClient();
  if (!supabase || !id) return;

  const { error } = await supabase.rpc("process_deletion_request", {
    p_id: id,
    p_approve: approve,
    p_note: note,
  });
  if (error) throw new Error(error.message);
  revalidatePath("/admin/deletions");
}
