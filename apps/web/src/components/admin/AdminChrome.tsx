"use client";

import { usePathname } from "next/navigation";
import Link from "next/link";

const NAV = [
  { href: "/admin", label: "Dashboard" },
  { href: "/admin/courses", label: "Courses" },
  { href: "/admin/students", label: "Students" },
  { href: "/admin/content", label: "Content" },
  { href: "/admin/schedule", label: "Schedule" },
  { href: "/admin/doubts", label: "Doubts" },
  { href: "/admin/tickets", label: "Tickets" },
  { href: "/admin/notifications", label: "Notifications" },
  { href: "/admin/popups", label: "Popups" },
  { href: "/admin/banners", label: "App slider" },
];

export function AdminSidebar() {
  const pathname = usePathname();

  return (
    <aside className="w-full shrink-0 border-b border-border bg-surface md:h-screen md:w-60 md:border-r md:border-b-0">
      <div className="px-5 py-5">
        <Link href="/" className="text-sm font-semibold text-navy">
          Akhand Bharat Academy
        </Link>
        <p className="mt-0.5 text-xs text-muted">Admin console</p>
      </div>
      <nav className="flex gap-1 overflow-x-auto px-3 pb-3 md:flex-col md:overflow-visible">
        {NAV.map((item) => {
          const active =
            item.href === "/admin" ? pathname === "/admin" : pathname.startsWith(item.href);
          return (
            <Link
              key={item.href}
              href={item.href}
              className={`whitespace-nowrap rounded-lg px-3 py-2 text-sm transition-colors ${
                active
                  ? "bg-primary-soft font-semibold text-primary"
                  : "text-muted hover:bg-surface-soft hover:text-navy"
              }`}
            >
              {item.label}
            </Link>
          );
        })}
      </nav>
    </aside>
  );
}

export function DemoBanner() {
  return (
    <div className="border-b border-orange/30 bg-orange/10 px-6 py-2.5 text-xs text-navy">
      <strong className="font-semibold">Demo data.</strong> No Supabase project is connected, so
      this console reads an in-memory mock and changes reset when the server restarts. Set
      NEXT_PUBLIC_SUPABASE_URL and NEXT_PUBLIC_SUPABASE_ANON_KEY to switch to live data.
    </div>
  );
}

export function PageHeader({
  title,
  description,
  action,
}: {
  title: string;
  description?: string;
  action?: React.ReactNode;
}) {
  return (
    <div className="mb-6 flex flex-wrap items-start justify-between gap-4">
      <div>
        <h1 className="text-2xl font-semibold tracking-tight text-navy">{title}</h1>
        {description ? <p className="mt-1 text-sm text-muted">{description}</p> : null}
      </div>
      {action}
    </div>
  );
}

export function Card({
  children,
  className = "",
}: {
  children: React.ReactNode;
  className?: string;
}) {
  return (
    <div
      className={`rounded-2xl border border-border bg-surface p-5 shadow-[var(--shadow-card)] ${className}`}
    >
      {children}
    </div>
  );
}

const STATUS_STYLES: Record<string, string> = {
  live: "bg-pink/15 text-pink",
  scheduled: "bg-primary-soft text-primary",
  ended: "bg-surface-soft text-muted",
  open: "bg-orange/15 text-orange",
  in_progress: "bg-primary-soft text-primary",
  resolved: "bg-success/15 text-success",
  closed: "bg-surface-soft text-muted",
  published: "bg-success/15 text-success",
  draft: "bg-surface-soft text-muted",
};

export function Pill({ status, label }: { status: string; label?: string }) {
  return (
    <span
      className={`inline-flex rounded-full px-2.5 py-1 text-xs font-semibold ${
        STATUS_STYLES[status] ?? "bg-surface-soft text-muted"
      }`}
    >
      {label ?? status.replace("_", " ")}
    </span>
  );
}

export function EmptyRow({ children }: { children: React.ReactNode }) {
  return <p className="py-8 text-center text-sm text-muted">{children}</p>;
}
