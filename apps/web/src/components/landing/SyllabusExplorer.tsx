"use client";

import { useState } from "react";
import { SYLLABUS, type SubjectKey } from "@/lib/landing";

const SUBJECTS = Object.keys(SYLLABUS) as SubjectKey[];
const pad = (n: number) => String(n).padStart(2, "0");

/** Subject tabs, the chapter grid, and what each chapter includes. */
export function SyllabusExplorer() {
  const [subject, setSubject] = useState<SubjectKey>("Physics");
  const [sel, setSel] = useState(0);
  const chapters = SYLLABUS[subject];
  const index = Math.min(sel, chapters.length - 1);

  return (
    <div className="rounded-3xl border border-sand bg-paper p-4 sm:p-8">
      <div className="flex flex-wrap items-center justify-between gap-4">
        <div className="flex flex-wrap gap-2" role="tablist" aria-label="Subject">
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
                className={`h-11 rounded-full border px-5 text-[15px] font-semibold transition-colors ${
                  on ? "border-coal bg-coal text-cream" : "border-sand text-coal hover:border-coal"
                }`}
              >
                {s}
              </button>
            );
          })}
        </div>
        <p className="text-sm text-taupe">Class 12 syllabus · tap a chapter</p>
      </div>

      <div className="mt-6 grid gap-6 lg:grid-cols-[1fr_360px]">
        <div className="grid grid-cols-2 content-start gap-2.5 sm:grid-cols-3 xl:grid-cols-4">
          {chapters.map((name, i) => {
            const on = i === index;
            return (
              <button
                key={name}
                type="button"
                aria-pressed={on}
                onClick={() => setSel(i)}
                className={`flex min-h-[96px] flex-col gap-2 rounded-2xl border p-3.5 text-left text-coal transition-colors sm:p-4 ${
                  on ? "border-coal bg-saffron" : "border-sand bg-cream hover:border-coal"
                }`}
              >
                <span className="text-[11px] font-bold tracking-[0.08em] opacity-70">CHAPTER {pad(i + 1)}</span>
                <span className="text-[15px] font-semibold leading-snug">{name}</span>
              </button>
            );
          })}
        </div>

        <div className="flex flex-col rounded-2xl bg-coal p-6 text-cream sm:p-7" aria-live="polite">
          <p className="text-xs font-bold uppercase tracking-[0.14em] text-saffron">
            {subject} · Chapter {pad(index + 1)}
          </p>
          <h3 className="mt-3 font-serif text-[32px] leading-[1.05] sm:text-[40px]">{chapters[index]}</h3>
          <dl className="mt-auto pt-7">
            {[
              ["Recorded class", "Included"],
              ["Live doubt session", "Included"],
              ["Notes + board questions", "Included"],
            ].map(([k, v], i) => (
              <div key={k} className="flex justify-between border-t border-coal-line py-3.5">
                <dt className="text-mist">{k}</dt>
                <dd className={`font-bold ${i === 2 ? "text-saffron" : ""}`}>{v}</dd>
              </div>
            ))}
          </dl>
        </div>
      </div>
    </div>
  );
}
