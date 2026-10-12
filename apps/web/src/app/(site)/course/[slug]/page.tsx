import Image from "next/image";
import Link from "next/link";
import { notFound } from "next/navigation";
import { CurriculumAccordion, FaqAccordion } from "@/components/CurriculumAccordion";
import { PlayIcon } from "@/components/icons";
import { fetchCourseBySlug, listCourseSlugs } from "@/lib/catalog";
import {
  CRASH_COURSE_DAYS,
  courseFaqs,
  discountPercent,
  formatInr,
  getCourse,
  initials,
} from "@/lib/courses";

type CoursePageProps = {
  params: Promise<{ slug: string }>;
};

export async function generateStaticParams() {
  const slugs = await listCourseSlugs();
  return slugs.map((slug) => ({ slug }));
}

export async function generateMetadata({ params }: CoursePageProps) {
  const { slug } = await params;
  const course = (await fetchCourseBySlug(slug)) || getCourse(slug);
  if (!course) return { title: "Course" };
  return { title: course.title, description: course.description };
}

export default async function CourseDetailPage({ params }: CoursePageProps) {
  const { slug } = await params;
  const remote = await fetchCourseBySlug(slug);
  const local = getCourse(slug);
  // Database fields win; the local catalog fills in the rich copy (curriculum,
  // deliverables, Hindi blurb) that has no column yet.
  const course = remote ? { ...local, ...remote } : local;
  if (!course) notFound();

  const off = discountPercent(course.price, course.originalPrice);
  const bilingual = /hindi/i.test(course.language) && /english/i.test(course.language);
  const deliverables =
    course.deliverables ??
    course.highlights.map((title) => ({ title, body: "Included with your enrolment." }));

  const stats = [
    { value: `${course.lessons}+`, label: "Lectures" },
    { value: String(CRASH_COURSE_DAYS), label: "Day plan" },
    {
      value: course.questions ? `${course.questions.toLocaleString("en-IN")}+` : "Weekly",
      label: course.questions ? "Questions" : "Tests",
    },
    { value: bilingual ? "Bilingual" : course.language, label: "Language" },
  ];

  return (
    <>
      <section className="bg-navy text-white">
        <div className="mx-auto grid max-w-[1200px] gap-10 px-4 pb-12 pt-8 sm:px-6 lg:grid-cols-[minmax(0,1fr)_minmax(300px,360px)]">
          <div>
            <nav className="flex flex-wrap gap-2 text-[13px] text-[#9aa7c2]">
              <Link href="/courses" className="hover:text-white">
                Courses
              </Link>
              <span>›</span>
              <Link href={`/courses?class=${course.classLevel}`} className="hover:text-white">
                Class {course.classLevel}
              </Link>
              <span>›</span>
              <span className="text-white">{course.title}</span>
            </nav>
            <div className="mt-6 flex flex-wrap gap-2">
              <Chip className="bg-primary">{CRASH_COURSE_DAYS}-day crash course</Chip>
              <Chip className="bg-white/10">
                {course.board} · {course.language}
              </Chip>
              {course.badge ? (
                <Chip className="bg-orange text-navy">{course.badge}</Chip>
              ) : null}
            </div>
            <h1 className="mt-[18px] text-[30px] font-bold leading-[1.15] tracking-[-0.02em] sm:text-[40px]">
              {course.title}
            </h1>
            {course.hindiBlurb ? (
              <p className="font-hindi mt-3.5 text-base leading-[1.6] text-[#c8d1e4]">
                {course.hindiBlurb}
              </p>
            ) : null}
            <div className="mt-[18px] flex flex-wrap items-center gap-x-3 gap-y-1 text-sm text-[#c8d1e4]">
              <span className="font-bold text-[#ffc56b]">★ {course.rating}</span>
              {course.reviewCount ? (
                <span>({course.reviewCount.toLocaleString("en-IN")} reviews)</span>
              ) : null}
              <span>·</span>
              <span className="font-semibold text-white">{course.teacher}</span>
              {course.teacherTitle ? <span>{course.teacherTitle}</span> : null}
            </div>
            <div className="mt-7 grid grid-cols-2 rounded-[10px] border border-white/[0.12] sm:grid-cols-4">
              {stats.map((stat, index) => (
                <div
                  key={stat.label}
                  className={`px-[18px] py-3.5 ${index % 2 === 0 ? "border-r border-white/[0.12]" : ""} ${
                    index < 2 ? "border-b border-white/[0.12] sm:border-b-0" : ""
                  } ${index === 1 ? "sm:border-r" : ""}`}
                >
                  <p className="text-xl font-bold">{stat.value}</p>
                  <p className="mt-0.5 text-xs text-[#9aa7c2]">{stat.label}</p>
                </div>
              ))}
            </div>
          </div>
          <div className="hidden lg:block" />
        </div>
      </section>

      <div className="mx-auto grid max-w-[1200px] items-start gap-10 px-4 pb-[72px] sm:px-6 lg:grid-cols-[minmax(0,1fr)_minmax(300px,360px)]">
        <div className="min-w-0 pt-10">
          <div className="relative aspect-video overflow-hidden rounded-xl bg-navy">
            <Image
              src="/images/feature-live-class.png"
              alt="Course preview"
              width={1280}
              height={720}
              className="size-full object-cover opacity-90"
            />
            <div className="absolute inset-0 flex items-center justify-center">
              <span className="flex size-16 items-center justify-center rounded-full bg-white text-primary shadow-[0_10px_30px_rgba(0,0,0,0.25)]">
                <PlayIcon size={22} />
              </span>
            </div>
            <span className="absolute bottom-4 left-4 rounded-md bg-navy/80 px-2.5 py-1 text-xs font-semibold text-white">
              Watch free preview · 4:12
            </span>
          </div>

          <section className="mt-12">
            <h2 className="text-2xl font-bold tracking-[-0.01em] text-navy">
              Course Highlights &amp; Deliverables
            </h2>
            <div className="mt-5 grid gap-3 md:grid-cols-2">
              {deliverables.map((item) => (
                <div
                  key={item.title}
                  className="flex gap-3.5 rounded-[10px] border border-border bg-white p-[18px]"
                >
                  <svg width="20" height="20" viewBox="0 0 18 18" fill="none" className="mt-px shrink-0" aria-hidden>
                    <circle cx="9" cy="9" r="9" fill="#e8f0ff" />
                    <path d="M5 9.2 7.6 11.7 13 6.4" stroke="#2962ff" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round" />
                  </svg>
                  <div>
                    <h3 className="text-[15px] font-semibold text-navy">{item.title}</h3>
                    <p className="mt-1 text-sm leading-[1.55] text-muted">{item.body}</p>
                  </div>
                </div>
              ))}
            </div>
          </section>

          {course.curriculum?.length ? (
            <CurriculumAccordion
              chapters={course.curriculum}
              subject={course.curriculumSubject}
            />
          ) : null}

          <section className="mt-12 grid items-center gap-7 rounded-xl border border-border bg-white p-7 sm:grid-cols-[120px_minmax(0,1fr)]">
            <div className="flex size-[120px] items-center justify-center rounded-xl bg-primary text-[34px] font-bold text-white">
              {initials(course.teacher)}
            </div>
            <div>
              <p className="text-[11px] font-semibold uppercase tracking-[0.08em] text-primary">
                Master Faculty
              </p>
              <h2 className="mt-1 text-xl font-bold text-navy">{course.teacher}</h2>
              {course.teacherTitle ? (
                <p className="mt-0.5 text-sm text-muted">{course.teacherTitle}</p>
              ) : null}
              {course.teacherBio ? (
                <p className="mt-2.5 text-sm leading-[1.6] text-ink">{course.teacherBio}</p>
              ) : null}
              <div className="mt-4 flex gap-7">
                {[
                  ["40+", "Toppers guided"],
                  ["2k+", "Alumni"],
                  ["Board", "Pass focus"],
                ].map(([value, label]) => (
                  <div key={label}>
                    <p className="text-lg font-bold text-navy">{value}</p>
                    <p className="text-xs text-muted">{label}</p>
                  </div>
                ))}
              </div>
            </div>
          </section>

          <section className="mt-12">
            <h2 className="text-2xl font-bold tracking-[-0.01em] text-navy">
              Frequently Asked Questions
            </h2>
            <FaqAccordion faqs={courseFaqs.slice(0, 4)} />
          </section>
        </div>

        <aside className="-order-1 mt-8 rounded-xl border border-border bg-white p-6 shadow-[0_14px_40px_rgba(18,32,70,0.1)] lg:sticky lg:top-[88px] lg:order-none lg:-mt-[260px]">
          {off ? (
            <p className="rounded-md bg-[#fff1f0] px-3 py-2 text-[13px] font-semibold text-[#c62828]">
              Special offer available on this batch
            </p>
          ) : null}
          <div className="mt-[18px] flex flex-wrap items-baseline gap-x-2.5 gap-y-1.5">
            <span className="text-[34px] font-bold tracking-[-0.02em] text-navy">
              {formatInr(course.price)}
            </span>
            {course.originalPrice ? (
              <span className="text-[15px] text-muted line-through">
                {formatInr(course.originalPrice)}
              </span>
            ) : null}
            {off ? (
              <span className="whitespace-nowrap rounded bg-success-soft px-2 py-0.5 text-xs font-bold text-success">
                {off}% OFF
              </span>
            ) : null}
          </div>
          <Link
            href={`/checkout/${course.slug}`}
            className="mt-5 flex h-12 items-center justify-center rounded-lg bg-primary text-[15px] font-semibold text-white hover:bg-primary-dark"
          >
            Enroll in Batch Now
          </Link>
          <Link
            href="/notes"
            className="mt-2.5 flex h-11 items-center justify-center rounded-lg border border-primary-line text-sm font-semibold text-primary hover:bg-primary-soft"
          >
            Download Syllabus PDF
          </Link>
          <div className="mt-[22px] flex flex-col gap-2.5 text-sm text-ink">
            <Row label="Live classes" value="As per batch schedule" />
            <Row label="Validity" value={course.validity ?? course.batch} />
            <Row label="Medium" value={course.language} />
          </div>
          <div className="mt-[18px] flex flex-col gap-2 border-t border-border pt-[18px] text-sm text-ink">
            <span>✓ Board-aligned content</span>
            <span>✓ Access on web and mobile app</span>
            <span>✓ Notes &amp; recordings included</span>
          </div>
          <div className="mt-[18px] rounded-lg bg-surface-soft p-3.5 text-sm">
            <p className="font-semibold text-navy">Call student support</p>
            <p className="mt-0.5 text-muted">+91 90000 00000</p>
          </div>
        </aside>
      </div>
    </>
  );
}

function Chip({ children, className }: { children: React.ReactNode; className: string }) {
  return (
    <span className={`whitespace-nowrap rounded-md px-2.5 py-1 text-xs font-semibold ${className}`}>
      {children}
    </span>
  );
}

function Row({ label, value }: { label: string; value: string }) {
  return (
    <div className="flex justify-between gap-3">
      <span>{label}</span>
      <span className="text-right font-semibold text-navy">{value}</span>
    </div>
  );
}
