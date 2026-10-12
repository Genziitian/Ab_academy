"use client";

import Link from "next/link";
import { useState } from "react";
import { ProgressBar, TabButton } from "@/components/portal/ui";
import type { DownloadItem } from "@/lib/portal/data";

const tabs = [
  ["all", "All"],
  ["video", "Videos"],
  ["pdf", "Notes"],
] as const;

export function DownloadsList({ items }: { items: DownloadItem[] }) {
  const [tab, setTab] = useState<(typeof tabs)[number][0]>("all");
  const [removed, setRemoved] = useState<string[]>([]);
  const [paused, setPaused] = useState(false);

  const visible = items.filter((d) => !removed.includes(d.id) && (tab === "all" || d.kind === tab));

  return (
    <section className="overflow-hidden rounded-xl border border-border bg-white">
      <div className="flex gap-1 border-b border-border px-5">
        {tabs.map(([value, label]) => (
          <TabButton key={value} active={tab === value} onClick={() => setTab(value)}>
            {label}
          </TabButton>
        ))}
      </div>
      {visible.map((item) => {
        const video = item.kind === "video";
        return (
          <div key={item.id} className="flex items-center gap-4 border-b border-line px-5 py-4 last:border-b-0">
            <span
              className={`flex size-11 shrink-0 items-center justify-center rounded-lg font-bold ${
                video ? "bg-primary-soft text-sm text-primary" : "bg-pdf-soft text-[10px] text-danger"
              }`}
            >
              {video ? "▶" : "PDF"}
            </span>
            <div className="min-w-0 flex-1">
              <p className="text-[15px] font-semibold text-navy">{item.title}</p>
              <p className="mt-0.5 text-[13px] text-muted">
                {item.downloading && paused ? `Paused · ${item.progress}% of 280 MB` : item.meta}
              </p>
              {item.downloading ? (
                <ProgressBar value={item.progress ?? 0} className="mt-2 h-1 w-full max-w-[240px]" />
              ) : null}
            </div>
            {item.downloading ? (
              <button
                type="button"
                onClick={() => setPaused(!paused)}
                className="text-[13px] font-semibold text-primary"
              >
                {paused ? "Resume" : "Pause"}
              </button>
            ) : (
              <Link
                href={video ? "/lecture/current-electricity-3" : "/materials"}
                className="text-[13px] font-semibold text-primary"
              >
                {video ? "Play" : "Open"}
              </Link>
            )}
            <button
              type="button"
              onClick={() => setRemoved((r) => [...r, item.id])}
              className="h-8 rounded-md border border-border bg-white px-2.5 text-[13px] text-muted hover:text-navy"
            >
              Remove
            </button>
          </div>
        );
      })}
      {visible.length === 0 ? (
        <p className="px-5 py-10 text-center text-sm text-muted">Nothing downloaded here yet.</p>
      ) : null}
    </section>
  );
}
