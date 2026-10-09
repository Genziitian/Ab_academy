import Link from "next/link";
import { Card, EmptyRow, PageHeader } from "@/components/admin/AdminChrome";
import {
  CheckboxField,
  Field,
  SelectField,
  SubmitButton,
  TextAreaField,
} from "@/components/admin/Fields";
import { listCourses, listPopups } from "@/lib/admin/data";
import { describeAudience, formatWhen } from "@/lib/admin/format";
import { deletePopupAction, savePopupAction } from "./actions";

export const metadata = { title: "Popups" };

const PLACEMENTS = [
  { value: "app_launch", label: "On app launch" },
  { value: "home", label: "Home screen card" },
  { value: "course", label: "Course screen" },
];

/** Live = active, started, and not yet expired — the same rule as the RLS policy. */
function isLive(popup: { isActive: boolean; startsAt: string; endsAt: string | null }) {
  if (!popup.isActive) return false;
  const now = Date.now();
  if (new Date(popup.startsAt).getTime() > now) return false;
  if (popup.endsAt && new Date(popup.endsAt).getTime() <= now) return false;
  return true;
}

export default async function AdminPopupsPage({
  searchParams,
}: {
  searchParams: Promise<{ edit?: string }>;
}) {
  const { edit } = await searchParams;

  const [popups, courses] = await Promise.all([listPopups(), listCourses()]);
  const editing = edit ? popups.find((p) => p.id === edit) : undefined;

  return (
    <>
      <PageHeader
        title="Popups"
        description="Interstitial cards the app shows on launch or home. Targeted the same way as notifications."
      />

      <div className="grid gap-4 lg:grid-cols-[1.4fr_1fr]">
        <div className="space-y-4">
          {popups.length === 0 ? (
            <Card>
              <EmptyRow>No popups yet — create the first one.</EmptyRow>
            </Card>
          ) : (
            popups.map((popup) => {
              const live = isLive(popup);
              return (
                <Card key={popup.id}>
                  <div className="flex flex-wrap items-start justify-between gap-3">
                    <div className="min-w-0">
                      <div className="flex flex-wrap items-center gap-2">
                        <h3 className="font-semibold text-navy">{popup.title}</h3>
                        <span
                          className={`rounded-full px-2.5 py-1 text-xs font-semibold ${
                            live
                              ? "bg-success/15 text-success"
                              : "bg-surface-soft text-muted"
                          }`}
                        >
                          {live ? "live" : popup.isActive ? "scheduled" : "off"}
                        </span>
                        {popup.priority > 0 ? (
                          <span className="rounded-full bg-primary-soft px-2.5 py-1 text-xs font-semibold text-primary">
                            priority {popup.priority}
                          </span>
                        ) : null}
                      </div>

                      {popup.body ? (
                        <p className="mt-1.5 text-sm text-muted">{popup.body}</p>
                      ) : null}

                      <p className="mt-2 text-xs text-muted">
                        {PLACEMENTS.find((p) => p.value === popup.placement)?.label}{" "}
                        · {describeAudience(popup.audienceKind, popup.audienceValue)}
                      </p>
                      <p className="mt-1 text-xs text-muted">
                        {formatWhen(popup.startsAt)} →{" "}
                        {popup.endsAt ? formatWhen(popup.endsAt) : "no end date"}
                        {popup.maxViewsPerStudent === 0
                          ? " · every launch"
                          : ` · max ${popup.maxViewsPerStudent} view${
                              popup.maxViewsPerStudent === 1 ? "" : "s"
                            } per student`}
                      </p>
                      {popup.ctaLabel ? (
                        <p className="mt-1 text-xs text-muted">
                          CTA: &ldquo;{popup.ctaLabel}&rdquo; → {popup.ctaUrl}
                        </p>
                      ) : null}
                    </div>

                    <div className="text-right">
                      <p className="text-2xl font-semibold tracking-tight text-navy">
                        {popup.viewCount.toLocaleString("en-IN")}
                      </p>
                      <p className="text-xs text-muted">views</p>
                      <p className="mt-1 text-sm font-semibold text-navy">
                        {popup.clickCount.toLocaleString("en-IN")}
                      </p>
                      <p className="text-xs text-muted">clicks</p>
                    </div>
                  </div>

                  <div className="mt-4 flex items-center gap-4 border-t border-border pt-3">
                    <Link
                      href={`/admin/popups?edit=${popup.id}`}
                      className="text-xs font-medium text-primary hover:underline"
                    >
                      Edit
                    </Link>
                    <form action={deletePopupAction}>
                      <input type="hidden" name="id" value={popup.id} />
                      <button
                        type="submit"
                        className="text-xs font-medium text-pink hover:underline"
                      >
                        Delete
                      </button>
                    </form>
                  </div>
                </Card>
              );
            })
          )}
        </div>

        <Card className="h-fit">
          <h2 className="mb-1 font-semibold text-navy">
            {editing ? "Edit popup" : "New popup"}
          </h2>
          <p className="mb-4 text-xs text-muted">
            A popup shows only while it is active and inside its date window.
            Higher priority wins when two would show at once.
          </p>

          <form action={savePopupAction} className="space-y-3">
            {editing ? (
              <input type="hidden" name="id" value={editing.id} />
            ) : null}

            <Field
              label="Title"
              name="title"
              defaultValue={editing?.title}
              placeholder="Board exam crash course"
              required
            />

            <TextAreaField
              label="Body"
              name="body"
              defaultValue={editing?.body}
              placeholder="Revision batch for Class 10 starts Monday."
            />

            <label className="block">
              <span className="text-xs font-medium text-navy">Image</span>
              <input
                type="file"
                name="image"
                accept="image/png,image/jpeg,image/webp"
                className="mt-1 w-full text-xs text-muted"
              />
              <span className="mt-1 block text-xs text-muted">
                Optional. Shown above the title. Max 5 MB.
                {editing?.imageUrl ? " Leave empty to keep the current image." : ""}
              </span>
            </label>

            <SelectField
              label="Placement"
              name="placement"
              defaultValue={editing?.placement}
              options={PLACEMENTS}
            />

            <div className="grid grid-cols-2 gap-3">
              <SelectField
                label="Audience"
                name="audienceKind"
                defaultValue={editing?.audienceKind}
                options={[
                  { value: "all", label: "Everyone" },
                  { value: "class", label: "One class" },
                  { value: "course", label: "One course" },
                  { value: "student", label: "One student" },
                ]}
              />
              <Field
                label="Class / course id"
                name="audienceValue"
                defaultValue={editing?.audienceValue ?? ""}
                placeholder="10"
                hint="Leave empty for everyone"
              />
            </div>

            {courses.length > 0 ? (
              <p className="text-xs text-muted">
                Course ids:{" "}
                {courses.slice(0, 3).map((c) => (
                  <span key={c.id} className="block font-mono text-[11px]">
                    {c.title} → {c.id}
                  </span>
                ))}
              </p>
            ) : null}

            <div className="grid grid-cols-2 gap-3">
              <Field
                label="Starts"
                name="startsAt"
                type="datetime-local"
                defaultValue={editing?.startsAt}
                required
              />
              <Field
                label="Ends"
                name="endsAt"
                type="datetime-local"
                defaultValue={editing?.endsAt ?? ""}
                hint="Optional"
              />
            </div>

            <div className="grid grid-cols-2 gap-3">
              <Field
                label="CTA label"
                name="ctaLabel"
                defaultValue={editing?.ctaLabel ?? ""}
                placeholder="See the batch"
              />
              <Field
                label="CTA link"
                name="ctaUrl"
                defaultValue={editing?.ctaUrl ?? ""}
                placeholder="/course/class-10"
              />
            </div>

            <div className="grid grid-cols-2 gap-3">
              <Field
                label="Max views / student"
                name="maxViewsPerStudent"
                type="number"
                min="0"
                defaultValue={editing?.maxViewsPerStudent ?? 1}
                hint="0 = every launch"
              />
              <Field
                label="Priority"
                name="priority"
                type="number"
                defaultValue={editing?.priority ?? 0}
              />
            </div>

            <CheckboxField
              label="Active"
              name="isActive"
              defaultChecked={editing?.isActive ?? true}
            />

            <SubmitButton>
              {editing ? "Save popup" : "Create popup"}
            </SubmitButton>

            {editing ? (
              <Link
                href="/admin/popups"
                className="block text-center text-xs font-medium text-muted hover:text-navy"
              >
                Cancel
              </Link>
            ) : null}
          </form>
        </Card>
      </div>
    </>
  );
}
