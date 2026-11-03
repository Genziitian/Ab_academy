import { redirect } from "next/navigation";

// Live classes are listed in the student portal and joined from the app.
export default function ClassroomPage() {
  redirect("/live");
}
