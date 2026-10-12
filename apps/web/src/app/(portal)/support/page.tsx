import { PortalTopbar } from "@/components/portal/PortalTopbar";
import { tickets } from "@/lib/portal/data";
import { SupportDesk } from "./SupportDesk";

export const metadata = { title: "Help & Support" };

export default function SupportPage() {
  return (
    <>
      <PortalTopbar title="Help & Support" />
      <SupportDesk initial={tickets} />
    </>
  );
}
