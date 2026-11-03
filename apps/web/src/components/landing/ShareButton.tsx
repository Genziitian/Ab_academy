"use client";

import { useState } from "react";

/** Share a course: the phone's share sheet, or copy the link on desktop. */
export function ShareButton({ path, title }: { path: string; title: string }) {
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
      aria-label={`Share ${title}`}
      title={copied ? "Link copied" : "Share"}
      className="relative flex size-10 shrink-0 items-center justify-center rounded-full border border-sand text-taupe transition hover:border-coal hover:text-coal"
    >
      <svg width="17" height="17" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" aria-hidden>
        <circle cx="18" cy="5" r="3" />
        <circle cx="6" cy="12" r="3" />
        <circle cx="18" cy="19" r="3" />
        <path d="m8.6 13.5 6.8 4M15.4 6.5l-6.8 4" />
      </svg>
      {copied ? (
        <span className="absolute -top-8 whitespace-nowrap rounded-full bg-coal px-2.5 py-1 text-xs font-semibold text-cream">
          Link copied
        </span>
      ) : null}
    </button>
  );
}
