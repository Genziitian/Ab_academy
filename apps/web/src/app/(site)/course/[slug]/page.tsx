import Image from "next/image";
import Link from "next/link";
import { notFound } from "next/navigation";
import { AdminManageButton } from "@/components/AdminManageButton";
import { CurriculumAccordion, FaqList } from "@/components/CurriculumAccordion";
import { EnrollWithLanguage } from "@/components/LanguagePicker";
import { Check, Panel, Pill } from "@/components/ui";
import { fetchCourseBySlug } from "@/lib/catalog";
import { CRASH_COURSE_DAYS, courseArt, discountPercent, formatInr, getCourse, initials } from "@/lib/courses";
import { courseTitle, subjectName, syllabusFor, validityText } from "@/lib/i18n/content";
import { getT } from "@/lib/i18n/server";
import { CONTACT, TEACHER, subjectKey } from "@/lib/landing";

type CoursePageProps = { params: Promise<{ slug: string }> };

export async function generateMetadata({ params }: CoursePageProps) {
  const { slug } = await params;
  const course = (await fetchCourseBySlug(slug)) || getCourse(slug);
  if (!course) return { title: "Course" };
  return { title: course.title, description: course.description };
}

export default async function CourseDetailPage({ params }: CoursePageProps) {
  const { slug } = await params;
  const [remote, { t, locale }] = await Promise.all([fetchCourseBySlug(slug), getT()]);
  const local = getCourse(slug);
  // Database fields win; the local catalog fills in the curriculum and copy.
  const course = remote ? { ...local, ...remote } : local;
  if (!course) notFound();

  const c = t.course;
  const off = discountPercent(course.price, course.originalPrice);
  const key = course.curriculumSubject ? subjectKey(course.curriculumSubject) : null;
  const chapters = key ? syllabusFor(locale)[key] : (course.curriculum?.map((ch) => ch.title) ?? []);
  const subject = key ? subjectName(key, locale) : course.subjects.map((s) => subjectName(s, locale)).join(" · ");
  const title = courseTitle(course, locale);
  const art = courseArt(course);
  const teacher = course.teacher === TEACHER.name ? t.common.teacherName : course.teacher;
  const blurb = locale === "hi" ? (course.hindiBlurb ?? course.description) : course.description;

  const stats = [
    [String(chapters.length || course.lessons), c.statChapters],
    [String(CRASH_COURSE_DAYS), c.statPlan],
    [c.statEach, c.statEachLabel],
    [t.common.hindiOrHinglish, c.statLang],
  ];

  return (
    <>
      <div className="mx-auto grid max-w-[1280px] items-start gap-10 px-4 pb-20 pt-8 sm:px-6 lg:grid-cols-[minmax(0,1fr)_380px] lg:gap-14 lg:px-10 lg:pt-12">
        <div className="min-w-0">
          <nav className="flex flex-wrap items-center gap-2 text-[13px] text-ab-ink-3">
            <Link href="/courses" className="hover:text-ab-ink">
              {c.breadcrumb}
            </Link>
            <span aria-hidden>/</span>
            <span className="text-ab-ink-2">{t.common.classN(course.classLevel)}</span>
          </nav>
          <div className="mt-6 flex flex-wrap gap-2">
            <Pill tone="accent">{c.days(CRASH_COURSE_DAYS)}</Pill>
            <Pill>{t.common.board}</Pill>
            <Pill>{t.common.hindiOrHinglish}</Pill>
          </div>
          <h1 className="ab-display mt-5 text-[36px] sm:text-[48px]">{title}</h1>
          {blurb ? <p className="mt-4 max-w-[640px] text-[17px] leading-[1.65] text-ab-ink-2">{blurb}</p> : null}
          <p className="mt-4 text-[15px] text-ab-ink-2">
            <span className="font-medium text-ab-ink">{teacher}</span>
            {course.teacherTitle ? ` · ${t.home.teacherSubjects}` : ""}
          </p>

          <dl className="mt-8 grid grid-cols-2 gap-px overflow-hidden rounded-2xl border border-ab-rule bg-ab-rule sm:grid-cols-4">
            {stats.map(([value, label]) => (
              <div key={label} className="bg-ab-panel px-4 py-4">
                <dd className={value.length > 4 ? "text-[15px] font-medium text-ab-ink" : "ab-fig text-2xl font-medium text-ab-ink"}>{value}</dd>
                <dt className="mt-1 text-[13px] text-ab-ink-3">{label}</dt>
              </div>
            ))}
          </dl>

          {art ? (
            <div className="relative mt-8 aspect-[16/7] overflow-hidden rounded-2xl bg-ab-tray">
              <Image src={art} alt="" fill priority sizes="(min-width: 1024px) 800px, 100vw" className="object-cover" />
            </div>
          ) : null}

          <section className="mt-14">
            <h2 className="ab-title text-[26px]">{c.includedTitle}</h2>
            <div className="mt-5 grid gap-px overflow-hidden rounded-2xl border border-ab-rule bg-ab-rule md:grid-cols-2">
              {c.deliverables(chapters.length || course.lessons / 2, subject).map(([head, body]) => (
                <div key={head} className="flex gap-3.5 bg-ab-panel p-5">
                  <Check className="mt-1 text-ab-accent" />
                  <div>
                    <h3 className="text-[15px] font-medium text-ab-ink">{head}</h3>
                    <p className="mt-1 text-sm leading-[1.55] text-ab-ink-2">{body}</p>
                  </div>
                </div>
              ))}
            </div>
          </section>

          {chapters.length ? <CurriculumAccordion chapters={chapters} subject={subject} /> : null}

          <Panel as="section" className="mt-14 grid items-center gap-6 p-6 sm:grid-cols-[112px_minmax(0,1fr)] sm:p-7">
            {course.teacher === TEACHER.name && TEACHER.photo ? (
              <div className="relative size-[112px] overflow-hidden rounded-xl bg-ab-tray">
                <Image src={TEACHER.photo} alt={teacher} fill sizes="112px" className="object-cover object-top" />
              </div>
            ) : (
              <div className="ab-fig flex size-[112px] items-center justify-center rounded-xl bg-ab-tray text-3xl text-ab-ink-3">
                {initials(course.teacher)}
              </div>
            )}
            <div>
              <p className="ab-eyebrow">{c.teacherEyebrow}</p>
              <h2 className="ab-title mt-1.5 text-xl">{teacher}</h2>
              <p className="mt-2 text-[15px] leading-[1.6] text-ab-ink-2">{t.home.teacherBio}</p>
              <dl className="mt-4 flex gap-8">
                {[
                  [c.years(TEACHER.years), c.teacherYears],
                  ["3", c.teacherSubjects],
                  [c.live, c.teacherLive],
                ].map(([value, label]) => (
                  <div key={label}>
                    <dd className="ab-num text-lg font-medium text-ab-ink">{value}</dd>
                    <dt className="text-[13px] text-ab-ink-3">{label}</dt>
                  </div>
                ))}
              </dl>
            </div>
          </Panel>

          <section className="mt-14">
            <h2 className="ab-title text-[26px]">{c.faqTitle}</h2>
            <FaqList faqs={c.faqs} />
          </section>
        </div>

        <aside className="-order-1 rounded-[22px] bg-ab-tray p-1.5 lg:sticky lg:top-24 lg:order-none">
          <div className="rounded-[16px] border border-ab-rule bg-ab-panel p-6">
            {off ? <Pill tone="accent">{c.offer}</Pill> : null}
            <div className={`flex flex-wrap items-baseline gap-x-3 gap-y-1 ${off ? "mt-4" : ""}`}>
              <span className="ab-fig text-[40px] font-medium leading-none text-ab-ink">
                {course.price ? formatInr(course.price) : t.common.free}
              </span>
              {course.originalPrice && off ? (
                <>
                  <span className="ab-num text-[15px] text-ab-ink-3 line-through">{formatInr(course.originalPrice)}</span>
                  <span className="text-sm font-medium text-ab-live">{c.off(off)}</span>
                </>
              ) : null}
            </div>
            <EnrollWithLanguage slug={course.slug} />
            <dl className="mt-6 flex flex-col gap-2.5 border-t border-ab-rule pt-5 text-sm">
              {[
                [c.eachChapter, c.eachChapterValue],
                [c.validity, validityText(course.validity, locale)],
                [c.language, t.common.hindiOrHinglish],
              ].map(([label, value]) => (
                <div key={label} className="flex justify-between gap-3">
                  <dt className="text-ab-ink-3">{label}</dt>
                  <dd className="text-right font-medium text-ab-ink">{value}</dd>
                </div>
              ))}
            </dl>
            <ul className="mt-5 flex flex-col gap-2 border-t border-ab-rule pt-5 text-sm text-ab-ink-2">
              {c.trust.map((line) => (
                <li key={line} className="flex items-center gap-2">
                  <Check size={14} className="text-ab-accent" />
                  {line}
                </li>
              ))}
            </ul>
          </div>
          <div className="px-4 py-3.5 text-sm">
            <p className="text-ab-ink-2">{c.questions}</p>
            <a href={`mailto:${CONTACT.email}`} className="font-medium text-ab-ink underline decoration-ab-rule-strong underline-offset-4 hover:decoration-ab-ink">
              {CONTACT.email}
            </a>
          </div>
        </aside>
      </div>
      {course.id ? <AdminManageButton courseId={course.id} label={c.manage} /> : null}
    </>
  );
}
