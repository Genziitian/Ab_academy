import Link from "next/link";
import { CourseCard } from "@/components/CourseCard";
import { FaqList } from "@/components/CurriculumAccordion";
import { Eyebrow } from "@/components/ui";
import type { Course } from "@/lib/courses";
import type { Locale } from "@/lib/i18n/config";
import { subjectName } from "@/lib/i18n/content";
import type { Dict } from "@/lib/i18n/dictionaries";

/**
 * The course list, filtered by subject through the URL (?subject=Physics) so
 * it needs no client JavaScript and a filtered list can be shared.
 */
export function CoursesCatalog({
  courses,
  subject,
  t,
  locale,
}: {
  courses: Course[];
  subject: string | null;
  t: Dict;
  locale: Locale;
}) {
  const subjects = [...new Set(courses.flatMap((c) => c.subjects))];
  const shown = subject ? courses.filter((c) => c.subjects.includes(subject)) : courses;
  const chip = (on: boolean) =>
    `inline-flex h-9 items-center whitespace-nowrap rounded-full border px-4 text-sm transition-colors ${
      on ? "border-ab-ink bg-ab-ink text-white" : "border-ab-rule bg-ab-panel text-ab-ink-2 hover:border-ab-rule-strong hover:text-ab-ink"
    }`;

  return (
    <>
      <section className="mx-auto max-w-[1280px] px-4 pb-10 pt-12 sm:px-6 lg:px-10 lg:pt-16">
        <Eyebrow>{t.nav.courses}</Eyebrow>
        <h1 className="ab-display mt-3 text-[40px] sm:text-[56px]">{t.catalog.title}</h1>
        <p className="mt-4 max-w-[620px] text-[17px] leading-[1.6] text-ab-ink-2">{t.catalog.lead}</p>
      </section>

      <section className="mx-auto max-w-[1280px] px-4 pb-20 sm:px-6 lg:px-10">
        <div className="flex flex-wrap items-center gap-2 border-b border-ab-rule pb-5">
          <div className="no-scrollbar -mx-1 flex gap-2 overflow-x-auto px-1">
            <Link href="/courses" scroll={false} className={chip(!subject)}>
              {t.catalog.all}
            </Link>
            {subjects.map((s) => (
              <Link key={s} href={`/courses?subject=${encodeURIComponent(s)}`} scroll={false} className={chip(subject === s)}>
                {subjectName(s, locale)}
              </Link>
            ))}
          </div>
          <span className="ab-num ml-auto text-[13px] text-ab-ink-3">{t.catalog.count(shown.length, courses.length)}</span>
        </div>

        {shown.length ? (
          <div className="mt-8 grid gap-5 sm:grid-cols-2 xl:grid-cols-3">
            {shown.map((course) => (
              <CourseCard key={course.slug} course={course} t={t} locale={locale} />
            ))}
          </div>
        ) : (
          <p className="mt-8 rounded-2xl border border-dashed border-ab-rule-strong py-16 text-center text-ab-ink-3">{t.catalog.empty}</p>
        )}
      </section>

      <section className="border-t border-ab-rule bg-ab-panel">
        <div className="mx-auto grid max-w-[1280px] gap-10 px-4 py-16 sm:px-6 lg:grid-cols-[1fr_1.5fr] lg:px-10">
          <h2 className="ab-title text-[28px]">{t.catalog.faqTitle}</h2>
          <FaqList faqs={t.course.faqs} />
        </div>
      </section>
    </>
  );
}
