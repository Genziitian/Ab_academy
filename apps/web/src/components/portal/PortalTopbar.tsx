import Link from "next/link";
import { getStudent } from "@/lib/portal/student";

/** Page header: a small label, a serif title and the student's avatar. */
export async function PortalTopbar({ title, crumb }: { title: string; crumb?: React.ReactNode }) {
  const student = await getStudent();
  return (
    <header className="flex items-end gap-5 px-4 pb-2 pt-8 sm:px-8 lg:pt-10">
      <div className="min-w-0 flex-1">
        {crumb ? <p className="truncate text-sm font-semibold text-clay">{crumb}</p> : null}
        <h1 className="mt-1 font-serif text-[40px] leading-none tracking-[-0.02em] text-coal sm:text-[48px]">{title}</h1>
      </div>
      <Link href="/profile" className="hidden items-center gap-3 sm:flex" aria-label="Profile">
        <span className="text-right leading-tight">
          <span className="block text-sm font-semibold text-coal">{student.name}</span>
          <span className="block text-xs text-taupe">{student.summary}</span>
        </span>
        <span className="flex size-11 items-center justify-center rounded-full bg-clay text-sm font-bold text-white">
          {student.initials}
        </span>
      </Link>
    </header>
  );
}
