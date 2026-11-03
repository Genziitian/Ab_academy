import type { Metadata } from "next";
import { PortalMobileNav, PortalSidebar } from "@/components/portal/PortalNav";
import { getStudent, isPortalDemo } from "@/lib/portal/student";

export const metadata: Metadata = {
  title: { default: "My learning", template: "%s · AB Academy" },
  robots: { index: false, follow: false },
};

export default async function PortalLayout({ children }: { children: React.ReactNode }) {
  // Resolves the session up front so an expired one redirects before render.
  await getStudent();
  const demo = isPortalDemo();

  return (
    <div className="theme-saffron flex min-h-screen flex-1 bg-paper">
      <PortalSidebar demo={demo} />
      <div className="flex min-w-0 flex-1 flex-col">
        <PortalMobileNav demo={demo} />
        {children}
      </div>
    </div>
  );
}
