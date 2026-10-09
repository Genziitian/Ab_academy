"use server";

import { revalidatePath } from "next/cache";
import { replyToTicket, setTicketStatus } from "@/lib/admin/data";
import { requireAdmin } from "@/lib/admin/auth";
import type { TicketStatus } from "@/lib/admin/types";

export async function replyAction(formData: FormData) {
  const ticketId = String(formData.get("ticketId") ?? "");
  await requireAdmin();

  const body = String(formData.get("body") ?? "").trim();
  if (body) await replyToTicket(ticketId, body);
  revalidatePath(`/admin/tickets/${ticketId}`);
  revalidatePath("/admin/tickets");
  revalidatePath("/admin");
}

export async function setStatusAction(formData: FormData) {
  const ticketId = String(formData.get("ticketId") ?? "");
  await requireAdmin();
  await setTicketStatus(ticketId, String(formData.get("status") ?? "open") as TicketStatus);
  revalidatePath(`/admin/tickets/${ticketId}`);
  revalidatePath("/admin/tickets");
  revalidatePath("/admin");
}
