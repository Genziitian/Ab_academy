import Image from "next/image";
import Link from "next/link";

export const metadata = {
  title: "About",
  description: "About Akhand Bharat Academy — an online learning platform built for clarity.",
};

export default function AboutPage() {
  return (
    <section className="mx-auto grid max-w-[1200px] gap-16 px-4 py-14 sm:px-6 sm:py-[72px] lg:grid-cols-[minmax(0,1fr)_minmax(0,1.2fr)]">
      <div>
        <p className="eyebrow">About us</p>
        <h1 className="mt-3 text-[36px] font-bold leading-[1.1] tracking-[-0.025em] text-navy sm:text-[46px]">
          Akhand Bharat Academy
        </h1>
        <div className="mt-8 aspect-[4/3] overflow-hidden rounded-2xl bg-[#eef3ff]">
          <Image
            src="/images/hero-students.png"
            alt="Students"
            width={800}
            height={600}
            className="size-full object-cover"
          />
        </div>
      </div>
      <div className="flex flex-col gap-[22px] text-lg leading-[1.7] text-ink lg:pt-11">
        <p className="text-[22px] font-medium leading-[1.55] text-navy">
          Akhand Bharat Academy is an online learning platform built for clarity
          — live classes, recordings and notes so every student knows what to
          study next.
        </p>
        <p>
          Our current focus is Class 11 &amp; 12 crash courses for Bihar Board.
          More boards, competitive and domain courses will launch soon under the
          same academy.
        </p>
        <p className="font-hindi rounded-[10px] bg-surface-soft px-6 py-5 text-navy">
          हमारा लक्ष्य है कि हर छात्र को यह स्पष्ट रहे कि आगे क्या पढ़ना है —
          बिना भ्रमित करने वाले ऐप अनुभव के।
        </p>
        <p>
          Hindi and English medium learners both get a simple path: pick your
          class, join live, revise with recordings, and track progress.
        </p>
        <div className="mt-2 flex flex-wrap gap-3">
          <Link
            href="/courses"
            className="flex h-[46px] items-center rounded-lg bg-primary px-[22px] text-[15px] font-semibold text-white hover:bg-primary-dark"
          >
            Explore Courses
          </Link>
          <Link
            href="/contact"
            className="flex h-[46px] items-center rounded-lg border border-primary-line px-[22px] text-[15px] font-semibold text-primary hover:bg-primary-soft"
          >
            Talk to us
          </Link>
        </div>
      </div>
    </section>
  );
}
