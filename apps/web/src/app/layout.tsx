import type { Metadata } from "next";
import {
  Geist,
  Geist_Mono,
  Hanken_Grotesk,
  IBM_Plex_Mono,
  IBM_Plex_Sans,
  IBM_Plex_Sans_Devanagari,
  Instrument_Serif,
  Mukta,
} from "next/font/google";
import { LocaleProvider } from "@/lib/i18n/client";
import { getLocale } from "@/lib/i18n/server";
import "./globals.css";

// Site, sign-in, checkout and portal: Geist for Latin, Mukta for Devanagari,
// Geist Mono for numbers, dates and chapter indexes.
const geist = Geist({ variable: "--font-geist", subsets: ["latin"] });
const geistMono = Geist_Mono({ variable: "--font-geist-mono", subsets: ["latin"], weight: ["400", "500"] });
const mukta = Mukta({ variable: "--font-mukta", subsets: ["devanagari"], weight: ["400", "500", "600", "700"] });

// The admin console keeps IBM Plex and Instrument Serif.
const plex = IBM_Plex_Sans({ variable: "--font-plex", subsets: ["latin"], weight: ["400", "500", "600", "700"] });
const plexDevanagari = IBM_Plex_Sans_Devanagari({
  variable: "--font-plex-devanagari",
  subsets: ["devanagari"],
  weight: ["400", "500", "600"],
});
const plexMono = IBM_Plex_Mono({ variable: "--font-plex-mono", subsets: ["latin"], weight: ["500"] });
const instrument = Instrument_Serif({
  variable: "--font-instrument",
  subsets: ["latin"],
  weight: "400",
  style: ["normal", "italic"],
});
const hanken = Hanken_Grotesk({ variable: "--font-hanken", subsets: ["latin"], weight: ["400", "500", "600", "700"] });

export const metadata: Metadata = {
  title: {
    default: "AB Academy | Class 12 Crash Course for Bihar Board",
    template: "%s | AB Academy",
  },
  description:
    "Class 12 crash courses for Bihar Board — recorded classes, live doubt sessions with Ajit Sir, chapter notes and board-pattern questions in Hindi & Hinglish.",
};

// The single root layout. Each route group — (site), (portal), (focus) and
// (admin) — adds its own chrome. The language comes from the `ab_lang` cookie.
export default async function RootLayout({ children }: Readonly<{ children: React.ReactNode }>) {
  const locale = await getLocale();
  const fonts = [geist, geistMono, mukta, plex, plexDevanagari, plexMono, instrument, hanken]
    .map((f) => f.variable)
    .join(" ");

  return (
    <html lang={locale} className={`${fonts} h-full antialiased`}>
      <body className="flex min-h-full flex-col font-sans">
        <LocaleProvider locale={locale}>{children}</LocaleProvider>
      </body>
    </html>
  );
}
