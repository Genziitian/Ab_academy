"use client";

import Link from "next/link";
import { useState } from "react";
import type { NotificationKind, PortalNotification } from "@/lib/portal/data";

const KIND: Record<NotificationKind, { className: string; glyph: string }> = {
  live: { className: "bg-danger-soft text-danger", glyph: "●" },
  test: { className: "bg-amber-soft text-amber", glyph: "✎" },
  recording: { className: "bg-primary-soft text-primary", glyph: "▶" },
  notes: { className: "bg-violet-soft text-[#6b4fd8]", glyph: "≡" },
  result: { className: "bg-success-soft text-success", glyph: "✓" },
};

const GROUPS = ["Today", "Yesterday", "Earlier"] as const;

export function NotificationList({ items }: { items: PortalNotification[] }) {
  const [allRead, setAllRead] = useState(false);
  const unread = allRead ? 0 : items.filter((n) => n.unread).length;

  return (
    <div className="max-w-[860px] px-4 pb-12 pt-7 sm:px-8">
      <div className="mb-4 flex items-center justify-between">
        <span className="text-sm text-muted">{unread ? `${unread} unread` : "All caught up"}</span>
        <button
          type="button"
          onClick={() => setAllRead(true)}
          disabled={!unread}
          className="text-sm font-semibold text-primary disabled:text-subtle"
        >
          Mark all as read
        </button>
      </div>
      {GROUPS.map((group) => {
        const groupItems = items.filter((n) => n.group === group);
        if (!groupItems.length) return null;
        return (
          <div key={group}>
            <p className="mb-2.5 mt-5 text-xs font-semibold uppercase tracking-[0.06em] text-muted">
              {group}
            </p>
            <div className="overflow-hidden rounded-xl border border-border bg-white">
              {groupItems.map((n) => {
                const isUnread = n.unread && !allRead;
                const kind = KIND[n.kind];
                return (
                  <div
                    key={n.id}
                    className={`flex gap-3.5 border-b border-l-[3px] border-b-line px-5 py-4 last:border-b-0 ${
                      isUnread ? "border-l-primary bg-surface-soft" : "border-l-transparent bg-white"
                    }`}
                  >
                    <span
                      className={`flex size-[38px] shrink-0 items-center justify-center rounded-lg text-sm font-bold ${kind.className}`}
                    >
                      {kind.glyph}
                    </span>
                    <div className="min-w-0 flex-1">
                      <div className="flex justify-between gap-3">
                        <p className="text-[15px] font-semibold text-navy">{n.title}</p>
                        {n.time ? <span className="text-xs text-subtle">{n.time}</span> : null}
                      </div>
                      <p className="mt-[3px] text-sm text-ink">{n.body}</p>
                      {n.action ? (
                        <Link
                          href={n.action.href}
                          className="mt-2 inline-flex text-[13px] font-semibold text-primary"
                        >
                          {n.action.label}
                        </Link>
                      ) : null}
                    </div>
                  </div>
                );
              })}
            </div>
          </div>
        );
      })}
    </div>
  );
}
