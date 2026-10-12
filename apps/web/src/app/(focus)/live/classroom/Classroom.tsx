"use client";

import Image from "next/image";
import Link from "next/link";
import { useEffect, useState } from "react";
import { Avatar, TeacherBadge } from "@/components/portal/ui";
import type { classroom as ClassroomData } from "@/lib/portal/data";

type Message = {
  author: string;
  initials: string;
  body: string;
  meta?: string;
  teacher?: boolean;
};

const STARTED_SECONDS_AGO = 24 * 60 + 18;

export function Classroom({
  data,
  studentInitials,
}: {
  data: typeof ClassroomData;
  studentInitials: string;
}) {
  const [tab, setTab] = useState<"chat" | "qa">("chat");
  const [chat, setChat] = useState<Message[]>(data.chat);
  const [questions, setQuestions] = useState<Message[]>(data.questions);
  const [draft, setDraft] = useState("");
  const [elapsed, setElapsed] = useState(STARTED_SECONDS_AGO);
  const [hand, setHand] = useState(false);
  const [notes, setNotes] = useState([{ time: "6:14 PM", body: data.myNote }]);
  const [noteDraft, setNoteDraft] = useState<string | null>(null);

  useEffect(() => {
    const id = setInterval(() => setElapsed((s) => s + 1), 1000);
    return () => clearInterval(id);
  }, []);

  const items = tab === "chat" ? chat : questions;

  function send() {
    const body = draft.trim();
    if (!body) return;
    const message = {
      author: "You",
      initials: studentInitials,
      body,
      meta: tab === "qa" ? "Asked by you · 0 upvotes" : undefined,
    };
    if (tab === "chat") setChat((m) => [...m, message]);
    else setQuestions((m) => [...m, message]);
    setDraft("");
  }

  function saveNote() {
    const body = noteDraft?.trim();
    if (body) {
      const time = new Date().toLocaleTimeString("en-IN", { hour: "numeric", minute: "2-digit" });
      setNotes((n) => [{ time, body }, ...n]);
    }
    setNoteDraft(null);
  }

  const timer = `${Math.floor(elapsed / 60)}:${String(elapsed % 60).padStart(2, "0")}`;
  const darkButton =
    "rounded-[10px] bg-[#16264a] px-[18px] py-3 text-sm font-semibold text-white hover:bg-[#1d3160]";

  return (
    <div className="flex min-h-screen flex-1 flex-col bg-foreground text-white lg:h-screen">
      <header className="flex min-h-[60px] shrink-0 flex-wrap items-center gap-x-4 gap-y-2 border-b border-white/[0.08] px-4 py-3 sm:px-6">
        <Link href="/live" className="text-sm font-medium text-[#c8d1e4] hover:text-white">
          ← Leave
        </Link>
        <span className="h-5 w-px bg-white/[0.12]" />
        <span className="inline-flex items-center gap-1.5 rounded bg-pink/[0.18] px-2 py-[3px] text-[11px] font-bold tracking-[0.06em] text-[#ff8fb0]">
          <span className="size-1.5 rounded-full bg-pink" />
          LIVE · {timer}
        </span>
        <p className="text-[15px] font-semibold">
          {data.subject} · {data.title}
        </p>
        <span className="ml-auto text-[13px] text-[#9aa7c2]">
          {data.teacher} · {data.students} students
        </span>
      </header>

      <div className="grid min-h-0 flex-1 lg:grid-cols-[minmax(0,1fr)_360px]">
        <div className="flex min-h-0 flex-col gap-4 p-4 sm:p-6">
          <div className="relative flex min-h-[320px] flex-1 flex-col rounded-xl bg-white p-6 text-navy sm:p-12">
            <p className="text-xs font-semibold tracking-[0.08em] text-muted">
              SLIDE {data.slide.index} / {data.slide.total}
            </p>
            <h2 className="mt-3 text-[28px] font-bold tracking-[-0.02em] sm:text-4xl">
              {data.slide.heading}
            </h2>
            <div className="mt-8 flex flex-col gap-[18px] text-lg font-medium sm:text-2xl">
              {data.points.map((point) => (
                <span key={point}>{point}</span>
              ))}
            </div>
            <div className="absolute bottom-5 right-5 hidden aspect-[4/3] w-[180px] overflow-hidden rounded-lg border-2 border-white bg-[#1c2c5c] shadow-[0_6px_20px_rgba(0,0,0,0.2)] sm:block">
              <Image
                src="/images/feature-live-class.png"
                alt="Teacher camera"
                width={360}
                height={270}
                className="size-full object-cover"
              />
            </div>
          </div>

          <div className="flex flex-wrap items-stretch gap-3">
            {noteDraft !== null ? (
              <form
                onSubmit={(e) => {
                  e.preventDefault();
                  saveNote();
                }}
                className="flex min-w-[240px] flex-1 gap-2 rounded-[10px] bg-[#16264a] p-2"
              >
                <input
                  autoFocus
                  value={noteDraft}
                  onChange={(e) => setNoteDraft(e.target.value)}
                  placeholder="Write a note for yourself…"
                  className="min-w-0 flex-1 bg-transparent px-2 text-sm text-white outline-none placeholder:text-[#9aa7c2]"
                />
                <button type="submit" className="rounded-lg bg-primary px-3 text-sm font-semibold">
                  Save
                </button>
              </form>
            ) : (
              <div className="min-w-[240px] flex-1 rounded-[10px] bg-[#16264a] px-4 py-3.5">
                <p className="text-xs text-[#9fb8ff]">My notes · {notes[0].time}</p>
                <p className="mt-1 text-sm text-[#e2e8f4]">{notes[0].body}</p>
              </div>
            )}
            <button
              type="button"
              onClick={() => setHand(!hand)}
              className={hand ? "rounded-[10px] bg-[#ffc56b] px-[18px] py-3 text-sm font-semibold text-navy" : darkButton}
            >
              ✋ {hand ? "Hand raised" : "Raise hand"}
            </button>
            <button type="button" onClick={() => setNoteDraft("")} className={darkButton}>
              + Add note
            </button>
          </div>
        </div>

        <aside className="flex min-h-[420px] flex-col bg-white text-navy lg:min-h-0">
          <div className="flex border-b border-border">
            {(
              [
                ["chat", "Live chat"],
                ["qa", `Questions (${questions.length})`],
              ] as const
            ).map(([value, label]) => (
              <button
                key={value}
                type="button"
                onClick={() => setTab(value)}
                className={`h-12 flex-1 border-b-2 text-sm ${
                  tab === value
                    ? "border-primary font-semibold text-primary"
                    : "border-transparent font-medium text-muted"
                }`}
              >
                {label}
              </button>
            ))}
          </div>
          <div className="flex flex-1 flex-col gap-4 overflow-auto p-[18px]">
            {items.map((message, index) => (
              <div key={`${message.author}-${index}`} className="flex gap-2.5">
                <Avatar initials={message.initials} size={30} tone={message.teacher ? "solid" : "soft"} />
                <div className="flex-1">
                  <div className="flex items-center gap-1.5">
                    <span className="text-[13px] font-semibold">{message.author}</span>
                    {message.teacher ? <TeacherBadge small /> : null}
                  </div>
                  <p className="mt-[3px] text-sm leading-[1.5] text-ink">{message.body}</p>
                  {message.meta ? (
                    <p className="mt-[3px] text-xs text-subtle">{message.meta}</p>
                  ) : null}
                </div>
              </div>
            ))}
          </div>
          <form
            onSubmit={(e) => {
              e.preventDefault();
              send();
            }}
            className="flex gap-2 border-t border-border p-3.5"
          >
            <input
              value={draft}
              onChange={(e) => setDraft(e.target.value)}
              placeholder={tab === "chat" ? "Message the class…" : "Ask the teacher a question…"}
              className="h-[42px] min-w-0 flex-1 rounded-lg border border-field px-3 text-sm outline-none focus:border-primary"
            />
            <button
              type="submit"
              className="h-[42px] rounded-lg bg-primary px-4 text-sm font-semibold text-white hover:bg-primary-dark"
            >
              Send
            </button>
          </form>
        </aside>
      </div>
    </div>
  );
}
