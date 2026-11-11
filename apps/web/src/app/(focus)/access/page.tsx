import Link from "next/link";
import { BrandMark, Wordmark } from "@/components/icons";
import { isDemoMode } from "@/lib/admin/auth";
import { safeNext } from "@/lib/safe-next";
import { AccessForm } from "./AccessForm";

// Not linked from anywhere, and kept out of search results.
export const metadata = {
  title: "Staff access",
  robots: { index: false, follow: false },
};

export default async function AccessPage({
  searchParams,
}: {
  searchParams: Promise<{ next?: string; error?: string }>;
}) {
  const { next, error } = await searchParams;
  const clean = safeNext(next, "/admin");
  const safe = clean === "/admin" || clean.startsWith("/admin/") ? clean : "/admin";

  return (
    <div className="ab flex min-h-screen flex-1 items-center justify-center px-6 py-10">
      <div className="w-full max-w-[400px]">
        <Link href="/" className="mb-10 flex items-center gap-3">
          <BrandMark />
          <Wordmark />
        </Link>
        {error === "not-staff" ? (
          <p role="alert" className="mb-6 rounded-lg bg-danger-soft px-3 py-2.5 text-sm text-danger">
            That account does not have staff access.
          </p>
        ) : null}
        <AccessForm next={safe} demo={isDemoMode()} />
      </div>
    </div>
  );
}
