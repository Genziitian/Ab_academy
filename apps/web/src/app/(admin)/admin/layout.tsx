import { AdminSidebar, DemoBanner } from "@/components/admin/AdminChrome";
import { isDemoMode, requireAdmin } from "@/lib/admin/auth";

export default async function AdminLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  const admin = await requireAdmin();
  const demo = isDemoMode();

  return (
    <div className="flex min-h-screen flex-col md:flex-row">
      <AdminSidebar />
      <div className="flex min-w-0 flex-1 flex-col">
        {demo ? <DemoBanner /> : null}
        <header className="flex items-center justify-end gap-3 border-b border-border bg-surface px-6 py-3">
          <div className="text-right">
            <p className="text-sm font-medium text-navy">{admin.name}</p>
            <p className="text-xs text-muted">{admin.role.replace("_", " ")}</p>
          </div>
          <div className="grid size-9 place-items-center rounded-full bg-primary-soft text-sm font-semibold text-primary">
            {admin.name
              .split(" ")
              .map((part) => part[0])
              .join("")
              .slice(0, 2)
              .toUpperCase()}
          </div>
          {demo ? null : (
            <form action="/auth/signout" method="post">
              <button
                type="submit"
                className="rounded-lg border border-border px-3 py-1.5 text-xs font-medium text-muted transition-colors hover:bg-surface-soft hover:text-navy"
              >
                Sign out
              </button>
            </form>
          )}
        </header>
        <main className="min-w-0 flex-1 p-6">{children}</main>
      </div>
    </div>
  );
}
