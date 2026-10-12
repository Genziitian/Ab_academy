// Small building blocks shared by the student portal pages.

export function Card({
  children,
  className = "",
}: {
  children: React.ReactNode;
  className?: string;
}) {
  return (
    <section className={`rounded-xl border border-border bg-white ${className}`}>{children}</section>
  );
}

export function SectionTitle({
  children,
  className = "mb-3",
}: {
  children: React.ReactNode;
  className?: string;
}) {
  return <h3 className={`text-base font-semibold text-navy ${className}`}>{children}</h3>;
}

export function ProgressBar({
  value,
  className = "h-1.5",
  color = "bg-primary",
}: {
  value: number;
  className?: string;
  color?: string;
}) {
  return (
    <div className={`overflow-hidden rounded-full bg-track ${className}`}>
      <div className={`h-full rounded-full ${color}`} style={{ width: `${value}%` }} />
    </div>
  );
}

/** Underlined tab button used across portal pages. */
export function TabButton({
  active,
  onClick,
  children,
  className = "h-12 px-3.5",
}: {
  active: boolean;
  onClick: () => void;
  children: React.ReactNode;
  className?: string;
}) {
  return (
    <button
      type="button"
      onClick={onClick}
      className={`whitespace-nowrap border-b-2 text-sm ${className} ${
        active
          ? "border-primary font-semibold text-primary"
          : "border-transparent font-medium text-muted hover:text-navy"
      }`}
    >
      {children}
    </button>
  );
}

/** Dark-filled pill used for subject filters. */
export function FilterPill({
  active,
  onClick,
  children,
}: {
  active: boolean;
  onClick: () => void;
  children: React.ReactNode;
}) {
  return (
    <button
      type="button"
      onClick={onClick}
      className={`h-[34px] whitespace-nowrap rounded-lg border px-3.5 text-[13px] font-medium ${
        active
          ? "border-navy bg-navy text-white"
          : "border-border bg-white text-ink hover:border-primary-line"
      }`}
    >
      {children}
    </button>
  );
}

export function Avatar({
  initials,
  size = 32,
  tone = "soft",
  rounded = "full",
}: {
  initials: string;
  size?: number;
  tone?: "soft" | "solid";
  rounded?: "full" | "lg";
}) {
  return (
    <span
      className={`flex shrink-0 items-center justify-center font-semibold ${
        rounded === "full" ? "rounded-full" : "rounded-lg"
      } ${tone === "solid" ? "bg-primary text-white" : "bg-primary-soft text-primary"}`}
      style={{ width: size, height: size, fontSize: size <= 28 ? 10 : size <= 32 ? 11 : 13 }}
    >
      {initials}
    </span>
  );
}

export function TeacherBadge({ small }: { small?: boolean }) {
  return (
    <span
      className={`rounded bg-primary font-bold tracking-[0.05em] text-white ${
        small ? "px-[5px] py-px text-[9px]" : "px-1.5 py-px text-[10px]"
      }`}
    >
      TEACHER
    </span>
  );
}

export function LiveNowBadge() {
  return (
    <span className="inline-flex items-center gap-1.5 whitespace-nowrap rounded bg-pink/[0.18] px-2.5 py-1 text-xs font-bold tracking-[0.06em] text-[#ff8fb0]">
      <span className="size-[7px] rounded-full bg-pink" />
      LIVE NOW
    </span>
  );
}
