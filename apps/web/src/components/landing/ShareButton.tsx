"use client";

import { useState } from "react";
import { useT } from "@/lib/i18n/client";

/** Share a course: the phone's share sheet, or copy the link on desktop. */
export function ShareButton({ path, title }: { path: string; title: string }) {
  const t = useT();
  const [copied, setCopied] = useState(false);

  async function share() {
    const url = `${window.location.origin}${path}`;
    try {
      if (navigator.share) {
        await navigator.share({ title, url });
        return;
      }
      await navigator.clipboard.writeText(url);
      setCopied(true);
      setTimeout(() => setCopied(false), 1800);
    } catch {
      /* the user closed the share sheet */
    }
  }

  return (
    <button
      type="button"
      onClick={share}
      aria-label={t.home.share(title)}
      title={copied ? t.home.linkCopied : t.home.share(title)}
      className="relative flex size-9 shrink-0 items-center justify-center rounded-full bg-white/90 text-ab-ink backdrop-blur transition hover:bg-white"
    >
      <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" aria-hidden>
        <circle cx="18" cy="5" r="3" />
        <circle cx="6" cy="12" r="3" />
        <circle cx="18" cy="19" r="3" />
        <path d="m8.6 13.5 6.8 4M15.4 6.5l-6.8 4" />
      </svg>
      {copied ? (
        <span className="absolute right-0 top-11 whitespace-nowrap rounded-full bg-ab-ink px-2.5 py-1 text-xs font-medium text-white">
          {t.home.linkCopied}
        </span>
      ) : null}
    </button>
  );
}
