import type { Metadata } from "next";
import { PortalMobileNav, PortalSidebar } from "@/components/portal/PortalNav";
import { unreadCount } from "@/lib/portal/data";
import { getStudent, isPortalDemo } from "@/lib/portal/student";

export const metadata: Metadata = {
  title: { default: "Student portal", template: "%s · Student portal" },
  robots: { index: false, follow: false },
};

export default async function PortalLayout({ children }: { children: React.ReactNode }) {
  // Resolves the session up front so an expired one redirects before render.
  await getStudent();
  const demo = isPortalDemo();

  return (
    <div className="flex min-h-screen flex-1 bg-[#fafbfd]">
      <PortalSidebar unread={unreadCount} demo={demo} />
      <div className="flex min-w-0 flex-1 flex-col">
        <PortalMobileNav unread={unreadCount} demo={demo} />
        <p className="border-b border-[#f6e3c4] bg-[#fff8ec] px-4 py-2 text-xs text-[#8a6a3e] sm:px-8">
          <strong className="font-semibold text-navy">Sample data.</strong> The
          portal layout is live; courses, schedule and notes shown here are
          placeholders until they are connected to your enrolments.
        </p>
        {children}
      </div>
    </div>
  );
}
