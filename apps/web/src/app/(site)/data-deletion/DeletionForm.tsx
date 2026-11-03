"use client";

import { useActionState, useState } from "react";
import { type DeletionResult, requestDeletion } from "./actions";

const OPTIONS = [
  {
    kind: "data",
    title: "Delete my data",
    body: "Erase my name, school, doubts, comments, tickets and history. Keep my account and courses.",
  },
  {
    kind: "account",
    title: "Delete my account",
    body: "Erase everything above and close my account for good, including access to courses I bought.",
  },
] as const;

export function DeletionForm() {
  const [kind, setKind] = useState<"data" | "account">("data");
  const [state, action, pending] = useActionState<DeletionResult, FormData>(requestDeletion, {});

  if (state.ok) {
    return (
      <p role="status" className="rounded-2xl bg-primary-soft px-5 py-4 text-[15px] font-medium text-primary">
        Request received. We will complete it within 3 days and you can track it above.
      </p>
    );
  }

  return (
    <form action={action} className="flex flex-col gap-4">
      <fieldset className="grid gap-3 sm:grid-cols-2">
        <legend className="mb-2 text-sm font-semibold text-muted">What should we delete?</legend>
        {OPTIONS.map((o) => (
          <label
            key={o.kind}
            className={`flex cursor-pointer flex-col gap-1.5 rounded-2xl border-2 p-4 ${
              kind === o.kind ? "border-primary bg-primary-soft" : "border-border bg-white"
            }`}
          >
            <span className="flex items-center gap-2.5 font-semibold text-navy">
              <input
                type="radio"
                name="kind"
                value={o.kind}
                checked={kind === o.kind}
                onChange={() => setKind(o.kind)}
                className="size-4 accent-[var(--primary)]"
              />
              {o.title}
            </span>
            <span className="text-sm leading-[1.55] text-ink">{o.body}</span>
          </label>
        ))}
      </fieldset>

      <label className="flex flex-col gap-1.5 text-sm font-semibold text-muted" htmlFor="deletion-reason">
        Reason (optional)
        <textarea
          id="deletion-reason"
          name="reason"
          rows={3}
          maxLength={1000}
          className="rounded-xl border border-field bg-white px-3.5 py-3 text-[15px] font-normal text-navy outline-none focus:border-primary"
        />
      </label>

      <label className="flex items-start gap-2.5 text-[15px] text-ink" htmlFor="deletion-confirm">
        <input id="deletion-confirm" type="checkbox" name="confirm" className="mt-1 size-4 accent-[var(--primary)]" />
        {kind === "account"
          ? "I understand my account and course access will be permanently deleted and cannot be restored."
          : "I understand my personal data and activity will be permanently erased."}
      </label>

      {state.error ? (
        <p role="alert" className="text-sm font-medium text-danger">
          {state.error}
        </p>
      ) : null}

      <button
        type="submit"
        disabled={pending}
        className="h-12 w-full rounded-full bg-danger px-6 text-[15px] font-semibold text-white hover:opacity-90 disabled:opacity-60 sm:w-fit"
      >
        {pending ? "Sending…" : kind === "account" ? "Request account deletion" : "Request data deletion"}
      </button>
    </form>
  );
}
