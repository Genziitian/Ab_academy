"use client";

import { useActionState, useState } from "react";
import { btn, field } from "@/components/ui";
import { useT } from "@/lib/i18n/client";
import { type DeletionResult, requestDeletion } from "./actions";

export function DeletionForm() {
  const t = useT();
  const d = t.deletion;
  const [kind, setKind] = useState<"data" | "account">("data");
  const [state, action, pending] = useActionState<DeletionResult, FormData>(requestDeletion, {});

  if (state.ok) {
    return (
      <p role="status" className="rounded-xl border border-[#cfe5d7] bg-ab-live-soft px-5 py-4 text-[15px] text-ab-live">
        {d.received}
      </p>
    );
  }

  return (
    <form action={action} className="flex flex-col gap-5">
      <fieldset className="grid gap-3 sm:grid-cols-2">
        <legend className="mb-2.5 text-sm font-medium text-ab-ink">{d.what}</legend>
        {d.options.map(([value, title, body]) => {
          const on = kind === value;
          return (
            <label
              key={value}
              className={`flex cursor-pointer flex-col gap-1.5 rounded-xl border p-4 transition-colors ${
                on ? "border-ab-ink shadow-[inset_0_0_0_1px_var(--color-ab-ink)]" : "border-ab-rule hover:border-ab-rule-strong"
              }`}
            >
              <span className="flex items-center gap-2.5 font-medium text-ab-ink">
                <input
                  type="radio"
                  name="kind"
                  value={value}
                  checked={on}
                  onChange={() => setKind(value as "data" | "account")}
                  className="size-4 accent-[var(--color-ab-ink)]"
                />
                {title}
              </span>
              <span className="text-sm leading-[1.55] text-ab-ink-2">{body}</span>
            </label>
          );
        })}
      </fieldset>

      <label className="block text-sm font-medium text-ab-ink" htmlFor="deletion-reason">
        {d.reason}
        <textarea id="deletion-reason" name="reason" rows={3} maxLength={1000} className={`${field} h-auto py-2.5`} />
      </label>

      <label className="flex items-start gap-2.5 text-[15px] text-ab-ink-2" htmlFor="deletion-confirm">
        <input id="deletion-confirm" type="checkbox" name="confirm" className="mt-1 size-4 accent-[var(--color-ab-ink)]" />
        {kind === "account" ? d.confirmAccount : d.confirmData}
      </label>

      {state.error ? (
        <p role="alert" className="text-sm font-medium text-ab-danger">
          {state.error}
        </p>
      ) : null}

      <button type="submit" disabled={pending} className={`${btn.primary} !bg-ab-danger hover:!bg-[#8f1c13] sm:w-fit`}>
        {pending ? d.sending : kind === "account" ? d.requestAccount : d.requestData}
      </button>
    </form>
  );
}
