"use client";

import Link from "next/link";
import { useState } from "react";
import { BrandMark, CloseIcon, MenuIcon } from "@/components/icons";
import { BATCH_START_LABEL, PLAY_STORE_URL } from "@/lib/landing";

const nav = [
  { href: "/#how", label: "How it works" },
  { href: "/#courses", label: "Courses" },
  { href: "/notes", label: "Free notes" },
  { href: "/#about", label: "About" },
  { href: "/#faq", label: "FAQ" },
];

export function SiteHeader() {
  const [open, setOpen] = useState(false);

  return (
    <>
      <div className="bg-coal text-cream">
        <p className="mx-auto flex max-w-[1280px] flex-wrap items-center justify-center gap-x-4 gap-y-1 px-4 py-2.5 text-center text-[13px] sm:text-[15px]">
          <span>
            <strong className="text-saffron">Class 12 Crash Course</strong>: classes start {BATCH_START_LABEL}
          </span>
          <Link href="/#courses" className="border-b border-saffron font-bold text-cream">
            Join now →
          </Link>
          {PLAY_STORE_URL ? (
            <a
              href={PLAY_STORE_URL}
              target="_blank"
              rel="noopener noreferrer"
              className="hidden border-b border-saffron font-bold text-cream sm:inline"
            >
              Download the app on Play Store
            </a>
          ) : null}
        </p>
      </div>

      <header className="sticky top-0 z-50 border-b border-sand bg-cream/95 backdrop-blur-md">
        <div className="mx-auto flex h-[72px] max-w-[1280px] items-center gap-6 px-4 sm:h-[84px] sm:px-6 lg:px-16">
          <Link href="/" className="flex shrink-0 items-center gap-3">
            <BrandMark size={40} />
            <span className="font-serif text-[28px] leading-none text-coal sm:text-[34px]">AB Academy</span>
          </Link>

          <nav className="hidden min-w-0 flex-1 justify-center gap-8 text-[15px] font-medium lg:flex">
            {nav.map((item) => (
              <Link key={item.href} href={item.href} className="whitespace-nowrap text-ink hover:text-clay">
                {item.label}
              </Link>
            ))}
          </nav>

          <div className="ml-auto hidden shrink-0 items-center gap-2.5 lg:flex">
            <Link
              href="/login"
              className="flex h-11 items-center rounded-full border border-coal px-5 text-[15px] font-semibold text-coal hover:bg-coal hover:text-cream"
            >
              Log in
            </Link>
            <Link
              href="/#courses"
              className="flex h-11 items-center whitespace-nowrap rounded-full bg-saffron px-5 text-[15px] font-bold text-coal hover:bg-coal hover:text-cream"
            >
              Join Class 12 Crash Course
            </Link>
          </div>

          <button
            type="button"
            className="ml-auto flex size-11 items-center justify-center rounded-full border border-sand text-coal lg:hidden"
            aria-label={open ? "Close menu" : "Open menu"}
            aria-expanded={open}
            onClick={() => setOpen((value) => !value)}
          >
            {open ? <CloseIcon size={20} /> : <MenuIcon size={20} />}
          </button>
        </div>

        {open ? (
          <div className="border-t border-sand bg-cream px-4 pb-5 pt-2 lg:hidden">
            <nav className="flex flex-col">
              {nav.map((item) => (
                <Link
                  key={item.href}
                  href={item.href}
                  onClick={() => setOpen(false)}
                  className="border-b border-sand py-3.5 text-base font-medium text-coal"
                >
                  {item.label}
                </Link>
              ))}
            </nav>
            <div className="mt-4 grid gap-2.5">
              <Link
                href="/#courses"
                onClick={() => setOpen(false)}
                className="flex h-12 items-center justify-center rounded-full bg-saffron text-[15px] font-bold text-coal"
              >
                Join Class 12 Crash Course
              </Link>
              <Link
                href="/login"
                onClick={() => setOpen(false)}
                className="flex h-12 items-center justify-center rounded-full border border-coal text-[15px] font-semibold text-coal"
              >
                Log in
              </Link>
            </div>
          </div>
        ) : null}
      </header>
    </>
  );
}
