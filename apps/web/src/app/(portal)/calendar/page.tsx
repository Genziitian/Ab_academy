import { PortalTopbar } from "@/components/portal/PortalTopbar";
import { calendarMarks, todayAgenda } from "@/lib/portal/data";
import { CalendarView } from "./CalendarView";

export const metadata = { title: "Calendar" };

export default function CalendarPage() {
  // Classes run on IST, so "today" is the IST date regardless of server zone.
  const todayIso = new Intl.DateTimeFormat("en-CA", { timeZone: "Asia/Kolkata" }).format(new Date());

  return (
    <>
      <PortalTopbar title="Calendar" />
      <CalendarView todayIso={todayIso} today={todayAgenda} marks={calendarMarks} />
    </>
  );
}
