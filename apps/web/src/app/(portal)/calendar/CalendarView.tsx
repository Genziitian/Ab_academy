"use client";

import Link from "next/link";
import { useMemo, useState } from "react";
import type { AgendaItem, AgendaKind } from "@/lib/portal/data";

const DOWS = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
const DOT: Record<AgendaKind, string> = { live: "#e5484d", recorded: "#2962ff", test: "#ff8a3d" };
const TAG: Record<AgendaKind, string> = {
  live: "bg-danger-soft text-danger",
  recorded: "bg-primary-soft text-primary",
  test: "bg-amber-soft text-amber",
};

type Mark = { offset: number; kind: AgendaKind; item: AgendaItem };

/** Dates are handled as UTC midnights so day arithmetic ignores DST and zones. */
function parseIso(iso: string) {
  const [y, m, d] = iso.split("-").map(Number);
  return new Date(Date.UTC(y, m - 1, d));
}

function key(date: Date) {
  return date.toISOString().slice(0, 10);
}

function addDays(date: Date, days: number) {
  return new Date(date.getTime() + days * 86_400_000);
}

export function CalendarView({
  todayIso,
  today,
  marks,
}: {
  todayIso: string;
  today: AgendaItem[];
  marks: Mark[];
}) {
  const todayDate = parseIso(todayIso);
  const [month, setMonth] = useState(() => new Date(Date.UTC(todayDate.getUTCFullYear(), todayDate.getUTCMonth(), 1)));
  const [selected, setSelected] = useState(todayIso);

  const events = useMemo(() => {
    const map = new Map<string, { kind: AgendaKind; items: AgendaItem[] }>();
    map.set(todayIso, { kind: today[0]?.kind ?? "live", items: today });
    for (const mark of marks) {
      map.set(key(addDays(todayDate, mark.offset)), { kind: mark.kind, items: [mark.item] });
    }
    return map;
    // todayDate is derived from todayIso.
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [todayIso, today, marks]);

  // Monday-first grid covering the whole month.
  const lead = (month.getUTCDay() + 6) % 7;
  const daysInMonth = new Date(Date.UTC(month.getUTCFullYear(), month.getUTCMonth() + 1, 0)).getUTCDate();
  const cells = Math.ceil((lead + daysInMonth) / 7) * 7;

  const monthLabel = month.toLocaleDateString("en-IN", { month: "long", year: "numeric", timeZone: "UTC" });
  const selectedLabel = parseIso(selected).toLocaleDateString("en-IN", {
    day: "numeric",
    month: "long",
    year: "numeric",
    timeZone: "UTC",
  });
  const agenda = events.get(selected)?.items ?? [];

  function shiftMonth(delta: number) {
    setMonth(new Date(Date.UTC(month.getUTCFullYear(), month.getUTCMonth() + delta, 1)));
  }

  return (
    <div className="grid max-w-[1280px] items-start gap-6 px-4 pb-12 pt-7 sm:px-8 xl:grid-cols-[minmax(0,1fr)_360px]">
      <section className="rounded-xl border border-border bg-white p-4 sm:p-6">
        <div className="flex flex-wrap items-center justify-between gap-3">
          <h2 className="text-xl font-semibold text-navy">{monthLabel}</h2>
          <div className="flex items-center gap-4">
            <div className="hidden gap-3.5 text-xs text-ink sm:flex">
              {(["live", "recorded", "test"] as const).map((kind) => (
                <span key={kind} className="flex items-center gap-1.5 capitalize">
                  <span className="size-2 rounded-full" style={{ background: DOT[kind] }} />
                  {kind}
                </span>
              ))}
            </div>
            <div className="flex gap-1">
              <button
                type="button"
                aria-label="Previous month"
                onClick={() => shiftMonth(-1)}
                className="size-[34px] rounded-lg border border-border bg-white text-base text-navy hover:bg-surface-grey"
              >
                ‹
              </button>
              <button
                type="button"
                aria-label="Next month"
                onClick={() => shiftMonth(1)}
                className="size-[34px] rounded-lg border border-border bg-white text-base text-navy hover:bg-surface-grey"
              >
                ›
              </button>
            </div>
          </div>
        </div>
        <div className="mt-5 grid grid-cols-7 gap-px overflow-hidden rounded-[10px] border border-border bg-border">
          {DOWS.map((d) => (
            <div key={d} className="bg-surface-grey p-2.5 text-center text-xs font-semibold text-muted">
              {d}
            </div>
          ))}
          {Array.from({ length: cells }, (_, i) => {
            const day = i - lead + 1;
            const valid = day >= 1 && day <= daysInMonth;
            if (!valid) return <div key={i} className="h-16 bg-white sm:h-[84px]" />;
            const date = key(new Date(Date.UTC(month.getUTCFullYear(), month.getUTCMonth(), day)));
            const on = date === selected;
            const isToday = date === todayIso;
            const event = events.get(date);
            return (
              <button
                key={i}
                type="button"
                onClick={() => setSelected(date)}
                className={`flex h-16 flex-col items-start justify-between p-2 text-left sm:h-[84px] sm:p-2.5 ${
                  on ? "bg-primary-soft" : "bg-white hover:bg-surface-grey"
                }`}
              >
                <span
                  className={`text-sm ${on ? "font-bold text-primary" : isToday ? "font-bold text-navy" : "font-medium text-navy"}`}
                >
                  {day}
                </span>
                <span
                  className="size-2 rounded-full"
                  style={{ background: event ? DOT[event.kind] : "transparent" }}
                />
              </button>
            );
          })}
        </div>
      </section>

      <aside className="rounded-xl border border-border bg-white p-6">
        <p className="text-xs font-semibold tracking-[0.06em] text-muted">AGENDA</p>
        <h3 className="mt-1 text-lg font-semibold text-navy">
          {selected === todayIso ? `Today · ${selectedLabel}` : selectedLabel}
        </h3>
        <div className="mt-5 flex flex-col gap-3">
          {agenda.map((item) => (
            <div
              key={`${item.time}-${item.title}`}
              className={`rounded-[10px] border p-4 ${
                item.joinable ? "border-primary-line bg-surface-soft" : "border-border bg-white"
              }`}
            >
              <div className="flex items-center justify-between">
                <span className="text-[13px] font-semibold text-navy">{item.time}</span>
                <span
                  className={`whitespace-nowrap rounded px-2 py-0.5 text-[11px] font-bold uppercase tracking-[0.04em] ${TAG[item.kind]}`}
                >
                  {item.kind}
                </span>
              </div>
              <p className="mt-2 text-[15px] font-semibold text-navy">{item.title}</p>
              <p className="mt-0.5 text-[13px] text-muted">{item.sub}</p>
              {item.joinable ? (
                <Link
                  href="/live/classroom"
                  className="mt-3 flex h-9 items-center justify-center rounded-lg bg-primary text-sm font-semibold text-white hover:bg-primary-dark"
                >
                  Join now
                </Link>
              ) : null}
            </div>
          ))}
          {agenda.length === 0 ? (
            <p className="rounded-[10px] border border-dashed border-[#d5dcea] p-6 text-center text-sm text-muted">
              No classes scheduled.
            </p>
          ) : null}
        </div>
      </aside>
    </div>
  );
}
