"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import { useState } from "react";
import { BookIcon, CloseIcon, DownloadIcon, HomeIcon, MenuIcon } from "@/components/icons";
import { LEGAL_DOCS } from "@/components/LegalPage";
import { NOTES_LIVE, PLAY_STORE_URL } from "@/lib/landing";
import { helpHref } from "@/lib/support";

const MORE_GROUPS = [
  {
    title: "Learn",
    links: [
      { href: "/#about", label: "About us" },
      { href: "/notes", label: NOTES_LIVE ? "Notes" : "Notes — coming soon" },
      { href: "/#how", label: "How it works" },
      { href: "/#faq", label: "FAQ" },
    ],
  },
  {
    title: "Help",
    links: [{ href: helpHref, label: "Contact & support" }],
  },
  {
    title: "Legal",
    links: LEGAL_DOCS.map((d) => ({ href: d.href, label: d.label })),
  },
];

/** The app's bottom tabs, on the website below laptop width. */
export function MobileTabBar() {
  const pathname = usePathname();
  const [moreOpen, setMoreOpen] = useState(false);

  const tab = (on: boolean) =>
    `flex h-16 flex-col items-center justify-center gap-1 text-[11px] font-semibold ${on ? "text-primary" : "text-muted"}`;

  return (
    <>
      {moreOpen ? (
        <div className="fixed inset-0 z-[60] lg:hidden" role="dialog" aria-modal="true" aria-label="More">
          <button
            type="button"
            aria-label="Close"
            className="absolute inset-0 bg-coal/40"
            onClick={() => setMoreOpen(false)}
          />
          <div className="absolute inset-x-0 bottom-0 max-h-[80vh] overflow-y-auto rounded-t-[28px] bg-cream px-5 pb-[calc(24px+env(safe-area-inset-bottom))] pt-4">
            <div className="flex items-center justify-between">
              <p className="font-serif text-3xl text-coal">More</p>
              <button
                type="button"
                onClick={() => setMoreOpen(false)}
                aria-label="Close"
                className="flex size-11 items-center justify-center rounded-full border border-sand text-coal"
              >
                <CloseIcon size={20} />
              </button>
            </div>
            {MORE_GROUPS.map((group) => (
              <div key={group.title} className="mt-5">
                <p className="text-[11px] font-bold uppercase tracking-[0.14em] text-clay">{group.title}</p>
                <div className="mt-1.5 flex flex-col">
                  {group.links.map((link) => (
                    <Link
                      key={link.href}
                      href={link.href}
                      onClick={() => setMoreOpen(false)}
                      className="flex items-center justify-between border-b border-sand py-3.5 text-base font-medium text-coal"
                    >
                      {link.label}
                      <span aria-hidden className="text-taupe">
                        →
                      </span>
                    </Link>
                  ))}
                </div>
              </div>
            ))}
          </div>
        </div>
      ) : null}

      <nav
        aria-label="Main"
        className="fixed inset-x-0 bottom-0 z-50 grid grid-cols-4 border-t border-border bg-cream pb-[env(safe-area-inset-bottom)] lg:hidden"
      >
        <Link href="/" aria-current={pathname === "/" ? "page" : undefined} className={tab(pathname === "/" && !moreOpen)}>
          <HomeIcon size={22} />
          Home
        </Link>
        <Link
          href="/#courses"
          className={tab((pathname.startsWith("/courses") || pathname.startsWith("/course/")) && !moreOpen)}
        >
          <BookIcon size={22} />
          Courses
        </Link>
        {PLAY_STORE_URL ? (
          <a href={PLAY_STORE_URL} target="_blank" rel="noopener noreferrer" className={tab(false)}>
            <DownloadIcon size={22} />
            Get app
          </a>
        ) : (
          <Link href="/#app" className={tab(false)}>
            <DownloadIcon size={22} />
            Get app
          </Link>
        )}
        <button
          type="button"
          aria-expanded={moreOpen}
          onClick={() => setMoreOpen((v) => !v)}
          className={tab(moreOpen)}
        >
          <MenuIcon size={22} />
          More
        </button>
      </nav>
    </>
  );
}
