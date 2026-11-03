import Image from "next/image";
import Link from "next/link";
import type { MyCourse } from "@/lib/portal/live";

/** Cards for the student's enrolled courses; each opens its curriculum. */
export function CourseCards({ courses }: { courses: MyCourse[] }) {
  return (
    <div className="grid gap-5 sm:grid-cols-2 xl:grid-cols-3">
      {courses.map((c) => (
        <Link
          key={c.id}
          href={`/my-courses/${c.id}`}
          className="group flex flex-col overflow-hidden rounded-[22px] border border-sand bg-cream transition hover:-translate-y-0.5 hover:border-coal hover:shadow-[0_18px_40px_rgba(28,24,20,0.1)]"
        >
          <div className="relative aspect-[16/8] bg-[linear-gradient(145deg,#e8742a,#b4521a)]">
            {c.art ? <Image src={c.art} alt="" fill sizes="(min-width: 1280px) 380px, 50vw" className="object-cover" /> : null}
          </div>
          <div className="flex flex-1 flex-col p-5">
            <p className="text-xs font-bold uppercase tracking-[0.14em] text-clay">{c.subjects.join(" · ") || "Course"}</p>
            <h3 className="mt-1.5 text-lg font-semibold leading-snug text-coal">{c.title}</h3>
            <p className="mt-1 text-sm text-taupe">
              {c.chapters} chapters · {c.lectures ? `${c.lectures} lectures ready` : "lectures coming soon"}
            </p>
            <span className="mt-auto pt-5 text-sm font-bold text-clay group-hover:underline">Open course →</span>
          </div>
        </Link>
      ))}
    </div>
  );
}

/** Shown when the student has no courses yet. */
export function NoCourses() {
  return (
    <div className="rounded-[24px] border border-dashed border-sand bg-cream px-6 py-12 text-center">
      <p className="font-serif text-[34px] leading-none text-coal">No courses yet</p>
      <p className="mx-auto mt-3 max-w-[420px] text-taupe">
        Join a Class 12 crash course — Physics, Chemistry or Maths — and it appears here with every lecture.
      </p>
      <Link
        href="/#courses"
        className="mt-6 inline-flex h-12 items-center rounded-full bg-saffron px-7 text-[15px] font-bold text-coal hover:bg-coal hover:text-cream"
      >
        Explore courses
      </Link>
    </div>
  );
}
