import Link from "next/link";
import { BrandMark, Wordmark } from "@/components/icons";
import { LanguageSwitch } from "@/components/LanguageSwitch";
import { PlanRegister } from "@/components/plan/PlanRegister";
import { Check } from "@/components/ui";
import { isDemoMode } from "@/lib/admin/auth";
import { getT } from "@/lib/i18n/server";
import { BATCH_START, EXAM_DATE } from "@/lib/landing";
import { requestNow } from "@/lib/now";
import { safeNext } from "@/lib/safe-next";
import { LoginForm } from "./LoginForm";

export const metadata = {
  title: "Log in",
  description: "Student sign-in for AB Academy.",
};

export default async function LoginPage({ searchParams }: { searchParams: Promise<{ next?: string; error?: string }> }) {
  const [{ next, error }, { t, locale }] = await Promise.all([searchParams, getT()]);
  const demo = isDemoMode();
  // The console has its own sign-in at /access.
  const cleanNext = safeNext(next, "/dashboard");
  const studentNext = cleanNext.startsWith("/admin") ? "/dashboard" : cleanNext;

  return (
    <div className="ab grid min-h-screen flex-1 lg:grid-cols-[1fr_1.05fr]">
      <div className="flex flex-col px-5 py-6 sm:px-10 sm:py-8 lg:border-r lg:border-ab-rule lg:px-12 lg:py-10">
        <div className="flex items-center justify-between gap-4">
          <Link href="/" className="flex items-center gap-2.5" aria-label={t.common.brand}>
            <BrandMark size={36} />
            <Wordmark />
          </Link>
          <LanguageSwitch className="lg:hidden" />
        </div>

        <div className="hidden flex-1 flex-col justify-center py-12 lg:flex">
          <p className="text-[15px] text-ab-accent-ink" lang="hi">
            {t.login.panelHindi}
          </p>
          <h1 className="ab-display mt-3 max-w-[480px] text-[48px]">{t.login.panelTitle}</h1>
          <ul className="mt-6 flex flex-col gap-2.5 text-[15px] text-ab-ink-2">
            {t.login.panelPoints.map((p) => (
              <li key={p} className="flex items-center gap-2.5">
                <Check className="text-ab-accent" />
                {p}
              </li>
            ))}
          </ul>
          <div className="mt-10 max-w-[520px]">
            <PlanRegister start={BATCH_START} exam={EXAM_DATE} now={requestNow()} t={t} locale={locale} compact />
          </div>
        </div>
        <p className="hidden text-[13px] text-ab-ink-3 lg:block">© {new Date().getFullYear()} AB Academy</p>
      </div>

      <div className="flex flex-col bg-ab-panel px-5 py-10 sm:px-10 lg:py-10">
        <div className="hidden justify-end lg:flex">
          <LanguageSwitch />
        </div>
        <div className="flex flex-1 items-center justify-center">
          <div className="w-full max-w-[400px]">
            {error ? (
              <p role="alert" className="mb-6 rounded-[10px] border border-[#f3cdc8] bg-ab-danger-soft px-3.5 py-2.5 text-sm text-ab-danger">
                {t.login.errors.generic}
              </p>
            ) : null}
            <LoginForm next={studentNext} demo={demo} />
          </div>
        </div>
      </div>
    </div>
  );
}
