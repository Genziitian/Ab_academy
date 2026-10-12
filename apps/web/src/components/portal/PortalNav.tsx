"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import { useState } from "react";
import {
  BellIcon,
  BookIcon,
  BrandMark,
  CalendarIcon,
  CloseIcon,
  DashboardIcon,
  DownloadIcon,
  HelpIcon,
  LiveIcon,
  MenuIcon,
  NotesIcon,
  SignOutIcon,
  UserIcon,
} from "@/components/icons";

const learn = [
  { href: "/dashboard", label: "Dashboard", Icon: DashboardIcon },
  { href: "/my-courses", label: "My Courses", Icon: BookIcon, also: ["/lecture"] },
  { href: "/live", label: "Live Classes", Icon: LiveIcon, live: true },
  { href: "/calendar", label: "Calendar", Icon: CalendarIcon },
  { href: "/materials", label: "Study Materials", Icon: NotesIcon },
  { href: "/downloads", label: "Downloads", Icon: DownloadIcon },
];

const account = [
  { href: "/notifications", label: "Notifications", Icon: BellIcon, badge: true },
  { href: "/support", label: "Help & Support", Icon: HelpIcon },
  { href: "/profile", label: "Profile & Settings", Icon: UserIcon },
];

type NavProps = { unread: number; demo: boolean };

function NavLinks({ unread, onNavigate }: { unread: number; onNavigate?: () => void }) {
  const pathname = usePathname();
  const isActive = (href: string, also: string[] = []) =>
    [href, ...also].some((p) => pathname === p || pathname.startsWith(`${p}/`));

  const item = (link: (typeof learn)[number] | (typeof account)[number]) => {
    const active = isActive(link.href, "also" in link ? link.also : []);
    return (
      <Link
        key={link.href}
        href={link.href}
        onClick={onNavigate}
        className={`flex h-10 items-center gap-3 rounded-lg px-2.5 text-sm ${
          active
            ? "bg-primary-soft font-semibold text-primary"
            : "font-medium text-ink hover:bg-surface-grey hover:text-navy"
        }`}
      >
        <link.Icon />
        {link.label}
        {"live" in link && link.live ? (
          <span className="ml-auto whitespace-nowrap rounded bg-danger-soft px-1.5 py-px text-[10px] font-bold tracking-[0.04em] text-danger">
            LIVE
          </span>
        ) : null}
        {"badge" in link && link.badge && unread ? (
          <span className="ml-auto flex h-[18px] min-w-[18px] items-center justify-center rounded-full bg-primary px-1 text-[11px] font-semibold text-white">
            {unread}
          </span>
        ) : null}
      </Link>
    );
  };

  return (
    <nav className="flex flex-1 flex-col gap-0.5 overflow-auto px-3 py-4">
      <p className="mb-1.5 px-2.5 text-[11px] font-semibold uppercase tracking-[0.08em] text-subtle">
        Learn
      </p>
      {learn.map(item)}
      <p className="mb-1.5 mt-[18px] px-2.5 text-[11px] font-semibold uppercase tracking-[0.08em] text-subtle">
        Account
      </p>
      {account.map(item)}
    </nav>
  );
}

function Footer({ demo }: { demo: boolean }) {
  return (
    <div className="flex flex-col gap-2.5 border-t border-border p-4">
      <Link
        href="/courses"
        className="flex h-[38px] items-center justify-center rounded-lg bg-primary-soft text-[13px] font-semibold text-primary hover:bg-[#dbe6ff]"
      >
        Browse more courses
      </Link>
      {demo ? (
        <Link
          href="/"
          className="flex items-center gap-2.5 px-2.5 py-1.5 text-[13px] font-medium text-muted hover:text-navy"
        >
          <SignOutIcon size={16} />
          Exit demo
        </Link>
      ) : (
        <form action="/auth/signout" method="post">
          <button
            type="submit"
            className="flex w-full items-center gap-2.5 px-2.5 py-1.5 text-[13px] font-medium text-muted hover:text-navy"
          >
            <SignOutIcon size={16} />
            Sign out
          </button>
        </form>
      )}
    </div>
  );
}

function Brand() {
  return (
    <Link href="/" className="flex items-center gap-2.5">
      <BrandMark size={32} />
      <span className="text-sm font-bold tracking-[-0.01em] text-navy">Akhand Bharat Academy</span>
    </Link>
  );
}

/** Fixed left rail on large screens. */
export function PortalSidebar({ unread, demo }: NavProps) {
  return (
    <aside className="sticky top-0 hidden h-screen w-[248px] shrink-0 flex-col border-r border-border bg-white lg:flex">
      <div className="flex h-[68px] items-center border-b border-border px-5">
        <Brand />
      </div>
      <NavLinks unread={unread} />
      <Footer demo={demo} />
    </aside>
  );
}

/** Brand bar with a slide-in drawer, shown below the `lg` breakpoint. */
export function PortalMobileNav({ unread, demo }: NavProps) {
  // Links close the drawer themselves via onNavigate.
  const [open, setOpen] = useState(false);

  return (
    <div className="lg:hidden">
      <div className="flex h-14 items-center justify-between border-b border-border bg-white px-4">
        <Brand />
        <button
          type="button"
          aria-label="Open menu"
          onClick={() => setOpen(true)}
          className="flex size-10 items-center justify-center rounded-lg border border-border text-navy"
        >
          <MenuIcon size={20} />
        </button>
      </div>
      {open ? (
        <div className="fixed inset-0 z-50 flex">
          <button
            type="button"
            aria-label="Close menu"
            className="absolute inset-0 bg-navy/40"
            onClick={() => setOpen(false)}
          />
          <aside className="relative flex h-full w-[280px] max-w-[85%] flex-col bg-white shadow-[var(--shadow-float)]">
            <div className="flex h-14 items-center justify-between border-b border-border px-4">
              <Brand />
              <button
                type="button"
                aria-label="Close menu"
                onClick={() => setOpen(false)}
                className="flex size-9 items-center justify-center rounded-lg text-muted"
              >
                <CloseIcon size={18} />
              </button>
            </div>
            <NavLinks unread={unread} onNavigate={() => setOpen(false)} />
            <Footer demo={demo} />
          </aside>
        </div>
      ) : null}
    </div>
  );
}
