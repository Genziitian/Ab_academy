import Link from "next/link";
import { PortalTopbar } from "@/components/portal/PortalTopbar";
import { Card } from "@/components/portal/ui";
import { downloads } from "@/lib/portal/data";
import { DownloadsList } from "./DownloadsList";

export const metadata = { title: "Downloads" };

export default function DownloadsPage() {
  return (
    <>
      <PortalTopbar title="Downloads" />
      <div className="flex max-w-[1080px] flex-col gap-5 px-4 pb-12 pt-7 sm:px-8">
        <Card className="p-6">
          <div className="flex flex-wrap items-baseline justify-between gap-2">
            <h2 className="text-base font-semibold text-navy">Device storage</h2>
            <span className="text-sm text-muted">
              <span className="font-semibold text-navy">1.8 GB used</span> · 4.2 GB free
            </span>
          </div>
          <div className="mt-3.5 flex h-2.5 overflow-hidden rounded-full bg-track">
            <span className="w-[26%] bg-primary" />
            <span className="w-[7%] bg-violet" />
          </div>
          <div className="mt-3 flex gap-5 text-[13px] text-ink">
            <span className="flex items-center gap-1.5">
              <span className="size-2 rounded-sm bg-primary" />
              Videos
            </span>
            <span className="flex items-center gap-1.5">
              <span className="size-2 rounded-sm bg-violet" />
              Notes
            </span>
          </div>
        </Card>
        <DownloadsList items={downloads} />
        <p className="text-[13px] text-muted">
          Tip: download lessons overnight on wifi. Set video quality under{" "}
          <Link href="/profile" className="font-semibold text-primary">
            Profile → Learning
          </Link>
          .
        </p>
      </div>
    </>
  );
}
