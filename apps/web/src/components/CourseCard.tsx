import Link from "next/link";
import { Course, discountPercent, formatInr } from "@/lib/courses";

export function CourseCard({ course }: { course: Course }) {
  const off = discountPercent(course.price, course.originalPrice);

  return (
    <article className="flex flex-col overflow-hidden rounded-2xl border border-border bg-white shadow-[var(--shadow-card)] transition hover:-translate-y-0.5 hover:shadow-[var(--shadow-soft)]">
      <Link href={`/course/${course.slug}`} className="relative block">
        <div
          className="relative flex min-h-[9.5rem] flex-col justify-between p-4 text-white sm:min-h-[10.5rem]"
          style={{
            background: `linear-gradient(145deg, hsl(${course.thumbnailHue} 70% 48%), hsl(${course.thumbnailHue + 22} 65% 34%))`,
          }}
        >
          <div className="flex flex-wrap gap-2">
            {course.badge ? (
              <span className="rounded-md bg-[#122046]/75 px-2 py-0.5 text-[0.65rem] font-semibold uppercase tracking-wide">
                {course.badge}
              </span>
            ) : null}
            <span className="rounded-md bg-white/20 px-2 py-0.5 text-[0.65rem] font-semibold backdrop-blur-sm">
              Class {course.classLevel}
            </span>
          </div>
          <div className="flex items-end justify-between gap-2">
            <p className="text-xs text-white/85">{course.lessons}+ lectures</p>
            <span className="rounded-full bg-white/95 px-2 py-1 text-xs font-bold text-navy">
              ★ {course.rating}
            </span>
          </div>
        </div>
      </Link>

      <div className="flex flex-1 flex-col p-4 sm:p-5">
        <p className="text-xs font-semibold uppercase tracking-wide text-primary">
          {course.tagline || course.subjects.slice(0, 2).join(" · ")}
        </p>
        <Link href={`/course/${course.slug}`}>
          <h3 className="mt-1.5 line-clamp-2 text-base font-bold leading-snug text-navy sm:text-lg">
            {course.title}
          </h3>
        </Link>
        <p className="mt-2 line-clamp-2 text-sm text-muted">{course.description}</p>

        <ul className="mt-3 space-y-1.5 text-xs text-muted sm:text-sm">
          {course.highlights.slice(0, 2).map((item) => (
            <li key={item} className="flex gap-2">
              <span className="text-success">✓</span>
              <span className="line-clamp-1">{item}</span>
            </li>
          ))}
        </ul>

        <div className="mt-4 flex items-center gap-2.5">
          <span className="flex h-8 w-8 items-center justify-center rounded-full bg-primary-soft text-xs font-bold text-primary">
            {course.teacher
              .split(" ")
              .map((w) => w[0])
              .slice(0, 2)
              .join("")}
          </span>
          <div className="min-w-0">
            <p className="truncate text-sm font-semibold text-navy">
              {course.teacher}
            </p>
            <p className="truncate text-xs text-muted">
              {course.teacherTitle || course.board}
            </p>
          </div>
        </div>

        <div className="mt-4 flex items-end justify-between gap-3 border-t border-border pt-4">
          <div>
            <p className="text-lg font-extrabold text-navy">
              {formatInr(course.price)}
            </p>
            <div className="flex items-center gap-2">
              {course.originalPrice ? (
                <span className="text-xs text-muted line-through">
                  {formatInr(course.originalPrice)}
                </span>
              ) : null}
              {off > 0 ? (
                <span className="text-xs font-bold text-success">{off}% OFF</span>
              ) : null}
            </div>
          </div>
          <Link
            href={`/course/${course.slug}`}
            className="rounded-lg bg-navy px-4 py-2.5 text-sm font-semibold text-white hover:bg-primary"
          >
            Enroll
          </Link>
        </div>
      </div>
    </article>
  );
}
