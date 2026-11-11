import Link from "next/link";
import { LegalPage } from "@/components/LegalPage";
import { btn } from "@/components/ui";
import { formatDate } from "@/lib/i18n/config";
import { legalDoc } from "@/lib/i18n/legal";
import { getT } from "@/lib/i18n/server";
import { CONTACT } from "@/lib/landing";
import { createServerClient } from "@/lib/supabase/server";
import { cancelDeletion } from "./actions";
import { DeletionForm } from "./DeletionForm";

export async function generateMetadata() {
  const { locale } = await getT();
  const doc = legalDoc("deletion", locale);
  return { title: doc.title, description: doc.description };
}

type Request = {
  id: string;
  kind: "data" | "account";
  status: "pending" | "completed" | "rejected" | "cancelled";
  requested_at: string;
  due_at: string;
};

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
  const [{ signedIn, requests }, { t, locale }] = await Promise.all([myRequests(), getT()]);
  const d = t.deletion;
  const hasPending = requests.some((r) => r.status === "pending");

  return (
    <LegalPage active="/data-deletion" doc={legalDoc("deletion", locale)} t={t} locale={locale}>
      <div className="rounded-[22px] border border-ab-rule bg-ab-panel p-5 sm:p-7">
        {signedIn ? (
          <>
            {requests.length ? (
              <div className="mb-6">
                <h2 className="ab-title text-lg">{d.yourRequests}</h2>
                <ul className="mt-3 divide-y divide-ab-rule rounded-xl border border-ab-rule">
                  {requests.map((r) => (
                    <li key={r.id} className="flex flex-wrap items-center justify-between gap-3 px-4 py-3.5 text-[15px]">
                      <span>
                        <span className="font-medium text-ab-ink">{r.kind === "account" ? d.deleteAccount : d.deleteData}</span>
                        <span className="block text-sm text-ab-ink-3">
                          {d.requested(formatDate(r.requested_at, locale))}
                          {r.status === "pending" ? ` · ${d.doneBy(formatDate(r.due_at, locale))}` : ""}
                        </span>
                      </span>
                      <span className="flex items-center gap-3">
                        <span className="rounded-full border border-ab-rule bg-ab-canvas px-2.5 py-1 text-xs text-ab-ink-2">{d.status[r.status]}</span>
                        {r.status === "pending" ? (
                          <form action={cancelDeletion}>
                            <input type="hidden" name="id" value={r.id} />
                            <button type="submit" className="text-sm font-medium text-ab-ink underline underline-offset-4">
                              {d.cancel}
                            </button>
                          </form>
                        ) : null}
                      </span>
                    </li>
                  ))}
                </ul>
              </div>
            ) : null}
            {hasPending ? <p className="text-[15px] text-ab-ink-2">{d.inProgress}</p> : <DeletionForm />}
          </>
        ) : (
          <div className="flex flex-col gap-4">
            <p className="text-[15px] leading-[1.6] text-ab-ink-2">{d.signInNote}</p>
            <div className="flex flex-col gap-3 sm:flex-row">
              <Link href="/login?next=/data-deletion" className={btn.primary}>
                {d.signIn}
              </Link>
              <a href={`mailto:${CONTACT.email}?subject=${encodeURIComponent("Delete my AB Academy account")}`} className={btn.secondary}>
                {d.emailUs(CONTACT.email)}
              </a>
            </div>
          </div>
        )}
      </div>
    </LegalPage>
  );
}
