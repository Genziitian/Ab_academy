"use client";

import Link from "next/link";
import { useState } from "react";
import { COURSE_LANGUAGES, type CourseLanguage } from "@/lib/courses";

/** "Hindi or Hinglish?" toggle, then Enroll — the choice travels to checkout. */
export function EnrollWithLanguage({ slug }: { slug: string }) {
  const [lang, setLang] = useState<CourseLanguage>("Hindi");

  return (
    <div className="mt-5">
      <p className="text-[13px] font-semibold text-navy">Choose your language</p>
      <LanguageToggle value={lang} onChange={setLang} />
      <Link
        href={`/checkout/${slug}?lang=${lang}`}
        className="mt-4 flex h-12 items-center justify-center rounded-full bg-primary text-[15px] font-semibold text-white hover:bg-primary-dark"
      >
        Enroll in {lang}
      </Link>
    </div>
  );
}

export function LanguageToggle({
  value,
  onChange,
}: {
  value: CourseLanguage;
  onChange: (value: CourseLanguage) => void;
}) {
  return (
    <div role="radiogroup" aria-label="Course language" className="mt-2 grid grid-cols-2 gap-2">
      {COURSE_LANGUAGES.map((l) => {
        const on = value === l.value;
        return (
          <button
            key={l.value}
            type="button"
            role="radio"
            aria-checked={on}
            onClick={() => onChange(l.value)}
            className={`rounded-xl px-3 py-2.5 text-left transition ${
              on ? "border-2 border-primary bg-primary-soft" : "border border-border bg-white hover:border-primary-line"
            }`}
          >
            <span className="block text-[15px] font-semibold text-navy">{l.label}</span>
            <span className="block text-xs text-muted">{l.hint}</span>
          </button>
        );
      })}
    </div>
  );
}
