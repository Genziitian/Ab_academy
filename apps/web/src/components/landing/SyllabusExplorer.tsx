"use client";

import { useState } from "react";
import { Check } from "@/components/ui";
import { useLocale, useT } from "@/lib/i18n/client";
import { syllabusFor } from "@/lib/i18n/content";
import type { SubjectKey } from "@/lib/landing";

const SUBJECTS: SubjectKey[] = ["Physics", "Chemistry", "Maths"];
const pad = (n: number) => String(n).padStart(2, "0");

/** Subject tabs, the chapter register, and what each chapter includes. */
export function SyllabusExplorer() {
  const t = useT();
  const locale = useLocale();
  const syllabus = syllabusFor(locale);
  const [subject, setSubject] = useState<SubjectKey>("Physics");
  const [sel, setSel] = useState(0);
  const chapters = syllabus[subject];
  const index = Math.min(sel, chapters.length - 1);

  return (
    <div className="grid gap-5 lg:grid-cols-[1fr_380px]">
      <div className="rounded-2xl border border-ab-rule bg-ab-panel">
        <div className="flex flex-wrap items-center justify-between gap-3 border-b border-ab-rule p-3">
          <div role="tablist" aria-label={t.home.syllabusEyebrow} className="inline-flex rounded-[12px] bg-ab-canvas p-1">
            {SUBJECTS.map((s) => {
              const on = s === subject;
              return (
                <button
                  key={s}
                  type="button"
                  role="tab"
                  aria-selected={on}
                  onClick={() => {
                    setSubject(s);
                    setSel(0);
                  }}
                  className={`h-9 rounded-[9px] px-4 text-[15px] transition-colors ${
                    on ? "bg-ab-panel font-medium text-ab-ink shadow-[0_0_0_1px_var(--color-ab-rule)]" : "text-ab-ink-2 hover:text-ab-ink"
                  }`}
                >
                  {t.common.subjects[s]}
                </button>
              );
            })}
          </div>
          <span className="ab-num px-2 text-[13px] text-ab-ink-3">{t.common.chapters(chapters.length)}</span>
        </div>

        <ol className="grid sm:grid-cols-2">
          {chapters.map((name, i) => {
            const on = i === index;
            return (
              <li key={name} className="border-b border-ab-rule sm:odd:border-r">
                <button
                  type="button"
                  aria-pressed={on}
                  onClick={() => setSel(i)}
                  className={`flex w-full items-center gap-4 px-5 py-3.5 text-left transition-colors ${on ? "bg-ab-canvas" : "hover:bg-ab-canvas/60"}`}
                >
                  <span className={`ab-num w-7 shrink-0 text-[13px] ${on ? "text-ab-accent-ink" : "text-ab-ink-3"}`}>{pad(i + 1)}</span>
                  <span className={`min-w-0 flex-1 text-[15px] ${on ? "font-medium text-ab-ink" : "text-ab-ink-2"}`}>{name}</span>
                  <span className={`size-1.5 shrink-0 rounded-full ${on ? "bg-ab-accent" : "bg-transparent"}`} />
                </button>
              </li>
            );
          })}
        </ol>
      </div>

      <div className="flex flex-col rounded-2xl bg-ab-ink p-6 text-white sm:p-7 lg:sticky lg:top-24 lg:self-start" aria-live="polite">
        <p className="ab-num text-[13px] text-white/50">
          {t.common.subjects[subject]} · {t.home.chapter} {pad(index + 1)}
        </p>
        <h3 className="ab-title mt-3 text-[28px] sm:text-[32px]">{chapters[index]}</h3>
        <dl className="mt-10">
          {t.home.included.map((k) => (
            <div key={k} className="flex items-center justify-between border-t border-white/10 py-3.5">
              <dt className="text-white/75">{k}</dt>
              <dd className="flex items-center gap-1.5 text-sm text-white">
                <Check size={14} className="text-ab-accent" />
                {t.home.includedValue}
              </dd>
            </div>
          ))}
        </dl>
      </div>
    </div>
  );
}
