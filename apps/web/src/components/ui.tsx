// Building blocks for the "calm classroom" look. Plain server components and
// class strings, so they work on any page without client JavaScript.

export const btn = {
  primary:
    "inline-flex h-11 items-center justify-center gap-2 whitespace-nowrap rounded-[10px] bg-ab-ink px-5 text-[15px] font-medium text-white transition-colors hover:bg-black disabled:cursor-not-allowed disabled:opacity-60",
  secondary:
    "inline-flex h-11 items-center justify-center gap-2 whitespace-nowrap rounded-[10px] border border-ab-rule-strong bg-ab-panel px-5 text-[15px] font-medium text-ab-ink transition-colors hover:border-ab-ink disabled:opacity-60",
  ghost:
    "inline-flex h-11 items-center justify-center gap-2 whitespace-nowrap rounded-[10px] px-4 text-[15px] font-medium text-ab-ink-2 transition-colors hover:bg-ab-tray hover:text-ab-ink",
  /** Bigger hit area for the main call to action on a page. */
  lg: "!h-12 !px-6 !text-base",
  link: "inline-flex items-center gap-1.5 text-[15px] font-medium text-ab-ink underline decoration-ab-rule-strong decoration-1 underline-offset-4 hover:decoration-ab-ink",
};

export const field =
  "mt-1.5 block h-11 w-full rounded-[10px] border border-ab-rule-strong bg-ab-panel px-3.5 text-[15px] font-normal text-ab-ink outline-none transition-colors placeholder:text-ab-ink-3 focus:border-ab-ink";

export const label = "block text-sm font-medium text-ab-ink";

export function Panel({
  children,
  className = "",
  as: Tag = "div",
}: {
  children: React.ReactNode;
  className?: string;
  as?: "div" | "section" | "article" | "aside" | "form" | "ul";
}) {
  return <Tag className={`rounded-2xl border border-ab-rule bg-ab-panel ${className}`}>{children}</Tag>;
}

/**
 * A grey tray with a label row and a white card inside it — the stat tile of
 * the dashboard. `aside` sits at the right of the label row.
 */
export function Tray({
  label,
  aside,
  children,
  className = "",
  inner = "",
}: {
  label: React.ReactNode;
  aside?: React.ReactNode;
  children: React.ReactNode;
  className?: string;
  inner?: string;
}) {
  return (
    <div className={`flex flex-col rounded-[20px] bg-ab-tray p-1.5 ${className}`}>
      <div className="flex items-center justify-between gap-3 px-3 pb-2 pt-1.5 text-sm text-ab-ink-2">
        <span>{label}</span>
        {aside ? <span className="text-ab-ink-3">{aside}</span> : null}
      </div>
      <div className={`flex flex-1 flex-col rounded-[14px] border border-ab-rule bg-ab-panel p-4 sm:p-5 ${inner}`}>{children}</div>
    </div>
  );
}

export function Eyebrow({ children, className = "" }: { children: React.ReactNode; className?: string }) {
  return <p className={`ab-eyebrow ${className}`}>{children}</p>;
}

/** Eyebrow, heading and an optional lead paragraph. */
export function SectionHead({
  eyebrow,
  title,
  lead,
  id,
  className = "",
  tone = "dark",
}: {
  eyebrow?: React.ReactNode;
  title: React.ReactNode;
  lead?: React.ReactNode;
  id?: string;
  className?: string;
  tone?: "dark" | "light";
}) {
  return (
    <div className={className}>
      {eyebrow ? <Eyebrow className={tone === "light" ? "!text-white/55" : ""}>{eyebrow}</Eyebrow> : null}
      <h2 id={id} className="ab-display mt-3 text-[34px] sm:text-[44px] lg:text-[52px]">
        {title}
      </h2>
      {lead ? (
        <p className={`mt-4 max-w-[560px] text-[17px] leading-[1.6] ${tone === "light" ? "text-white/70" : "text-ab-ink-2"}`}>
          {lead}
        </p>
      ) : null}
    </div>
  );
}

export function Arrow({ size = 14, className = "" }: { size?: number; className?: string }) {
  return (
    <svg width={size} height={size} viewBox="0 0 16 16" fill="none" aria-hidden className={`shrink-0 ${className}`}>
      <path d="M3 8h10M9 4l4 4-4 4" stroke="currentColor" strokeWidth="1.6" strokeLinecap="round" strokeLinejoin="round" />
    </svg>
  );
}

export function Check({ size = 16, className = "" }: { size?: number; className?: string }) {
  return (
    <svg width={size} height={size} viewBox="0 0 16 16" fill="none" aria-hidden className={`shrink-0 ${className}`}>
      <path d="M3.5 8.4 6.4 11.2 12.5 5" stroke="currentColor" strokeWidth="1.7" strokeLinecap="round" strokeLinejoin="round" />
    </svg>
  );
}

/** Small status pill. "live" pulses its dot. */
export function Pill({
  children,
  tone = "neutral",
  className = "",
}: {
  children: React.ReactNode;
  tone?: "neutral" | "live" | "accent" | "danger" | "ink";
  className?: string;
}) {
  const tones = {
    neutral: "border-ab-rule bg-ab-canvas text-ab-ink-2",
    live: "border-[#cfe5d7] bg-ab-live-soft text-ab-live",
    accent: "border-[#f3d5c2] bg-ab-accent-soft text-ab-accent-ink",
    danger: "border-[#f3cdc8] bg-ab-danger-soft text-ab-danger",
    ink: "border-ab-ink bg-ab-ink text-white",
  }[tone];
  return (
    <span className={`inline-flex h-7 items-center gap-1.5 whitespace-nowrap rounded-full border px-2.5 text-[13px] font-medium ${tones} ${className}`}>
      {tone === "live" ? <span className="size-1.5 animate-pulse rounded-full bg-ab-live" /> : null}
      {children}
    </span>
  );
}

/** Two-letter avatar in ink. */
export function Initials({ text, size = 40, className = "" }: { text: string; size?: number; className?: string }) {
  return (
    <span
      className={`flex shrink-0 items-center justify-center rounded-full bg-ab-ink font-medium text-white ${className}`}
      style={{ width: size, height: size, fontSize: Math.round(size * 0.36) }}
      aria-hidden
    >
      {text}
    </span>
  );
}
