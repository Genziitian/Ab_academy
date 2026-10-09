import Link from "next/link";
import { isDemoMode } from "@/lib/admin/auth";
import { LoginForm } from "./LoginForm";

export const metadata = {
  title: "Login",
  description: "Staff and student sign-in for Akhand Bharat Academy.",
};

export default async function LoginPage({
  searchParams,
}: {
  searchParams: Promise<{ next?: string; error?: string }>;
}) {
  const { next, error } = await searchParams;
  const demo = isDemoMode();

  return (
    <div className="mx-auto flex min-h-[70vh] max-w-md flex-col justify-center px-4 py-14 sm:px-6">
      <div className="rounded-2xl border border-border bg-surface p-6 shadow-[var(--shadow-soft)] sm:p-8">
        <p className="text-sm font-semibold uppercase tracking-[0.14em] text-primary">
          Akhand Bharat Academy
        </p>
        <h1 className="mt-3 font-display text-3xl font-semibold tracking-tight">
          Sign in
        </h1>
        <p className="mt-3 text-sm text-muted">
          Staff sign in here to reach the admin console. Students sign in from
          the mobile app with their mobile number.
        </p>

        {error ? (
          <p
            role="alert"
            className="mt-6 rounded-xl bg-pink/10 px-3 py-2.5 text-sm text-pink"
          >
            {decodeURIComponent(error)}
          </p>
        ) : null}

        <LoginForm next={next || "/admin"} demo={demo} />

        <p className="mt-6 text-center text-sm text-muted">
          Looking for courses?{" "}
          <Link href="/courses" className="font-semibold text-primary">
            Browse the catalog
          </Link>
        </p>
      </div>
    </div>
  );
}
