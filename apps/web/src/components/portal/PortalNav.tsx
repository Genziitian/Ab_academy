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

const LINKS = [
  { href: "/dashboard", label: "Home", Icon: DashboardIcon },
  { href: "/my-courses", label: "My courses", Icon: BookIcon, also: ["/lecture"] },
  { href: "/live", label: "Live classes", Icon: LiveIcon },
  { href: "/materials", label: "Notes", Icon: NotesIcon },
  { href: "/support", label: "Help & support", Icon: HelpIcon },
  { href: "/profile", label: "Profile", Icon: UserIcon },
];

function NavLinks({ onNavigate }: { onNavigate?: () => void }) {
  const pathname = usePathname();
  const active = (href: string, also: string[] = []) =>
    [href, ...also].some((p) => pathname === p || pathname.startsWith(`${p}/`));

  return (
    <nav className="flex flex-1 flex-col gap-1 overflow-y-auto px-3 py-5">
      {LINKS.map((link) => {
        const on = active(link.href, link.also);
        return (
          <Link
            key={link.href}
            href={link.href}
            onClick={onNavigate}
            aria-current={on ? "page" : undefined}
            className={`flex h-11 items-center gap-3 rounded-xl px-3 text-[15px] transition-colors ${
              on ? "bg-coal font-semibold text-cream" : "font-medium text-coal hover:bg-paper"
            }`}
          >
            <link.Icon />
            {link.label}
          </Link>
        );
      })}
    </nav>
  );
}

function Footer({ demo }: { demo: boolean }) {
  const cls = "flex h-11 w-full items-center gap-3 rounded-xl px-3 text-[15px] font-medium text-taupe hover:bg-paper hover:text-coal";
  return (
    <div className="flex flex-col gap-2 border-t border-sand p-3">
      <Link
        href="/#courses"
        className="flex h-11 items-center justify-center rounded-full bg-saffron text-sm font-bold text-coal hover:bg-coal hover:text-cream"
      >
        Explore courses
      </Link>
      {demo ? (
        <Link href="/" className={cls}>
          <SignOutIcon size={18} />
          Exit preview
        </Link>
      ) : (
        <form action="/auth/signout" method="post">
          <button type="submit" className={cls}>
            <SignOutIcon size={18} />
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
      <BrandMark size={36} />
      <Wordmark size="sm" />
    </Link>
  );
}

/** Left rail on large screens. */
export function PortalSidebar({ demo }: { demo: boolean }) {
  return (
    <aside className="sticky top-0 hidden h-screen w-[248px] shrink-0 flex-col border-r border-sand bg-cream lg:flex">
      <div className="flex h-[72px] items-center border-b border-sand px-5">
        <Brand />
      </div>
      <NavLinks />
      <Footer demo={demo} />
    </aside>
  );
}

/** Brand bar with a slide-in drawer below the `lg` breakpoint. */
export function PortalMobileNav({ demo }: { demo: boolean }) {
  const [open, setOpen] = useState(false);
  return (
    <div className="lg:hidden">
      <div className="flex h-16 items-center justify-between border-b border-sand bg-cream px-4">
        <Brand />
        <button
          type="button"
          aria-label="Open menu"
          onClick={() => setOpen(true)}
          className="flex size-10 items-center justify-center rounded-full border border-sand text-coal"
        >
          <MenuIcon size={20} />
        </button>
      </div>
      <div className={`fixed inset-0 z-50 ${open ? "" : "pointer-events-none"}`} aria-hidden={!open}>
        <button
          type="button"
          aria-label="Close menu"
          tabIndex={open ? 0 : -1}
          className={`absolute inset-0 bg-coal/40 transition-opacity duration-300 ${open ? "opacity-100" : "opacity-0"}`}
          onClick={() => setOpen(false)}
        />
        <aside
          className={`absolute inset-y-0 left-0 flex w-[280px] max-w-[85%] flex-col bg-cream transition-transform duration-300 ${
            open ? "translate-x-0" : "-translate-x-full"
          }`}
        >
          <div className="flex h-16 items-center justify-between border-b border-sand px-4">
            <Brand />
            <button
              type="button"
              aria-label="Close menu"
              onClick={() => setOpen(false)}
              className="flex size-9 items-center justify-center rounded-full text-taupe"
            >
              <CloseIcon size={18} />
            </button>
          </div>
          <NavLinks onNavigate={() => setOpen(false)} />
          <Footer demo={demo} />
        </aside>
      </div>
    </div>
  );
}
