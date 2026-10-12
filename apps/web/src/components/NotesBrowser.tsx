"use client";

import Link from "next/link";
import { useState } from "react";
import type { PublicNote } from "@/lib/notes";

export function NotesBrowser({ notes }: { notes: PublicNote[] }) {
  const [classLevel, setClassLevel] = useState<11 | 12>(12);
  const [subject, setSubject] = useState("All");

  const subjects = [
    "All",
    ...new Set(notes.filter((n) => n.classLevel === classLevel).map((n) => n.subject)),
  ];
  const visible = notes.filter(
    (n) => n.classLevel === classLevel && (subject === "All" || n.subject === subject),
  );

  return (
    <>
      <section className="border-b border-border bg-white">
        <div className="mx-auto max-w-[1200px] px-4 pt-9 sm:px-6">
          <nav className="flex gap-2 text-[13px] text-muted">
            <Link href="/" className="hover:text-navy">
              Home
            </Link>
            <span>›</span>
            <span className="text-navy">Notes</span>
          </nav>
          <h1 className="mt-4 text-[30px] font-bold tracking-[-0.02em] text-navy sm:text-[38px]">
            Class 11 &amp; 12 Notes
          </h1>
          <p className="mt-3 max-w-[640px] text-base leading-[1.6] text-muted">
            Chapter-wise PDF notes, formula sheets and syllabus for Bihar Board.
            Free notes open for everyone; full sets unlock with a crash course.
          </p>
          <div className="mt-6 flex flex-wrap gap-1">
            {([12, 11] as const).map((level) => {
              const on = classLevel === level;
              return (
                <button
                  key={level}
                  type="button"
                  onClick={() => {
                    setClassLevel(level);
                    setSubject("All");
                  }}
                  className={`h-11 whitespace-nowrap border-b-2 px-4 text-sm ${
                    on
                      ? "border-primary font-semibold text-primary"
                      : "border-transparent font-medium text-muted hover:text-navy"
                  }`}
                >
                  Class {level}
                </button>
              );
            })}
          </div>
        </div>
      </section>

      <div className="mx-auto max-w-[1200px] px-4 pb-[72px] pt-7 sm:px-6">
        <div className="mb-5 flex flex-wrap gap-2">
          {subjects.map((name) => {
            const on = subject === name;
            return (
              <button
                key={name}
                type="button"
                onClick={() => setSubject(name)}
                className={`h-[34px] whitespace-nowrap rounded-lg border px-3.5 text-[13px] font-medium ${
                  on
                    ? "border-navy bg-navy text-white"
                    : "border-border bg-white text-ink hover:border-primary-line"
                }`}
              >
                {name}
              </button>
            );
          })}
        </div>

        <div className="grid gap-4 [grid-template-columns:repeat(auto-fill,minmax(280px,1fr))]">
          {visible.map((note) => (
            <div
              key={note.title}
              className="flex flex-col gap-3 rounded-xl border border-border bg-white p-[18px]"
            >
              <div className="flex items-start gap-3">
                <PdfBadge />
                <div className="min-w-0 flex-1">
                  <p className="text-xs font-semibold text-primary">
                    {note.subject} · Class {note.classLevel}
                  </p>
                  <p className="mt-[3px] text-[15px] font-semibold text-navy">{note.title}</p>
                  <p className="mt-[3px] text-[13px] text-muted">{note.meta}</p>
                </div>
              </div>
              <div className="flex items-center justify-between border-t border-line pt-3">
                <span
                  className={`whitespace-nowrap rounded px-2 py-0.5 text-[11px] font-bold ${
                    note.free ? "bg-success-soft text-success" : "bg-[#f2f3f7] text-ink"
                  }`}
                >
                  {note.free ? "Free" : "With crash course"}
                </span>
                <Link
                  href={note.free ? "/login?next=/materials" : "/courses"}
                  className="whitespace-nowrap text-sm font-semibold text-primary hover:text-primary-dark"
                >
                  {note.free ? "Open PDF" : "Unlock →"}
                </Link>
              </div>
            </div>
          ))}
        </div>

        <section className="mt-8 flex flex-wrap items-center justify-between gap-5 rounded-xl bg-navy p-7 text-white">
          <div>
            <p className="text-lg font-semibold">Get every chapter&apos;s notes with a crash course</p>
            <p className="mt-1.5 text-sm text-[#c8d1e4]">
              Includes formula banks, important questions and solved board papers.
            </p>
          </div>
          <Link
            href="/courses"
            className="flex h-11 items-center whitespace-nowrap rounded-lg bg-white px-5 text-sm font-semibold text-navy hover:bg-primary-soft"
          >
            View crash courses
          </Link>
        </section>
      </div>
    </>
  );
}

export function PdfBadge({ size = 40 }: { size?: number }) {
  return (
    <span
      className="flex shrink-0 items-center justify-center rounded-lg bg-pdf-soft text-[10px] font-bold text-danger"
      style={{ width: size, height: size }}
    >
      PDF
    </span>
  );
}
