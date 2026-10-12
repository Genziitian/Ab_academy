import Link from "next/link";
import {
  Course,
  CRASH_COURSE_DAYS,
  discountPercent,
  formatInr,
  thumbnailGradient,
} from "@/lib/courses";

type Props = {
  course: Course;
  /**
   * "featured" is the larger home-page card with the stream name on the
   * thumbnail; "catalog" is the compact card in the course grid, which also
   * shows the teacher and medium.
   */
  variant?: "featured" | "catalog";
  className?: string;
};

export function CourseCard({ course, variant = "catalog", className = "" }: Props) {
  const off = discountPercent(course.price, course.originalPrice);
  const href = `/course/${course.slug}`;
  const featured = variant === "featured";

  return (
    <article
      className={`flex flex-col overflow-hidden rounded-xl border border-border bg-white transition-shadow hover:shadow-[var(--shadow-soft)] ${className}`}
    >
      <Link
        href={href}
        className={`flex flex-col justify-between ${featured ? "min-h-[170px] p-4" : "min-h-[140px] p-3.5"}`}
        style={{ background: thumbnailGradient(course.thumbnailHue) }}
      >
        <div className="flex gap-1.5">
          {course.badge ? (
            <span className="whitespace-nowrap rounded bg-navy/70 px-2 py-[3px] text-[11px] font-semibold uppercase tracking-[0.04em] text-white">
              {course.badge}
            </span>
          ) : null}
          <span className="whitespace-nowrap rounded bg-white/[0.22] px-2 py-[3px] text-[11px] font-semibold text-white">
            Class {course.classLevel}
          </span>
        </div>
        {featured ? (
          <div>
            <p className="text-[22px] font-bold tracking-[-0.01em] text-white">
              {course.stream ?? course.subjects.join(" · ")}
            </p>
            <div className="mt-1.5 flex items-end justify-between">
              <span className="text-[13px] text-white/90">
                {course.lessons}+ lectures · {CRASH_COURSE_DAYS} days
              </span>
              <Rating value={course.rating} />
            </div>
          </div>
        ) : (
          <div className="flex items-end justify-between">
            <span className="text-[13px] text-white/90">
              {course.lessons}+ lectures
            </span>
            <Rating value={course.rating} />
          </div>
        )}
      </Link>

      <div className={`flex flex-1 flex-col ${featured ? "p-5" : "p-[18px]"}`}>
        {course.tagline ? (
          <p className="text-xs font-semibold uppercase tracking-[0.04em] text-primary">
            {course.tagline}
          </p>
        ) : null}
        <Link
          href={href}
          className={`mt-1.5 font-semibold leading-[1.35] text-navy hover:text-primary ${featured ? "text-lg" : "text-base"}`}
        >
          {course.title}
        </Link>
        <p
          className={`mt-2 flex-1 leading-[1.55] text-muted ${featured ? "text-sm" : "text-[13px]"}`}
        >
          {course.description}
        </p>
        {featured ? null : (
          <p className="mt-3 text-[13px] text-ink">
            <span className="font-semibold text-navy">{course.teacher}</span> ·{" "}
            {course.language}
          </p>
        )}

        <div
          className={`flex items-center justify-between gap-3 border-t border-border ${featured ? "mt-4 pt-4" : "mt-3.5 pt-3.5"}`}
        >
          {featured ? (
            <div className="flex min-w-0 items-baseline gap-x-1.5 whitespace-nowrap">
              <span className="text-lg font-bold text-navy">
                {formatInr(course.price)}
              </span>
              {course.originalPrice ? (
                <span className="text-xs text-muted line-through">
                  {formatInr(course.originalPrice)}
                </span>
              ) : null}
              {off ? (
                <span className="text-xs font-semibold text-success">
                  {off}% OFF
                </span>
              ) : null}
            </div>
          ) : (
            <div>
              <p className="text-lg font-bold text-navy">{formatInr(course.price)}</p>
              {course.originalPrice ? (
                <p className="text-xs">
                  <span className="text-muted line-through">
                    {formatInr(course.originalPrice)}
                  </span>{" "}
                  {off ? (
                    <span className="font-semibold text-success">{off}% OFF</span>
                  ) : null}
                </p>
              ) : null}
            </div>
          )}
          <Link
            href={href}
            className={`flex shrink-0 items-center whitespace-nowrap rounded-lg bg-navy text-sm font-semibold text-white hover:bg-primary ${featured ? "h-[38px] px-4" : "h-9 px-3.5"}`}
          >
            Enroll
          </Link>
        </div>
      </div>
    </article>
  );
}

function Rating({ value }: { value: number }) {
  return (
    <span className="whitespace-nowrap rounded bg-white px-2 py-[3px] text-xs font-bold text-navy">
      ★ {value}
    </span>
  );
}
