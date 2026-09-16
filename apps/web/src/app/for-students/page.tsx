import { ButtonLink } from "@/components/ButtonLink";

const steps = [
  {
    title: "Create your profile",
    body: "Login with mobile OTP and select your class, medium and stream.",
  },
  {
    title: "Choose a course",
    body: "Browse complete batches or subject courses. Bihar Board is available now.",
  },
  {
    title: "Learn every day",
    body: "Join live classes, watch recordings, download notes and follow your calendar.",
  },
];

export const metadata = {
  title: "For Students",
  description: "How students learn at Akhand Bharat Academy.",
};

export default function ForStudentsPage() {
  return (
    <div className="mx-auto max-w-6xl px-4 py-14 sm:px-6">
      <div className="max-w-2xl">
        <p className="text-sm font-semibold uppercase tracking-[0.14em] text-primary">
          For students
        </p>
        <h1 className="mt-3 font-display text-4xl font-semibold tracking-tight">
          A calm path from login to lesson
        </h1>
        <p className="mt-4 text-muted">
          No marketplace clutter. Just your classes, your progress and what to
          study next.
        </p>
      </div>

      <ol className="mt-12 grid gap-8 md:grid-cols-3">
        {steps.map((step, index) => (
          <li key={step.title} className="relative">
            <p className="font-display text-4xl font-semibold text-primary/20">
              0{index + 1}
            </p>
            <h2 className="mt-2 text-xl font-semibold">{step.title}</h2>
            <p className="mt-2 text-sm leading-relaxed text-muted">{step.body}</p>
          </li>
        ))}
      </ol>

      <div className="mt-14 rounded-2xl border border-border bg-surface px-6 py-8">
        <h2 className="font-display text-2xl font-semibold">
          What you get in every course
        </h2>
        <ul className="mt-4 grid gap-3 text-sm text-muted sm:grid-cols-2">
          <li>✓ Live class schedule with reminders</li>
          <li>✓ Recordings attached to each chapter</li>
          <li>✓ PDF notes with secure downloads</li>
          <li>✓ Continue-learning from last position</li>
        </ul>
        <div className="mt-6">
          <ButtonLink href="/courses">Browse courses</ButtonLink>
        </div>
      </div>
    </div>
  );
}
