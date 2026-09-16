"use client";

import { useState } from "react";
import { CurriculumChapter } from "@/lib/courses";

export function CurriculumAccordion({
  chapters,
}: {
  chapters: CurriculumChapter[];
}) {
  const [openId, setOpenId] = useState<number | null>(0);
  const [expandAll, setExpandAll] = useState(false);

  const totalLectures = chapters.reduce((sum, c) => sum + c.lectures, 0);
  const totalNotes = chapters.reduce((sum, c) => sum + c.notes, 0);

  return (
    <section className="mt-12">
      <div className="flex flex-wrap items-end justify-between gap-3">
        <div>
          <h2 className="text-xl font-extrabold text-navy sm:text-2xl">
            Curriculum Structure
          </h2>
          <p className="mt-1 text-sm text-muted">
            {chapters.length} units · {totalLectures} lectures · {totalNotes}{" "}
            notes
          </p>
        </div>
        <button
          type="button"
          onClick={() => {
            setExpandAll((v) => !v);
            setOpenId(expandAll ? null : 0);
          }}
          className="text-sm font-semibold text-primary hover:underline"
        >
          {expandAll ? "Collapse all" : "Expand all chapters"}
        </button>
      </div>

      <div className="mt-5 space-y-3">
        {chapters.map((chapter, index) => {
          const open = expandAll || openId === index;
          return (
            <div
              key={chapter.title}
              className="overflow-hidden rounded-2xl border border-border bg-white"
            >
              <button
                type="button"
                className="flex w-full items-center gap-3 px-4 py-4 text-left sm:px-5"
                onClick={() =>
                  setOpenId((current) => (current === index ? null : index))
                }
              >
                <span className="flex h-9 w-9 shrink-0 items-center justify-center rounded-xl bg-primary-soft text-sm font-bold text-primary">
                  {String(index + 1).padStart(2, "0")}
                </span>
                <span className="min-w-0 flex-1">
                  <span className="block font-bold text-navy">
                    {chapter.title}
                  </span>
                  <span className="text-xs text-muted">
                    {chapter.lectures} lectures · {chapter.notes} notes
                  </span>
                </span>
                <span className="text-muted">{open ? "−" : "+"}</span>
              </button>

              {open ? (
                <ul className="space-y-2 border-t border-border bg-[#fafbff] px-4 py-3 sm:px-5">
                  {chapter.lessons.map((lesson) => (
                    <li
                      key={lesson.title}
                      className="flex flex-wrap items-center justify-between gap-2 rounded-xl bg-white px-3 py-2.5 text-sm"
                    >
                      <span className="font-medium text-navy">
                        ▶ {lesson.title}
                      </span>
                      <span className="flex items-center gap-3 text-xs text-muted">
                        <span>{lesson.duration}</span>
                        {lesson.hasNotes ? (
                          <span className="rounded-md bg-primary-soft px-2 py-0.5 font-semibold text-primary">
                            Notes PDF
                          </span>
                        ) : null}
                      </span>
                    </li>
                  ))}
                </ul>
              ) : null}
            </div>
          );
        })}
      </div>
    </section>
  );
}
