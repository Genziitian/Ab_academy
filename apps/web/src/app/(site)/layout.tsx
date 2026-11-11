import Link from "next/link";
import { ChatIcon } from "@/components/icons";
import { MobileTabBar } from "@/components/MobileTabBar";
import { SiteFooter } from "@/components/SiteFooter";
import { SiteHeader } from "@/components/SiteHeader";
import { getT } from "@/lib/i18n/server";
import { helpHref, helpIsWhatsApp } from "@/lib/support";

export default async function SiteLayout({ children }: Readonly<{ children: React.ReactNode }>) {
  const { t } = await getT();
  return (
    <div className="ab flex min-h-full flex-1 flex-col pb-[calc(64px+env(safe-area-inset-bottom))] lg:pb-0">
      <SiteHeader />
      <main className="flex-1">{children}</main>
      <SiteFooter />
      <MobileTabBar />
      <Link
        href={helpHref}
        className="fixed bottom-6 right-6 z-40 hidden h-11 items-center gap-2 rounded-full border border-ab-rule bg-ab-panel px-4 text-sm font-medium text-ab-ink shadow-[0_12px_32px_-12px_rgba(23,21,17,0.3)] hover:border-ab-ink lg:flex"
      >
        <ChatIcon size={16} />
        {helpIsWhatsApp ? t.nav.whatsapp : t.nav.helpFloat}
      </Link>
    </div>
  );
}
