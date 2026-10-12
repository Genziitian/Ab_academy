"use client";

import { useState } from "react";
import { PdfBadge } from "@/components/NotesBrowser";
import { FilterPill } from "@/components/portal/ui";
import { type Material, toneFor } from "@/lib/portal/data";

const COLUMNS = "md:grid-cols-[minmax(0,1fr)_140px_140px_200px]";

export function MaterialsTable({ items, subjects }: { items: Material[]; subjects: string[] }) {
  const [filter, setFilter] = useState("All");
  const [offline, setOffline] = useState<string[]>(["m2"]);

  const visible = items.filter((m) => filter === "All" || m.subject === filter);

  return (
    <div className="max-w-[1280px] px-4 pb-12 pt-7 sm:px-8">
      <div className="no-scrollbar mb-5 flex gap-2 overflow-x-auto">
        {["All", ...subjects].map((name) => (
          <FilterPill key={name} active={filter === name} onClick={() => setFilter(name)}>
            {name}
          </FilterPill>
        ))}
      </div>
      <div className="overflow-hidden rounded-xl border border-border bg-white">
        <div
          className={`hidden gap-4 border-b border-border bg-surface-grey px-5 py-3 text-xs font-semibold uppercase tracking-[0.04em] text-muted md:grid ${COLUMNS}`}
        >
          <span>Document</span>
          <span>Subject</span>
          <span>Updated</span>
          <span className="text-right">Actions</span>
        </div>
        {visible.map((item) => {
          const isOffline = offline.includes(item.id);
          const tone = toneFor(item.subject);
          return (
            <div
              key={item.id}
              className={`grid items-center gap-x-4 gap-y-2.5 border-b border-line px-5 py-4 last:border-b-0 ${COLUMNS}`}
            >
              <div className="flex min-w-0 items-center gap-3.5">
                <PdfBadge />
                <div className="min-w-0">
                  <p className="text-[15px] font-semibold text-navy">{item.title}</p>
                  <p className="mt-0.5 text-[13px] text-muted">{item.size}</p>
                </div>
              </div>
              <span
                className="justify-self-start rounded px-2 py-[3px] text-xs font-semibold"
                style={{ background: tone.bg, color: tone.fg }}
              >
                {item.subject}
              </span>
              <span className="hidden text-[13px] text-muted md:block">{item.updated}</span>
              <div className="flex gap-2 md:justify-end">
                {/* Every row opens the bundled sample PDF until notes come from storage. */}
                <a
                  href="/sample-notes.pdf"
                  target="_blank"
                  rel="noreferrer"
                  className="flex h-[34px] items-center rounded-lg border border-primary-line bg-white px-3 text-[13px] font-semibold text-primary hover:bg-primary-soft"
                >
                  Open
                </a>
                <button
                  type="button"
                  onClick={() =>
                    setOffline((prev) =>
                      isOffline ? prev.filter((id) => id !== item.id) : [...prev, item.id],
                    )
                  }
                  className={`h-[34px] whitespace-nowrap rounded-lg px-3 text-[13px] font-semibold ${
                    isOffline ? "bg-success-soft text-success" : "bg-primary text-white hover:bg-primary-dark"
                  }`}
                >
                  {isOffline ? "✓ Offline" : "Download"}
                </button>
              </div>
            </div>
          );
        })}
      </div>
    </div>
  );
}
