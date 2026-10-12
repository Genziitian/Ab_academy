"use client";

import Image from "next/image";
import Link from "next/link";
import { useState } from "react";
import { PdfBadge } from "@/components/NotesBrowser";
import { PlayIcon } from "@/components/icons";
import { Avatar, TabButton, TeacherBadge } from "@/components/portal/ui";
import type { Lecture, LessonKind, PortalLesson } from "@/lib/portal/data";

const tabs = ["About", "Discussion", "Notes", "Feedback"] as const;
type Tab = (typeof tabs)[number];

const playlistTone: Record<LessonKind, { icon: string; className: string }> = {
  done: { icon: "✓", className: "bg-success-soft text-success text-[11px]" },
  current: { icon: "▶", className: "bg-primary text-white text-[11px]" },
  live: { icon: "●", className: "bg-danger-soft text-danger text-[11px]" },
  notes: { icon: "PDF", className: "bg-pdf-soft text-danger text-[8px]" },
};

export function LectureView({
  lecture,
  playlist,
  chapterLabel,
  studentInitials,
}: {
  lecture: Lecture;
  playlist: PortalLesson[];
  chapterLabel: string;
  studentInitials: string;
}) {
  const [tab, setTab] = useState<Tab>("About");
  const [draft, setDraft] = useState("");
  const [mine, setMine] = useState<string[]>([]);
  const [rating, setRating] = useState(0);
  const [complete, setComplete] = useState(lecture.progress === 100);
  const [saved, setSaved] = useState(false);
  const [feedbackSent, setFeedbackSent] = useState(false);

  const comments = [
    ...lecture.comments,
    ...mine.map((body) => ({
      author: "You",
      initials: studentInitials,
      body,
      time: "Just now",
      replies: [],
    })),
  ];

  function post() {
    const body = draft.trim();
    if (!body) return;
    setMine((prev) => [...prev, body]);
    setDraft("");
  }

  const button =
    "h-[38px] whitespace-nowrap rounded-lg border border-border bg-white px-3.5 text-[13px] font-semibold text-navy hover:bg-surface-grey";

  return (
    <div className="grid max-w-[1320px] gap-6 px-4 pb-12 pt-6 sm:px-8 xl:grid-cols-[minmax(0,1fr)_340px]">
      <div className="min-w-0">
        <div className="relative aspect-video overflow-hidden rounded-xl bg-foreground">
          <Image
            src="/images/feature-live-class.png"
            alt="Lecture"
            width={1280}
            height={720}
            className="size-full object-cover opacity-55"
          />
          <div className="absolute inset-0 flex items-center justify-center">
            <span className="flex size-[68px] items-center justify-center rounded-full bg-white/95 text-primary">
              <PlayIcon size={24} />
            </span>
          </div>
          <div className="absolute inset-x-0 bottom-0 bg-gradient-to-b from-transparent to-foreground/85 px-[18px] py-3.5 text-white">
            <div className="h-1 rounded-sm bg-white/25">
              <div className="h-full rounded-sm bg-primary" style={{ width: `${lecture.progress}%` }} />
            </div>
            <div className="mt-2.5 flex justify-between text-[13px]">
              <span>
                {lecture.position} / {lecture.duration}
              </span>
              <span className="flex gap-4 text-[#c8d1e4]">
                <span>1.0×</span>
                <span>480p</span>
                <span>CC</span>
                <span>⛶</span>
              </span>
            </div>
          </div>
        </div>

        <div className="mt-5 flex flex-wrap items-start justify-between gap-6">
          <div>
            <p className="text-xs font-semibold uppercase tracking-[0.06em] text-primary">
              {lecture.subject} · Chapter {String(lecture.chapterNumber).padStart(2, "0")}
            </p>
            <h1 className="mt-1.5 text-2xl font-bold tracking-[-0.01em] text-navy">
              {lecture.title}
            </h1>
            <div className="mt-2.5 flex items-center gap-2.5">
              <Avatar initials={lecture.teacher.initials} size={28} />
              <span className="text-sm font-medium text-navy">{lecture.teacher.name}</span>
              <span className="text-[13px] text-muted">
                · ★ {lecture.rating} ({lecture.ratingCount} ratings)
              </span>
            </div>
          </div>
          <div className="flex flex-wrap gap-2">
            <Link href="/downloads" className={`flex items-center ${button}`}>
              ↓ Download
            </Link>
            <button type="button" onClick={() => setSaved(!saved)} className={button}>
              {saved ? "✓ Saved" : "Save"}
            </button>
            <button
              type="button"
              onClick={() => setComplete(!complete)}
              className={`h-[38px] whitespace-nowrap rounded-lg px-3.5 text-[13px] font-semibold ${
                complete ? "bg-success-soft text-success" : "bg-primary text-white"
              }`}
            >
              {complete ? "✓ Completed" : "Mark complete"}
            </button>
          </div>
        </div>

        <div className="mt-6 rounded-xl border border-border bg-white">
          <div className="no-scrollbar flex gap-1 overflow-x-auto border-b border-border px-5">
            {tabs.map((t) => (
              <TabButton key={t} active={tab === t} onClick={() => setTab(t)}>
                {t}
              </TabButton>
            ))}
          </div>
          <div className="p-6">
            {tab === "About" ? (
              <>
                <h3 className="text-base font-semibold text-navy">About this lesson</h3>
                <p className="mt-2 max-w-[720px] text-[15px] leading-[1.7] text-ink">
                  {lecture.about}
                </p>
              </>
            ) : null}

            {tab === "Discussion" ? (
              <>
                <p className="mb-[18px] text-[13px] text-muted">
                  Questions about this lesson go to your teacher&apos;s doubt queue.
                </p>
                <div className="flex flex-col gap-5">
                  {comments.map((comment, index) => (
                    <div key={`${comment.author}-${index}`}>
                      <div className="flex gap-3">
                        <Avatar initials={comment.initials} size={32} />
                        <div className="flex-1">
                          <div className="flex items-center gap-2">
                            <span className="text-sm font-semibold text-navy">{comment.author}</span>
                            <span className="text-xs text-subtle">{comment.time}</span>
                          </div>
                          <p className="mt-1 text-sm leading-[1.6] text-ink">{comment.body}</p>
                        </div>
                      </div>
                      {comment.replies.map((reply) => (
                        <div
                          key={reply.body}
                          className="ml-11 mt-3.5 flex gap-2.5 rounded-lg bg-surface-soft px-3.5 py-3"
                        >
                          <Avatar initials={reply.initials} size={26} tone="solid" />
                          <div>
                            <div className="flex flex-wrap items-center gap-2">
                              <span className="text-[13px] font-semibold text-navy">{reply.author}</span>
                              <TeacherBadge />
                              <span className="text-xs text-subtle">{reply.time}</span>
                            </div>
                            <p className="mt-1 text-sm leading-[1.6] text-ink">{reply.body}</p>
                          </div>
                        </div>
                      ))}
                    </div>
                  ))}
                </div>
                <form
                  onSubmit={(e) => {
                    e.preventDefault();
                    post();
                  }}
                  className="mt-6 flex gap-2.5"
                >
                  <input
                    value={draft}
                    onChange={(e) => setDraft(e.target.value)}
                    placeholder="Ask a question about this lesson…"
                    className="h-11 min-w-0 flex-1 rounded-lg border border-field px-3.5 text-sm outline-none focus:border-primary"
                  />
                  <button
                    type="submit"
                    className="h-11 rounded-lg bg-primary px-[18px] text-sm font-semibold text-white hover:bg-primary-dark"
                  >
                    Post
                  </button>
                </form>
              </>
            ) : null}

            {tab === "Notes" ? (
              <>
                <h3 className="text-base font-semibold text-navy">Attached notes</h3>
                <p className="mb-4 mt-1 text-[13px] text-muted">
                  Open them here — no download needed.
                </p>
                <div className="flex flex-col gap-2.5">
                  {lecture.notes.map((note) => (
                    <div
                      key={note.title}
                      className="flex items-center gap-3.5 rounded-[10px] border border-border p-3.5"
                    >
                      <PdfBadge />
                      <div className="min-w-0 flex-1">
                        <p className="text-sm font-semibold text-navy">{note.title}</p>
                        <p className="mt-0.5 text-xs text-muted">{note.size}</p>
                      </div>
                      <Link href="/materials" className="text-[13px] font-semibold text-primary">
                        Open
                      </Link>
                    </div>
                  ))}
                </div>
              </>
            ) : null}

            {tab === "Feedback" ? (
              <>
                <div className="flex items-center gap-4">
                  <span className="text-4xl font-bold tracking-[-0.02em] text-navy">
                    {lecture.rating}
                  </span>
                  <div>
                    <p className="text-lg tracking-[2px] text-[#e0a33a]">★★★★★</p>
                    <p className="mt-0.5 text-[13px] text-muted">{lecture.ratingCount} ratings</p>
                  </div>
                </div>
                {feedbackSent ? (
                  <p className="mt-6 rounded-lg bg-success-soft px-4 py-3 text-sm font-medium text-success">
                    Thanks — your feedback was sent to {lecture.teacher.name}.
                  </p>
                ) : (
                  <form
                    onSubmit={(e) => {
                      e.preventDefault();
                      if (rating) setFeedbackSent(true);
                    }}
                  >
                    <h3 className="mb-2.5 mt-6 text-base font-semibold text-navy">Rate this lesson</h3>
                    <div className="flex gap-1.5">
                      {[1, 2, 3, 4, 5].map((n) => (
                        <button
                          key={n}
                          type="button"
                          aria-label={`${n} star${n > 1 ? "s" : ""}`}
                          onClick={() => setRating(n)}
                          className={`text-[32px] leading-none ${n <= rating ? "text-[#e0a33a]" : "text-[#c7cad3]"}`}
                        >
                          ★
                        </button>
                      ))}
                    </div>
                    <textarea
                      rows={3}
                      placeholder="What worked, what could be clearer? (optional)"
                      className="mt-3.5 w-full resize-y rounded-lg border border-field px-3 py-2.5 text-sm outline-none focus:border-primary"
                    />
                    <button
                      type="submit"
                      disabled={!rating}
                      className="mt-3 h-[42px] rounded-lg bg-primary px-[18px] text-sm font-semibold text-white hover:bg-primary-dark disabled:opacity-50"
                    >
                      Submit feedback
                    </button>
                  </form>
                )}
              </>
            ) : null}
          </div>
        </div>
      </div>

      <aside className="self-start overflow-hidden rounded-xl border border-border bg-white xl:sticky xl:top-[92px]">
        <div className="border-b border-border px-[18px] py-4">
          <p className="text-xs text-muted">Chapter {String(lecture.chapterNumber).padStart(2, "0")}</p>
          <p className="mt-0.5 text-[15px] font-semibold text-navy">{chapterLabel}</p>
        </div>
        {playlist.map((item) => {
          const playing = item.id === lecture.id;
          const kind: LessonKind = playing ? "current" : item.kind === "current" ? "done" : item.kind;
          const tone = playlistTone[kind];
          const href =
            item.kind === "live"
              ? "/live/classroom"
              : item.kind === "notes"
                ? "/materials"
                : `/lecture/${item.id}`;
          return (
            <Link
              key={item.id}
              href={href}
              className={`flex items-center gap-3 border-b border-l-[3px] border-b-line px-[18px] py-3 last:border-b-0 ${
                playing ? "border-l-primary bg-surface-soft" : "border-l-transparent bg-white hover:bg-surface-grey"
              }`}
            >
              <span
                className={`flex size-[26px] shrink-0 items-center justify-center rounded-md font-bold ${tone.className}`}
              >
                {tone.icon}
              </span>
              <span className="min-w-0 flex-1">
                <span className="block text-[13px] font-semibold text-navy">{item.title}</span>
                <span className={`text-xs ${item.kind === "live" ? "text-danger" : "text-muted"}`}>
                  {playing ? `Now playing · ${lecture.position}` : item.meta}
                </span>
              </span>
            </Link>
          );
        })}
      </aside>
    </div>
  );
}
