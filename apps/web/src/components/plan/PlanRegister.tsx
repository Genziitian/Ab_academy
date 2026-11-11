import { Pill } from "@/components/ui";
import { CRASH_COURSE_DAYS } from "@/lib/courses";
import { formatDate, type Locale } from "@/lib/i18n/config";
import type { Dict } from "@/lib/i18n/dictionaries";

const DAY = 864e5;
const PLAN_DAYS = CRASH_COURSE_DAYS;
const PHASES = 3;
const PHASE = PLAN_DAYS / PHASES;

/** Where today falls in the plan: 0 before it starts, PLAN_DAYS + 1 after it ends. */
export function planDay(start: Date, now: number) {
  if (now < start.getTime()) return 0;
  return Math.min(PLAN_DAYS + 1, Math.floor((now - start.getTime()) / DAY) + 1);
}

export function daysUntil(target: Date, now: number) {
  return Math.max(0, Math.ceil((target.getTime() - now) / DAY));
}

/**
 * The board plan drawn as a register: three phases (concepts, practice,
 * revision), one cell per day, filled up to today. Real dates only — it never
 * pretends to know a student's attendance.
 *
 * "hero" is the lighter version for the home page: no legend, dates on one line.
 */
export function PlanRegister({
  start,
  exam,
  now,
  t,
  locale,
  title,
  compact = false,
  variant = "full",
}: {
  start: Date;
  exam: Date;
  now: number;
  t: Dict;
  locale: Locale;
  title?: string;
  compact?: boolean;
  variant?: "full" | "hero";
}) {
  const p = t.plan;
  const day = planDay(start, now);
  const toStart = daysUntil(start, now);
  const toExam = daysUntil(exam, now);
  const hero = variant === "hero";
  const date = (d: Date) => formatDate(d, locale, { day: "numeric", month: "short", year: "numeric" });

  const status =
    day === 0 ? (
      <Pill tone="accent">{p.startsIn(toStart)}</Pill>
    ) : day > PLAN_DAYS ? (
      <Pill tone="neutral">{p.done}</Pill>
    ) : (
      <Pill tone="live">{p.dayOf(day)}</Pill>
    );

  const summary = day === 0 ? p.startsIn(toStart) : day > PLAN_DAYS ? p.done : p.dayOf(day);

  return (
    <div className={`flex flex-col rounded-[22px] bg-ab-tray p-1.5 ${hero ? "" : "h-full"}`}>
      <div className="flex items-center justify-between gap-3 px-3 pb-2 pt-1.5">
        <span className="text-sm text-ab-ink-2">{title ?? p.title}</span>
        {status}
      </div>

      <div className={`flex flex-1 flex-col rounded-[16px] border border-ab-rule bg-ab-panel ${hero ? "p-5 sm:p-7" : "p-4 sm:p-6"}`}>
        <div role="img" aria-label={`${title ?? p.title}: ${summary}`} className="grid grid-cols-3 gap-4 sm:gap-6">
          {Array.from({ length: PHASES }, (_, phase) => (
            <div key={phase}>
              <div className="grid grid-cols-5 gap-[5px] sm:gap-1.5">
                {Array.from({ length: PHASE }, (_, i) => {
                  const d = phase * PHASE + i + 1;
                  const cls =
                    d < day ? "bg-ab-ink" : d === day ? "bg-ab-accent ring-2 ring-ab-accent/25" : "border border-ab-rule bg-ab-canvas";
                  return <span key={d} className={`aspect-square rounded-[3px] ${cls}`} />;
                })}
              </div>
              <p className={`mt-3 font-medium text-ab-ink ${compact ? "text-[13px]" : "text-sm"}`}>{p.phases[phase]}</p>
              <p className="ab-num mt-0.5 text-[11px] text-ab-ink-3 sm:text-xs">{p.phaseDays[phase]}</p>
            </div>
          ))}
        </div>

        {hero ? (
          <dl className="mt-7 grid grid-cols-2 gap-4 border-t border-ab-rule pt-5">
            <div>
              <dt className="text-[13px] text-ab-ink-3">{p.classesStart}</dt>
              <dd className="ab-num mt-1 text-[15px] text-ab-ink">{date(start)}</dd>
            </div>
            <div>
              <dt className="text-[13px] text-ab-ink-3">
                {p.boardExam} · {p.expected}
              </dt>
              <dd className="ab-num mt-1 text-[15px] text-ab-ink">{date(exam)}</dd>
              <dd className="mt-0.5 text-[13px] text-ab-accent-ink">{p.daysLeft(toExam)}</dd>
            </div>
          </dl>
        ) : (
          <>
            <div className="mt-5 flex flex-wrap items-center gap-x-4 gap-y-1.5 text-xs text-ab-ink-3">
              {[
                ["bg-ab-ink", p.legendDone],
                ["bg-ab-accent", p.legendToday],
                ["border border-ab-rule bg-ab-canvas", p.legendAhead],
              ].map(([c, l]) => (
                <span key={l} className="inline-flex items-center gap-1.5">
                  <span className={`size-2.5 rounded-[2px] ${c}`} />
                  {l}
                </span>
              ))}
            </div>
            <div className="min-h-6 flex-1" />
            <dl className="grid grid-cols-2 gap-px overflow-hidden rounded-xl border border-ab-rule bg-ab-rule">
              <div className="bg-ab-panel p-4">
                <dt className="text-[13px] text-ab-ink-3">{p.classesStart}</dt>
                <dd className="ab-num mt-1.5 text-[17px] font-medium text-ab-ink sm:text-lg">{date(start)}</dd>
              </div>
              <div className="bg-ab-panel p-4">
                <dt className="text-[13px] text-ab-ink-3">
                  {p.boardExam} <span className="text-ab-ink-3/80">· {p.expected}</span>
                </dt>
                <dd className="ab-num mt-1.5 text-[17px] font-medium text-ab-ink sm:text-lg">{date(exam)}</dd>
                <dd className="mt-0.5 text-[13px] text-ab-accent-ink">{p.daysLeft(toExam)}</dd>
              </div>
            </dl>
          </>
        )}
      </div>
    </div>
  );
}
