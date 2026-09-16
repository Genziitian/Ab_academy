"use client";

import Link from "next/link";
import { useMemo, useState } from "react";
import { CourseCard } from "@/components/CourseCard";
import {
  Course,
  classes,
  courseFaqs,
  subjectFilters,
} from "@/lib/courses";

type Props = {
  initialCourses: Course[];
  initialClass?: number;
};

export function CoursesCatalog({ initialCourses, initialClass }: Props) {
  const [classLevel, setClassLevel] = useState<number | "all">(
    initialClass ?? "all",
  );
  const [selectedSubjects, setSelectedSubjects] = useState<string[]>([]);
  const [courseType, setCourseType] = useState<"all" | "complete" | "subject">(
    "all",
  );
  const [maxPrice, setMaxPrice] = useState(5000);
  const [minRating, setMinRating] = useState(0);
  const [medium, setMedium] = useState<"all" | "Hindi" | "English" | "Bilingual">(
    "all",
  );
  const [sortBy, setSortBy] = useState<"popular" | "price-asc" | "price-desc">(
    "popular",
  );
  const [filtersOpen, setFiltersOpen] = useState(false);

  const filtered = useMemo(() => {
    let list = [...initialCourses];

    if (classLevel !== "all") {
      list = list.filter((c) => c.classLevel === classLevel);
    }
    if (selectedSubjects.length) {
      list = list.filter((c) =>
        selectedSubjects.some((s) => c.subjects.includes(s)),
      );
    }
    if (courseType === "complete") {
      list = list.filter((c) => c.subjects.length >= 3);
    }
    if (courseType === "subject") {
      list = list.filter((c) => c.subjects.length <= 2);
    }
    list = list.filter((c) => c.price <= maxPrice);
    if (minRating > 0) {
      list = list.filter((c) => c.rating >= minRating);
    }
    if (medium === "Hindi") {
      list = list.filter((c) => c.language.toLowerCase().includes("hindi"));
    }
    if (medium === "English") {
      list = list.filter((c) => c.language.toLowerCase().includes("english"));
    }
    if (medium === "Bilingual") {
      list = list.filter(
        (c) =>
          c.language.toLowerCase().includes("hindi") &&
          c.language.toLowerCase().includes("english"),
      );
    }

    if (sortBy === "price-asc") list.sort((a, b) => a.price - b.price);
    if (sortBy === "price-desc") list.sort((a, b) => b.price - a.price);
    if (sortBy === "popular") list.sort((a, b) => b.rating - a.rating);

    return list;
  }, [
    initialCourses,
    classLevel,
    selectedSubjects,
    courseType,
    maxPrice,
    minRating,
    medium,
    sortBy,
  ]);

  function toggleSubject(subject: string) {
    setSelectedSubjects((prev) =>
      prev.includes(subject)
        ? prev.filter((s) => s !== subject)
        : [...prev, subject],
    );
  }

  function clearAll() {
    setClassLevel("all");
    setSelectedSubjects([]);
    setCourseType("all");
    setMaxPrice(5000);
    setMinRating(0);
    setMedium("all");
    setSortBy("popular");
  }

  const sidebar = (
    <aside className="space-y-5">
      <div className="rounded-2xl border border-border bg-white p-4 shadow-[var(--shadow-card)]">
        <div className="mb-4 flex items-center justify-between">
          <h2 className="text-sm font-bold text-navy">Filters</h2>
          <button
            type="button"
            onClick={clearAll}
            className="text-xs font-semibold text-primary hover:underline"
          >
            Clear all
          </button>
        </div>

        <FilterBlock title="Subjects">
          <div className="space-y-2">
            {subjectFilters.map((subject) => {
              const count = initialCourses.filter((c) =>
                c.subjects.includes(subject),
              ).length;
              if (!count) return null;
              return (
                <label
                  key={subject}
                  className="flex cursor-pointer items-center justify-between gap-2 text-sm text-navy"
                >
                  <span className="flex items-center gap-2">
                    <input
                      type="checkbox"
                      checked={selectedSubjects.includes(subject)}
                      onChange={() => toggleSubject(subject)}
                      className="accent-primary"
                    />
                    {subject}
                  </span>
                  <span className="text-xs text-muted">{count}</span>
                </label>
              );
            })}
          </div>
        </FilterBlock>

        <FilterBlock title="Course type">
          {(
            [
              ["all", "All types"],
              ["complete", "Complete yearly batch"],
              ["subject", "Subject course"],
            ] as const
          ).map(([value, label]) => (
            <label
              key={value}
              className="mb-2 flex cursor-pointer items-center gap-2 text-sm text-navy"
            >
              <input
                type="radio"
                name="courseType"
                checked={courseType === value}
                onChange={() => setCourseType(value)}
                className="accent-primary"
              />
              {label}
            </label>
          ))}
        </FilterBlock>

        <FilterBlock title={`Max price · ₹${maxPrice}`}>
          <input
            type="range"
            min={500}
            max={5000}
            step={100}
            value={maxPrice}
            onChange={(e) => setMaxPrice(Number(e.target.value))}
            className="w-full accent-primary"
          />
        </FilterBlock>

        <FilterBlock title="Student rating">
          {[0, 4, 4.5].map((value) => (
            <label
              key={value}
              className="mb-2 flex cursor-pointer items-center gap-2 text-sm text-navy"
            >
              <input
                type="radio"
                name="rating"
                checked={minRating === value}
                onChange={() => setMinRating(value)}
                className="accent-primary"
              />
              {value === 0 ? "Any rating" : `${value}+ stars`}
            </label>
          ))}
        </FilterBlock>
      </div>

      <div className="rounded-2xl bg-[#0f3d2e] p-5 text-white">
        <p className="text-xs font-bold uppercase tracking-[0.14em] text-emerald-200">
          Medha Scholarship
        </p>
        <p className="mt-2 text-sm font-semibold leading-snug">
          Merit support for dedicated learners
        </p>
        <Link
          href="/contact"
          className="mt-4 inline-flex text-sm font-semibold text-emerald-200 underline"
        >
          Check eligibility
        </Link>
      </div>

      <div className="rounded-2xl bg-[#eef0ff] p-5">
        <p className="text-sm font-bold text-navy">Academic counselor</p>
        <p className="mt-1 text-sm text-muted">
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
  );

  return (
    <div className="bg-[#f7f8fc]">
      <section className="border-b border-border bg-white">
        <div className="mx-auto max-w-6xl px-4 py-8 sm:px-6 sm:py-10">
          <nav className="text-xs text-muted sm:text-sm">
            <Link href="/" className="hover:text-primary">
              Home
            </Link>
            <span className="mx-2">›</span>
            <span className="text-navy">Courses</span>
          </nav>
          <div className="mt-4 flex flex-col gap-6 lg:flex-row lg:items-end lg:justify-between">
            <div className="max-w-2xl">
              <h1 className="text-2xl font-extrabold tracking-tight text-navy sm:text-4xl">
                Explore All Batches & Courses
              </h1>
              <p className="mt-3 text-sm leading-relaxed text-muted sm:text-base">
                Syllabus-aligned batches, notes and live mentorship under Akhand
                Bharat Academy. Bihar Board Classes 9–12 available now — more
                domains coming soon.
              </p>
            </div>
            <div className="rounded-2xl border border-border bg-primary-soft px-5 py-4 text-center">
              <p className="text-2xl font-extrabold text-primary">
                {initialCourses.length}
              </p>
              <p className="text-xs font-semibold uppercase tracking-wide text-navy">
                Batches live
              </p>
            </div>
          </div>
        </div>
      </section>

      <div className="mx-auto max-w-6xl px-4 py-6 sm:px-6 sm:py-8">
        <div className="mb-4 flex gap-2 overflow-x-auto pb-1 lg:hidden">
          <button
            type="button"
            onClick={() => setFiltersOpen(true)}
            className="shrink-0 rounded-full border border-border bg-white px-4 py-2 text-sm font-semibold text-navy"
          >
            Filters
          </button>
        </div>

        <div className="mb-5 flex gap-2 overflow-x-auto pb-1 [-ms-overflow-style:none] [scrollbar-width:none] [&::-webkit-scrollbar]:hidden">
          <ClassTab
            active={classLevel === "all"}
            onClick={() => setClassLevel("all")}
            label="All Batches"
          />
          {classes.map((item) => (
            <ClassTab
              key={item.level}
              active={classLevel === item.level}
              onClick={() => setClassLevel(item.level)}
              label={item.title}
            />
          ))}
        </div>

        <div className="mb-6 flex flex-wrap items-center gap-2 text-sm">
          {(["all", "Hindi", "English", "Bilingual"] as const).map((value) => (
            <button
              key={value}
              type="button"
              onClick={() => setMedium(value)}
              className={`rounded-full px-3 py-1.5 font-medium ${
                medium === value
                  ? "bg-navy text-white"
                  : "bg-white text-muted ring-1 ring-border"
              }`}
            >
              {value === "all" ? "Any medium" : value}
            </button>
          ))}
          <select
            value={sortBy}
            onChange={(e) =>
              setSortBy(e.target.value as "popular" | "price-asc" | "price-desc")
            }
            className="ml-auto rounded-full border border-border bg-white px-3 py-1.5 text-sm font-medium text-navy"
          >
            <option value="popular">Sort: Popular</option>
            <option value="price-asc">Price: Low to high</option>
            <option value="price-desc">Price: High to low</option>
          </select>
        </div>

        <div className="grid gap-6 lg:grid-cols-[260px_1fr]">
          <div className="hidden lg:block">{sidebar}</div>

          <div>
            {(selectedSubjects.length > 0 ||
              classLevel !== "all" ||
              courseType !== "all") && (
              <div className="mb-4 flex flex-wrap gap-2">
                {classLevel !== "all" ? (
                  <Chip onRemove={() => setClassLevel("all")}>
                    Class {classLevel}
                  </Chip>
                ) : null}
                {selectedSubjects.map((s) => (
                  <Chip key={s} onRemove={() => toggleSubject(s)}>
                    {s}
                  </Chip>
                ))}
                {courseType !== "all" ? (
                  <Chip onRemove={() => setCourseType("all")}>
                    {courseType === "complete" ? "Complete batch" : "Subject"}
                  </Chip>
                ) : null}
              </div>
            )}

            <div className="grid gap-4 sm:grid-cols-2 xl:grid-cols-3">
              {filtered.map((course) => (
                <CourseCard key={course.slug} course={course} />
              ))}
            </div>

            {filtered.length === 0 ? (
              <p className="rounded-2xl border border-dashed border-border bg-white py-16 text-center text-muted">
                No courses match these filters.
              </p>
            ) : null}

            <section className="mt-10 overflow-hidden rounded-2xl bg-[#e8f0ff] p-5 sm:p-6">
              <div className="flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
                <div>
                  <p className="text-xs font-bold uppercase tracking-[0.14em] text-primary">
                    Student stories
                  </p>
                  <p className="mt-2 max-w-xl text-sm font-semibold text-navy sm:text-base">
                    “Clear classes and notes helped me stay consistent every
                    week.” — Rahul, Class 10
                  </p>
                </div>
                <Link
                  href="/for-students"
                  className="inline-flex shrink-0 rounded-full bg-navy px-4 py-2.5 text-sm font-semibold text-white"
                >
                  How learning works
                </Link>
              </div>
            </section>
          </div>
        </div>

        <section className="mt-14">
          <h2 className="text-2xl font-extrabold text-navy">
            Frequently Asked Questions
          </h2>
          <p className="mt-2 text-sm text-muted">
            Admission & batch details · प्रवेश और बैच संबंधी प्रश्न
          </p>
          <div className="mt-6 grid gap-4 md:grid-cols-2">
            {courseFaqs.map((item) => (
              <div
                key={item.q}
                className="rounded-2xl border border-border bg-white p-5 shadow-[var(--shadow-card)]"
              >
                <h3 className="text-sm font-bold text-navy">{item.q}</h3>
                <p className="mt-2 text-sm leading-relaxed text-muted">{item.a}</p>
              </div>
            ))}
          </div>
        </section>
      </div>

      {filtersOpen ? (
        <div className="fixed inset-0 z-50 lg:hidden">
          <button
            type="button"
            className="absolute inset-0 bg-navy/40"
            aria-label="Close filters"
            onClick={() => setFiltersOpen(false)}
          />
          <div className="absolute inset-y-0 left-0 w-[min(100%,20rem)] overflow-y-auto bg-[#f7f8fc] p-4 shadow-xl">
            <div className="mb-3 flex items-center justify-between">
              <p className="font-bold text-navy">Filters</p>
              <button
                type="button"
                onClick={() => setFiltersOpen(false)}
                className="text-sm font-semibold text-primary"
              >
                Done
              </button>
            </div>
            {sidebar}
          </div>
        </div>
      ) : null}
    </div>
  );
}

function FilterBlock({
  title,
  children,
}: {
  title: string;
  children: React.ReactNode;
}) {
  return (
    <div className="border-t border-border py-4 first:border-t-0 first:pt-0">
      <p className="mb-3 text-xs font-bold uppercase tracking-[0.12em] text-muted">
        {title}
      </p>
      {children}
    </div>
  );
}

function ClassTab({
  label,
  active,
  onClick,
}: {
  label: string;
  active: boolean;
  onClick: () => void;
}) {
  return (
    <button
      type="button"
      onClick={onClick}
      className={`shrink-0 rounded-full px-4 py-2 text-sm font-semibold transition ${
        active
          ? "bg-navy text-white"
          : "bg-white text-muted ring-1 ring-border hover:text-navy"
      }`}
    >
      {label}
    </button>
  );
}

function Chip({
  children,
  onRemove,
}: {
  children: React.ReactNode;
  onRemove: () => void;
}) {
  return (
    <button
      type="button"
      onClick={onRemove}
      className="inline-flex items-center gap-1.5 rounded-full bg-primary-soft px-3 py-1 text-xs font-semibold text-primary"
    >
      {children}
      <span aria-hidden>×</span>
    </button>
  );
}
