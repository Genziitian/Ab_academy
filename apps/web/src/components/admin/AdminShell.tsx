"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import { useEffect, useState, useSyncExternalStore } from "react";
import { BrandMark, Wordmark } from "@/components/icons";
import {
  IconBell,
  IconBook,
  IconChat,
  IconChevronsLeft,
  IconExternal,
  IconGrid,
  IconImages,
  IconLifebuoy,
  IconLogOut,
  IconMegaphone,
  IconMenu,
  IconNotes,
  IconRupee,
  IconUsers,
  IconUserX,
  IconVideo,
  IconX,
} from "./AdminIcons";

type Item = { href: string; label: string; Icon: (p: { size?: number }) => React.ReactElement };

const GROUPS: { title: string; items: Item[]; superOnly?: boolean }[] = [
  { title: "Overview", items: [{ href: "/admin", label: "Dashboard", Icon: IconGrid }] },
  {
    title: "Teaching",
    items: [
      { href: "/admin/courses", label: "Courses", Icon: IconBook },
      { href: "/admin/notes", label: "Free notes", Icon: IconNotes },
      { href: "/admin/schedule", label: "Live classes", Icon: IconVideo },
      { href: "/admin/doubts", label: "Doubts", Icon: IconChat },
    ],
  },
  {
    title: "Students",
    items: [
      { href: "/admin/students", label: "Students", Icon: IconUsers },
      { href: "/admin/tickets", label: "Support tickets", Icon: IconLifebuoy },
    ],
  },
  {
    title: "Engage",
    items: [
      { href: "/admin/notifications", label: "Notifications", Icon: IconBell },
      { href: "/admin/popups", label: "Pop-ups", Icon: IconMegaphone },
      { href: "/admin/banners", label: "App slider", Icon: IconImages },
    ],
  },
  {
    title: "Super admin",
    superOnly: true,
    items: [
      { href: "/admin/transactions", label: "Transactions", Icon: IconRupee },
      { href: "/admin/deletions", label: "Deletion requests", Icon: IconUserX },
    ],
  },
];

const KEY = "ab-admin-sidebar";

// The collapsed state lives in localStorage; read it without a render loop.
function subscribe(cb: () => void) {
  window.addEventListener("storage", cb);
  window.addEventListener("ab-sidebar", cb);
  return () => {
    window.removeEventListener("storage", cb);
    window.removeEventListener("ab-sidebar", cb);
  };
}
function readCollapsed() {
  try {
    return window.localStorage.getItem(KEY) === "collapsed";
  } catch {
    return false;
  }
}
function writeCollapsed(value: boolean) {
  try {
    window.localStorage.setItem(KEY, value ? "collapsed" : "open");
  } catch {
    /* private mode: the toggle still works for this page */
  }
  window.dispatchEvent(new Event("ab-sidebar"));
}

function NavList({
  role,
  collapsed,
  onNavigate,
}: {
  role: string;
  collapsed: boolean;
  onNavigate?: () => void;
}) {
  const pathname = usePathname();
  return (
    <nav className="flex flex-1 flex-col gap-3.5 overflow-y-auto overflow-x-hidden px-3 py-3">
      {GROUPS.filter((g) => !g.superOnly || role === "super_admin").map((group) => (
        <div key={group.title}>
          <p
            className={`mb-1.5 px-3 text-[11px] font-bold uppercase tracking-[0.14em] text-[#9a8f82] transition-opacity duration-200 ${
              collapsed ? "opacity-0" : "opacity-100"
            }`}
          >
            {group.title}
          </p>
          <div className="flex flex-col gap-1">
            {group.items.map(({ href, label, Icon }) => {
              const active = href === "/admin" ? pathname === "/admin" : pathname.startsWith(href);
              return (
                <Link
                  key={href}
                  href={href}
                  onClick={onNavigate}
                  title={collapsed ? label : undefined}
                  aria-current={active ? "page" : undefined}
                  className={`group flex h-10 items-center gap-3 rounded-xl px-3 text-[15px] font-medium transition-colors ${
                    active ? "bg-saffron text-coal" : "text-[#d9d1c4] hover:bg-white/8 hover:text-cream"
                  }`}
                >
                  <span className="flex size-5 shrink-0 items-center justify-center">
                    <Icon size={20} />
                  </span>
                  <span
                    className={`whitespace-nowrap transition-opacity duration-200 ${collapsed ? "opacity-0" : "opacity-100"}`}
                  >
                    {label}
                  </span>
                </Link>
              );
            })}
          </div>
        </div>
      ))}
    </nav>
  );
}

function SignOut({ collapsed, demo }: { collapsed: boolean; demo: boolean }) {
  const cls =
    "flex h-11 w-full items-center gap-3 rounded-xl px-3 text-[15px] font-medium text-[#f0a48a] transition-colors hover:bg-white/8";
  const body = (
    <>
      <span className="flex size-5 shrink-0 items-center justify-center">
        <IconLogOut size={20} />
      </span>
      <span className={`whitespace-nowrap transition-opacity duration-200 ${collapsed ? "opacity-0" : ""}`}>
        {demo ? "Exit demo" : "Sign out"}
      </span>
    </>
  );
  return demo ? (
    <Link href="/" className={cls} title={collapsed ? "Exit demo" : undefined}>
      {body}
    </Link>
  ) : (
    <form action="/auth/signout" method="post">
      <button type="submit" className={cls} title={collapsed ? "Sign out" : undefined}>
        {body}
      </button>
    </form>
  );
}

function Brand({ collapsed }: { collapsed: boolean }) {
  return (
    <Link href="/admin" className="flex h-[72px] shrink-0 items-center gap-3 px-[18px]">
      <BrandMark size={40} />
      <span className={`whitespace-nowrap transition-opacity duration-200 ${collapsed ? "opacity-0" : ""}`}>
        <Wordmark size="sm" tone="light" />
        <span className="mt-1.5 block text-[10px] font-bold uppercase tracking-[0.16em] text-[#9a8f82]">Admin console</span>
      </span>
    </Link>
  );
}

/**
 * The console frame: a coal sidebar that collapses to an icon rail on
 * desktop (remembered per browser) and slides in as a drawer on phones.
 * Only width and opacity animate, so it stays smooth on slow machines.
 */
export function AdminShell({
  role,
  name,
  demo,
  children,
}: {
  role: string;
  name: string;
  demo: boolean;
  children: React.ReactNode;
}) {
  const collapsed = useSyncExternalStore(subscribe, readCollapsed, () => false);
  const [drawer, setDrawer] = useState(false);
  const pathname = usePathname();

  // Close the phone drawer with Escape.
  useEffect(() => {
    if (!drawer) return;
    const onKey = (e: KeyboardEvent) => e.key === "Escape" && setDrawer(false);
    window.addEventListener("keydown", onKey);
    return () => window.removeEventListener("keydown", onKey);
  }, [drawer]);

  const initials = name
    .split(" ")
    .map((p) => p[0])
    .join("")
    .slice(0, 2)
    .toUpperCase();

  return (
    <div className="theme-saffron flex min-h-screen bg-paper">
      {/* Desktop sidebar */}
      <aside
        className={`sticky top-0 hidden h-screen shrink-0 flex-col bg-coal transition-[width] duration-300 ease-out lg:flex ${
          collapsed ? "w-[76px]" : "w-[264px]"
        }`}
      >
        <Brand collapsed={collapsed} />
        <NavList role={role} collapsed={collapsed} />
        <div className="flex flex-col gap-1 border-t border-white/10 p-3">
          <SignOut collapsed={collapsed} demo={demo} />
          <button
            type="button"
            onClick={() => writeCollapsed(!collapsed)}
            aria-label={collapsed ? "Expand sidebar" : "Collapse sidebar"}
            className="flex h-11 items-center gap-3 rounded-xl px-3 text-[15px] font-medium text-[#9a8f82] hover:bg-white/8 hover:text-cream"
          >
            <span className={`flex size-5 shrink-0 items-center justify-center transition-transform duration-300 ${collapsed ? "rotate-180" : ""}`}>
              <IconChevronsLeft size={20} />
            </span>
            <span className={`whitespace-nowrap transition-opacity duration-200 ${collapsed ? "opacity-0" : ""}`}>
              Collapse
            </span>
          </button>
        </div>
      </aside>

      {/* Phone drawer */}
      <div
        className={`fixed inset-0 z-50 lg:hidden ${drawer ? "" : "pointer-events-none"}`}
        aria-hidden={!drawer}
      >
        <button
          type="button"
          aria-label="Close menu"
          tabIndex={drawer ? 0 : -1}
          onClick={() => setDrawer(false)}
          className={`absolute inset-0 bg-coal/50 transition-opacity duration-300 ${drawer ? "opacity-100" : "opacity-0"}`}
        />
        <aside
          className={`absolute inset-y-0 left-0 flex w-[280px] flex-col bg-coal transition-transform duration-300 ease-out ${
            drawer ? "translate-x-0" : "-translate-x-full"
          }`}
        >
          <div className="flex items-center justify-between pr-3">
            <Brand collapsed={false} />
            <button
              type="button"
              onClick={() => setDrawer(false)}
              aria-label="Close menu"
              className="flex size-10 items-center justify-center rounded-full text-cream hover:bg-white/10"
            >
              <IconX />
            </button>
          </div>
          <NavList key={pathname} role={role} collapsed={false} onNavigate={() => setDrawer(false)} />
          <div className="border-t border-white/10 p-3">
            <SignOut collapsed={false} demo={demo} />
          </div>
        </aside>
      </div>

      <div className="flex min-w-0 flex-1 flex-col">
        {demo ? (
          <p className="border-b border-saffron/40 bg-saffron/15 px-6 py-2.5 text-xs text-coal">
            <strong className="font-semibold">Demo data.</strong> No Supabase project is connected, so changes reset
            when the server restarts.
          </p>
        ) : null}
        <header className="sticky top-0 z-30 flex h-16 items-center gap-3 border-b border-sand bg-cream px-4 sm:px-8">
          <button
            type="button"
            onClick={() => setDrawer(true)}
            aria-label="Open menu"
            className="flex size-10 items-center justify-center rounded-full border border-sand text-coal lg:hidden"
          >
            <IconMenu />
          </button>
          <Wordmark size="sm" className="lg:hidden" />
          <div className="ml-auto flex items-center gap-3">
            <Link
              href="/"
              target="_blank"
              className="hidden h-10 items-center gap-2 rounded-full border border-sand px-4 text-sm font-semibold text-coal hover:border-clay hover:text-clay md:inline-flex"
            >
              <IconExternal size={16} />
              View website
            </Link>
            <div className="hidden text-right sm:block">
              <p className="text-sm font-semibold text-coal">{name}</p>
              <p className="text-xs capitalize text-taupe">{role.replace("_", " ")}</p>
            </div>
            <span className="flex size-10 items-center justify-center rounded-full bg-clay text-sm font-bold text-white">
              {initials}
            </span>
          </div>
        </header>
        <main className="min-w-0 flex-1 px-4 py-6 sm:px-8 sm:py-8">{children}</main>
      </div>
    </div>
  );
}
