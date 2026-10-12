"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import { useState } from "react";
import { BrandMark, CloseIcon, MenuIcon, SearchIcon } from "@/components/icons";

const nav = [
  { href: "/courses", label: "Courses", match: ["/courses", "/course/"] },
  { href: "/notes", label: "Notes", match: ["/notes"] },
];

const mobileExtra = [
  { href: "/for-students", label: "How learning works" },
  { href: "/about", label: "About" },
  { href: "/contact", label: "Contact" },
];

export function SiteHeader() {
  const pathname = usePathname();
  const [open, setOpen] = useState(false);

  return (
    <header className="sticky top-0 z-50 border-b border-border bg-white/[0.97]">
      <div className="mx-auto flex h-[68px] max-w-[1200px] items-center gap-5 px-4 sm:px-6">
        <Link href="/" className="flex shrink-0 items-center gap-2.5">
          <BrandMark />
          <span className="flex flex-col whitespace-nowrap leading-[1.15]">
            <span className="text-[15px] font-bold tracking-[-0.01em] text-navy">
              Akhand Bharat Academy
            </span>
            <span className="text-[11px] font-medium tracking-[0.02em] text-muted">
              Class 11 &amp; 12 Crash Courses
            </span>
          </span>
        </Link>

        <nav className="hidden min-w-0 flex-1 items-center gap-0.5 md:flex">
          {nav.map((item) => {
            const active = item.match.some((m) => pathname.startsWith(m));
            return (
              <Link
                key={item.href}
                href={item.href}
                className={`whitespace-nowrap rounded-md px-2.5 py-2 text-sm ${
                  active
                    ? "bg-primary-soft font-semibold text-primary"
                    : "font-medium text-ink hover:text-navy"
                }`}
              >
                {item.label}
              </Link>
            );
          })}
        </nav>

        <div className="ml-auto hidden shrink-0 items-center gap-2.5 md:flex">
          <Link
            href="/courses"
            title="Search courses"
            className="flex size-[38px] items-center justify-center rounded-lg border border-border bg-surface-grey text-muted hover:text-navy"
          >
            <SearchIcon size={16} />
          </Link>
          <Link
            href="/login"
            className="flex h-[38px] items-center whitespace-nowrap rounded-lg border border-primary-line px-3.5 text-sm font-semibold text-primary hover:border-primary hover:bg-primary-soft"
          >
            Log in
          </Link>
          <Link
            href="/login"
            className="flex h-[38px] items-center whitespace-nowrap rounded-lg bg-primary px-3.5 text-sm font-semibold text-white hover:bg-primary-dark"
          >
            Sign up free
          </Link>
        </div>

        <button
          type="button"
          className="ml-auto flex size-10 items-center justify-center rounded-lg border border-border text-navy md:hidden"
          aria-label={open ? "Close menu" : "Open menu"}
          aria-expanded={open}
          onClick={() => setOpen((value) => !value)}
        >
          {open ? <CloseIcon size={20} /> : <MenuIcon size={20} />}
        </button>
      </div>

      {open ? (
        <div className="border-t border-border bg-white px-4 pb-4 pt-2 md:hidden">
          <nav className="flex flex-col">
            {[...nav, ...mobileExtra].map((item) => (
              <Link
                key={item.href}
                href={item.href}
                onClick={() => setOpen(false)}
                className="border-b border-line py-3 text-[15px] font-medium text-navy"
              >
                {item.label}
              </Link>
            ))}
          </nav>
          <div className="mt-4 grid grid-cols-2 gap-2.5">
            <Link
              href="/login"
              onClick={() => setOpen(false)}
              className="flex h-11 items-center justify-center rounded-lg border border-primary-line text-sm font-semibold text-primary"
            >
              Log in
            </Link>
            <Link
              href="/login"
              onClick={() => setOpen(false)}
              className="flex h-11 items-center justify-center rounded-lg bg-primary text-sm font-semibold text-white"
            >
              Sign up free
            </Link>
          </div>
        </div>
      ) : null}
    </header>
  );
}
