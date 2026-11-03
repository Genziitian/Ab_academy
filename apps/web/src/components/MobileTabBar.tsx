"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import { BookIcon, ChatIcon, HomeIcon, NotesIcon, UserIcon } from "@/components/icons";
import { helpHref } from "@/lib/support";

const tabs = [
  { href: "/", label: "Home", Icon: HomeIcon, match: (p: string) => p === "/" },
  {
    href: "/courses",
    label: "Courses",
    Icon: BookIcon,
    match: (p: string) => p.startsWith("/courses") || p.startsWith("/course/"),
  },
  { href: "/notes", label: "Notes", Icon: NotesIcon, match: (p: string) => p.startsWith("/notes") },
  { href: helpHref, label: "Help", Icon: ChatIcon, match: (p: string) => p.startsWith("/contact") },
  { href: "/login", label: "Log in", Icon: UserIcon, match: (p: string) => p.startsWith("/login") },
];

/** The app's bottom tabs, on the website below laptop width. */
export function MobileTabBar() {
  const pathname = usePathname();
  return (
    <nav
      aria-label="Main"
      className="fixed inset-x-0 bottom-0 z-50 grid grid-cols-5 border-t border-border bg-white/95 pb-[env(safe-area-inset-bottom)] backdrop-blur-md lg:hidden"
    >
      {tabs.map(({ href, label, Icon, match }) => {
        const on = match(pathname);
        return (
          <Link
            key={label}
            href={href}
            aria-current={on ? "page" : undefined}
            className={`flex h-16 flex-col items-center justify-center gap-1 text-[11px] font-semibold ${
              on ? "text-primary" : "text-muted"
            }`}
          >
            <Icon size={22} />
            {label}
          </Link>
        );
      })}
    </nav>
  );
}
