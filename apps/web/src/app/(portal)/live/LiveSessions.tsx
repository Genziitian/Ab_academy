"use client";

import Link from "next/link";
import { useEffect, useState } from "react";
import { TabButton } from "@/components/portal/ui";
import { type LiveSession, toneFor } from "@/lib/portal/data";

const pad = (n: number) => String(n).padStart(2, "0");

/** Seconds until `hour`:00 today, or until tomorrow's if that has passed. */
function secondsUntil(hour: number) {
  const now = new Date();
  const target = new Date(now);
  target.setHours(hour, 0, 0, 0);
  if (target <= now) target.setDate(target.getDate() + 1);
  return Math.round((target.getTime() - now.getTime()) / 1000);
}

export function NextUpCard({
  title,
  teacher,
  time,
  hour,
}: {
  title: string;
  teacher: string;
  time: string;
  hour: number;
}) {
  // Null until mounted so the server and client render the same markup.
  const [left, setLeft] = useState<number | null>(null);
  const [remind, setRemind] = useState(false);

  useEffect(() => {
    const tick = () => setLeft(secondsUntil(hour));
    tick();
    const id = setInterval(tick, 1000);
    return () => clearInterval(id);
  }, [hour]);

  const units =
    left === null
      ? [
          ["--", "MIN"],
          ["--", "SEC"],
        ]
      : left >= 3600
        ? [
            [pad(Math.floor(left / 3600)), "HRS"],
            [pad(Math.floor((left % 3600) / 60)), "MIN"],
            [pad(left % 60), "SEC"],
          ]
        : [
            [pad(Math.floor(left / 60)), "MIN"],
            [pad(left % 60), "SEC"],
          ];

  return (
    <div className="rounded-xl border border-border bg-white p-7">
      <p className="text-xs font-semibold tracking-[0.06em] text-muted">NEXT UP · LOBBY</p>
      <h3 className="mt-2 text-xl font-semibold text-navy">{title}</h3>
      <p className="mt-1 text-sm text-muted">
        {teacher} · {time}
      </p>
      <div className="mt-5 flex gap-2">
        {units.map(([value, label]) => (
          <div key={label} className="flex-1 rounded-lg bg-surface-soft p-3 text-center">
            <p className="font-mono text-[26px] font-medium text-navy">{value}</p>
            <p className="text-[11px] text-muted">{label}</p>
          </div>
        ))}
      </div>
      <div className="mt-4 flex gap-2">
        <button
          type="button"
          onClick={() => setRemind(!remind)}
          className={`h-10 flex-1 whitespace-nowrap rounded-lg text-sm font-semibold ${
            remind ? "bg-success-soft text-success" : "bg-primary text-white hover:bg-primary-dark"
          }`}
        >
          {remind ? "✓ Reminder set" : "Remind me"}
        </button>
        <Link
          href="/calendar"
          className="flex h-10 items-center whitespace-nowrap rounded-lg border border-border px-3.5 text-sm font-semibold text-navy hover:bg-surface-grey"
        >
          Add to calendar
        </Link>
      </div>
    </div>
  );
}

export function SessionTabs({
  upcoming,
  past,
}: {
  upcoming: LiveSession[];
  past: LiveSession[];
}) {
  const [tab, setTab] = useState<"up" | "past">("up");
  const [reminders, setReminders] = useState<string[]>([]);
  const list = tab === "up" ? upcoming : past;

  return (
    <section>
      <div className="mb-4 flex gap-1 border-b border-border">
        <TabButton active={tab === "up"} onClick={() => setTab("up")} className="h-11 px-3.5">
          Upcoming ({upcoming.length})
        </TabButton>
        <TabButton active={tab === "past"} onClick={() => setTab("past")} className="h-11 px-3.5">
          Past recordings ({past.length})
        </TabButton>
      </div>
      <div className="overflow-hidden rounded-xl border border-border bg-white">
        {list.map((session) => {
          const tone = toneFor(session.subject);
          const reminded = reminders.includes(session.title);
          return (
            <div
              key={session.title}
              className="grid items-center gap-x-4 gap-y-2 border-b border-line px-5 py-4 last:border-b-0 md:grid-cols-[minmax(110px,150px)_minmax(0,1fr)_auto_auto]"
            >
              <span className="text-sm font-semibold text-navy">{session.when}</span>
              <div className="flex min-w-0 items-center gap-3">
                <span
                  className="flex size-9 shrink-0 items-center justify-center rounded-lg text-xs font-semibold"
                  style={{ background: tone.bg, color: tone.fg }}
                >
                  {session.initials}
                </span>
                <div className="min-w-0">
                  <p className="text-[15px] font-semibold text-navy">{session.title}</p>
                  <p className="mt-0.5 text-[13px] text-muted">
                    {session.subject} · {session.teacher} · {session.chapter}
                  </p>
                </div>
              </div>
              <span className="text-[13px] text-muted">{session.meta}</span>
              {tab === "up" ? (
                <button
                  type="button"
                  onClick={() =>
                    setReminders((prev) =>
                      reminded ? prev.filter((t) => t !== session.title) : [...prev, session.title],
                    )
                  }
                  className={`h-9 justify-self-start whitespace-nowrap rounded-lg px-3.5 text-[13px] font-semibold md:justify-self-end ${
                    reminded
                      ? "bg-success-soft text-success"
                      : "border border-primary-line text-primary hover:bg-primary-soft"
                  }`}
                >
                  {reminded ? "✓ Reminder set" : "Set reminder"}
                </button>
              ) : (
                <Link
                  href="/lecture/current-electricity-3"
                  className="flex h-9 items-center justify-self-start whitespace-nowrap rounded-lg border border-primary-line px-3.5 text-[13px] font-semibold text-primary hover:bg-primary-soft md:justify-self-end"
                >
                  Watch recording
                </Link>
              )}
            </div>
          );
        })}
      </div>
    </section>
  );
}
