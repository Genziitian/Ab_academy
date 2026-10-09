import type { Metadata } from "next";
import { Noto_Sans_Devanagari, Outfit } from "next/font/google";
import { MobileExploreBar } from "@/components/MobileExploreBar";
import { SiteFooter } from "@/components/SiteFooter";
import { SiteHeader } from "@/components/SiteHeader";
import "../globals.css";

const outfit = Outfit({
  variable: "--font-outfit",
  subsets: ["latin"],
});

const notoDevanagari = Noto_Sans_Devanagari({
  variable: "--font-noto-devanagari",
  subsets: ["devanagari"],
  weight: ["400", "500", "600", "700"],
});

export const metadata: Metadata = {
  title: {
    default: "Akhand Bharat Academy | Learn with clarity",
    template: "%s | Akhand Bharat Academy",
  },
  description:
    "Akhand Bharat Academy — live classes, recordings and notes. Starting with Bihar Board Classes 9–12, expanding to more domains soon.",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html
      lang="en"
      className={`${outfit.variable} ${notoDevanagari.variable} h-full antialiased`}
    >
      <body className="flex min-h-full flex-col font-sans">
        <SiteHeader />
        <main className="flex-1 pb-20 md:pb-0">{children}</main>
        <SiteFooter />
        <MobileExploreBar />
      </body>
    </html>
  );
}
