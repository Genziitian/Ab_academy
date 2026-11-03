// Shared building blocks of the admin console, in the site's Saffron & Ink
// style. The frame itself (sidebar, header) is AdminShell.

export function PageHeader({
  title,
  description,
  action,
}: {
  title: string;
  description?: string;
  action?: React.ReactNode;
}) {
  return (
    <div className="mb-7 flex flex-wrap items-end justify-between gap-4">
      <div>
        <h1 className="font-serif text-[40px] leading-none tracking-[-0.02em] text-coal sm:text-[48px]">{title}</h1>
        {description ? <p className="mt-2 max-w-[640px] text-[15px] text-taupe">{description}</p> : null}
      </div>
      {action}
    </div>
  );
}

export function Card({
  children,
  className = "",
}: {
  children: React.ReactNode;
  className?: string;
}) {
  return (
    <div
      className={`rounded-[22px] border border-sand bg-cream p-5 sm:p-6 ${className}`}
    >
      {children}
    </div>
  );
}

const STATUS_STYLES: Record<string, string> = {
  live: "bg-pink/15 text-pink",
  scheduled: "bg-primary-soft text-primary",
  ended: "bg-surface-soft text-muted",
  open: "bg-orange/15 text-orange",
  in_progress: "bg-primary-soft text-primary",
  resolved: "bg-success/15 text-success",
  closed: "bg-surface-soft text-muted",
  published: "bg-success/15 text-success",
  draft: "bg-surface-soft text-muted",
  paid: "bg-success/15 text-success",
  failed: "bg-pink/15 text-pink",
  refunded: "bg-orange/15 text-orange",
  created: "bg-surface-soft text-muted",
  pending: "bg-surface-soft text-muted",
};

export function Pill({ status, label }: { status: string; label?: string }) {
  return (
    <span
      className={`inline-flex rounded-full px-2.5 py-1 text-xs font-semibold ${
        STATUS_STYLES[status] ?? "bg-surface-soft text-muted"
      }`}
    >
      {label ?? status.replace("_", " ")}
    </span>
  );
}

export function EmptyRow({ children }: { children: React.ReactNode }) {
  return <p className="py-8 text-center text-sm text-muted">{children}</p>;
}
