"use client";

import Link from "next/link";
import { useMemo, useState } from "react";
import { CourseCard } from "@/components/CourseCard";
import {
  Course,
  CRASH_COURSE_DAYS,
  courseFaqs,
  formatInr,
  subjectFilters,
} from "@/lib/courses";

type ClassTab = "all" | 11 | 12;
type CourseType = "all" | "complete" | "subject";
type Medium = "all" | "Hindi" | "English" | "Bilingual";
type SortBy = "popular" | "price-asc" | "price-desc";

const MAX_PRICE = 5000;

const classTabs: { value: ClassTab; label: string }[] = [
  { value: "all", label: "All Crash Courses" },
  { value: 12, label: "Class 12" },
  { value: 11, label: "Class 11" },
];

const courseTypes: { value: CourseType; label: string }[] = [
  { value: "all", label: "All types" },
  { value: "complete", label: "Full stream crash course" },
  { value: "subject", label: "Single subject" },
];

const ratings = [0, 4, 4.5];
const mediums: Medium[] = ["all", "Hindi", "English", "Bilingual"];

type Props = {
  initialCourses: Course[];
  initialClass?: number;
};

export function CoursesCatalog({ initialCourses, initialClass }: Props) {
  const [classLevel, setClassLevel] = useState<ClassTab>(
    initialClass === 11 || initialClass === 12 ? initialClass : "all",
  );
  const [subjects, setSubjects] = useState<string[]>([]);
  const [courseType, setCourseType] = useState<CourseType>("all");
  const [maxPrice, setMaxPrice] = useState(MAX_PRICE);
  const [minRating, setMinRating] = useState(0);
  const [medium, setMedium] = useState<Medium>("all");
  const [sortBy, setSortBy] = useState<SortBy>("popular");
  const [filtersOpen, setFiltersOpen] = useState(false);

  const filtered = useMemo(() => {
    const list = initialCourses.filter((c) => {
      const language = c.language.toLowerCase();
      const bilingual = language.includes("hindi") && language.includes("english");
      return (
        (classLevel === "all" || c.classLevel === classLevel) &&
        (!subjects.length || subjects.some((s) => c.subjects.includes(s))) &&
        (courseType === "all" ||
          (courseType === "complete" ? c.subjects.length >= 3 : c.subjects.length <= 2)) &&
        c.price <= maxPrice &&
        c.rating >= minRating &&
        (medium === "all" ||
          (medium === "Bilingual" ? bilingual : language.includes(medium.toLowerCase())))
      );
    });
    if (sortBy === "price-asc") list.sort((a, b) => a.price - b.price);
    else if (sortBy === "price-desc") list.sort((a, b) => b.price - a.price);
    else list.sort((a, b) => b.rating - a.rating);
    return list;
  }, [initialCourses, classLevel, subjects, courseType, maxPrice, minRating, medium, sortBy]);

  const subjectCounts = subjectFilters
    .map((name) => ({
      name,
      count: initialCourses.filter((c) => c.subjects.includes(name)).length,
    }))
    .filter((s) => s.count > 0);

  function clearAll() {
    setClassLevel("all");
    setSubjects([]);
    setCourseType("all");
    setMaxPrice(MAX_PRICE);
    setMinRating(0);
    setMedium("all");
    setSortBy("popular");
  }

  return (
    <>
      <section className="border-b border-border bg-white">
        <div className="mx-auto max-w-[1200px] px-4 pt-9 sm:px-6">
          <nav className="flex gap-2 text-[13px] text-muted">
            <Link href="/" className="hover:text-navy">
              Home
            </Link>
            <span>›</span>
            <span className="text-navy">Courses</span>
          </nav>
          <div className="mt-4 flex flex-wrap items-end justify-between gap-8">
            <div className="max-w-[640px]">
              <h1 className="text-[30px] font-bold tracking-[-0.02em] text-navy sm:text-[38px]">
                Class 11 &amp; 12 Crash Courses
              </h1>
              <p className="mt-3 text-base leading-[1.6] text-pretty text-muted">
                Fast-track, board-focused crash courses with live classes,
                recordings and notes. Bihar Board Class 11 &amp; 12 — Science,
                Commerce and Arts.
              </p>
            </div>
            <div className="flex gap-8 pb-1">
              <Stat value={String(initialCourses.length)} label="Crash courses" accent />
              <Stat value={String(CRASH_COURSE_DAYS)} label="Day plan" />
            </div>
          </div>
          <div className="no-scrollbar mt-7 flex gap-1 overflow-x-auto">
            {classTabs.map((tab) => {
              const on = classLevel === tab.value;
              return (
                <button
                  key={tab.label}
                  type="button"
                  onClick={() => setClassLevel(tab.value)}
                  className={`h-11 whitespace-nowrap border-b-2 px-4 text-sm ${
                    on
                      ? "border-primary font-semibold text-primary"
                      : "border-transparent font-medium text-muted hover:text-navy"
                  }`}
                >
                  {tab.label}
                </button>
              );
            })}
          </div>
        </div>
      </section>

      <div className="mx-auto grid max-w-[1200px] items-start gap-7 px-4 pb-16 pt-7 sm:px-6 lg:grid-cols-[260px_minmax(0,1fr)]">
        <aside className="flex flex-col gap-4 lg:sticky lg:top-[88px]">
          <button
            type="button"
            onClick={() => setFiltersOpen((v) => !v)}
            className="flex h-11 items-center justify-between rounded-xl border border-border bg-white px-4 text-sm font-semibold text-navy lg:hidden"
          >
            Filters
            <span className="text-muted">{filtersOpen ? "−" : "+"}</span>
          </button>

          <div
            className={`${filtersOpen ? "block" : "hidden"} rounded-xl border border-border bg-white p-5 lg:block`}
          >
            <div className="flex items-center justify-between">
              <h2 className="text-[15px] font-semibold text-navy">Filters</h2>
              <button
                type="button"
                onClick={clearAll}
                className="text-[13px] font-semibold text-primary"
              >
                Clear all
              </button>
            </div>

            <FilterLabel first>Subjects</FilterLabel>
            <div className="flex flex-col gap-2">
              {subjectCounts.map((s) => (
                <label
                  key={s.name}
                  className="flex cursor-pointer items-center justify-between text-sm text-navy"
                >
                  <span className="flex items-center gap-2">
                    <input
                      type="checkbox"
                      checked={subjects.includes(s.name)}
                      onChange={() =>
                        setSubjects((prev) =>
                          prev.includes(s.name)
                            ? prev.filter((x) => x !== s.name)
                            : [...prev, s.name],
                        )
                      }
                      className="m-0 size-[15px] accent-primary"
                    />
                    {s.name}
                  </span>
                  <span className="text-xs text-muted">{s.count}</span>
                </label>
              ))}
            </div>

            <FilterLabel>Course type</FilterLabel>
            <div className="flex flex-col gap-2">
              {courseTypes.map((t) => (
                <label
                  key={t.value}
                  className="flex cursor-pointer items-center gap-2 text-sm text-navy"
                >
                  <input
                    type="radio"
                    name="course-type"
                    checked={courseType === t.value}
                    onChange={() => setCourseType(t.value)}
                    className="m-0 accent-primary"
                  />
                  {t.label}
                </label>
              ))}
            </div>

            <FilterLabel>Max price · {formatInr(maxPrice)}</FilterLabel>
            <input
              type="range"
              min={500}
              max={MAX_PRICE}
              step={100}
              value={maxPrice}
              onChange={(e) => setMaxPrice(Number(e.target.value))}
              className="w-full accent-primary"
            />

            <FilterLabel>Student rating</FilterLabel>
            <div className="flex flex-col gap-2">
              {ratings.map((r) => (
                <label
                  key={r}
                  className="flex cursor-pointer items-center gap-2 text-sm text-navy"
                >
                  <input
                    type="radio"
                    name="rating"
                    checked={minRating === r}
                    onChange={() => setMinRating(r)}
                    className="m-0 accent-primary"
                  />
                  {r ? `${r}+ stars` : "Any rating"}
                </label>
              ))}
            </div>
          </div>

          <div className="hidden rounded-xl bg-navy p-5 text-white lg:block">
            <p className="text-[11px] font-semibold uppercase tracking-[0.08em] text-[#9fb8ff]">
              Medha Scholarship
            </p>
            <p className="mt-2 text-[15px] font-semibold leading-[1.4]">
              Merit support for dedicated learners
            </p>
            <Link
              href="/contact"
              className="mt-3 inline-flex text-sm font-semibold text-[#9fb8ff] hover:text-white"
            >
              Check eligibility →
            </Link>
          </div>
          <div className="hidden rounded-xl bg-primary-soft p-5 lg:block">
            <p className="text-[15px] font-semibold text-navy">Academic counselor</p>
            <p className="mt-1.5 text-sm leading-[1.5] text-ink">
              Confused about which batch to pick? Chat with us.
            </p>
            <Link
              href="/contact"
              className="mt-3 inline-flex text-sm font-semibold text-primary"
            >
              Chat on WhatsApp →
            </Link>
          </div>
        </aside>

        <div className="min-w-0">
          <div className="mb-5 flex flex-wrap items-center gap-2">
            <div className="no-scrollbar flex gap-2 overflow-x-auto">
              {mediums.map((m) => {
                const on = medium === m;
                return (
                  <button
                    key={m}
                    type="button"
                    onClick={() => setMedium(m)}
                    className={`h-[34px] whitespace-nowrap rounded-lg border px-3.5 text-[13px] font-medium ${
                      on
                        ? "border-navy bg-navy text-white"
                        : "border-border bg-white text-ink hover:border-primary-line"
                    }`}
                  >
                    {m === "all" ? "Any medium" : m}
                  </button>
                );
              })}
            </div>
            <span className="ml-auto text-sm text-muted">
              {filtered.length} of {initialCourses.length} courses
            </span>
            <select
              value={sortBy}
              onChange={(e) => setSortBy(e.target.value as SortBy)}
              className="h-9 rounded-lg border border-border bg-white px-2.5 text-sm text-navy"
            >
              <option value="popular">Sort: Popular</option>
              <option value="price-asc">Price: Low to high</option>
              <option value="price-desc">Price: High to low</option>
            </select>
          </div>

          {filtered.length ? (
            <div className="grid gap-5 sm:grid-cols-2 xl:grid-cols-3">
              {filtered.map((course) => (
                <CourseCard key={course.slug} course={course} />
              ))}
            </div>
          ) : (
            <p className="rounded-xl border border-dashed border-[#d5dcea] bg-white py-16 text-center text-muted">
              No courses match these filters.
            </p>
          )}

          <section className="mt-8 flex flex-wrap items-center justify-between gap-6 rounded-xl bg-primary-soft p-6">
            <div className="flex-[1_1_320px]">
              <p className="text-[11px] font-semibold uppercase tracking-[0.08em] text-primary">
                Student stories
              </p>
              <p className="mt-2 text-base font-medium text-navy">
                “The 90-day plan kept me on track for every chapter before
                boards.” — Rahul, Class 12
              </p>
            </div>
            <Link
              href="/for-students"
              className="flex h-10 shrink-0 items-center rounded-lg bg-navy px-4 text-sm font-semibold text-white hover:bg-primary"
            >
              How learning works
            </Link>
          </section>
        </div>
      </div>

      <section className="border-t border-border bg-white">
        <div className="mx-auto grid max-w-[1200px] gap-12 px-4 py-16 sm:px-6 lg:grid-cols-[320px_minmax(0,1fr)]">
          <div>
            <h2 className="text-[28px] font-bold tracking-[-0.02em] text-navy">
              Frequently Asked Questions
            </h2>
            <p className="mt-2.5 text-sm text-muted">
              Admission &amp; batch details ·{" "}
              <span className="font-hindi">प्रवेश और बैच संबंधी प्रश्न</span>
            </p>
          </div>
          <div className="grid gap-px overflow-hidden rounded-xl border border-border bg-border md:grid-cols-2">
            {courseFaqs.map((faq) => (
              <div key={faq.q} className="bg-white p-5">
                <h3 className="text-[15px] font-semibold text-navy">{faq.q}</h3>
                <p className="mt-2 text-sm leading-[1.6] text-muted">{faq.a}</p>
              </div>
            ))}
          </div>
        </div>
      </section>
    </>
  );
}

function Stat({ value, label, accent }: { value: string; label: string; accent?: boolean }) {
  return (
    <div>
      <p className={`text-[28px] font-bold ${accent ? "text-primary" : "text-navy"}`}>{value}</p>
      <p className="mt-0.5 text-xs font-semibold uppercase tracking-[0.06em] text-muted">
        {label}
      </p>
    </div>
  );
}

function FilterLabel({ children, first }: { children: React.ReactNode; first?: boolean }) {
  return (
    <p
      className={`mb-2.5 text-[11px] font-semibold uppercase tracking-[0.08em] text-muted ${
        first ? "mt-5" : "mt-5 border-t border-border pt-5"
      }`}
    >
      {children}
    </p>
  );
}
