"use client";

import { useState } from "react";
import { PlayIcon } from "@/components/icons";
import type { CurriculumChapter } from "@/lib/courses";

export function CurriculumAccordion({
  chapters,
  subject,
}: {
  chapters: CurriculumChapter[];
  subject?: string;
}) {
  const [open, setOpen] = useState<number[]>([0]);
  const [all, setAll] = useState(false);

  const totalLectures = chapters.reduce((sum, c) => sum + c.lectures, 0);
  const totalNotes = chapters.reduce((sum, c) => sum + c.notes, 0);

  return (
    <section className="mt-12">
      <div className="flex flex-wrap items-end justify-between gap-3">
        <div>
          <h2 className="text-2xl font-bold tracking-[-0.01em] text-navy">
            Curriculum Structure
          </h2>
          <p className="mt-1.5 text-sm text-muted">
            {subject ? `${subject} · ` : ""}
            {chapters.length} units shown · {totalLectures} lectures · {totalNotes} notes
          </p>
        </div>
        <button
          type="button"
          onClick={() => {
            setAll(!all);
            setOpen(all ? [] : [0]);
          }}
          className="text-sm font-semibold text-primary"
        >
          {all ? "Collapse all" : "Expand all chapters"}
        </button>
      </div>

      <div className="mt-5 overflow-hidden rounded-xl border border-border bg-white">
        {chapters.map((chapter, index) => {
          const isOpen = all || open.includes(index);
          return (
            <div key={chapter.title} className={index ? "border-t border-border" : ""}>
              <button
                type="button"
                aria-expanded={isOpen}
                onClick={() =>
                  setOpen((prev) =>
                    prev.includes(index)
                      ? prev.filter((i) => i !== index)
                      : [...prev, index],
                  )
                }
                className="flex w-full items-center gap-3.5 bg-white px-5 py-4 text-left"
              >
                <span className="flex size-[34px] shrink-0 items-center justify-center rounded-lg bg-primary-soft text-[13px] font-semibold text-primary">
                  {String(index + 1).padStart(2, "0")}
                </span>
                <span className="min-w-0 flex-1">
                  <span className="block text-[15px] font-semibold text-navy">
                    {chapter.title}
                  </span>
                  <span className="text-[13px] text-muted">
                    {chapter.lectures} lectures · {chapter.notes} notes
                  </span>
                </span>
                <span className="text-lg text-muted">{isOpen ? "−" : "+"}</span>
              </button>
              {isOpen ? (
                <div className="flex flex-col gap-0.5 pb-4 pl-5 pr-5 pt-1 sm:pl-[68px]">
                  {chapter.lessons.map((lesson) => (
                    <div
                      key={lesson.title}
                      className="flex items-center gap-3 rounded-lg bg-surface-grey px-3 py-2.5 text-sm"
                    >
                      <PlayIcon size={14} className="shrink-0 text-muted" />
                      <span className="min-w-0 flex-1 text-navy">{lesson.title}</span>
                      <span className="text-[13px] text-muted">{lesson.duration}</span>
                      <span
                        className={`hidden whitespace-nowrap rounded bg-primary-soft px-2 py-0.5 text-xs font-semibold text-primary sm:inline ${
                          lesson.hasNotes ? "" : "invisible"
                        }`}
                      >
                        Notes PDF
                      </span>
                    </div>
                  ))}
                </div>
              ) : null}
            </div>
          );
        })}
      </div>
    </section>
  );
}

export function FaqAccordion({ faqs }: { faqs: { q: string; a: string }[] }) {
  const [open, setOpen] = useState(0);

  return (
    <div className="mt-5 overflow-hidden rounded-xl border border-border bg-white">
      {faqs.map((faq, index) => {
        const isOpen = open === index;
        return (
          <div key={faq.q} className={index ? "border-t border-border" : ""}>
            <button
              type="button"
              aria-expanded={isOpen}
              onClick={() => setOpen(isOpen ? -1 : index)}
              className="flex w-full justify-between gap-4 bg-white px-5 py-[18px] text-left text-[15px] font-semibold text-navy"
            >
              {faq.q}
              <span className="text-muted">{isOpen ? "−" : "+"}</span>
            </button>
            {isOpen ? (
              <p className="px-5 pb-[18px] text-sm leading-[1.6] text-muted">{faq.a}</p>
            ) : null}
          </div>
        );
      })}
    </div>
  );
}
