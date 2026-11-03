import Link from "next/link";
import { PortalTopbar } from "@/components/portal/PortalTopbar";
import { getStudent } from "@/lib/portal/student";
import { saveProfileAction } from "./actions";

export const metadata = { title: "Profile" };

const field =
  "mt-1.5 h-11 w-full rounded-xl border border-sand bg-white px-3.5 text-[15px] text-coal outline-none focus:border-clay focus:ring-2 focus:ring-clay/15";

export default async function ProfilePage() {
  const student = await getStudent();
  return (
    <>
      <PortalTopbar crumb={student.email ?? student.phone ?? "Your account"} title="Profile" />
      <div className="grid max-w-[1000px] gap-6 px-4 pb-16 pt-6 sm:px-8 lg:grid-cols-[1fr_320px]">
        <form action={saveProfileAction} className="space-y-4 rounded-[22px] border border-sand bg-cream p-6">
          <div className="flex items-center gap-4">
            <span className="flex size-16 items-center justify-center rounded-full bg-clay text-xl font-bold text-white">{student.initials}</span>
            <div>
              <p className="text-lg font-semibold text-coal">{student.name}</p>
              <p className="text-sm text-taupe">{student.summary}</p>
            </div>
          </div>
          <label className="block text-[13px] font-semibold text-coal">
            Full name
            <input name="name" defaultValue={student.name} className={field} />
          </label>
          <div className="grid grid-cols-2 gap-3">
            <label className="block text-[13px] font-semibold text-coal">
              Class
              <select name="classLevel" defaultValue={String(student.classLevel ?? 12)} className={field}>
                {[12, 11, 10, 9].map((c) => (
                  <option key={c} value={c}>
                    Class {c}
                  </option>
                ))}
              </select>
            </label>
            <label className="block text-[13px] font-semibold text-coal">
              Study language
              <select name="medium" defaultValue={student.medium ?? "Hindi"} className={field}>
                <option value="Hindi">Hindi</option>
                <option value="Hinglish">Hinglish</option>
              </select>
            </label>
          </div>
          <button type="submit" className="h-12 rounded-full bg-clay px-7 text-[15px] font-semibold text-white hover:bg-coal">
            Save changes
          </button>
        </form>

        <div className="flex h-fit flex-col gap-1 rounded-[22px] border border-sand bg-cream p-3">
          {[
            ["/support", "Help & support"],
            ["/privacy", "Privacy policy"],
            ["/terms", "Terms & conditions"],
            ["/refund", "Refund policy"],
            ["/data-deletion", "Delete my account or data"],
          ].map(([href, label]) => (
            <Link key={href} href={href} className="flex justify-between rounded-xl px-3 py-3 font-medium text-coal hover:bg-paper">
              {label}
              <span className="text-taupe">→</span>
            </Link>
          ))}
          <form action="/auth/signout" method="post">
            <button type="submit" className="w-full rounded-xl px-3 py-3 text-left font-semibold text-[#b23a26] hover:bg-[#fdf1f1]">
              Sign out
            </button>
          </form>
        </div>
      </div>
    </>
  );
}
