"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import { useState } from "react";
import { BookIcon, CloseIcon, DownloadIcon, HomeIcon, MenuIcon } from "@/components/icons";
import { LanguageSwitch } from "@/components/LanguageSwitch";
import { LEGAL_DOCS } from "@/lib/legal-docs";
import { Arrow } from "@/components/ui";
import { useT } from "@/lib/i18n/client";
import { NOTES_LIVE, PLAY_STORE_URL } from "@/lib/landing";
import { helpHref } from "@/lib/support";

/** The app's bottom tabs, on the website below laptop width. */
export function MobileTabBar() {
  const t = useT();
  const pathname = usePathname();
  const [moreOpen, setMoreOpen] = useState(false);

  const groups = [
    {
      title: t.nav.learn,
      links: [
        { href: "/about", label: t.nav.about },
        { href: "/notes", label: NOTES_LIVE ? t.nav.notes : `${t.nav.notes} · ${t.common.comingSoon}` },
        { href: "/#how", label: t.nav.how },
        { href: "/#faq", label: t.nav.faq },
        { href: helpHref, label: t.nav.contact },
      ],
    },
    { title: t.nav.legal, links: LEGAL_DOCS.map((d) => ({ href: d.href, label: t.legalDocs[d.key] })) },
  ];

  const tab = (on: boolean) =>
    `flex h-16 flex-col items-center justify-center gap-1 text-[11px] font-medium ${on ? "text-ab-ink" : "text-ab-ink-3"}`;

  return (
    <>
      {moreOpen ? (
        <div className="fixed inset-0 z-[60] lg:hidden" role="dialog" aria-modal="true" aria-label={t.nav.more}>
          <button type="button" aria-label={t.nav.close} className="absolute inset-0 bg-ab-ink/30" onClick={() => setMoreOpen(false)} />
          <div className="absolute inset-x-0 bottom-0 max-h-[82vh] overflow-y-auto rounded-t-[24px] bg-ab-canvas px-5 pb-[calc(24px+env(safe-area-inset-bottom))] pt-3">
            <div className="mx-auto mb-3 h-1 w-10 rounded-full bg-ab-rule-strong" />
            <div className="flex items-center justify-between gap-3">
              <p className="ab-title text-2xl">{t.nav.more}</p>
              <div className="flex items-center gap-2">
                <LanguageSwitch />
                <button
                  type="button"
                  onClick={() => setMoreOpen(false)}
                  aria-label={t.nav.close}
                  className="flex size-10 items-center justify-center rounded-full border border-ab-rule bg-ab-panel text-ab-ink"
                >
                  <CloseIcon size={18} />
                </button>
              </div>
            </div>
            {groups.map((group) => (
              <div key={group.title} className="mt-6">
                <p className="ab-eyebrow">{group.title}</p>
                <div className="mt-2 overflow-hidden rounded-2xl border border-ab-rule bg-ab-panel">
                  {group.links.map((link) => (
                    <Link
                      key={link.href}
                      href={link.href}
                      onClick={() => setMoreOpen(false)}
                      className="flex items-center justify-between border-b border-ab-rule px-4 py-3.5 text-[15px] text-ab-ink last:border-b-0"
                    >
                      {link.label}
                      <Arrow className="text-ab-ink-3" />
                    </Link>
                  ))}
                </div>
              </div>
            ))}
          </div>
        </div>
      ) : null}

      <nav
        aria-label={t.nav.main}
        className="fixed inset-x-0 bottom-0 z-50 grid grid-cols-4 border-t border-ab-rule bg-ab-panel/95 pb-[env(safe-area-inset-bottom)] backdrop-blur lg:hidden"
      >
        <Link href="/" aria-current={pathname === "/" ? "page" : undefined} className={tab(pathname === "/" && !moreOpen)}>
          <HomeIcon size={21} />
          {t.nav.home}
        </Link>
        <Link href="/courses" className={tab((pathname.startsWith("/courses") || pathname.startsWith("/course/")) && !moreOpen)}>
          <BookIcon size={21} />
          {t.nav.courses}
        </Link>
        {PLAY_STORE_URL ? (
          <a href={PLAY_STORE_URL} target="_blank" rel="noopener noreferrer" className={tab(false)}>
            <DownloadIcon size={21} />
            {t.nav.getApp}
          </a>
        ) : (
          <Link href="/#app" className={tab(false)}>
            <DownloadIcon size={21} />
            {t.nav.getApp}
          </Link>
        )}
        <button type="button" aria-expanded={moreOpen} onClick={() => setMoreOpen((v) => !v)} className={tab(moreOpen)}>
          <MenuIcon size={21} />
          {t.nav.more}
        </button>
      </nav>
    </>
  );
}
