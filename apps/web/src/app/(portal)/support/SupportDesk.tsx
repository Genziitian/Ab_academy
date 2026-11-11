"use client";

import { useState } from "react";
import type { Ticket } from "@/lib/portal/data";

const CATEGORIES = ["Payment", "Technical", "Course content", "Other"];
const field =
  "rounded-lg border border-field px-3 text-[15px] font-normal outline-none focus:border-primary";

function StatusBadge({ status }: { status: Ticket["status"] }) {
  const resolved = status === "resolved";
  return (
    <span
      className={`whitespace-nowrap rounded px-2 py-0.5 text-[11px] font-bold tracking-[0.03em] ${
        resolved ? "bg-success-soft text-success" : "bg-amber-soft text-amber"
      }`}
    >
      {resolved ? "RESOLVED" : "IN PROGRESS"}
    </span>
  );
}

export function SupportDesk({ initial }: { initial: Ticket[] }) {
  const [tickets, setTickets] = useState(initial);
  const [selected, setSelected] = useState(0);
  const [mode, setMode] = useState<"view" | "new">("view");
  const [category, setCategory] = useState(CATEGORIES[0]);
  const [reply, setReply] = useState("");

  const ticket = tickets[selected];

  function submitTicket(event: React.FormEvent<HTMLFormElement>) {
    event.preventDefault();
    const data = new FormData(event.currentTarget);
    const subject = String(data.get("subject") ?? "").trim();
    const details = String(data.get("details") ?? "").trim();
    if (!subject || !details) return;
    const created: Ticket = {
      reference: `ABA-T-${1043 + tickets.length}`,
      subject,
      category,
      status: "progress",
      opened: "Opened just now",
      messages: [{ body: details, time: "Just now" }],
    };
    setTickets([created, ...tickets]);
    setSelected(0);
    setMode("view");
  }

  function sendReply() {
    const body = reply.trim();
    if (!body) return;
    setTickets((all) =>
      all.map((t, i) =>
        i === selected ? { ...t, messages: [...t.messages, { body, time: "Just now" }] } : t,
      ),
    );
    setReply("");
  }

  return (
    <div className="grid max-w-[1280px] items-start gap-6 px-4 pb-12 pt-7 sm:px-8 lg:grid-cols-[380px_minmax(0,1fr)]">
      <div className="flex flex-col gap-3">
        <button
          type="button"
          onClick={() => setMode("new")}
          className="h-11 rounded-lg bg-primary text-sm font-semibold text-white hover:bg-primary-dark"
        >
          + New ticket
        </button>
        <div className="overflow-hidden rounded-xl border border-border bg-white">
          {tickets.map((t, index) => {
            const active = mode === "view" && selected === index;
            return (
              <button
                key={t.reference}
                type="button"
                onClick={() => {
                  setSelected(index);
                  setMode("view");
                }}
                className={`block w-full border-b border-l-[3px] border-b-line px-[18px] py-4 text-left last:border-b-0 ${
                  active ? "border-l-primary bg-surface-soft" : "border-l-transparent bg-white hover:bg-surface-grey"
                }`}
              >
                <span className="flex items-center justify-between">
                  <span className="font-mono text-xs text-muted">{t.reference}</span>
                  <StatusBadge status={t.status} />
                </span>
                <span className="mt-1.5 block text-sm font-semibold text-navy">{t.subject}</span>
                <span className="mt-1 block text-xs text-muted">
                  {t.category} · {t.opened}
                </span>
              </button>
            );
          })}
        </div>
      </div>

      {mode === "new" ? (
        <form
          onSubmit={submitTicket}
          className="flex flex-col gap-4 rounded-xl border border-border bg-white p-6 sm:p-7"
        >
          <h2 className="text-xl font-semibold text-navy">Raise a new ticket</h2>
          <div>
            <p className="mb-2 text-sm font-medium text-navy">Category</p>
            <div className="flex flex-wrap gap-2">
              {CATEGORIES.map((name) => (
                <button
                  key={name}
                  type="button"
                  onClick={() => setCategory(name)}
                  className={`h-[34px] whitespace-nowrap rounded-lg border px-3.5 text-[13px] font-medium ${
                    category === name
                      ? "border-primary bg-primary-soft text-primary"
                      : "border-border bg-white text-ink"
                  }`}
                >
                  {name}
                </button>
              ))}
            </div>
          </div>
          <label className="flex flex-col gap-1.5 text-sm font-medium text-navy">
            Subject
            <input name="subject" required placeholder="Briefly describe the issue" className={`h-11 ${field}`} />
          </label>
          <label className="flex flex-col gap-1.5 text-sm font-medium text-navy">
            Details
            <textarea
              name="details"
              required
              rows={5}
              placeholder="Include order ID, course name or screenshots where helpful"
              className={`resize-y py-2.5 ${field}`}
            />
          </label>
          <div className="flex gap-2.5">
            <button
              type="button"
              onClick={() => setMode("view")}
              className="h-11 rounded-lg border border-border bg-white px-[18px] text-sm font-semibold text-navy hover:bg-surface-grey"
            >
              Cancel
            </button>
            <button
              type="submit"
              className="h-11 rounded-lg bg-primary px-[18px] text-sm font-semibold text-white hover:bg-primary-dark"
            >
              Submit ticket
            </button>
          </div>
        </form>
      ) : ticket ? (
        <section className="overflow-hidden rounded-xl border border-border bg-white">
          <div className="border-b border-border px-6 py-5">
            <div className="flex items-center gap-2.5">
              <span className="font-mono text-xs text-muted">{ticket.reference}</span>
              <StatusBadge status={ticket.status} />
            </div>
            <h2 className="mt-1.5 text-xl font-semibold text-navy">{ticket.subject}</h2>
          </div>
          <div className="flex flex-col gap-4 p-6">
            {ticket.messages.map((m, index) => (
              <div key={index} className={`flex ${m.support ? "justify-start" : "justify-end"}`}>
                <div
                  className={`max-w-[85%] rounded-[10px] border px-4 py-3 sm:max-w-[75%] ${
                    m.support ? "border-[#dbe6ff] bg-surface-soft" : "border-border bg-white"
                  }`}
                >
                  <p className={`text-xs font-semibold ${m.support ? "text-primary" : "text-muted"}`}>
                    {m.support ?? "You"} · {m.time}
                  </p>
                  <p className="mt-1.5 text-sm leading-[1.6] text-navy">{m.body}</p>
                </div>
              </div>
            ))}
          </div>
          <form
            onSubmit={(e) => {
              e.preventDefault();
              sendReply();
            }}
            className="flex gap-2.5 border-t border-border px-6 py-4"
          >
            <input
              value={reply}
              onChange={(e) => setReply(e.target.value)}
              placeholder="Write a reply…"
              className={`h-11 min-w-0 flex-1 text-sm ${field}`}
            />
            <button
              type="submit"
              className="h-11 rounded-lg bg-primary px-[18px] text-sm font-semibold text-white hover:bg-primary-dark"
            >
              Reply
            </button>
          </form>
        </section>
      ) : null}
    </div>
  );
}
