import Link from "next/link";
import { BrandMark, Wordmark } from "@/components/icons";
import { LanguageSwitch } from "@/components/LanguageSwitch";
import { Arrow, btn } from "@/components/ui";
import { listCourses } from "@/lib/catalog";
import { formatInr } from "@/lib/courses";
import { formatDate } from "@/lib/i18n/config";
import { courseTitle } from "@/lib/i18n/content";
import { getT } from "@/lib/i18n/server";
import { BATCH_START, NOTES_LIVE, PLAY_STORE_URL } from "@/lib/landing";

const navItem = "flex h-10 items-center gap-1.5 whitespace-nowrap rounded-[10px] px-3 text-[15px] text-ab-ink-2 transition-colors hover:bg-ab-tray hover:text-ab-ink";

export async function SiteHeader() {
  const [{ t, locale }, courses] = await Promise.all([getT(), listCourses()]);
  const start = formatDate(BATCH_START, locale, { day: "numeric", month: "long" });

  return (
    <>
      <div className="bg-ab-ink text-white">
        <p className="mx-auto flex max-w-[1280px] flex-wrap items-center justify-center gap-x-4 gap-y-1 px-4 py-2 text-center text-[13px] sm:text-sm">
          <span className="inline-flex items-center gap-2">
            <span className="size-1.5 rounded-full bg-ab-accent" />
            {t.nav.announcement(start)}
          </span>
          <Link href="/#courses" className="inline-flex items-center gap-1 font-medium text-white underline decoration-white/30 underline-offset-4 hover:decoration-white">
            {t.nav.announceJoin}
            <Arrow size={12} />
          </Link>
          {PLAY_STORE_URL ? (
            <a
              href={PLAY_STORE_URL}
              target="_blank"
              rel="noopener noreferrer"
              className="hidden font-medium text-white/80 underline decoration-white/30 underline-offset-4 hover:text-white sm:inline"
            >
              {t.nav.getApp}
            </a>
          ) : null}
        </p>
      </div>

      <header className="sticky top-0 z-50 border-b border-ab-rule bg-ab-canvas/90 backdrop-blur-md">
        <div className="mx-auto flex h-[68px] max-w-[1280px] items-center gap-4 px-4 sm:px-6 lg:px-10">
          <Link href="/" className="flex shrink-0 items-center gap-2.5" aria-label={t.common.brand}>
            <BrandMark size={36} />
            <Wordmark />
          </Link>

          <nav aria-label={t.nav.main} className="hidden min-w-0 flex-1 items-center justify-center gap-1 lg:flex">
            <div className="group relative">
              <button type="button" className={navItem} aria-haspopup="true">
                {t.nav.courses}
                <svg width="10" height="10" viewBox="0 0 12 12" aria-hidden className="transition group-focus-within:rotate-180 group-hover:rotate-180">
                  <path d="M2.5 4.5 6 8l3.5-3.5" fill="none" stroke="currentColor" strokeWidth="1.6" strokeLinecap="round" />
                </svg>
              </button>
              <div className="invisible absolute left-1/2 top-full z-50 w-[380px] -translate-x-1/2 pt-2 opacity-0 transition group-focus-within:visible group-focus-within:opacity-100 group-hover:visible group-hover:opacity-100">
                <div className="rounded-2xl border border-ab-rule bg-ab-panel p-1.5 shadow-[0_24px_48px_-24px_rgba(23,21,17,0.25)]">
                  {courses.map((c) => (
                    <Link key={c.slug} href={`/course/${c.slug}`} className="flex items-center justify-between gap-3 rounded-[10px] px-3 py-2.5 hover:bg-ab-canvas">
                      <span className="min-w-0 truncate text-[15px] text-ab-ink">{courseTitle(c, locale)}</span>
                      <span className="ab-num shrink-0 text-sm text-ab-ink-2">{c.price ? formatInr(c.price) : t.common.free}</span>
                    </Link>
                  ))}
                  <Link href="/courses" className="mt-1 flex items-center justify-between rounded-[10px] border-t border-ab-rule px-3 py-2.5 text-sm font-medium text-ab-ink hover:bg-ab-canvas">
                    {t.nav.compareAll}
                    <Arrow />
                  </Link>
                </div>
              </div>
            </div>
            <Link href="/notes" className={navItem}>
              {t.nav.notes}
              {NOTES_LIVE ? null : <span className="rounded-full bg-ab-tray px-2 py-0.5 text-[11px] text-ab-ink-3">{t.common.comingSoon}</span>}
            </Link>
            <Link href="/#how" className={navItem}>
              {t.nav.how}
            </Link>
            <Link href="/about" className={navItem}>
              {t.nav.about}
            </Link>
            <Link href="/#faq" className={navItem}>
              {t.nav.faq}
            </Link>
            <Link href="/contact" className={navItem}>
              {t.nav.help}
            </Link>
          </nav>

          <div className="ml-auto flex shrink-0 items-center gap-2">
            <LanguageSwitch />
            <Link href="/login" className={`${btn.ghost} !h-10 max-sm:hidden`}>
              {t.common.login}
            </Link>
            <Link href="/#courses" className={`${btn.primary} !h-10 max-lg:hidden`}>
              {t.nav.join}
            </Link>
            <Link href="/login" className={`${btn.primary} !h-10 !px-4 sm:!hidden`}>
              {t.common.login}
            </Link>
          </div>
        </div>
      </header>
    </>
  );
}
