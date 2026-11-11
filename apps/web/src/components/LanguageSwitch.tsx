"use client";

import { useTransition } from "react";
import { setLocaleAction } from "@/lib/i18n/actions";
import type { Locale } from "@/lib/i18n/config";
import { useLocale } from "@/lib/i18n/client";

const OPTIONS: { value: Locale; label: string; name: string }[] = [
  { value: "en", label: "EN", name: "English" },
  { value: "hi", label: "हिं", name: "हिंदी" },
];

/**
 * EN | हिं. A server action saves the choice in a cookie for a year, and
 * Next re-renders the page in the new language; the URL stays the same.
 */
export function LanguageSwitch({ tone = "light", className = "" }: { tone?: "light" | "dark"; className?: string }) {
  const locale = useLocale();
  const [pending, start] = useTransition();

  function choose(next: Locale) {
    if (next === locale) return;
    start(() => setLocaleAction(next));
  }

  const frame = tone === "dark" ? "border-white/15 bg-white/5" : "border-ab-rule bg-ab-panel";
  return (
    <div
      role="group"
      aria-label="Language · भाषा"
      aria-busy={pending}
      className={`inline-flex h-9 shrink-0 items-center rounded-full border p-[3px] ${frame} ${pending ? "opacity-70" : ""} ${className}`}
    >
      {OPTIONS.map((o) => {
        const on = o.value === locale;
        const style = on
          ? tone === "dark"
            ? "bg-white text-ab-ink"
            : "bg-ab-ink text-white"
          : tone === "dark"
            ? "text-white/60 hover:text-white"
            : "text-ab-ink-2 hover:text-ab-ink";
        return (
          <button
            key={o.value}
            type="button"
            lang={o.value}
            aria-pressed={on}
            title={o.name}
            onClick={() => choose(o.value)}
            className={`h-full min-w-[38px] rounded-full px-2.5 text-[13px] font-medium transition-colors ${style}`}
          >
            {o.label}
          </button>
        );
      })}
    </div>
  );
}
