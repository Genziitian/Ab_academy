"use client";

import Link from "next/link";
import { useState } from "react";
import { Avatar, Card, ProgressBar } from "@/components/portal/ui";
import {
  type EnrolledCourse,
  type LessonKind,
  type PortalChapter,
  physicsChapters,
  teachers,
} from "@/lib/portal/data";

const lessonStyle: Record<
  LessonKind,
  { icon: string; iconClass: string; cta: string; ctaClass: string; href: (id: string) => string }
> = {
  done: {
    icon: "✓",
    iconClass: "bg-success-soft text-success text-xs",
    cta: "Rewatch",
    ctaClass: "text-muted",
    href: (id) => `/lecture/${id}`,
  },
  current: {
    icon: "▶",
    iconClass: "bg-primary text-white text-xs",
    cta: "Resume",
    ctaClass: "text-primary",
    href: (id) => `/lecture/${id}`,
  },
  live: {
    icon: "●",
    iconClass: "bg-danger-soft text-danger text-xs",
    cta: "Join",
    ctaClass: "text-danger",
    href: () => "/live/classroom",
  },
  notes: {
    icon: "PDF",
    iconClass: "bg-pdf-soft text-danger text-[9px]",
    cta: "Open",
    ctaClass: "text-primary",
    href: () => "/materials",
  },
};

export function MyCourses({
  courses,
  initialCourse,
}: {
  courses: EnrolledCourse[];
  initialCourse: number;
}) {
  const [selected, setSelected] = useState(initialCourse);
  const [subject, setSubject] = useState("Physics");
  const [open, setOpen] = useState(2);
  const course = courses[selected];
  // Only Physics has sample chapters; other subjects show the same outline.
  const chapters: PortalChapter[] = physicsChapters;

  return (
    <div className="max-w-[1280px] px-4 pb-12 pt-7 sm:px-8">
      <div className="flex flex-col gap-3 sm:flex-row">
        {courses.map((c, index) => (
          <button
            key={c.id}
            type="button"
            onClick={() => {
              setSelected(index);
              setSubject(c.subjects[0]);
            }}
            className={`flex-1 rounded-xl bg-white p-[18px] text-left ${
              selected === index ? "border-2 border-primary" : "border border-border"
            }`}
          >
            <span className="block text-[11px] font-semibold tracking-[0.06em] text-muted">
              {c.batch}
            </span>
            <span className="mt-1 block text-base font-semibold text-navy">{c.title}</span>
            <span className="mt-3 flex items-center gap-2.5">
              <ProgressBar value={c.pct} className="h-1.5 flex-1" />
              <span className="text-[13px] font-bold text-primary">{c.pct}%</span>
            </span>
          </button>
        ))}
      </div>

      <div className="mt-6 grid items-start gap-6 lg:grid-cols-[minmax(0,1fr)_minmax(240px,300px)]">
        <Card className="overflow-hidden">
          <div className="flex flex-wrap items-center justify-between gap-x-4 gap-y-3 border-b border-border px-6 py-5">
            <div>
              <h2 className="text-lg font-semibold text-navy">Curriculum</h2>
              <p className="mt-[3px] text-[13px] text-muted">
                {course.chaptersDone} / {course.chaptersTotal} chapters · {course.next}
              </p>
            </div>
            <div className="flex flex-wrap gap-1.5">
              {course.subjects.map((name) => (
                <button
                  key={name}
                  type="button"
                  onClick={() => setSubject(name)}
                  className={`h-[30px] whitespace-nowrap rounded-md px-2.5 text-xs font-semibold ${
                    subject === name ? "bg-navy text-white" : "bg-[#f2f3f7] text-ink hover:text-navy"
                  }`}
                >
                  {name}
                </button>
              ))}
            </div>
          </div>

          {chapters.map((chapter, index) => {
            const isOpen = open === index && Boolean(chapter.lessons);
            const complete = chapter.done === chapter.total;
            return (
              <div key={chapter.title} className="border-b border-line last:border-b-0">
                <button
                  type="button"
                  aria-expanded={isOpen}
                  onClick={() => setOpen(open === index ? -1 : index)}
                  className="flex w-full items-center gap-3.5 bg-white px-4 py-4 text-left sm:px-6"
                >
                  <span
                    className={`flex size-8 shrink-0 items-center justify-center rounded-lg text-xs font-semibold ${
                      complete ? "bg-success-soft text-success" : "bg-primary-soft text-primary"
                    }`}
                  >
                    {chapter.lockedUntil ? "🔒" : String(index + 1).padStart(2, "0")}
                  </span>
                  <span className="min-w-0 flex-1">
                    <span
                      className={`block text-[15px] font-semibold ${
                        chapter.lockedUntil ? "text-subtle" : "text-navy"
                      }`}
                    >
                      {chapter.title}
                    </span>
                    <span className="text-[13px] text-muted">
                      {chapter.lockedUntil ??
                        chapter.note ??
                        `${chapter.done} / ${chapter.total} lessons`}
                    </span>
                  </span>
                  <ProgressBar
                    value={(chapter.done / chapter.total) * 100}
                    className="hidden h-1 w-[72px] shrink-0 sm:block"
                  />
                  <span className="w-4 text-base text-muted">
                    {chapter.lessons ? (isOpen ? "−" : "+") : ""}
                  </span>
                </button>
                {isOpen ? (
                  <div className="flex flex-col gap-1.5 px-4 pb-4 sm:pl-[70px] sm:pr-6">
                    {chapter.lessons!.map((lesson) => {
                      const style = lessonStyle[lesson.kind];
                      const current = lesson.kind === "current";
                      return (
                        <Link
                          key={lesson.id}
                          href={style.href(lesson.id)}
                          className={`flex items-center gap-3 rounded-lg px-3 py-2.5 ${
                            current
                              ? "border border-primary-line bg-surface-soft"
                              : "border border-transparent bg-surface-grey hover:border-border"
                          }`}
                        >
                          <span
                            className={`flex size-7 shrink-0 items-center justify-center rounded-md font-bold ${style.iconClass}`}
                          >
                            {style.icon}
                          </span>
                          <span className="min-w-0 flex-1">
                            <span className="block text-sm font-semibold text-navy">
                              {lesson.title}
                            </span>
                            <span
                              className={`text-xs ${lesson.kind === "live" ? "text-danger" : "text-muted"}`}
                            >
                              {lesson.meta}
                            </span>
                          </span>
                          <span className={`text-[13px] font-semibold ${style.ctaClass}`}>
                            {style.cta}
                          </span>
                        </Link>
                      );
                    })}
                  </div>
                ) : null}
              </div>
            );
          })}
        </Card>

        <aside className="flex flex-col gap-4">
          <Card className="p-5">
            <h3 className="text-[15px] font-semibold text-navy">Course details</h3>
            <div className="mt-3.5 grid grid-cols-3 gap-2 text-center">
              {[
                [course.lessons, "Lessons"],
                [course.notes, "Notes"],
                [course.live, "Live"],
              ].map(([value, label]) => (
                <div key={label} className="rounded-lg bg-surface-soft px-1 py-3">
                  <p className="text-lg font-bold text-navy">{value}</p>
                  <p className="text-[11px] text-muted">{label}</p>
                </div>
              ))}
            </div>
            <p className="mt-3.5 text-[13px] leading-[1.55] text-muted">{course.validity}</p>
          </Card>
          <Card className="p-5">
            <h3 className="text-[15px] font-semibold text-navy">Teachers</h3>
            <div className="mt-3 flex flex-col gap-3">
              {teachers
                .filter((t) => course.subjects.includes(t.subject))
                .map((teacher) => (
                  <div key={teacher.name} className="flex items-center gap-2.5">
                    <Avatar initials={teacher.initials} size={36} />
                    <div>
                      <p className="text-sm font-semibold text-navy">{teacher.name}</p>
                      <p className="text-xs text-muted">
                        {teacher.subject} · {teacher.years} yrs
                      </p>
                    </div>
                  </div>
                ))}
            </div>
          </Card>
          <Link
            href="/materials"
            className="flex items-center justify-between rounded-xl bg-primary-soft px-5 py-4 text-sm font-semibold text-primary"
          >
            All notes for this course <span>→</span>
          </Link>
        </aside>
      </div>
    </div>
  );
}
