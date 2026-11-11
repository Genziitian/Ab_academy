import Link from "next/link";
import { LanguageSwitch } from "@/components/LanguageSwitch";
import { LEGAL_DOCS } from "@/lib/legal-docs";
import { PortalTopbar } from "@/components/portal/PortalTopbar";
import { Arrow, Initials, btn, field, label } from "@/components/ui";
import { getT } from "@/lib/i18n/server";
import { getStudent } from "@/lib/portal/student";
import { saveProfileAction } from "./actions";

export const metadata = { title: "Profile" };

export default async function ProfilePage() {
  const [student, { t }] = await Promise.all([getStudent(), getT()]);
  const p = t.portal;
  const summary = [student.classLevel ? t.common.classN(student.classLevel) : null, t.common.board].filter(Boolean).join(" · ");
  const links = [
    ["/support", p.support],
    ...LEGAL_DOCS.filter((d) => d.key !== "deletion").map((d) => [d.href, t.legalDocs[d.key]]),
  ];

  return (
    <>
      <PortalTopbar title={p.profile} lead={student.email ?? student.phone ?? p.profileLead} />
      <div className="grid max-w-[1040px] gap-5 px-4 pb-16 pt-5 sm:px-8 lg:grid-cols-[1fr_320px]">
        <div className="flex flex-col gap-5">
          <form action={saveProfileAction} className="rounded-2xl border border-ab-rule p-6">
            <div className="flex items-center gap-4">
              <Initials text={student.initials} size={56} />
              <div>
                <p className="text-lg font-medium text-ab-ink">{student.name}</p>
                <p className="text-sm text-ab-ink-3">{summary}</p>
              </div>
            </div>
            <div className="mt-6 flex flex-col gap-4 border-t border-ab-rule pt-6">
              <label className={label}>
                {p.fullName}
                <input name="name" defaultValue={student.name} className={field} />
              </label>
              <div className="grid grid-cols-2 gap-3">
                <label className={label}>
                  {p.classLabel}
                  <select name="classLevel" defaultValue={String(student.classLevel ?? 12)} className={field}>
                    {[12, 11, 10, 9].map((c) => (
                      <option key={c} value={c}>
                        {t.common.classN(c)}
                      </option>
                    ))}
                  </select>
                </label>
                <label className={label}>
                  {p.studyLanguage}
                  <select name="medium" defaultValue={student.medium ?? "Hindi"} className={field}>
                    <option value="Hindi">{t.common.hindi}</option>
                    <option value="Hinglish">{t.common.hinglish}</option>
                  </select>
                </label>
              </div>
              <button type="submit" className={`${btn.primary} w-fit`}>
                {p.save}
              </button>
            </div>
          </form>

          <div className="flex flex-wrap items-center justify-between gap-4 rounded-2xl border border-ab-rule p-6">
            <div>
              <p className="font-medium text-ab-ink">{p.siteLanguage}</p>
              <p className="mt-0.5 text-sm text-ab-ink-3">{p.siteLanguageHint}</p>
            </div>
            <LanguageSwitch />
          </div>
        </div>

        <div className="h-fit rounded-[20px] bg-ab-tray p-1.5">
          <div className="overflow-hidden rounded-[14px] border border-ab-rule bg-ab-panel">
            {links.map(([href, text]) => (
              <Link key={href} href={href} className="flex items-center justify-between border-b border-ab-rule px-4 py-3.5 text-[15px] text-ab-ink hover:bg-ab-canvas">
                {text}
                <Arrow className="text-ab-ink-3" />
              </Link>
            ))}
            <Link href="/data-deletion" className="flex items-center justify-between border-b border-ab-rule px-4 py-3.5 text-[15px] text-ab-danger hover:bg-ab-danger-soft">
              {p.deleteAccount}
              <Arrow />
            </Link>
            <form action="/auth/signout" method="post">
              <button type="submit" className="w-full px-4 py-3.5 text-left text-[15px] font-medium text-ab-ink hover:bg-ab-canvas">
                {t.common.signOut}
              </button>
            </form>
          </div>
        </div>
      </div>
    </>
  );
}
