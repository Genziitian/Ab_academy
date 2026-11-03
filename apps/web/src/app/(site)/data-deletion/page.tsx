import Link from "next/link";
import { LegalPage } from "@/components/LegalPage";
import { CONTACT } from "@/lib/landing";
import { createServerClient } from "@/lib/supabase/server";
import { cancelDeletion } from "./actions";
import { DeletionForm } from "./DeletionForm";

export const metadata = {
  title: "Data & Account Deletion",
  description: "Ask AB Academy to delete your data or your whole account.",
};

type Request = {
  id: string;
  kind: "data" | "account";
  status: "pending" | "completed" | "rejected" | "cancelled";
  requested_at: string;
  due_at: string;
};

const fmt = (iso: string) =>
  new Date(iso).toLocaleDateString("en-IN", { day: "numeric", month: "short", year: "numeric" });

async function myRequests() {
  const supabase = await createServerClient();
  if (!supabase) return { signedIn: false, requests: [] as Request[] };
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) return { signedIn: false, requests: [] as Request[] };
  const { data } = await supabase
    .from("deletion_requests")
    .select("id, kind, status, requested_at, due_at")
    .eq("user_id", user.id)
    .order("requested_at", { ascending: false })
    .limit(10);
  return { signedIn: true, requests: (data ?? []) as Request[] };
}

export default async function DataDeletionPage() {
  const { signedIn, requests } = await myRequests();
  const hasPending = requests.some((r) => r.status === "pending");

  return (
    <LegalPage
      active="/data-deletion"
      title="Data & account deletion"
      intro="You can ask us to delete your personal data, or your whole AB Academy account, at any time — from the app (More → Delete account or data) or on this page. We complete every request within 3 days."
      sections={[
        {
          heading: "What “Delete my data” removes",
          body: [
            [
              "Your name, profile photo and school.",
              "Doubts and comments you posted, lecture ratings and support tickets.",
              "Notification and pop-up history, and the app's push-notification tokens.",
            ],
            "Your account, sign-in and the courses you bought stay, so you can keep studying.",
          ],
        },
        {
          heading: "What “Delete my account” removes",
          body: [
            "Everything above, plus your sign-in, profile, class details, enrolments and progress. The account cannot be restored, and access to courses you bought ends.",
          ],
        },
        {
          heading: "What we keep, and why",
          body: [
            "Orders and payment records are kept, separated from your name, for as long as Indian tax law requires (typically up to 8 years). A short record that you asked for deletion is kept, with your contact details masked.",
          ],
        },
        {
          heading: "Can't sign in?",
          body: [
            `Email ${CONTACT.email} from the email address on your account, or include the mobile number you sign in with, and write “Delete my account” or “Delete my data”. We verify it is you and complete the request within 3 days.`,
          ],
        },
      ]}
    >
      <div className="rounded-3xl border border-border bg-white p-5 sm:p-7">
        {signedIn ? (
          <>
            {requests.length ? (
              <div className="mb-6">
                <h2 className="text-lg font-bold text-navy">Your requests</h2>
                <ul className="mt-3 divide-y divide-border rounded-2xl border border-border">
                  {requests.map((r) => (
                    <li key={r.id} className="flex flex-wrap items-center justify-between gap-3 px-4 py-3.5 text-[15px]">
                      <span>
                        <span className="font-semibold text-navy">
                          {r.kind === "account" ? "Delete account" : "Delete data"}
                        </span>
                        <span className="block text-sm text-muted">
                          Requested {fmt(r.requested_at)}
                          {r.status === "pending" ? ` · done by ${fmt(r.due_at)}` : ""}
                        </span>
                      </span>
                      <span className="flex items-center gap-3">
                        <span className="rounded-full bg-surface-grey px-3 py-1 text-xs font-bold uppercase tracking-[0.08em] text-ink">
                          {r.status}
                        </span>
                        {r.status === "pending" ? (
                          <form action={cancelDeletion}>
                            <input type="hidden" name="id" value={r.id} />
                            <button type="submit" className="text-sm font-semibold text-primary hover:underline">
                              Cancel
                            </button>
                          </form>
                        ) : null}
                      </span>
                    </li>
                  ))}
                </ul>
              </div>
            ) : null}
            {hasPending ? (
              <p className="text-[15px] text-ink">
                You have a request in progress. You can cancel it above until it is completed.
              </p>
            ) : (
              <DeletionForm />
            )}
          </>
        ) : (
          <div className="flex flex-col gap-4">
            <p className="text-[15px] leading-[1.6] text-ink">
              Sign in with the mobile number or Google account you use for AB Academy to send a request.
            </p>
            <div className="flex flex-col gap-3 sm:flex-row">
              <Link
                href="/login?next=/data-deletion"
                className="flex h-12 items-center justify-center rounded-full bg-primary px-6 text-[15px] font-semibold text-white hover:bg-primary-dark"
              >
                Sign in to request deletion
              </Link>
              <a
                href={`mailto:${CONTACT.email}?subject=${encodeURIComponent("Delete my AB Academy account")}`}
                className="flex h-12 items-center justify-center rounded-full border border-primary-line px-6 text-[15px] font-semibold text-primary hover:bg-primary-soft"
              >
                Email {CONTACT.email}
              </a>
            </div>
          </div>
        )}
      </div>
    </LegalPage>
  );
}
