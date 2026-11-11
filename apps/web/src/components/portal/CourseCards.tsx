import Image from "next/image";
import Link from "next/link";
import { Arrow, btn } from "@/components/ui";
import type { Locale } from "@/lib/i18n/config";
import { courseTitle, subjectName } from "@/lib/i18n/content";
import type { Dict } from "@/lib/i18n/dictionaries";
import type { MyCourse } from "@/lib/portal/live";

/** The student's enrolled courses; each opens its curriculum. */
export function CourseCards({ courses, t, locale }: { courses: MyCourse[]; t: Dict; locale: Locale }) {
  return (
    <div className="grid gap-4 sm:grid-cols-2 xl:grid-cols-3">
      {courses.map((c) => (
        <Link
          key={c.id}
          href={`/my-courses/${c.id}`}
          className="group flex flex-col overflow-hidden rounded-2xl border border-ab-rule bg-ab-panel transition-colors hover:border-ab-rule-strong"
        >
          <div className="relative aspect-[16/7] bg-ab-tray">
            {c.art ? <Image src={c.art} alt="" fill sizes="(min-width: 1280px) 380px, 50vw" className="object-cover" /> : null}
          </div>
          <div className="flex flex-1 flex-col p-5">
            <p className="text-[13px] text-ab-ink-3">{c.subjects.map((s) => subjectName(s, locale)).join(" · ") || t.nav.courses}</p>
            <h3 className="ab-title mt-1 text-lg">{courseTitle(c, locale)}</h3>
            <p className="ab-num mt-1.5 text-[13px] text-ab-ink-2">
              {t.common.chapters(c.chapters)} · {c.lectures ? t.portal.lecturesReady(c.lectures) : t.portal.lecturesSoon}
            </p>
            <span className="mt-auto flex items-center gap-1.5 pt-5 text-sm font-medium text-ab-ink">
              {t.portal.openCourse}
              <Arrow className="transition-transform group-hover:translate-x-0.5" />
            </span>
          </div>
        </Link>
      ))}
    </div>
  );
}

/** Shown when the student has no courses yet. */
export function NoCourses({ t }: { t: Dict }) {
  return (
    <div className="rounded-2xl border border-dashed border-ab-rule-strong px-6 py-12 text-center">
      <p className="ab-title text-2xl">{t.portal.noCoursesTitle}</p>
      <p className="mx-auto mt-2 max-w-[420px] text-[15px] text-ab-ink-2">{t.portal.noCoursesBody}</p>
      <Link href="/courses" className={`${btn.primary} mt-6`}>
        {t.portal.explore}
      </Link>
    </div>
  );
}
