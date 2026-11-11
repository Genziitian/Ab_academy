"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import { useState } from "react";
import {
  BookIcon,
  BrandMark,
  CloseIcon,
  DashboardIcon,
  HelpIcon,
  LiveIcon,
  MenuIcon,
  NotesIcon,
  SignOutIcon,
  UserIcon,
  Wordmark,
} from "@/components/icons";
import { LanguageSwitch } from "@/components/LanguageSwitch";
import { Initials } from "@/components/ui";
import { useT } from "@/lib/i18n/client";

export type NavStudent = { name: string; initials: string; summary: string };

function useGroups() {
  const p = useT().portal;
  return [
    {
      title: p.groupLearn,
      links: [
        { href: "/dashboard", label: p.home, Icon: DashboardIcon },
        { href: "/my-courses", label: p.myCourses, Icon: BookIcon, also: ["/lecture"] },
        { href: "/live", label: p.live, Icon: LiveIcon },
        { href: "/materials", label: p.notes, Icon: NotesIcon },
      ],
    },
    {
      title: p.groupAccount,
      links: [
        { href: "/support", label: p.support, Icon: HelpIcon },
        { href: "/profile", label: p.profile, Icon: UserIcon },
      ],
    },
  ];
}

function NavLinks({ onNavigate }: { onNavigate?: () => void }) {
  const pathname = usePathname();
  const groups = useGroups();
  const active = (href: string, also: string[] = []) => [href, ...also].some((x) => pathname === x || pathname.startsWith(`${x}/`));

  return (
    <nav className="flex flex-1 flex-col gap-6 overflow-y-auto px-3 py-5">
      {groups.map((group) => (
        <div key={group.title}>
          <p className="ab-eyebrow mb-1.5 px-3">{group.title}</p>
          <div className="flex flex-col gap-0.5">
            {group.links.map((link) => {
              const on = active(link.href, "also" in link ? link.also : []);
              return (
                <Link
                  key={link.href}
                  href={link.href}
                  onClick={onNavigate}
                  aria-current={on ? "page" : undefined}
                  className={`relative flex h-10 items-center gap-3 rounded-[10px] px-3 text-[15px] transition-colors ${
                    on
                      ? "bg-ab-panel font-medium text-ab-ink shadow-[0_0_0_1px_var(--color-ab-rule),0_1px_2px_rgba(23,21,17,0.04)]"
                      : "text-ab-ink-2 hover:bg-ab-tray/70 hover:text-ab-ink"
                  }`}
                >
                  <link.Icon size={18} className={on ? "text-ab-ink" : "text-ab-ink-3"} />
                  {link.label}
                  {on ? <span className="ml-auto size-1.5 rounded-full bg-ab-accent" /> : null}
                </Link>
              );
            })}
          </div>
        </div>
      ))}
    </nav>
  );
}

function Footer({ demo, student }: { demo: boolean; student: NavStudent }) {
  const p = useT().portal;
  const t = useT();
  return (
    <div className="flex flex-col gap-3 p-3">
      <div className="rounded-2xl border border-ab-rule bg-ab-panel p-3">
        <Link href="/profile" className="flex items-center gap-3">
          <Initials text={student.initials} size={36} />
          <span className="min-w-0 leading-tight">
            <span className="block truncate text-[15px] font-medium text-ab-ink">{student.name}</span>
            <span className="block truncate text-[13px] text-ab-ink-3">{student.summary}</span>
          </span>
        </Link>
        <div className="mt-3 flex items-center justify-between gap-2 border-t border-ab-rule pt-3">
          <LanguageSwitch />
          {demo ? (
            <Link href="/" className="flex h-9 items-center gap-1.5 rounded-[10px] px-2.5 text-[13px] text-ab-ink-2 hover:bg-ab-canvas hover:text-ab-ink">
              <SignOutIcon size={15} />
              {p.exitPreview}
            </Link>
          ) : (
            <form action="/auth/signout" method="post">
              <button type="submit" className="flex h-9 items-center gap-1.5 rounded-[10px] px-2.5 text-[13px] text-ab-ink-2 hover:bg-ab-canvas hover:text-ab-ink">
                <SignOutIcon size={15} />
                {t.common.signOut}
              </button>
            </form>
          )}
        </div>
      </div>
    </div>
  );
}

function Brand() {
  const t = useT();
  return (
    <Link href="/" className="flex items-center gap-2.5" aria-label={t.common.brand}>
      <BrandMark size={34} />
      <Wordmark size="sm" />
    </Link>
  );
}

/** Left rail on large screens. */
export function PortalSidebar({ demo, student }: { demo: boolean; student: NavStudent }) {
  return (
    <aside className="sticky top-0 hidden h-screen w-[260px] shrink-0 flex-col lg:flex">
      <div className="flex h-[76px] items-center px-6">
        <Brand />
      </div>
      <NavLinks />
      <Footer demo={demo} student={student} />
    </aside>
  );
}

/** Brand bar with a slide-in drawer below the `lg` breakpoint. */
export function PortalMobileNav({ demo, student }: { demo: boolean; student: NavStudent }) {
  const p = useT().portal;
  const [open, setOpen] = useState(false);

  return (
    <div className="lg:hidden">
      <div className="flex h-16 items-center justify-between gap-3 border-b border-ab-rule px-4">
        <Brand />
        <div className="flex items-center gap-2">
          <LanguageSwitch />
          <button
            type="button"
            aria-label={p.openMenu}
            onClick={() => setOpen(true)}
            className="flex size-9 items-center justify-center rounded-full border border-ab-rule bg-ab-panel text-ab-ink"
          >
            <MenuIcon size={18} />
          </button>
        </div>
      </div>
      <div className={`fixed inset-0 z-50 ${open ? "" : "pointer-events-none"}`} aria-hidden={!open}>
        <button
          type="button"
          aria-label={p.closeMenu}
          tabIndex={open ? 0 : -1}
          className={`absolute inset-0 bg-ab-ink/30 transition-opacity duration-300 ${open ? "opacity-100" : "opacity-0"}`}
          onClick={() => setOpen(false)}
        />
        <aside
          className={`absolute inset-y-0 left-0 flex w-[290px] max-w-[85%] flex-col bg-ab-canvas transition-transform duration-300 ${
            open ? "translate-x-0" : "-translate-x-full"
          }`}
        >
          <div className="flex h-16 items-center justify-between px-4">
            <Brand />
            <button
              type="button"
              aria-label={p.closeMenu}
              tabIndex={open ? 0 : -1}
              onClick={() => setOpen(false)}
              className="flex size-9 items-center justify-center rounded-full text-ab-ink-2"
            >
              <CloseIcon size={18} />
            </button>
          </div>
          <NavLinks onNavigate={() => setOpen(false)} />
          <Footer demo={demo} student={student} />
        </aside>
      </div>
    </div>
  );
}
