import Link from "next/link";
import { BrandMark, Wordmark } from "@/components/icons";
import { LEGAL_DOCS } from "@/components/LegalPage";
import { listCourses } from "@/lib/catalog";
import { formatInr } from "@/lib/courses";
import { BATCH_START_LABEL, NOTES_LIVE, PLAY_STORE_URL } from "@/lib/landing";

const MORE_LINKS = [
  { href: "/#how", label: "How it works" },
  { href: "/#faq", label: "FAQ" },
  { href: "/contact", label: "Contact & support" },
  ...LEGAL_DOCS.map((d) => ({ href: d.href, label: d.label })),
];

const navItem = "flex h-11 items-center gap-1.5 whitespace-nowrap text-ink hover:text-clay";

/** Hover or keyboard-focus menu; no JavaScript needed. */
function Dropdown({ label, children, wide = false }: { label: string; children: React.ReactNode; wide?: boolean }) {
  return (
    <div className="group relative">
      <button type="button" className={navItem} aria-haspopup="true">
        {label}
        <svg width="12" height="12" viewBox="0 0 12 12" aria-hidden className="transition group-hover:rotate-180 group-focus-within:rotate-180">
          <path d="M2.5 4.5 6 8l3.5-3.5" fill="none" stroke="currentColor" strokeWidth="1.6" strokeLinecap="round" />
        </svg>
      </button>
      <div
        className={`invisible absolute left-1/2 top-full z-50 -translate-x-1/2 pt-2 opacity-0 transition group-hover:visible group-hover:opacity-100 group-focus-within:visible group-focus-within:opacity-100 ${
          wide ? "w-[360px]" : "w-[240px]"
        }`}
      >
        <div className="rounded-2xl border border-sand bg-cream p-2 shadow-[0_18px_40px_rgba(28,24,20,0.14)]">{children}</div>
      </div>
    </div>
  );
}

export async function SiteHeader() {
  const courses = await listCourses();
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

      <header className="sticky top-0 z-50 border-b border-sand bg-cream">
        <div className="mx-auto flex h-[72px] max-w-[1280px] items-center gap-6 px-4 sm:h-[84px] sm:px-6 lg:px-16">
          <Link href="/" className="flex shrink-0 items-center gap-3">
            <BrandMark size={40} />
            <Wordmark />
          </Link>

          <nav aria-label="Main" className="hidden min-w-0 flex-1 items-center justify-center gap-8 text-[15px] font-medium lg:flex">
            <Dropdown label="Courses" wide>
              {courses.map((c) => (
                <Link
                  key={c.slug}
                  href={`/course/${c.slug}`}
                  className="flex items-center justify-between gap-3 rounded-xl px-3 py-2.5 hover:bg-paper"
                >
                  <span className="min-w-0">
                    <span className="block truncate font-semibold text-coal">{c.title}</span>
                    <span className="block text-[13px] text-taupe">{c.teacher}</span>
                  </span>
                  <span className="shrink-0 text-sm font-bold text-clay">{c.price ? formatInr(c.price) : "Free"}</span>
                </Link>
              ))}
              <Link href="/#courses" className="mt-1 block rounded-xl border-t border-sand px-3 py-2.5 text-sm font-semibold text-clay hover:bg-paper">
                Compare all courses →
              </Link>
            </Dropdown>
            <Link href="/notes" className={navItem}>
              Notes
              {NOTES_LIVE ? null : (
                <span className="rounded-full bg-saffron/25 px-2 py-0.5 text-[11px] font-bold uppercase tracking-[0.06em] text-clay">
                  Coming soon
                </span>
              )}
            </Link>
            <Link href="/#about" className={navItem}>
              About us
            </Link>
            <Dropdown label="More">
              {MORE_LINKS.map((l) => (
                <Link key={l.href} href={l.href} className="block rounded-xl px-3 py-2.5 text-coal hover:bg-paper">
                  {l.label}
                </Link>
              ))}
            </Dropdown>
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

          <Link
            href="/login"
            className="ml-auto flex h-11 items-center rounded-full bg-coal px-5 text-[15px] font-semibold text-cream lg:hidden"
          >
            Log in
          </Link>
        </div>
      </header>
    </>
  );
}
