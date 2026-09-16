import { ButtonLink } from "@/components/ButtonLink";
import Link from "next/link";

export const metadata = {
  title: "Login",
  description: "Student login for Akhand Bharat Academy.",
};

export default function LoginPage() {
  return (
    <div className="mx-auto flex min-h-[70vh] max-w-md flex-col justify-center px-4 py-14 sm:px-6">
      <div className="rounded-2xl border border-border bg-surface p-6 shadow-[var(--shadow-soft)] sm:p-8">
        <p className="text-sm font-semibold uppercase tracking-[0.14em] text-primary">
          Student access
        </p>
        <h1 className="mt-3 font-display text-3xl font-semibold tracking-tight">
          Login with mobile OTP
        </h1>
        <p className="mt-3 text-sm text-muted">
          OTP authentication will connect to Supabase Auth in the next build
          slice. This screen is the UI shell.
        </p>

        <label className="mt-8 block text-sm font-medium">
          Mobile number
          <div className="mt-2 flex overflow-hidden rounded-xl border border-border">
            <span className="bg-background px-3 py-2.5 text-sm text-muted">
              +91
            </span>
            <input
              type="tel"
              inputMode="numeric"
              placeholder="98765 43210"
              className="w-full bg-surface px-3 py-2.5 outline-none"
            />
          </div>
        </label>

        <div className="mt-6">
          <ButtonLink href="/courses" className="w-full">
            Send OTP
          </ButtonLink>
        </div>

        <p className="mt-6 text-center text-sm text-muted">
          New here?{" "}
          <Link href="/courses" className="font-semibold text-primary">
            Explore courses
          </Link>
        </p>
      </div>
    </div>
  );
}
