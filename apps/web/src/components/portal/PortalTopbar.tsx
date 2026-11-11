/** Page header inside the portal frame: optional crumb, title, lead and actions. */
export function PortalTopbar({
  title,
  crumb,
  lead,
  actions,
}: {
  title: React.ReactNode;
  crumb?: React.ReactNode;
  lead?: React.ReactNode;
  actions?: React.ReactNode;
}) {
  return (
    <header className="flex flex-wrap items-end justify-between gap-x-6 gap-y-4 px-4 pb-2 pt-7 sm:px-8 lg:pt-9">
      <div className="min-w-0">
        {crumb ? <div className="mb-2 truncate text-sm text-ab-ink-2">{crumb}</div> : null}
        <h1 className="ab-title text-[28px] sm:text-[32px]">{title}</h1>
        {lead ? <p className="mt-1.5 text-[15px] text-ab-ink-2">{lead}</p> : null}
      </div>
      {actions ? <div className="flex shrink-0 items-center gap-2">{actions}</div> : null}
    </header>
  );
}
