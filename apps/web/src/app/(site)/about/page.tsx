import Image from "next/image";
import Link from "next/link";
import { Eyebrow, btn } from "@/components/ui";
import { getT } from "@/lib/i18n/server";

export const metadata = {
  title: "About",
  description: "About AB Academy (Akhand Bharat Academy) — Class 12 crash courses for Bihar Board.",
};

export default async function AboutPage() {
  const { t } = await getT();
  const a = t.about;
  return (
    <section className="mx-auto grid max-w-[1280px] gap-12 px-4 py-14 sm:px-6 lg:grid-cols-[minmax(0,1fr)_minmax(0,1.15fr)] lg:gap-16 lg:px-10 lg:py-20">
      <div>
        <Eyebrow>{a.eyebrow}</Eyebrow>
        <h1 className="ab-display mt-4 text-[38px] sm:text-[52px]">{a.title}</h1>
        <div className="relative mt-10 aspect-[4/3] overflow-hidden rounded-2xl bg-ab-tray">
          <Image src="/images/hero-students.png" alt={a.photoAlt} fill sizes="(min-width: 1024px) 560px, 100vw" className="object-cover" />
        </div>
      </div>
      <div className="flex flex-col gap-6 text-[17px] leading-[1.7] text-ab-ink-2 lg:pt-14">
        <p className="text-[21px] leading-[1.55] text-ab-ink">{a.lead}</p>
        <p>{a.p1}</p>
        <blockquote className="border-l-2 border-ab-accent py-1 pl-5 text-lg text-ab-ink" lang="hi">
          {a.quote}
        </blockquote>
        <p>{a.p2}</p>
        <div className="mt-2 flex flex-wrap gap-3">
          <Link href="/courses" className={btn.primary}>
            {a.explore}
          </Link>
          <Link href="/contact" className={btn.secondary}>
            {a.talk}
          </Link>
        </div>
      </div>
    </section>
  );
}
