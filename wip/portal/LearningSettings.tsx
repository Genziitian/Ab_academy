"use client";

import { useState } from "react";

const QUALITIES = ["Auto", "360p", "480p", "720p"];
const TOGGLES = [
  { key: "live", label: "Live class reminders", sub: "Push notification 5 minutes before class." },
  { key: "notes", label: "New notes & recordings", sub: "Alerts when teachers upload material." },
  { key: "wifi", label: "Download on wifi only", sub: "Pause offline downloads on mobile data." },
] as const;

type ToggleKey = (typeof TOGGLES)[number]["key"];

export function LearningSettings() {
  const [quality, setQuality] = useState("480p");
  const [on, setOn] = useState<Record<ToggleKey, boolean>>({ live: true, notes: true, wifi: false });

  return (
    <>
      <div className="flex flex-wrap items-center justify-between gap-3 border-b border-line px-6 py-4">
        <div>
          <p className="text-[15px] font-medium text-navy">Video quality on mobile data</p>
          <p className="mt-0.5 text-[13px] text-muted">Lower quality saves data and avoids buffering.</p>
        </div>
        <div className="flex rounded-lg border border-border bg-surface-grey p-[3px]">
          {QUALITIES.map((q) => (
            <button
              key={q}
              type="button"
              onClick={() => setQuality(q)}
              className={`h-[30px] rounded-md px-3 text-[13px] font-semibold ${
                quality === q ? "bg-white text-navy shadow-[0_1px_3px_rgba(18,32,70,0.1)]" : "text-muted"
              }`}
            >
              {q}
            </button>
          ))}
        </div>
      </div>
      {TOGGLES.map((t) => (
        <div
          key={t.key}
          className="flex items-center justify-between gap-4 border-b border-line px-6 py-4 last:border-b-0"
        >
          <div>
            <p className="text-[15px] font-medium text-navy">{t.label}</p>
            <p className="mt-0.5 text-[13px] text-muted">{t.sub}</p>
          </div>
          <button
            type="button"
            role="switch"
            aria-checked={on[t.key]}
            aria-label={t.label}
            onClick={() => setOn({ ...on, [t.key]: !on[t.key] })}
            className={`flex h-6 w-[42px] shrink-0 rounded-full p-[3px] ${
              on[t.key] ? "justify-end bg-primary" : "justify-start bg-[#d5dae4]"
            }`}
          >
            <span className="size-[18px] rounded-full bg-white shadow-[0_1px_2px_rgba(0,0,0,0.2)]" />
          </button>
        </div>
      ))}
    </>
  );
}
