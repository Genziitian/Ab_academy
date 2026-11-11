import Image from "next/image";
import Link from "next/link";
import { Panel, btn } from "@/components/ui";
import { type Course, courseArt, discountPercent, formatInr } from "@/lib/courses";
import type { Locale } from "@/lib/i18n/config";
import { courseTitle } from "@/lib/i18n/content";
import type { Dict } from "@/lib/i18n/dictionaries";

/** A course in the catalog grid. */
export function CourseCard({ course, t, locale }: { course: Course; t: Dict; locale: Locale }) {
  const off = discountPercent(course.price, course.originalPrice);
  const href = `/course/${course.slug}`;
  const art = courseArt(course);
  const free = course.price === 0;

  return (
    <Panel as="article" className="flex flex-col overflow-hidden transition-colors hover:border-ab-rule-strong">
      <Link href={href} className="relative block aspect-[16/8] bg-ab-tray" tabIndex={-1} aria-hidden>
        {art ? <Image src={art} alt="" fill sizes="(min-width: 1280px) 380px, 50vw" className="object-cover" /> : null}
      </Link>
      <div className="flex flex-1 flex-col p-5">
        <p className="text-[13px] text-ab-ink-3">
          {t.common.classN(course.classLevel)} · {free ? t.catalog.demo : t.common.board}
        </p>
        <Link href={href} className="ab-title mt-1.5 text-lg hover:underline">
          {courseTitle(course, locale)}
        </Link>
        <div className="min-h-5 flex-1" />
        <div className="flex items-end justify-between gap-3 border-t border-ab-rule pt-4">
          <div>
            {course.originalPrice && off ? (
              <p className="ab-num text-xs text-ab-ink-3">
                <span className="line-through">{formatInr(course.originalPrice)}</span> · {t.course.off(off)}
              </p>
            ) : null}
            <p className="ab-num text-[22px] font-medium text-ab-ink">{free ? t.common.free : formatInr(course.price)}</p>
          </div>
          <Link href={href} className={`${btn.secondary} !h-10 !px-4 !text-sm`}>
            {t.catalog.viewCourse}
          </Link>
        </div>
      </div>
    </Panel>
  );
}
