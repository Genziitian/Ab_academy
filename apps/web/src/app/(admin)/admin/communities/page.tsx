import Link from "next/link";
import { Card, EmptyRow, PageHeader } from "@/components/admin/AdminChrome";
import { listCommunities } from "@/lib/admin/data";

export default async function AdminCommunitiesPage() {
  const communities = await listCommunities();

  return (
    <>
      <PageHeader
        title="Communities"
        description="One group per course. Students join automatically when they enrol — there is nothing to create here."
      />

      <Card>
        {communities.length === 0 ? (
          <EmptyRow>No courses yet, so no communities.</EmptyRow>
        ) : (
          <div className="overflow-x-auto">
            <table className="w-full min-w-[40rem] text-left text-sm">
              <thead>
                <tr className="border-b border-border text-xs tracking-wide text-muted uppercase">
                  <th className="pb-2 font-medium">Community</th>
                  <th className="pb-2 font-medium">Members</th>
                  <th className="pb-2 font-medium">Messages</th>
                  <th className="pb-2 font-medium">Latest</th>
                  <th className="pb-2" />
                </tr>
              </thead>
              <tbody className="divide-y divide-border">
                {communities.map((community) => (
                  <tr key={community.id}>
                    <td className="py-3 pr-3">
                      <Link
                        href={`/admin/communities/${community.courseId}`}
                        className="font-medium text-navy hover:text-primary"
                      >
                        {community.name}
                      </Link>
                      <p className="text-xs text-muted">{community.courseId}</p>
                    </td>
                    <td className="py-3 pr-3 text-navy">{community.memberCount}</td>
                    <td className="py-3 pr-3 text-muted">{community.messageCount}</td>
                    <td className="py-3 max-w-xs">
                      <p className="truncate text-navy">{community.lastMessage}</p>
                      <p className="text-xs text-muted">{community.lastAuthor}</p>
                    </td>
                    <td className="py-3 text-right">
                      <Link
                        href={`/admin/communities/${community.courseId}`}
                        className="text-xs font-medium text-primary hover:underline"
                      >
                        Open
                      </Link>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </Card>

      <Card className="mt-4">
        <h2 className="font-semibold text-navy">How membership works</h2>
        <p className="mt-2 text-sm text-muted">
          The migration adds a trigger on <code>courses</code> that creates a community row, and a
          trigger on <code>enrollments</code> that inserts the student into{" "}
          <code>community_members</code>. Membership therefore follows enrolment in the database
          rather than being managed by hand here. Announcements and moderation live on each community’s own page: open one to post a
          pinned notice or delete a message.
        </p>
      </Card>
    </>
  );
}
