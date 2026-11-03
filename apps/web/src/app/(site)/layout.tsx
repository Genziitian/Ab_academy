import Link from "next/link";
import { ChatIcon } from "@/components/icons";
import { MobileTabBar } from "@/components/MobileTabBar";
import { SiteFooter } from "@/components/SiteFooter";
import { SiteHeader } from "@/components/SiteHeader";
import { helpHref, helpIsWhatsApp } from "@/lib/support";

export default function SiteLayout({
  children,
}: Readonly<{ children: React.ReactNode }>) {
  return (
    <div className="theme-saffron flex min-h-full flex-1 flex-col pb-[calc(64px+env(safe-area-inset-bottom))] lg:pb-0">
      <SiteHeader />
      <main className="flex-1">{children}</main>
      <SiteFooter />
      <MobileTabBar />
      <Link
        href={helpHref}
        className="fixed bottom-6 right-6 z-40 hidden h-12 items-center gap-2 rounded-full bg-coal px-5 text-[15px] font-semibold text-cream shadow-[var(--shadow-float)] hover:bg-clay lg:flex"
      >
        <ChatIcon size={18} />
        {helpIsWhatsApp ? "Chat on WhatsApp" : "Need help?"}
      </Link>
    </div>
  );
}
