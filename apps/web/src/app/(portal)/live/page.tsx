import Link from "next/link";
import { PortalTopbar } from "@/components/portal/PortalTopbar";
import { LiveNowBadge } from "@/components/portal/ui";
import { liveNow, nextUp, pastSessions, upcomingSessions } from "@/lib/portal/data";
import { NextUpCard, SessionTabs } from "./LiveSessions";

export const metadata = { title: "Live Classes" };

export default function LiveClassesPage() {
  return (
    <>
      <PortalTopbar title="Live Classes" />
      <div className="flex max-w-[1280px] flex-col gap-7 px-4 pb-12 pt-7 sm:px-8">
        <section className="grid gap-5 [grid-template-columns:repeat(auto-fit,minmax(300px,1fr))]">
          <div className="flex flex-col rounded-xl bg-navy p-7 text-white">
            <span className="self-start">
              <LiveNowBadge />
            </span>
            <p className="mt-5 text-[13px] text-[#9fb8ff]">{liveNow.chapter}</p>
            <h2 className="mt-1.5 text-[26px] font-bold tracking-[-0.02em] sm:text-[28px]">
              {liveNow.title}
            </h2>
            <p className="mt-2.5 text-sm text-[#c8d1e4]">
              {liveNow.teacher} · {liveNow.time} · {liveNow.students} students enrolled
            </p>
            <div className="mt-auto flex gap-2.5 pt-6">
              <Link
                href="/live/classroom"
                className="flex h-[46px] items-center rounded-lg bg-white px-5 text-[15px] font-semibold text-navy hover:bg-primary-soft"
              >
                Join Live Class →
              </Link>
            </div>
          </div>
          <NextUpCard {...nextUp} />
        </section>

        <SessionTabs upcoming={upcomingSessions} past={pastSessions} />
      </div>
    </>
  );
}
