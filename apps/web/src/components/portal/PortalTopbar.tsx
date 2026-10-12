import Link from "next/link";
import { BellIcon, SearchIcon } from "@/components/icons";
import { unreadCount } from "@/lib/portal/data";
import { getStudent } from "@/lib/portal/student";

/** Page title bar with search, notifications and the student's name. */
export async function PortalTopbar({ title, crumb }: { title: string; crumb?: string }) {
  const student = await getStudent();

  return (
    <div className="flex min-h-[68px] items-center gap-5 border-b border-border bg-white px-4 py-3 sm:px-8 lg:sticky lg:top-0 lg:z-20">
      <div className="min-w-0 flex-1">
        <p className="truncate text-xs text-muted">{crumb ?? "Student portal"}</p>
        <h1 className="mt-0.5 truncate text-lg font-semibold tracking-[-0.01em] text-navy">
          {title}
        </h1>
      </div>
      <label className="hidden h-[38px] w-[220px] min-w-[120px] shrink items-center gap-2 rounded-lg border border-border bg-surface-grey px-3 text-muted md:flex">
        <SearchIcon size={16} />
        <input
          placeholder="Search lessons, notes, chapters"
          className="min-w-0 flex-1 bg-transparent text-sm text-foreground outline-none"
        />
      </label>
      <Link
        href="/notifications"
        aria-label="Notifications"
        className="relative flex size-[38px] shrink-0 items-center justify-center rounded-lg border border-border text-navy hover:bg-surface-grey"
      >
        <BellIcon />
        {unreadCount ? (
          <span className="absolute right-[9px] top-2 size-[7px] rounded-full border-[1.5px] border-white bg-pink" />
        ) : null}
      </Link>
      <Link href="/profile" className="hidden items-center gap-2.5 pl-2 sm:flex">
        <span className="flex size-9 items-center justify-center rounded-full bg-primary-soft text-[13px] font-semibold text-primary">
          {student.initials}
        </span>
        <span className="flex flex-col whitespace-nowrap leading-[1.25]">
          <span className="text-sm font-semibold text-navy">{student.name}</span>
          <span className="text-xs text-muted">{student.summary}</span>
        </span>
      </Link>
    </div>
  );
}
