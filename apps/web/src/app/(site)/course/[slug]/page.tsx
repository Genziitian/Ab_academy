import Image from "next/image";
import Link from "next/link";
import { ButtonLink } from "@/components/ButtonLink";
import { CurriculumAccordion } from "@/components/CurriculumAccordion";
import { fetchCourseBySlug, listCourseSlugs } from "@/lib/catalog";
import {
  courseFaqs,
  discountPercent,
  formatInr,
  getCourse,
} from "@/lib/courses";
import { notFound } from "next/navigation";

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
  return {
    title: course.title,
    description: course.description,
  };
}

export default async function CourseDetailPage({ params }: CoursePageProps) {
  const { slug } = await params;
  const remote = await fetchCourseBySlug(slug);
  const local = getCourse(slug);
  const course = local
    ? { ...remote, ...local }
    : remote;
  if (!course) notFound();

  const off = discountPercent(course.price, course.originalPrice);
  const deliverables =
    course.deliverables ||
    course.highlights.map((title) => ({
      title,
      body: "Included with your enrollment.",
    }));
  const curriculum = course.curriculum || [];

  return (
    <div className="bg-[#f7f8fc]">
      <div className="border-b border-border bg-white">
        <div className="mx-auto max-w-6xl px-4 py-6 sm:px-6 sm:py-8">
          <nav className="text-xs text-muted sm:text-sm">
            <Link href="/courses" className="hover:text-primary">
              Courses
            </Link>
            <span className="mx-2">›</span>
            <span>Class {course.classLevel}</span>
            <span className="mx-2">›</span>
            <span className="text-navy">{course.title}</span>
          </nav>

          <div className="mt-5 grid gap-8 lg:grid-cols-[1.35fr_0.75fr]">
            <div>
              <div className="flex flex-wrap gap-2">
                <span className="rounded-full bg-primary-soft px-3 py-1 text-xs font-semibold text-primary">
                  {course.batch}
                </span>
                <span className="rounded-full bg-[#f0f2f8] px-3 py-1 text-xs font-semibold text-navy">
                  {course.board} · {course.language}
                </span>
              </div>

              <h1 className="mt-4 text-2xl font-extrabold leading-tight text-navy sm:text-4xl">
                {course.title}
              </h1>
              {course.hindiBlurb ? (
                <p className="font-hindi mt-3 text-sm text-muted sm:text-base">
                  {course.hindiBlurb}
                </p>
              ) : (
                <p className="mt-3 text-sm text-muted sm:text-base">
                  {course.description}
                </p>
              )}

              <div className="mt-4 flex flex-wrap items-center gap-3 text-sm">
                <span className="font-bold text-navy">★ {course.rating}</span>
                {course.reviewCount ? (
                  <span className="text-muted">
                    ({course.reviewCount.toLocaleString("en-IN")} reviews)
                  </span>
                ) : null}
                <span className="text-muted">·</span>
                <span className="font-semibold text-navy">{course.teacher}</span>
                {course.teacherTitle ? (
                  <span className="text-muted">{course.teacherTitle}</span>
                ) : null}
              </div>

              <div className="relative mt-6 overflow-hidden rounded-2xl border border-border bg-navy shadow-[var(--shadow-soft)]">
                <div className="relative aspect-[16/10]">
                  <Image
                    src="/images/feature-live-class.png"
                    alt={`${course.title} preview`}
                    fill
                    className="object-cover opacity-90"
                    sizes="(max-width: 1024px) 100vw, 60vw"
                    priority
                  />
                  <div className="absolute inset-0 bg-gradient-to-t from-navy/50 to-transparent" />
                  <div className="absolute inset-0 flex items-center justify-center">
                    <span className="flex h-16 w-16 items-center justify-center rounded-full bg-white/95 text-2xl text-primary shadow-lg">
                      ▶
                    </span>
                  </div>
                </div>
              </div>

              <div className="mt-4 grid grid-cols-3 gap-2 sm:gap-3">
                <Stat
                  label="Chapters"
                  value={`${course.chapters || Math.max(8, Math.round(course.lessons / 3))}+`}
                />
                <Stat
                  label="Questions"
                  value={`${(course.questions || course.lessons * 20).toLocaleString("en-IN")}+`}
                />
                <Stat label="Language" value={course.language} />
              </div>
            </div>

            <aside className="hidden h-fit lg:sticky lg:top-24 lg:block">
              <EnrollCard
                price={course.price}
                originalPrice={course.originalPrice}
                off={off}
                language={course.language}
                batch={course.batch}
              />
            </aside>
          </div>
        </div>
      </div>

      <div className="mx-auto max-w-6xl px-4 py-10 pb-28 sm:px-6 lg:pb-16">
        <section>
          <h2 className="text-xl font-extrabold text-navy sm:text-2xl">
            Course Highlights & Deliverables
          </h2>
          <div className="mt-5 grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
            {deliverables.map((item) => (
              <div
                key={item.title}
                className="rounded-2xl border border-border bg-white p-5 shadow-[var(--shadow-card)]"
              >
                <div className="mb-3 flex h-10 w-10 items-center justify-center rounded-xl bg-primary-soft text-primary">
                  ◆
                </div>
                <h3 className="font-bold text-navy">{item.title}</h3>
                <p className="mt-2 text-sm leading-relaxed text-muted">
                  {item.body}
                </p>
              </div>
            ))}
          </div>
        </section>

        {curriculum.length > 0 ? (
          <CurriculumAccordion chapters={curriculum} />
        ) : null}

        <section className="mt-12 overflow-hidden rounded-2xl border border-border bg-white shadow-[var(--shadow-card)]">
          <div className="grid gap-6 p-5 sm:p-6 md:grid-cols-[160px_1fr] md:items-center">
            <div
              className="mx-auto flex h-36 w-36 items-center justify-center rounded-2xl text-3xl font-extrabold text-white"
              style={{
                background: `linear-gradient(145deg, hsl(${course.thumbnailHue} 70% 48%), hsl(${course.thumbnailHue + 20} 65% 36%))`,
              }}
            >
              {course.teacher
                .split(" ")
                .map((w) => w[0])
                .slice(0, 2)
                .join("")}
            </div>
            <div>
              <p className="text-xs font-bold uppercase tracking-[0.14em] text-primary">
                Master Faculty
              </p>
              <h2 className="mt-1 text-xl font-extrabold text-navy">
                {course.teacher}
              </h2>
              <p className="mt-1 text-sm font-medium text-muted">
                {course.teacherTitle || course.board}
              </p>
              <p className="mt-3 text-sm leading-relaxed text-muted">
                {course.teacherBio ||
                  `${course.teacher} leads this batch with live teaching, notes and exam-focused practice at Akhand Bharat Academy.`}
              </p>
              <div className="mt-5 grid grid-cols-3 gap-3 text-center">
                <MiniStat label="Toppers guided" value="40+" />
                <MiniStat label="Alumni" value="2k+" />
                <MiniStat label="Pass focus" value="Board" />
              </div>
            </div>
          </div>
        </section>

        <section className="mt-12">
          <h2 className="text-xl font-extrabold text-navy sm:text-2xl">
            Frequently Asked Questions
          </h2>
          <div className="mt-5 space-y-3">
            {courseFaqs.slice(0, 4).map((item) => (
              <details
                key={item.q}
                className="group rounded-2xl border border-border bg-white px-4 py-3 open:shadow-[var(--shadow-card)]"
              >
                <summary className="cursor-pointer list-none font-semibold text-navy marker:content-none">
                  <span className="flex items-center justify-between gap-3">
                    {item.q}
                    <span className="text-muted group-open:hidden">+</span>
                    <span className="hidden text-muted group-open:inline">
                      −
                    </span>
                  </span>
                </summary>
                <p className="mt-2 text-sm leading-relaxed text-muted">
                  {item.a}
                </p>
              </details>
            ))}
          </div>
        </section>
      </div>

      <div className="fixed inset-x-0 bottom-0 z-40 border-t border-border bg-white/95 p-3 pb-[max(0.75rem,env(safe-area-inset-bottom))] backdrop-blur-md lg:hidden">
        <div className="mx-auto flex max-w-6xl items-center gap-3">
          <div className="min-w-0 flex-1">
            <p className="text-base font-extrabold text-navy">
              {formatInr(course.price)}
            </p>
            {off > 0 ? (
              <p className="text-xs font-semibold text-success">{off}% OFF</p>
            ) : null}
          </div>
          <ButtonLink href="/login" className="shrink-0 rounded-lg px-5">
            Enroll Now
          </ButtonLink>
        </div>
      </div>
    </div>
  );
}

function Stat({ label, value }: { label: string; value: string }) {
  return (
    <div className="rounded-xl border border-border bg-white px-2 py-3 text-center sm:px-3">
      <p className="text-sm font-extrabold text-navy sm:text-base">{value}</p>
      <p className="mt-0.5 text-[0.65rem] text-muted sm:text-xs">{label}</p>
    </div>
  );
}

function MiniStat({ label, value }: { label: string; value: string }) {
  return (
    <div className="rounded-xl bg-surface-soft px-2 py-3">
      <p className="text-base font-extrabold text-navy">{value}</p>
      <p className="text-[0.65rem] text-muted">{label}</p>
    </div>
  );
}

function EnrollCard({
  price,
  originalPrice,
  off,
  language,
  batch,
}: {
  price: number;
  originalPrice?: number;
  off: number;
  language: string;
  batch: string;
}) {
  return (
    <div className="rounded-2xl border border-border bg-white p-5 shadow-[var(--shadow-soft)]">
      <p className="rounded-lg bg-[#fff1f0] px-3 py-2 text-xs font-semibold text-[#c62828]">
        Special offer available on this batch
      </p>
      <div className="mt-4 flex items-end gap-2">
        <p className="text-3xl font-extrabold text-navy">{formatInr(price)}</p>
        {originalPrice ? (
          <p className="pb-1 text-sm text-muted line-through">
            {formatInr(originalPrice)}
          </p>
        ) : null}
        {off > 0 ? (
          <span className="mb-1 rounded-md bg-emerald-50 px-2 py-0.5 text-xs font-bold text-success">
            {off}% OFF
          </span>
        ) : null}
      </div>
      <ButtonLink href="/login" className="mt-5 w-full rounded-lg">
        Enroll in Batch Now
      </ButtonLink>
      <ButtonLink
        href="/contact"
        variant="secondary"
        className="mt-3 w-full rounded-lg"
      >
        Download Syllabus PDF
      </ButtonLink>
      <ul className="mt-5 space-y-2.5 text-sm text-muted">
        <li>📅 Live classes as per batch schedule</li>
        <li>⏳ Validity: {batch}</li>
        <li>🌐 Medium: {language}</li>
        <li>✓ Board-aligned content</li>
        <li>✓ Access on web (app soon)</li>
        <li>✓ Notes & recordings included</li>
      </ul>
      <div className="mt-5 rounded-xl bg-surface-soft p-3 text-sm">
        <p className="font-semibold text-navy">Call student support</p>
        <p className="mt-1 text-muted">+91 90000 00000</p>
      </div>
    </div>
  );
}
