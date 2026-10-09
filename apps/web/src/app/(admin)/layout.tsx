import type { Metadata } from "next";
import { Outfit } from "next/font/google";
import "../globals.css";

const outfit = Outfit({ variable: "--font-outfit", subsets: ["latin"] });

export const metadata: Metadata = {
  title: "Admin · Akhand Bharat Academy",
  description: "Manage courses, schedules, notifications, communities and support tickets.",
  robots: { index: false, follow: false },
};

// A second root layout: the admin console deliberately does not inherit the
// marketing header, footer and mobile CTA bar from the (site) group.
export default function AdminRootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en" className={`${outfit.variable} h-full antialiased`}>
      <body className="min-h-full bg-surface-soft font-sans">{children}</body>
    </html>
  );
}
