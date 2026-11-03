import { PortalTopbar } from "@/components/portal/PortalTopbar";
import { BATCH_START_LABEL, TEACHER, batchStarted } from "@/lib/landing";
import { getUpcomingClasses } from "@/lib/portal/live";

export const metadata = { title: "Live classes" };

const when = (iso: string) =>
  new Date(iso).toLocaleString("en-IN", {
    weekday: "short",
    day: "numeric",
    month: "short",
    hour: "numeric",
    minute: "2-digit",
    timeZone: "Asia/Kolkata",
  });

export default async function LivePage() {
  const classes = await getUpcomingClasses(20);
  const started = batchStarted();

  return (
    <>
      <PortalTopbar crumb="Doubt sessions with your teacher" title="Live classes" />
      <div className="px-4 pb-16 pt-6 sm:px-8">
        {classes.length ? (
          <ul className="divide-y divide-sand overflow-hidden rounded-[22px] border border-sand bg-cream">
            {classes.map((c) => (
              <li key={c.id} className="flex flex-wrap items-center gap-4 px-5 py-4">
                <span className="w-[150px] shrink-0 text-sm font-semibold text-coal">{when(c.startsAt)}</span>
                <span className="min-w-0 flex-1">
                  <span className="block font-semibold text-coal">{c.title}</span>
                  <span className="text-sm text-taupe">{c.course}</span>
                </span>
                {c.status === "LIVE" ? (
                  <span className="rounded-full bg-[#c8321e] px-3 py-1 text-xs font-bold uppercase tracking-[0.08em] text-white">
                    Live now
                  </span>
                ) : (
                  <span className="text-xs font-bold uppercase tracking-[0.08em] text-taupe">Scheduled</span>
                )}
              </li>
            ))}
          </ul>
        ) : (
          <div className="rounded-[26px] bg-coal px-6 py-14 text-center text-cream">
            <p className="text-xs font-bold uppercase tracking-[0.16em] text-saffron">Live doubt classes</p>
            <p className="mt-3 font-serif text-[40px] leading-none sm:text-[56px]">
              {started ? "No live class scheduled yet." : `Classes start ${BATCH_START_LABEL}.`}
            </p>
            <p className="mx-auto mt-4 max-w-[460px] text-mist">
              {TEACHER.name}&apos;s live sessions will be listed here with their date and time. Join them from the AB Academy
              app.
            </p>
          </div>
        )}
      </div>
    </>
  );
}
