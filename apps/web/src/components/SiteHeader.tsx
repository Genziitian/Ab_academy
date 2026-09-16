"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import { useState } from "react";

const nav = [
  { href: "/courses", label: "Courses" },
  { href: "/for-students", label: "Syllabus & Notes" },
  { href: "/for-students", label: "Live Classes" },
  { href: "/courses", label: "Past Papers" },
  { href: "/about", label: "Mentorship" },
];

export function SiteHeader() {
  const pathname = usePathname();
  const [open, setOpen] = useState(false);

  return (
    <header className="sticky top-0 z-50 border-b border-border bg-white/95 backdrop-blur-md">
      <div className="mx-auto flex h-[4.25rem] max-w-6xl items-center justify-between gap-3 px-4 sm:px-6">
        <Link href="/" className="flex min-w-0 items-center gap-2.5">
          <span className="flex h-10 w-10 shrink-0 items-center justify-center rounded-full bg-primary text-white shadow-[0_8px_20px_rgba(41,98,255,0.3)]">
            <GraduationIcon />
          </span>
          <span className="truncate text-[0.95rem] font-bold tracking-tight text-navy sm:text-base">
            Akhand Bharat Academy
          </span>
        </Link>

        <nav className="hidden items-center gap-0.5 xl:flex">
          {nav.map((item) => {
            const active =
              item.label === "Courses"
                ? pathname.startsWith("/courses") ||
                  pathname.startsWith("/course/")
                : false;
            return (
              <Link
                key={`${item.href}-${item.label}`}
                href={item.href}
                className={`rounded-full px-3 py-2 text-sm font-medium transition ${
                  active
                    ? "bg-primary-soft text-primary"
                    : "text-muted hover:bg-surface-soft hover:text-navy"
                }`}
              >
                {item.label}
              </Link>
            );
          })}
        </nav>

        <div className="hidden items-center gap-2 md:flex">
          <div className="hidden items-center rounded-full border border-border bg-[#f7f8fc] px-3 py-1.5 lg:flex">
            <SearchIcon />
            <input
              type="search"
              placeholder="Search courses"
              className="ml-2 w-36 bg-transparent text-sm outline-none placeholder:text-muted"
            />
          </div>
          <Link
            href="/courses?class=10"
            className="hidden rounded-full border border-border px-3 py-2 text-xs font-semibold text-navy lg:inline-flex"
          >
            Class 10
          </Link>
          <Link
            href="/login"
            className="rounded-full border-2 border-primary/25 px-4 py-2 text-sm font-semibold text-primary hover:border-primary hover:bg-primary-soft"
          >
            Login
          </Link>
          <Link
            href="/login"
            className="rounded-full bg-primary px-4 py-2.5 text-sm font-semibold text-white hover:bg-primary-dark"
          >
            Sign Up
          </Link>
        </div>

        <button
          type="button"
          className="inline-flex h-10 w-10 items-center justify-center rounded-full border border-border md:hidden"
          aria-label="Toggle menu"
          onClick={() => setOpen((value) => !value)}
        >
          <div className="space-y-1.5">
            <span className="block h-0.5 w-5 bg-navy" />
            <span className="block h-0.5 w-5 bg-navy" />
            <span className="block h-0.5 w-4 bg-navy" />
          </div>
        </button>
      </div>

      {open ? (
        <div className="border-t border-border bg-white px-4 py-3 md:hidden">
          <nav className="flex flex-col gap-1">
            <Link
              href="/"
              onClick={() => setOpen(false)}
              className="rounded-xl px-3 py-2.5 text-sm font-medium text-navy hover:bg-primary-soft"
            >
              Home
            </Link>
            {nav.map((item) => (
              <Link
                key={`${item.href}-${item.label}-m`}
                href={item.href}
                onClick={() => setOpen(false)}
                className="rounded-xl px-3 py-2.5 text-sm font-medium text-navy hover:bg-primary-soft"
              >
                {item.label}
              </Link>
            ))}
            <Link
              href="/contact"
              onClick={() => setOpen(false)}
              className="rounded-xl px-3 py-2.5 text-sm font-medium text-navy hover:bg-primary-soft"
            >
              Contact
            </Link>
            <Link
              href="/login"
              onClick={() => setOpen(false)}
              className="mt-2 rounded-full bg-primary px-3 py-2.5 text-center text-sm font-semibold text-white"
            >
              Login / Sign Up
            </Link>
          </nav>
        </div>
      ) : null}
    </header>
  );
}

function GraduationIcon() {
  return (
    <svg width="18" height="18" viewBox="0 0 24 24" fill="none" aria-hidden>
      <path
        d="M12 3 2 8l10 5 10-5-10-5Z"
        stroke="currentColor"
        strokeWidth="1.8"
        strokeLinejoin="round"
      />
      <path
        d="M5 10.5V16c0 .8 3.1 3 7 3s7-2.2 7-3v-5.5"
        stroke="currentColor"
        strokeWidth="1.8"
        strokeLinecap="round"
      />
      <path
        d="M22 8v6"
        stroke="currentColor"
        strokeWidth="1.8"
        strokeLinecap="round"
      />
    </svg>
  );
}

function SearchIcon() {
  return (
    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" aria-hidden>
      <circle cx="11" cy="11" r="7" stroke="currentColor" strokeWidth="1.8" />
      <path
        d="m20 20-3.5-3.5"
        stroke="currentColor"
        strokeWidth="1.8"
        strokeLinecap="round"
      />
    </svg>
  );
}
