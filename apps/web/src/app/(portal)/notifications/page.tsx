import { PortalTopbar } from "@/components/portal/PortalTopbar";
import { notifications } from "@/lib/portal/data";
import { NotificationList } from "./NotificationList";

export const metadata = { title: "Notifications" };

export default function NotificationsPage() {
  return (
    <>
      <PortalTopbar title="Notifications" />
      <NotificationList items={notifications} />
    </>
  );
}
