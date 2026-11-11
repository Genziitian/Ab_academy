import { PortalTopbar } from "@/components/portal/PortalTopbar";
import { Pill } from "@/components/ui";
import { formatDate, formatTime } from "@/lib/i18n/config";
import { getT } from "@/lib/i18n/server";
import { BATCH_START, batchStarted } from "@/lib/landing";
import { getUpcomingClasses } from "@/lib/portal/live";

export const metadata = { title: "Live classes" };

export default async function LivePage() {
  const [classes, { t, locale }] = await Promise.all([getUpcomingClasses(20), getT()]);
  const p = t.portal;
  const started = batchStarted();

  return (
    <>
      <PortalTopbar title={p.live} lead={p.liveLead} />
      <div className="px-4 pb-16 pt-5 sm:px-8">
        {classes.length ? (
          <ul className="overflow-hidden rounded-2xl border border-ab-rule">
            {classes.map((c) => (
              <li key={c.id} className="grid grid-cols-[88px_1fr] items-center gap-4 border-b border-ab-rule px-5 py-4 last:border-b-0 sm:grid-cols-[120px_1fr_auto]">
                <span className="ab-num text-sm leading-[1.45] text-ab-ink-2">
                  {formatDate(c.startsAt, locale, { weekday: "short", day: "numeric", month: "short" })}
                  <br />
                  <span className="text-ab-ink">{formatTime(c.startsAt, locale)}</span>
                </span>
                <span className="min-w-0">
                  <span className="block font-medium text-ab-ink">{c.title}</span>
                  <span className="text-sm text-ab-ink-3">{c.course}</span>
                </span>
                <span className="col-start-2 sm:col-start-auto">
                  {c.status === "LIVE" ? <Pill tone="live">{p.liveNow}</Pill> : <Pill>{p.scheduledTag}</Pill>}
                </span>
              </li>
            ))}
          </ul>
        ) : (
          <div className="rounded-[22px] bg-ab-tray p-1.5">
            <div className="rounded-[16px] border border-ab-rule bg-ab-panel px-6 py-14 text-center">
              <Pill className="mx-auto">{p.live}</Pill>
              <p className="ab-title mt-5 text-[28px] sm:text-[34px]">
                {started ? p.liveEmptyStarted : p.liveEmptyStarts(formatDate(BATCH_START, locale, { day: "numeric", month: "long" }))}
              </p>
              <p className="mx-auto mt-3 max-w-[460px] text-[15px] leading-[1.6] text-ab-ink-2">{p.liveEmptyBody}</p>
            </div>
          </div>
        )}
      </div>
    </>
  );
}
