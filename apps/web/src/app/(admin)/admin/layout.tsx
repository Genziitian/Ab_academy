import { AdminShell } from "@/components/admin/AdminShell";
import { isDemoMode, requireAdmin } from "@/lib/admin/auth";

export default async function AdminLayout({ children }: { children: React.ReactNode }) {
  const admin = await requireAdmin();
  return (
    <AdminShell role={admin.role} name={admin.name} demo={isDemoMode()}>
      {children}
    </AdminShell>
  );
}
