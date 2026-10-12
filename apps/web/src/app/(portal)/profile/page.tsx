import Link from "next/link";
import { PortalTopbar } from "@/components/portal/PortalTopbar";
import { Card } from "@/components/portal/ui";
import { getStudent, isPortalDemo } from "@/lib/portal/student";
import { LearningSettings } from "./LearningSettings";

export const metadata = { title: "Profile & Settings" };

export default async function ProfilePage() {
  const student = await getStudent();
  const demo = isPortalDemo();
  const contact = [
    student.phone ?? student.email,
    student.summary,
    student.medium ? `${student.medium} medium` : null,
  ]
    .filter(Boolean)
    .join(" · ");

  const academic = [
    ["Class", student.classLevel ? `Class ${student.classLevel}` : "Not set"],
    ["Board", student.board],
    ["Medium", student.medium ?? "Not set"],
    ["Stream", student.stream ?? "Not set"],
  ];

  const row =
    "flex justify-between border-b border-line px-6 py-4 text-[15px] text-navy hover:bg-surface-grey";

  return (
    <>
      <PortalTopbar title="Profile & Settings" />
      <div className="flex max-w-[960px] flex-col gap-5 px-4 pb-12 pt-7 sm:px-8">
        <Card className="flex flex-wrap items-center gap-5 p-6">
          <span className="flex size-[72px] items-center justify-center rounded-full bg-primary-soft text-2xl font-semibold text-primary">
            {student.initials}
          </span>
          <div className="min-w-0 flex-1">
            <h2 className="text-[22px] font-semibold text-navy">{student.name}</h2>
            <p className="mt-1 text-sm text-muted">{contact}</p>
          </div>
          <Link
            href="/support"
            className="flex h-10 items-center rounded-lg border border-primary-line bg-white px-4 text-sm font-semibold text-primary hover:bg-primary-soft"
          >
            Edit profile
          </Link>
        </Card>

        <Card className="overflow-hidden">
          <h3 className="border-b border-border px-6 py-[18px] text-[15px] font-semibold text-navy">
            Academic details
          </h3>
          <div className="grid sm:grid-cols-2">
            {academic.map(([label, value], index) => (
              <div
                key={label}
                className={`border-line px-6 py-4 ${index < 2 ? "border-b" : "max-sm:border-b"} ${
                  index % 2 === 0 ? "sm:border-r" : ""
                }`}
              >
                <p className="text-xs text-muted">{label}</p>
                <p className="mt-[3px] text-[15px] font-semibold text-navy">{value}</p>
              </div>
            ))}
          </div>
        </Card>

        <Card className="overflow-hidden">
          <h3 className="border-b border-border px-6 py-[18px] text-[15px] font-semibold text-navy">
            Learning
          </h3>
          <LearningSettings />
        </Card>

        <Card className="overflow-hidden">
          <h3 className="border-b border-border px-6 py-[18px] text-[15px] font-semibold text-navy">
            Account
          </h3>
          <Link href="/my-courses" className={row}>
            Purchases &amp; enrolments<span className="text-subtle">›</span>
          </Link>
          <Link href="/support" className={row}>
            Help &amp; support tickets<span className="text-subtle">›</span>
          </Link>
          <Link href="/privacy" className={row}>
            Privacy &amp; terms<span className="text-subtle">›</span>
          </Link>
          {demo ? (
            <Link href="/" className="flex px-6 py-4 text-[15px] font-semibold text-danger">
              Exit demo
            </Link>
          ) : (
            <form action="/auth/signout" method="post">
              <button type="submit" className="flex w-full px-6 py-4 text-[15px] font-semibold text-danger">
                Sign out
              </button>
            </form>
          )}
        </Card>
      </div>
    </>
  );
}
