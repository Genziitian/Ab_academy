"use client";

import { useState } from "react";
import { PlayIcon, TestIcon } from "@/components/icons";
import { useT } from "@/lib/i18n/client";

/** Chapters of a course; each opens to its lecture and practice session. */
export function CurriculumAccordion({ chapters, subject }: { chapters: string[]; subject?: string }) {
  const t = useT();
  const [open, setOpen] = useState<number[]>([0]);
  const allOpen = open.length === chapters.length;

  return (
    <section className="mt-14">
      <div className="flex flex-wrap items-end justify-between gap-3">
        <div>
          <h2 className="ab-title text-[26px]">{t.course.curriculumTitle}</h2>
          <p className="ab-num mt-1.5 text-[13px] text-ab-ink-3">
            {subject ? `${subject} · ` : ""}
            {t.course.curriculumMeta(chapters.length, chapters.length, chapters.length)}
          </p>
        </div>
        <button
          type="button"
          onClick={() => setOpen(allOpen ? [] : chapters.map((_, i) => i))}
          className="text-sm font-medium text-ab-ink underline decoration-ab-rule-strong underline-offset-4 hover:decoration-ab-ink"
        >
          {allOpen ? t.course.collapseAll : t.course.expandAll}
        </button>
      </div>

      <div className="mt-5 overflow-hidden rounded-2xl border border-ab-rule bg-ab-panel">
        {chapters.map((title, index) => {
          const isOpen = open.includes(index);
          return (
            <div key={title} className={index ? "border-t border-ab-rule" : ""}>
              <button
                type="button"
                aria-expanded={isOpen}
                onClick={() => setOpen((prev) => (prev.includes(index) ? prev.filter((i) => i !== index) : [...prev, index]))}
                className="flex w-full items-center gap-4 px-5 py-4 text-left hover:bg-ab-canvas/60"
              >
                <span className="ab-num w-7 shrink-0 text-[13px] text-ab-ink-3">{String(index + 1).padStart(2, "0")}</span>
                <span className="min-w-0 flex-1">
                  <span className="block text-[15px] font-medium text-ab-ink">{title}</span>
                  <span className="text-[13px] text-ab-ink-3">{t.course.perChapter}</span>
                </span>
                <span className="relative size-3.5 shrink-0 text-ab-ink-3" aria-hidden>
                  <span className="absolute inset-x-0 top-1/2 h-px -translate-y-1/2 bg-current" />
                  <span className={`absolute inset-y-0 left-1/2 w-px -translate-x-1/2 bg-current transition-transform ${isOpen ? "scale-y-0" : ""}`} />
                </span>
              </button>
              {isOpen ? (
                <ul className="flex flex-col gap-1 px-5 pb-4 sm:pl-[64px]">
                  {[
                    [t.course.lectureOf(title), t.course.lectureTag, PlayIcon],
                    [t.course.practiceOf(title), t.course.practiceTag, TestIcon],
                  ].map(([label, tag, Icon]) => {
                    const I = Icon as typeof PlayIcon;
                    return (
                      <li key={label as string} className="flex items-center gap-3 rounded-[10px] bg-ab-canvas px-3 py-2.5 text-sm">
                        <I size={13} className="shrink-0 text-ab-ink-2" />
                        <span className="min-w-0 flex-1 text-ab-ink">{label as string}</span>
                        <span className="whitespace-nowrap text-xs text-ab-ink-3">{tag as string}</span>
                      </li>
                    );
                  })}
                </ul>
              ) : null}
            </div>
          );
        })}
      </div>
    </section>
  );
}

export function FaqList({ faqs }: { faqs: [string, string][] }) {
  return (
    <div className="mt-5 overflow-hidden rounded-2xl border border-ab-rule bg-ab-panel">
      {faqs.map(([q, a], i) => (
        <details key={q} open={i === 0} className="group border-b border-ab-rule last:border-b-0">
          <summary className="flex cursor-pointer list-none justify-between gap-4 px-5 py-4 text-[15px] font-medium text-ab-ink">
            {q}
            <span className="relative mt-1 size-3.5 shrink-0 text-ab-ink-3" aria-hidden>
              <span className="absolute inset-x-0 top-1/2 h-px -translate-y-1/2 bg-current" />
              <span className="absolute inset-y-0 left-1/2 w-px -translate-x-1/2 bg-current transition-transform group-open:scale-y-0" />
            </span>
          </summary>
          <p className="px-5 pb-5 text-[15px] leading-[1.6] text-ab-ink-2">{a}</p>
        </details>
      ))}
    </div>
  );
}
