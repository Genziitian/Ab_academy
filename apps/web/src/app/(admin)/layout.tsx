import type { Metadata } from "next";

export const metadata: Metadata = {
  title: "Admin · Akhand Bharat Academy",
  description: "Manage courses, schedules, doubts, notifications and support tickets.",
  robots: { index: false, follow: false },
};

// The admin console deliberately does not inherit the marketing header and
// footer from the (site) group.
export default function AdminGroupLayout({ children }: { children: React.ReactNode }) {
  return <div className="min-h-full flex-1 bg-surface-soft">{children}</div>;
}
