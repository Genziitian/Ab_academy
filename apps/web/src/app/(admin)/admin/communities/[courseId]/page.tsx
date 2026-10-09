import Link from "next/link";
import { notFound } from "next/navigation";
import { Card, EmptyRow, PageHeader } from "@/components/admin/AdminChrome";
import { CheckboxField, SubmitButton, TextAreaField } from "@/components/admin/Fields";
import { listCommunities, listCommunityMessages } from "@/lib/admin/data";
import { formatWhen } from "@/lib/admin/format";
import { deleteMessageAction, postAnnouncementAction } from "../actions";

export default async function AdminCommunityDetailPage({
  params,
}: {
  params: Promise<{ courseId: string }>;
}) {
  const { courseId } = await params;

  const [communities, messages] = await Promise.all([
    listCommunities(),
    listCommunityMessages(courseId),
  ]);

  const community = communities.find((c) => c.courseId === courseId);
  if (!community) notFound();

  return (
    <>
      <Link
        href="/admin/communities"
        className="mb-4 inline-block text-sm text-primary"
      >
        ← All communities
      </Link>

      <PageHeader
        title={community.name}
        description={`${community.memberCount} members · ${community.messageCount} messages`}
      />

      <div className="grid gap-4 lg:grid-cols-[1.5fr_1fr]">
        <Card>
          <h2 className="mb-4 font-semibold text-navy">Recent messages</h2>

          {messages.length === 0 ? (
            <EmptyRow>Nothing posted in this community yet.</EmptyRow>
          ) : (
            <ul className="space-y-3">
              {messages.map((message) => (
                <li
                  key={message.id}
                  className={`rounded-xl px-3.5 py-3 ${
                    message.pinned
                      ? "border border-primary/30 bg-primary-soft"
                      : "bg-surface-soft"
                  }`}
                >
                  <div className="flex items-start justify-between gap-3">
                    <div className="min-w-0">
                      {message.pinned ? (
                        <p className="mb-1 text-xs font-semibold tracking-wide text-primary uppercase">
                          Pinned
                        </p>
                      ) : null}
                      <p className="text-sm text-navy">{message.body}</p>
                      <p className="mt-1.5 text-xs text-muted">
                        {message.authorName} · {formatWhen(message.createdAt)}
                      </p>
                    </div>
                    <form action={deleteMessageAction}>
                      <input type="hidden" name="courseId" value={courseId} />
                      <input type="hidden" name="messageId" value={message.id} />
                      <button
                        type="submit"
                        className="text-xs font-medium text-pink hover:underline"
                      >
                        Delete
                      </button>
                    </form>
                  </div>
                </li>
              ))}
            </ul>
          )}
        </Card>

        <Card className="h-fit">
          <h2 className="mb-1 font-semibold text-navy">Post an announcement</h2>
          <p className="mb-4 text-xs text-muted">
            Posts appear in the app immediately over the realtime subscription.
            Pinning keeps it at the top of the feed.
          </p>

          <form action={postAnnouncementAction} className="space-y-3">
            <input type="hidden" name="courseId" value={courseId} />
            <TextAreaField
              label="Message"
              name="body"
              rows={4}
              required
              placeholder="Live class moves to 7pm tomorrow."
            />
            <CheckboxField label="Pin to the top" name="pinned" />
            <SubmitButton>Post to community</SubmitButton>
          </form>
        </Card>
      </div>
    </>
  );
}
