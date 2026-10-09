import Link from "next/link";
import { Card, EmptyRow, PageHeader } from "@/components/admin/AdminChrome";
import { listDoubts } from "@/lib/admin/data";
import { formatWhen } from "@/lib/admin/format";
import { replyToDoubtAction, setDoubtResolvedAction } from "./actions";

export const metadata = { title: "Doubts" };

export default async function AdminDoubtsPage({
  searchParams,
}: {
  searchParams: Promise<{ filter?: string }>;
}) {
  const { filter } = await searchParams;
  const current = filter ?? "open";

  const resolved =
    current === "open" ? false : current === "resolved" ? true : undefined;
  const doubts = await listDoubts(resolved);

  const filters = [
    { value: "open", label: "Unanswered" },
    { value: "resolved", label: "Answered" },
    { value: "all", label: "All" },
  ];

  return (
    <>
      <PageHeader
        title="Doubts"
        description="Questions students asked under a lecture. Answering one posts a reply in the app."
      />

      <div className="mb-4 flex flex-wrap gap-2">
        {filters.map((f) => (
          <Link
            key={f.value}
            href={`/admin/doubts?filter=${f.value}`}
            className={`rounded-full px-3.5 py-1.5 text-sm font-medium transition-colors ${
              current === f.value
                ? "bg-primary text-white"
                : "border border-border bg-surface text-muted hover:text-navy"
            }`}
          >
            {f.label}
          </Link>
        ))}
      </div>

      {doubts.length === 0 ? (
        <Card>
          <EmptyRow>
            {current === "open"
              ? "Nothing unanswered. Nice."
              : "No doubts here yet."}
          </EmptyRow>
        </Card>
      ) : (
        <div className="space-y-4">
          {doubts.map((doubt) => (
            <Card key={doubt.id}>
              <div className="flex flex-wrap items-start justify-between gap-3">
                <div className="min-w-0">
                  <p className="text-xs text-muted">
                    {doubt.courseTitle} · {doubt.lessonTitle}
                  </p>
                  <p className="mt-1.5 text-sm text-navy">{doubt.body}</p>
                  <p className="mt-1.5 text-xs text-muted">
                    {doubt.authorName} · {formatWhen(doubt.createdAt)}
                  </p>
                </div>

                {doubt.isResolved ? (
                  <div className="text-right">
                    <span className="inline-flex rounded-full bg-success/15 px-2.5 py-1 text-xs font-semibold text-success">
                      answered
                    </span>
                    {doubt.resolvedBy ? (
                      <p className="mt-1 text-xs text-muted">
                        by {doubt.resolvedBy}
                      </p>
                    ) : null}
                    <form action={setDoubtResolvedAction} className="mt-2">
                      <input type="hidden" name="doubtId" value={doubt.id} />
                      <input type="hidden" name="resolved" value="false" />
                      <button
                        type="submit"
                        className="text-xs font-medium text-muted hover:text-navy hover:underline"
                      >
                        Reopen
                      </button>
                    </form>
                  </div>
                ) : (
                  <span className="inline-flex rounded-full bg-orange/15 px-2.5 py-1 text-xs font-semibold text-orange">
                    waiting
                  </span>
                )}
              </div>

              {doubt.replies.length > 0 ? (
                <ul className="mt-4 space-y-3 border-t border-border pt-4">
                  {doubt.replies.map((reply) => (
                    <li
                      key={reply.id}
                      className={`rounded-xl px-3.5 py-2.5 text-sm ${
                        reply.fromStaff
                          ? "bg-primary-soft text-navy"
                          : "bg-surface-soft text-navy"
                      }`}
                    >
                      <p>{reply.body}</p>
                      <p className="mt-1 text-xs text-muted">
                        {reply.authorName} · {formatWhen(reply.createdAt)}
                      </p>
                    </li>
                  ))}
                </ul>
              ) : null}

              <form
                action={replyToDoubtAction}
                className="mt-4 border-t border-border pt-4"
              >
                <input type="hidden" name="doubtId" value={doubt.id} />
                <textarea
                  name="body"
                  rows={2}
                  required
                  placeholder="Answer this doubt…"
                  className="w-full resize-y rounded-xl border border-border bg-surface px-3 py-2 text-sm text-navy outline-none focus:border-primary"
                />
                <div className="mt-2 flex flex-wrap items-center justify-between gap-3">
                  <label className="flex items-center gap-2 text-xs text-navy">
                    <input
                      type="checkbox"
                      name="resolve"
                      defaultChecked
                      className="size-4"
                    />
                    Mark answered
                  </label>
                  <button
                    type="submit"
                    className="rounded-xl bg-primary px-4 py-2 text-sm font-semibold text-white transition-colors hover:bg-primary-dark"
                  >
                    Send reply
                  </button>
                </div>
              </form>
            </Card>
          ))}
        </div>
      )}
    </>
  );
}
