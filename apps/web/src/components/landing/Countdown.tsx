"use client";

import { useEffect, useState } from "react";

const pad = (n: number) => String(n).padStart(2, "0");

function parts(target: number, now: number) {
  const diff = Math.max(0, target - now);
  return {
    days: Math.floor(diff / 864e5),
    h: pad(Math.floor(diff / 36e5) % 24),
    m: pad(Math.floor(diff / 6e4) % 60),
    s: pad(Math.floor(diff / 1e3) % 60),
  };
}

/** Ticking time-to-target, rendered as Days / Hours / Min / Sec. */
export function Countdown({ target }: { target: string }) {
  const at = new Date(target).getTime();
  const [now, setNow] = useState(() => Date.now());

  useEffect(() => {
    const id = setInterval(() => setNow(Date.now()), 1000);
    return () => clearInterval(id);
  }, []);

  const t = parts(at, now);
  const cells = [
    { v: String(t.days), label: "Days", big: true, accent: true },
    { v: t.h, label: "Hours" },
    { v: t.m, label: "Min" },
    { v: t.s, label: "Sec", accent: true },
  ];

  return (
    <div className="flex items-end gap-5 sm:gap-7" role="timer" aria-label={`${t.days} days to go`}>
      {cells.map((c) => (
        <div key={c.label}>
          <p
            suppressHydrationWarning
            className={`font-serif leading-[0.9] tabular-nums ${c.big ? "text-[64px] sm:text-[88px]" : "text-[40px] sm:text-[56px]"} ${c.accent ? "text-saffron" : ""}`}
          >
            {c.v}
          </p>
          <p className="mt-3 text-[11px] font-bold uppercase tracking-[0.14em] text-dust sm:text-xs">{c.label}</p>
        </div>
      ))}
    </div>
  );
}

/** Just the whole days left, for inline use. */
export function DaysLeft({ target }: { target: string }) {
  const at = new Date(target).getTime();
  const [now, setNow] = useState(() => Date.now());
  useEffect(() => {
    const id = setInterval(() => setNow(Date.now()), 60_000);
    return () => clearInterval(id);
  }, []);
  return <span suppressHydrationWarning>{parts(at, now).days}</span>;
}
