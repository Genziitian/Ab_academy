export const metadata = {
  title: "About",
  description:
    "About Akhand Bharat Academy — starting with Bihar Board, expanding to more domains soon.",
};

export default function AboutPage() {
  return (
    <div className="mx-auto max-w-3xl px-4 py-10 sm:px-6 sm:py-14">
      <p className="text-sm font-semibold uppercase tracking-[0.14em] text-primary">
        About us
      </p>
      <h1 className="mt-3 font-display text-3xl font-semibold tracking-tight sm:text-4xl">
        Akhand Bharat Academy
      </h1>
      <div className="mt-8 space-y-5 text-base leading-relaxed text-muted">
        <p>
          Akhand Bharat Academy is an online learning platform built for clarity
          — live classes, recordings and notes so every student knows what to
          study next.
        </p>
        <p>
          We are starting with Bihar Board Classes 9–12. More boards, competitive
          and domain courses will launch soon under the same academy.
        </p>
        <p className="font-hindi text-foreground/90">
          हमारा लक्ष्य है कि हर छात्र को यह स्पष्ट रहे कि आगे क्या पढ़ना है —
          बिना भ्रमित करने वाले ऐप अनुभव के।
        </p>
        <p>
          Hindi and English medium learners both get a simple path: pick your
          class, join live, revise with recordings, and track progress.
        </p>
      </div>
    </div>
  );
}
