import type { Metadata } from "next";
import {
  Hanken_Grotesk,
  IBM_Plex_Mono,
  IBM_Plex_Sans,
  IBM_Plex_Sans_Devanagari,
  Instrument_Serif,
} from "next/font/google";
import "./globals.css";

const plex = IBM_Plex_Sans({
  variable: "--font-plex",
  subsets: ["latin"],
  weight: ["400", "500", "600", "700"],
});

const plexDevanagari = IBM_Plex_Sans_Devanagari({
  variable: "--font-plex-devanagari",
  subsets: ["devanagari"],
  weight: ["400", "500", "600"],
});

const plexMono = IBM_Plex_Mono({
  variable: "--font-plex-mono",
  subsets: ["latin"],
  weight: ["500"],
});

// The public site's "Saffron & Ink" look: a serif for headlines, a grotesk for
// everything else. The portal and admin keep IBM Plex.
const instrument = Instrument_Serif({
  variable: "--font-instrument",
  subsets: ["latin"],
  weight: "400",
  style: ["normal", "italic"],
});

const hanken = Hanken_Grotesk({
  variable: "--font-hanken",
  subsets: ["latin"],
  weight: ["400", "500", "600", "700"],
});

export const metadata: Metadata = {
  title: {
    default: "AB Academy | Class 12 Crash Course for Bihar Board",
    template: "%s | AB Academy",
  },
  description:
    "Class 12 crash courses for Bihar Board — recorded classes, live doubt sessions with Ajit Sir, chapter notes and board-pattern tests in Hindi & English.",
};

// The single root layout. Each route group — (site), (portal), (focus) and
// (admin) — adds its own chrome on top, so moving between them is a client
// navigation rather than a full page reload.
export default function RootLayout({
  children,
}: Readonly<{ children: React.ReactNode }>) {
  return (
    <html
      lang="en"
      className={`${plex.variable} ${plexDevanagari.variable} ${plexMono.variable} ${instrument.variable} ${hanken.variable} h-full antialiased`}
    >
      <body className="flex min-h-full flex-col font-sans">{children}</body>
    </html>
  );
}
