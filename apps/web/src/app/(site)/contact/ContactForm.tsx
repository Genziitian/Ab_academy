"use client";

import { useState } from "react";

const SUPPORT_EMAIL = "support@akhandbharatacademy.in";
const topics = [
  "Course & batch selection",
  "Payment",
  "Live classes",
  "Refund / Grievance",
];

const field =
  "h-11 rounded-lg border border-field px-3 text-[15px] font-normal outline-none focus:border-primary";

/**
 * Visitors are not signed in, so they cannot open a support ticket (tickets
 * are tied to a profile by RLS). The form composes an email to support
 * instead; enrolled students are pointed at tickets in the portal.
 */
export function ContactForm() {
  const [sent, setSent] = useState(false);

  function onSubmit(event: React.FormEvent<HTMLFormElement>) {
    event.preventDefault();
    const data = new FormData(event.currentTarget);
    const subject = `[${data.get("topic")}] ${data.get("name")}`;
    const body = `${data.get("message")}\n\n— ${data.get("name")}, ${data.get("phone")}`;
    window.location.href = `mailto:${SUPPORT_EMAIL}?subject=${encodeURIComponent(subject)}&body=${encodeURIComponent(body)}`;
    setSent(true);
  }

  return (
    <form
      onSubmit={onSubmit}
      className="flex flex-col gap-[18px] rounded-xl border border-border bg-white p-6 shadow-[var(--shadow-card)] sm:p-8"
    >
      <h2 className="text-xl font-semibold text-navy">Send us a message</h2>
      <label className="flex flex-col gap-1.5 text-sm font-medium text-navy">
        Full name
        <input name="name" required placeholder="Rahul Kumar" className={field} />
      </label>
      <label className="flex flex-col gap-1.5 text-sm font-medium text-navy">
        Mobile number
        <input
          name="phone"
          required
          inputMode="tel"
          placeholder="98765 43210"
          className={field}
        />
      </label>
      <label className="flex flex-col gap-1.5 text-sm font-medium text-navy">
        Topic
        <select name="topic" className={`${field} bg-white px-2.5`}>
          {topics.map((topic) => (
            <option key={topic}>{topic}</option>
          ))}
        </select>
      </label>
      <label className="flex flex-col gap-1.5 text-sm font-medium text-navy">
        Message
        <textarea
          name="message"
          required
          rows={4}
          placeholder="How can we help?"
          className="resize-y rounded-lg border border-field px-3 py-2.5 text-[15px] font-normal outline-none focus:border-primary"
        />
      </label>
      <button
        type="submit"
        className="h-12 rounded-lg bg-primary text-[15px] font-semibold text-white hover:bg-primary-dark"
      >
        Send message
      </button>
      {sent ? (
        <p className="text-[13px] text-muted">
          Your email app should open with the message filled in. If it
          doesn&apos;t, write to {SUPPORT_EMAIL}.
        </p>
      ) : null}
    </form>
  );
}
