import Image from "next/image";
import Link from "next/link";
import { BrandMark } from "@/components/icons";
import { isDemoMode } from "@/lib/admin/auth";
import { LoginForm } from "./LoginForm";

export const metadata = {
  title: "Log in",
  description: "Student and staff sign-in for Akhand Bharat Academy.",
};

export default async function LoginPage({
  searchParams,
}: {
  searchParams: Promise<{ next?: string; error?: string }>;
}) {
  const { next, error } = await searchParams;
  const demo = isDemoMode();
  // A `next` inside the console means a staff member was bounced here.
  const staff = next?.startsWith("/admin") ?? false;

  return (
    <div className="grid min-h-screen flex-1 lg:grid-cols-2">
      <div className="flex flex-col bg-navy px-6 py-8 text-white sm:px-14 sm:py-10">
        <Link href="/" className="flex items-center gap-2.5 text-white">
          <BrandMark />
          <span className="text-base font-bold">Akhand Bharat Academy</span>
        </Link>
        <div className="mt-auto hidden pt-12 lg:block">
          <p className="font-hindi text-base text-[#9fb8ff]">
            आज शुरू करें — कल का आत्मविश्वास बनाएँ।
          </p>
          <h1 className="mt-3.5 max-w-[460px] text-[40px] font-bold leading-[1.15] tracking-[-0.02em]">
            Class 11 &amp; 12 crash courses — live, recorded and notes.
          </h1>
          <div className="mt-8 aspect-[16/10] max-w-[520px] overflow-hidden rounded-xl bg-[#1c2c5c]">
            <Image
              src="/images/feature-live-class.png"
              alt="Live class"
              width={1040}
              height={650}
              className="size-full object-cover"
            />
          </div>
        </div>
        <p className="mt-10 hidden text-[13px] text-[#8592ad] lg:block">
          © {new Date().getFullYear()} Akhand Bharat Academy
        </p>
      </div>

      <div className="flex items-center justify-center px-6 py-10 sm:p-10">
        <div className="w-full max-w-[400px]">
          {error ? (
            <p
              role="alert"
              className="mb-6 rounded-lg bg-danger-soft px-3 py-2.5 text-sm text-danger"
            >
              {error === "not-staff"
                ? "That account is not a staff account."
                : decodeURIComponent(error)}
            </p>
          ) : null}
          <LoginForm
            studentNext={!staff && next ? next : "/dashboard"}
            staffNext={staff && next ? next : "/admin"}
            demo={demo}
            initialTab={staff ? "staff" : "student"}
          />
        </div>
      </div>
    </div>
  );
}
