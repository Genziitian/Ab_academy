"use client";

import { useEffect, useState } from "react";

const TARGET = 75;
const R = 88;
const CIRC = 2 * Math.PI * R;

const SUBJECTS = [
  { name: "Physics", chapters: 14, fill: 0.78 },
  { name: "Chemistry", chapters: 10, fill: 0.74 },
  { name: "Maths", chapters: 13, fill: 0.76 },
];

const MILESTONES = [
  { day: "Day 1", label: "Start" },
  { day: "Day 30", label: "Concepts" },
  { day: "Day 60", label: "Practice" },
  { day: "Day 90", label: "Boards" },
];

/**
 * Hero visual: "Target 75% in 90 days". A score ring fills while the number
 * counts up, subject bars follow, and a marker runs along the 90-day plan.
 * Everything is CSS transitions plus one count-up, and it shows the final
 * state straight away for people who prefer reduced motion.
 */
export function TargetPanel({ days = 90 }: { days?: number }) {
  const [go, setGo] = useState(false);
  const [count, setCount] = useState(0);

  useEffect(() => {
    const reduce = window.matchMedia("(prefers-reduced-motion: reduce)").matches;
    const start = requestAnimationFrame(() => setGo(true));
    if (reduce) {
      const id = requestAnimationFrame(() => setCount(TARGET));
      return () => {
        cancelAnimationFrame(start);
        cancelAnimationFrame(id);
      };
    }
    const t0 = performance.now() + 250;
    let raf = 0;
    const tick = (now: number) => {
      const p = Math.min(1, Math.max(0, (now - t0) / 1800));
      const eased = 1 - Math.pow(1 - p, 3);
      setCount(Math.round(eased * TARGET));
      if (p < 1) raf = requestAnimationFrame(tick);
    };
    raf = requestAnimationFrame(tick);
    return () => {
      cancelAnimationFrame(start);
      cancelAnimationFrame(raf);
    };
  }, []);

  return (
    <div className="relative flex h-full flex-col overflow-hidden rounded-3xl bg-[radial-gradient(120%_90%_at_50%_0%,#f2a86b_0%,#e8742a_42%,#b4521a_100%)] p-6 text-cream sm:p-8">
      <div aria-hidden className="absolute -right-24 -top-24 size-72 rounded-full border border-white/15" />
      <div aria-hidden className="absolute -bottom-32 -left-20 size-80 rounded-full border border-white/10" />

      <div className="relative flex items-center justify-between gap-3">
        <p className="text-xs font-bold uppercase tracking-[0.18em] text-cream/85">Your {days}-day target</p>
        <span className="flex items-center gap-1.5 rounded-full bg-coal/25 px-3 py-1 text-xs font-bold">
          <span className="size-1.5 animate-pulse rounded-full bg-cream" />
          Board 2027
        </span>
      </div>

      {/* Score ring */}
      <div className="relative mx-auto mt-4 grid size-[200px] place-items-center sm:size-[220px]">
        <svg viewBox="0 0 200 200" className="absolute inset-0 size-full -rotate-90" aria-hidden>
          <circle cx="100" cy="100" r={R} fill="none" stroke="rgba(255,255,255,0.18)" strokeWidth="14" />
          <circle
            cx="100"
            cy="100"
            r={R}
            fill="none"
            stroke="#fff8ef"
            strokeWidth="14"
            strokeLinecap="round"
            strokeDasharray={CIRC}
            strokeDashoffset={go ? CIRC * (1 - TARGET / 100) : CIRC}
            style={{ transition: "stroke-dashoffset 2s cubic-bezier(.22,1,.36,1) .25s" }}
          />
        </svg>
        <div className="text-center" role="img" aria-label={`Target: ${TARGET} percent in the board exam`}>
          <p className="font-serif text-[76px] leading-none tabular-nums sm:text-[84px]">
            {count}
            <span className="text-[44px]">%</span>
          </p>
          <p className="mt-1 text-xs font-bold uppercase tracking-[0.16em] text-cream/85">Target score</p>
        </div>
      </div>

      <p className="relative mt-3 text-center font-serif text-[30px] leading-tight sm:text-[34px]">
        Target {TARGET}%+ in {days} days.
      </p>

      {/* Subject bars */}
      <div className="relative mt-6 flex flex-col gap-3">
        {SUBJECTS.map((s, i) => (
          <div key={s.name}>
            <div className="flex justify-between text-sm font-semibold">
              <span>{s.name}</span>
              <span className="text-cream/80">{s.chapters} chapters</span>
            </div>
            <div className="mt-1.5 h-2.5 overflow-hidden rounded-full bg-white/20">
              <div
                className="h-full rounded-full bg-cream"
                style={{
                  width: go ? `${s.fill * 100}%` : "0%",
                  transition: `width 1.4s cubic-bezier(.22,1,.36,1) ${0.6 + i * 0.25}s`,
                }}
              />
            </div>
          </div>
        ))}
      </div>

      {/* 90-day plan */}
      <div className="relative mt-auto pt-8">
        <div className="relative h-1 rounded-full bg-white/25">
          <div
            className="absolute inset-y-0 left-0 rounded-full bg-cream"
            style={{ width: go ? "100%" : "0%", transition: "width 3s cubic-bezier(.65,0,.35,1) 1s" }}
          />
          <span
            aria-hidden
            className="absolute top-1/2 size-4 -translate-x-1/2 -translate-y-1/2 rounded-full border-[3px] border-cream bg-clay shadow-[0_0_0_6px_rgba(255,248,239,0.25)]"
            style={{ left: go ? "100%" : "0%", transition: "left 3s cubic-bezier(.65,0,.35,1) 1s" }}
          />
        </div>
        <ol className="mt-4 grid grid-cols-4 text-center">
          {MILESTONES.map((m, i) => (
            <li
              key={m.day}
              className={i === 0 ? "text-left" : i === MILESTONES.length - 1 ? "text-right" : ""}
              style={{ opacity: go ? 1 : 0.35, transition: `opacity .4s ease ${1 + i * 0.8}s` }}
            >
              <p className="text-sm font-bold">{m.day}</p>
              <p className="text-xs text-cream/80">{m.label}</p>
            </li>
          ))}
        </ol>
      </div>
    </div>
  );
}
