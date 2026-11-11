import type { Metadata } from "next";
import { PortalMobileNav, PortalSidebar } from "@/components/portal/PortalNav";
import { getT } from "@/lib/i18n/server";
import { getStudent, isPortalDemo } from "@/lib/portal/student";

export const metadata: Metadata = {
  title: { default: "My learning", template: "%s · AB Academy" },
  robots: { index: false, follow: false },
};

export default async function PortalLayout({ children }: { children: React.ReactNode }) {
  // Resolves the session up front so an expired one redirects before render.
  const [student, { t }] = await Promise.all([getStudent(), getT()]);
  const demo = isPortalDemo();
  const nav = {
    name: student.name,
    initials: student.initials,
    summary: [student.classLevel ? t.common.classN(student.classLevel) : null, t.common.board].filter(Boolean).join(" · "),
  };

  return (
    <div className="ab flex min-h-screen flex-1">
      <PortalSidebar demo={demo} student={nav} />
      <div className="flex min-w-0 flex-1 flex-col lg:py-3 lg:pr-3">
        <PortalMobileNav demo={demo} student={nav} />
        <main className="flex-1 bg-ab-panel lg:rounded-[24px] lg:border lg:border-ab-rule">{children}</main>
      </div>
    </div>
  );
}
