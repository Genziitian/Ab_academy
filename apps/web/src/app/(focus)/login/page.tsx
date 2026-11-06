import Image from "next/image";
import Link from "next/link";
import { BrandMark, Wordmark } from "@/components/icons";
import { isDemoMode } from "@/lib/admin/auth";
import { LoginForm } from "./LoginForm";

export const metadata = {
  title: "Log in",
  description: "Student sign-in for AB Academy.",
};

export default async function LoginPage({
  searchParams,
}: {
  searchParams: Promise<{ next?: string; error?: string }>;
}) {
  const { next, error } = await searchParams;
  const demo = isDemoMode();
  // The console has its own sign-in at /access.
  const studentNext = next && !next.startsWith("/admin") ? next : "/dashboard";

  return (
    <div className="theme-saffron grid min-h-screen flex-1 lg:grid-cols-2">
      <div className="flex flex-col bg-coal px-6 py-8 text-cream sm:px-14 sm:py-10">
        <Link href="/" className="flex items-center gap-3 text-cream">
          <BrandMark />
          <Wordmark tone="light" />
        </Link>
        <div className="mt-auto hidden pt-12 lg:block">
          <p className="font-hindi text-base text-saffron">
            आज शुरू करें — कल का आत्मविश्वास बनाएँ।
          </p>
          <h1 className="mt-3.5 max-w-[460px] font-serif text-[56px] leading-[0.98] tracking-[-0.02em]">
            The <em className="text-saffron">last 90 days</em> before your boards.
          </h1>
          <div className="mt-8 aspect-[16/10] max-w-[520px] overflow-hidden rounded-3xl bg-coal-soft">
            <Image
              src="/images/feature-live-class.png"
              alt="A recorded lecture"
              width={1040}
              height={650}
              className="size-full object-cover"
            />
          </div>
        </div>
        <p className="mt-10 hidden text-[13px] text-dust lg:block">
          © {new Date().getFullYear()} AB Academy
        </p>
      </div>

      <div className="flex items-center justify-center px-6 py-10 sm:p-10">
        <div className="w-full max-w-[400px]">
          {error ? (
            <p
              role="alert"
              className="mb-6 rounded-lg bg-danger-soft px-3 py-2.5 text-sm text-danger"
            >
              {decodeURIComponent(error)}
            </p>
          ) : null}
          <LoginForm next={studentNext} demo={demo} />
        </div>
      </div>
    </div>
  );
}
