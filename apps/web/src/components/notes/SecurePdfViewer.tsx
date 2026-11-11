"use client";

import { createBrowserClient } from "@supabase/ssr";
import { useEffect, useRef, useState } from "react";
import { useT } from "@/lib/i18n/client";

/**
 * Class notes, drawn page by page onto canvases — the same `notes` Edge
 * Function as the app streams the PDF, so the Google Drive link never reaches
 * the browser. There is no download or print control, the student's identity
 * is stamped across every page, and right-click / Ctrl+S / Ctrl+P are off.
 * A determined user can still photograph the screen; this removes the easy
 * ways to copy notes out.
 */
export function SecurePdfViewer({ resourceId, watermark }: { resourceId: string; watermark: string }) {
  const n = useT().notes;
  const pagesRef = useRef<HTMLDivElement>(null);
  const [state, setState] = useState<"loading" | "ready" | "error">("loading");
  const [message, setMessage] = useState("");
  const [pageCount, setPageCount] = useState(0);

  useEffect(() => {
    let cancelled = false;
    const container = pagesRef.current;

    (async () => {
      try {
        const supabase = createBrowserClient(
          process.env.NEXT_PUBLIC_SUPABASE_URL!,
          process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
        );
        const { data } = await supabase.auth.getSession();
        const token = data.session?.access_token;
        if (!token) throw new Error(n.signInAgain);

        const res = await fetch(
          `${process.env.NEXT_PUBLIC_SUPABASE_URL}/functions/v1/notes?id=${encodeURIComponent(resourceId)}`,
          {
            headers: {
              Authorization: `Bearer ${token}`,
              apikey: process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
            },
            cache: "no-store",
          },
        );
        if (!res.ok) {
          const body = await res.json().catch(() => null);
          throw new Error(body?.error ?? n.cantOpen);
        }
        const bytes = new Uint8Array(await res.arrayBuffer());

        const pdfjs = await import("pdfjs-dist");
        pdfjs.GlobalWorkerOptions.workerSrc = "/pdfjs/pdf.worker.min.mjs";
        const pdf = await pdfjs.getDocument({ data: bytes }).promise;
        if (cancelled || !container) return;
        setPageCount(pdf.numPages);

        const width = Math.min(container.clientWidth, 900);
        const ratio = window.devicePixelRatio || 1;
        for (let n = 1; n <= pdf.numPages; n++) {
          const page = await pdf.getPage(n);
          if (cancelled) return;
          const base = page.getViewport({ scale: 1 });
          const viewport = page.getViewport({ scale: (width / base.width) * ratio });
          const canvas = document.createElement("canvas");
          canvas.width = viewport.width;
          canvas.height = viewport.height;
          canvas.style.width = `${viewport.width / ratio}px`;
          canvas.style.height = `${viewport.height / ratio}px`;
          canvas.className = "block max-w-full rounded-lg bg-white shadow-[var(--shadow-card)]";
          canvas.setAttribute("aria-label", `Page ${n}`);
          await page.render({ canvas, viewport }).promise;
          container.appendChild(canvas);
          if (n === 1) setState("ready");
        }
        await pdf.loadingTask.destroy();
      } catch (e) {
        if (cancelled) return;
        setMessage(e instanceof Error ? e.message : "These notes could not be opened.");
        setState("error");
      }
    })();

    const blockKeys = (e: KeyboardEvent) => {
      if ((e.ctrlKey || e.metaKey) && ["s", "p"].includes(e.key.toLowerCase())) e.preventDefault();
    };
    window.addEventListener("keydown", blockKeys);
    return () => {
      cancelled = true;
      window.removeEventListener("keydown", blockKeys);
      container?.replaceChildren();
    };
  }, [resourceId, n]);

  return (
    <div className="relative select-none print:hidden" onContextMenu={(e) => e.preventDefault()}>
      {state === "loading" ? <p className="py-16 text-center text-ab-ink-3">{n.opening}</p> : null}
      {state === "error" ? (
        <p role="alert" className="rounded-2xl border border-ab-rule bg-ab-panel px-6 py-10 text-center text-ab-ink">
          {message}
        </p>
      ) : null}
      <div ref={pagesRef} className="flex flex-col items-center gap-4" />
      {state === "ready" && watermark ? (
        // A repeating diagonal stamp over the pages, above the canvases.
        <div
          aria-hidden
          className="pointer-events-none absolute inset-0 overflow-hidden"
          style={{
            backgroundImage: `url("data:image/svg+xml,${encodeURIComponent(
              `<svg xmlns='http://www.w3.org/2000/svg' width='320' height='200'><text x='20' y='120' transform='rotate(-24 160 100)' font-family='sans-serif' font-size='15' fill='rgba(28,24,20,0.13)'>${watermark.replace(/[<>&'"]/g, "")}</text></svg>`,
            )}")`,
          }}
        />
      ) : null}
      {pageCount ? <p className="ab-num mt-6 text-center text-sm text-ab-ink-3">{n.pages(pageCount)}</p> : null}
    </div>
  );
}
