import Image from "next/image";
import Link from "next/link";
import { Check, Eyebrow, btn } from "@/components/ui";
import { getT } from "@/lib/i18n/server";

export const metadata = {
  title: "For Students",
  description: "How learning works at AB Academy.",
};

export default async function ForStudentsPage() {
  const { t } = await getT();
  const f = t.forStudents;
  const container = "mx-auto max-w-[1280px] px-4 sm:px-6 lg:px-10";
  return (
    <>
      <section className={`${container} grid items-center gap-12 py-14 lg:grid-cols-2 lg:py-20`}>
        <div>
          <Eyebrow>{f.eyebrow}</Eyebrow>
          <h1 className="ab-display mt-4 text-[38px] sm:text-[52px]">{f.title}</h1>
          <p className="mt-5 max-w-[480px] text-lg leading-[1.6] text-ab-ink-2">{f.lead}</p>
          <div className="mt-8 flex flex-wrap gap-3">
            <Link href="/login" className={btn.primary}>
              {f.create}
            </Link>
            <Link href="/courses" className={btn.secondary}>
              {f.browse}
            </Link>
          </div>
        </div>
        <div className="relative aspect-[4/3] overflow-hidden rounded-2xl bg-ab-tray">
          <Image src="/images/feature-live-class.png" alt={f.photoAlt} fill sizes="(min-width: 1024px) 600px, 100vw" className="object-cover" />
        </div>
      </section>

      <section className="border-y border-ab-rule bg-ab-panel">
        <div className={`${container} py-16`}>
          <h2 className="ab-title text-[28px]">{f.howTitle}</h2>
          <ol className="mt-8 grid gap-px overflow-hidden rounded-2xl border border-ab-rule bg-ab-rule md:grid-cols-3">
            {f.steps.map(([title, body], i) => (
              <li key={title} className="bg-ab-panel p-7">
                <p className="ab-num text-sm text-ab-ink-3">{String(i + 1).padStart(2, "0")}</p>
                <h3 className="ab-title mt-6 text-xl">{title}</h3>
                <p className="mt-2 text-[15px] leading-[1.6] text-ab-ink-2">{body}</p>
              </li>
            ))}
          </ol>
        </div>
      </section>

      <section className={`${container} grid gap-10 py-16 lg:grid-cols-[320px_minmax(0,1fr)] lg:py-20`}>
        <div>
          <h2 className="ab-title text-[28px]">{f.includedTitle}</h2>
          <Link href="/courses" className={`${btn.primary} mt-6`}>
            {f.browse}
          </Link>
        </div>
        <ul className="grid gap-px overflow-hidden rounded-2xl border border-ab-rule bg-ab-rule sm:grid-cols-2">
          {f.included.map((item) => (
            <li key={item} className="flex items-center gap-3 bg-ab-panel p-5 text-[15px] text-ab-ink">
              <Check className="text-ab-accent" />
              {item}
            </li>
          ))}
        </ul>
      </section>
    </>
  );
}
