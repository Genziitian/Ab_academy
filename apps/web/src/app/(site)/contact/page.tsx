export const metadata = {
  title: "Contact",
  description: "Contact Akhand Bharat Academy support.",
};

export default function ContactPage() {
  return (
    <div className="mx-auto max-w-6xl px-4 py-14 sm:px-6">
      <div className="grid gap-10 lg:grid-cols-2">
        <div>
          <p className="text-sm font-semibold uppercase tracking-[0.14em] text-primary">
            Contact
          </p>
          <h1 className="mt-3 font-display text-4xl font-semibold tracking-tight">
            We&apos;re here to help
          </h1>
          <p className="mt-4 text-muted">
            Questions about courses, payments or live classes? Reach the support
            team — OTP login and tickets will connect here in a later phase.
          </p>
          <dl className="mt-8 space-y-4 text-sm">
            <div>
              <dt className="font-semibold text-foreground">Email</dt>
              <dd className="mt-1 text-muted">support@akhandbharatacademy.in</dd>
            </div>
            <div>
              <dt className="font-semibold text-foreground">WhatsApp</dt>
              <dd className="mt-1 text-muted">+91 90000 00000 (placeholder)</dd>
            </div>
            <div>
              <dt className="font-semibold text-foreground">Hours</dt>
              <dd className="mt-1 text-muted">Mon–Sat, 9:00 AM – 7:00 PM IST</dd>
            </div>
          </dl>
        </div>

        <form className="rounded-2xl border border-border bg-surface p-6 shadow-[var(--shadow-soft)]">
          <label className="block text-sm font-medium">
            Full name
            <input
              type="text"
              name="name"
              className="mt-2 w-full rounded-xl border border-border bg-background px-3 py-2.5 outline-none focus:border-primary"
              placeholder="Rahul Kumar"
            />
          </label>
          <label className="mt-4 block text-sm font-medium">
            Mobile number
            <input
              type="tel"
              name="phone"
              className="mt-2 w-full rounded-xl border border-border bg-background px-3 py-2.5 outline-none focus:border-primary"
              placeholder="98765 43210"
            />
          </label>
          <label className="mt-4 block text-sm font-medium">
            Message
            <textarea
              name="message"
              rows={4}
              className="mt-2 w-full rounded-xl border border-border bg-background px-3 py-2.5 outline-none focus:border-primary"
              placeholder="How can we help?"
            />
          </label>
          <button
            type="button"
            className="mt-6 inline-flex w-full items-center justify-center rounded-xl bg-primary px-5 py-3 text-sm font-semibold text-white hover:bg-primary-dark"
          >
            Send message
          </button>
          <p className="mt-3 text-xs text-muted">
            Form submit will be wired to backend in a later phase.
          </p>
        </form>
      </div>
    </div>
  );
}
