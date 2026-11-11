"use client";

import Link from "next/link";
import { useActionState } from "react";
import { signInWithPassword, type LoginState } from "../login/actions";
import { DemoNote, ErrorNote, input, primaryButton } from "../login/LoginForm";

const initial: LoginState = {};

/** Email + password sign-in for teachers and admins. */
export function AccessForm({ next, demo }: { next: string; demo: boolean }) {
  const [state, action, pending] = useActionState(signInWithPassword, initial);

  return (
    <>
      <h1 className="ab-title text-[32px]">Staff access</h1>
      <p className="mt-3 text-[15px] text-ab-ink-2">Teachers and admins sign in to the admin console here.</p>
      <form action={action} className="mt-7 flex flex-col gap-3.5">
        <input type="hidden" name="next" value={next} />
        <label className="flex flex-col gap-1.5 text-sm font-medium text-ab-ink">
          Email
          <input name="email" type="email" required autoComplete="username" className={input} />
        </label>
        <label className="flex flex-col gap-1.5 text-sm font-medium text-ab-ink">
          Password
          <input name="password" type="password" required autoComplete="current-password" className={input} />
        </label>
        <ErrorNote message={state.error} />
        {demo ? (
          <>
            <Link href="/admin" className={`mt-1.5 ${primaryButton}`}>
              Open demo console
            </Link>
            <DemoNote />
          </>
        ) : (
          <button type="submit" disabled={pending} className={`mt-1.5 ${primaryButton}`}>
            {pending ? "Signing in…" : "Sign in"}
          </button>
        )}
      </form>
    </>
  );
}
