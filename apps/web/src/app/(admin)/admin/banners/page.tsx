import Link from "next/link";
import { Card, EmptyRow, PageHeader } from "@/components/admin/AdminChrome";
import { CheckboxField, Field, SelectField, SubmitButton } from "@/components/admin/Fields";
import { listBanners, listCourses } from "@/lib/admin/data";
import { formatWhen } from "@/lib/admin/format";
import { deleteBannerAction, saveBannerAction } from "./actions";

export const metadata = { title: "App slider" };

/** Live = active and inside its date window, the same rule as the RLS policy. */
function isLive(banner: { isActive: boolean; startsAt: string; endsAt: string | null }) {
  if (!banner.isActive) return false;
  const now = Date.now();
  if (new Date(banner.startsAt).getTime() > now) return false;
  if (banner.endsAt && new Date(banner.endsAt).getTime() <= now) return false;
  return true;
}

const gradient = (hue: number) =>
  `linear-gradient(145deg, hsl(${hue} 70% 48%), hsl(${hue + 22} 65% 34%))`;

export default async function AdminBannersPage({
  searchParams,
}: {
  searchParams: Promise<{ edit?: string }>;
}) {
  const { edit } = await searchParams;
  const [banners, courses] = await Promise.all([listBanners(), listCourses()]);
  const editing = edit ? banners.find((b) => b.id === edit) : undefined;

  return (
    <>
      <PageHeader
        title="App slider"
        description="Slides at the top of the app's Home and Courses screens. Lower order shows first; a slide linked to a course opens its page."
      />

      <div className="grid gap-4 lg:grid-cols-[1.4fr_1fr]">
        <div className="space-y-4">
          {banners.length === 0 ? (
            <Card>
              <EmptyRow>No slides yet — create the first one.</EmptyRow>
            </Card>
          ) : (
            banners.map((banner) => {
              const live = isLive(banner);
              return (
                <Card key={banner.id}>
                  <div className="flex flex-wrap gap-4">
                    <div
                      className="flex h-24 w-40 shrink-0 flex-col justify-end overflow-hidden rounded-xl bg-cover bg-center p-3 text-white"
                      style={{
                        backgroundImage: banner.imageUrl
                          ? `linear-gradient(transparent, rgba(18,32,70,0.7)), url(${banner.imageUrl})`
                          : gradient(banner.hue),
                      }}
                    >
                      <span className="line-clamp-2 text-xs font-semibold">{banner.title}</span>
                    </div>
                    <div className="min-w-0 flex-1">
                      <div className="flex flex-wrap items-center gap-2">
                        <h3 className="font-semibold text-navy">{banner.title}</h3>
                        <span
                          className={`rounded-full px-2.5 py-1 text-xs font-semibold ${
                            live ? "bg-success/15 text-success" : "bg-surface-soft text-muted"
                          }`}
                        >
                          {live ? "live" : banner.isActive ? "scheduled" : "off"}
                        </span>
                        <span className="rounded-full bg-primary-soft px-2.5 py-1 text-xs font-semibold text-primary">
                          order {banner.sortOrder}
                        </span>
                      </div>
                      {banner.subtitle ? (
                        <p className="mt-1.5 text-sm text-muted">{banner.subtitle}</p>
                      ) : null}
                      <p className="mt-2 text-xs text-muted">
                        {banner.courseTitle
                          ? `Opens ${banner.courseTitle} · “${banner.ctaLabel}”`
                          : "Not linked to a course"}
                      </p>
                      <p className="mt-1 text-xs text-muted">
                        {formatWhen(banner.startsAt)} →{" "}
                        {banner.endsAt ? formatWhen(banner.endsAt) : "no end date"}
                      </p>
                    </div>
                  </div>
                  <div className="mt-4 flex items-center gap-4 border-t border-border pt-3">
                    <Link
                      href={`/admin/banners?edit=${banner.id}`}
                      className="text-xs font-medium text-primary hover:underline"
                    >
                      Edit
                    </Link>
                    <form action={deleteBannerAction}>
                      <input type="hidden" name="id" value={banner.id} />
                      <button type="submit" className="text-xs font-medium text-pink hover:underline">
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
          <h2 className="mb-1 font-semibold text-navy">{editing ? "Edit slide" : "New slide"}</h2>
          <p className="mb-4 text-xs text-muted">
            A slide shows only while it is active and inside its date window.
          </p>

          <form action={saveBannerAction} className="space-y-3">
            {editing ? <input type="hidden" name="id" value={editing.id} /> : null}

            <Field
              label="Title"
              name="title"
              defaultValue={editing?.title}
              placeholder="Class 12 Science Crash Course"
              required
            />
            <Field
              label="Subtitle"
              name="subtitle"
              defaultValue={editing?.subtitle ?? ""}
              placeholder="Finish the syllabus in 90 days · 50% off"
            />

            <SelectField
              label="Links to course"
              name="courseId"
              defaultValue={editing?.courseId ?? ""}
              options={[
                { value: "", label: "No link (information only)" },
                ...courses.map((c) => ({ value: c.id, label: c.title })),
              ]}
            />

            <div className="grid grid-cols-2 gap-3">
              <Field
                label="Button label"
                name="ctaLabel"
                defaultValue={editing?.ctaLabel ?? "Enroll now"}
              />
              <Field
                label="Order"
                name="sortOrder"
                type="number"
                defaultValue={editing?.sortOrder ?? banners.length}
                hint="Lower shows first"
              />
            </div>

            <label className="block">
              <span className="text-xs font-medium text-navy">Artwork</span>
              <input
                type="file"
                name="image"
                accept="image/png,image/jpeg,image/webp"
                className="mt-1 w-full text-xs text-muted"
              />
              <span className="mt-1 block text-xs text-muted">
                Optional, 16:9, max 5 MB. Without it the slide uses a colour gradient.
              </span>
            </label>
            {editing?.imageUrl ? (
              <CheckboxField label="Remove current artwork" name="removeImage" />
            ) : null}

            <Field
              label="Gradient hue (0–360)"
              name="hue"
              type="number"
              min="0"
              defaultValue={editing?.hue ?? 214}
              hint="214 blue · 162 teal · 320 pink · 28 orange"
            />

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

            <CheckboxField label="Active" name="isActive" defaultChecked={editing?.isActive ?? true} />

            <SubmitButton>{editing ? "Save slide" : "Create slide"}</SubmitButton>

            {editing ? (
              <Link
                href="/admin/banners"
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
