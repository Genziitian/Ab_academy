"use client";

import Link from "next/link";
import { useState } from "react";
import { btn } from "@/components/ui";
import { useT } from "@/lib/i18n/client";
import { COURSE_LANGUAGES, type CourseLanguage } from "@/lib/courses";

/** "Hindi or Hinglish?" then Enroll — the choice travels to checkout. */
export function EnrollWithLanguage({ slug }: { slug: string }) {
  const t = useT();
  const [lang, setLang] = useState<CourseLanguage>("Hindi");
  const name = lang === "Hindi" ? t.common.hindi : t.common.hinglish;

  return (
    <div className="mt-6">
      <p className="text-sm font-medium text-ab-ink">{t.course.chooseLanguage}</p>
      <LanguageToggle value={lang} onChange={setLang} />
      <Link href={`/checkout/${slug}?lang=${lang}`} className={`${btn.primary} ${btn.lg} mt-4 w-full`}>
        {t.course.enrollIn(name)}
      </Link>
    </div>
  );
}

/** The study language for a course (not the website language). */
export function LanguageToggle({ value, onChange }: { value: CourseLanguage; onChange: (value: CourseLanguage) => void }) {
  const t = useT();
  return (
    <div role="radiogroup" aria-label={t.course.chooseLanguage} className="mt-2.5 grid grid-cols-2 gap-2">
      {COURSE_LANGUAGES.map((l) => {
        const on = value === l.value;
        return (
          <button
            key={l.value}
            type="button"
            role="radio"
            aria-checked={on}
            onClick={() => onChange(l.value)}
            className={`rounded-xl border px-3.5 py-3 text-left transition-colors ${
              on ? "border-ab-ink bg-ab-panel shadow-[inset_0_0_0_1px_var(--color-ab-ink)]" : "border-ab-rule bg-ab-panel hover:border-ab-rule-strong"
            }`}
          >
            <span className="flex items-center justify-between gap-2">
              <span className="text-[15px] font-medium text-ab-ink">{l.value === "Hindi" ? t.common.hindi : t.common.hinglish}</span>
              <span className={`size-3.5 rounded-full border ${on ? "border-[4px] border-ab-ink" : "border-ab-rule-strong"}`} />
            </span>
            <span className="mt-0.5 block text-[13px] text-ab-ink-3">{t.course.langHints[l.value]}</span>
          </button>
        );
      })}
    </div>
  );
}
