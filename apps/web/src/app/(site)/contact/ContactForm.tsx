"use client";

import { useState } from "react";
import { btn, field, label } from "@/components/ui";
import { useT } from "@/lib/i18n/client";
import { CONTACT } from "@/lib/landing";

/**
 * Visitors are not signed in, so they cannot open a support ticket (tickets
 * are tied to a profile by RLS). The form composes an email to support
 * instead; enrolled students are pointed at tickets in the portal.
 */
export function ContactForm() {
  const t = useT();
  const c = t.contact;
  const [sent, setSent] = useState(false);

  function onSubmit(event: React.FormEvent<HTMLFormElement>) {
    event.preventDefault();
    const data = new FormData(event.currentTarget);
    const subject = `[${data.get("topic")}] ${data.get("name")}`;
    const body = `${data.get("message")}\n\n— ${data.get("name")}, ${data.get("phone")}`;
    window.location.href = `mailto:${CONTACT.email}?subject=${encodeURIComponent(subject)}&body=${encodeURIComponent(body)}`;
    setSent(true);
  }

  return (
    <form onSubmit={onSubmit} className="flex flex-col gap-5 rounded-[22px] border border-ab-rule bg-ab-panel p-6 sm:p-8">
      <h2 className="ab-title text-[22px]">{c.formTitle}</h2>
      <label className={label}>
        {c.name}
        <input name="name" required placeholder={c.namePh} className={field} />
      </label>
      <label className={label}>
        {c.reach}
        <input name="phone" required placeholder={c.reachPh} className={field} />
      </label>
      <label className={label}>
        {c.topic}
        <select name="topic" className={field}>
          {c.topics.map((topic) => (
            <option key={topic}>{topic}</option>
          ))}
        </select>
      </label>
      <label className={label}>
        {c.message}
        <textarea name="message" required rows={4} placeholder={c.messagePh} className={`${field} h-auto resize-y py-2.5`} />
      </label>
      <button type="submit" className={`${btn.primary} ${btn.lg}`}>
        {c.send}
      </button>
      {sent ? <p className="text-[13px] text-ab-ink-2">{c.sent(CONTACT.email)}</p> : null}
    </form>
  );
}
