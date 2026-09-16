"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";

export function MobileExploreBar() {
  const pathname = usePathname();
  if (pathname.startsWith("/login") || pathname.startsWith("/course/")) {
    return null;
  }

  return (
    <div className="fixed inset-x-0 bottom-0 z-40 border-t border-border/80 bg-white/95 p-3 pb-[max(0.75rem,env(safe-area-inset-bottom))] backdrop-blur-md md:hidden">
      <Link
        href="/courses"
        className="flex h-12 w-full items-center justify-center rounded-full bg-primary text-sm font-semibold text-white shadow-[0_12px_28px_rgba(41,98,255,0.35)]"
      >
        Explore Courses
      </Link>
    </div>
  );
}
