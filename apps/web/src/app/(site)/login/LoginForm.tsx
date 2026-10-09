"use client";

import { useActionState } from "react";
import {
  signInWithGoogle,
  signInWithPassword,
  type LoginState,
} from "./actions";

const initial: LoginState = {};

export function LoginForm({ next, demo }: { next: string; demo: boolean }) {
  const [state, action, pending] = useActionState(signInWithPassword, initial);
  const [googleState, googleAction, googlePending] = useActionState(
    signInWithGoogle,
    initial,
  );

  // Either form can report a failure; show whichever one did.
  const error = state.error ?? googleState.error;
  const busy = pending || googlePending;

  return (
    <div className="mt-8">
      {/* Separate form: the Google button must not submit email/password. */}
      <form action={googleAction}>
        <input type="hidden" name="next" value={next} />
        <button
          type="submit"
          disabled={busy || demo}
          className="flex w-full items-center justify-center gap-3 rounded-xl border border-border bg-surface px-4 py-3 text-sm font-semibold transition-colors hover:bg-bg disabled:opacity-50"
        >
          <GoogleMark />
          {googlePending ? "Redirecting…" : "Continue with Google"}
        </button>
      </form>

      <div className="my-6 flex items-center gap-3" aria-hidden="true">
        <span className="h-px flex-1 bg-border" />
        <span className="text-xs uppercase tracking-[0.14em] text-muted">
          or
        </span>
        <span className="h-px flex-1 bg-border" />
      </div>

      <form action={action}>
        <input type="hidden" name="next" value={next} />

        <label className="block text-sm font-medium">
          Email
          <input
            name="email"
            type="email"
            required
            autoComplete="email"
            placeholder="you@akhandbharatacademy.in"
            className="mt-2 w-full rounded-xl border border-border bg-surface px-3 py-2.5 outline-none focus:border-primary"
          />
        </label>

        <label className="mt-4 block text-sm font-medium">
          Password
          <input
            name="password"
            type="password"
            required
            autoComplete="current-password"
            className="mt-2 w-full rounded-xl border border-border bg-surface px-3 py-2.5 outline-none focus:border-primary"
          />
        </label>

        {error ? (
          <p
            role="alert"
            className="mt-4 rounded-xl bg-pink/10 px-3 py-2.5 text-sm text-pink"
          >
            {error}
          </p>
        ) : null}

        {demo ? (
          <p className="mt-4 rounded-xl bg-orange/10 px-3 py-2.5 text-xs text-navy">
            <strong className="font-semibold">Demo mode.</strong> No Supabase
            project is connected, so sign-in is disabled and the console opens on
            mock data.
          </p>
        ) : null}

        <button
          type="submit"
          disabled={busy || demo}
          className="mt-6 w-full rounded-xl bg-primary px-4 py-3 text-sm font-semibold text-white transition-colors hover:bg-primary-dark disabled:opacity-50"
        >
          {pending ? "Signing in…" : "Sign in"}
        </button>
      </form>
    </div>
  );
}

function GoogleMark() {
  return (
    <svg width="18" height="18" viewBox="0 0 18 18" aria-hidden="true">
      <path
        fill="#4285F4"
        d="M17.64 9.2c0-.64-.06-1.25-.16-1.84H9v3.48h4.84a4.14 4.14 0 0 1-1.8 2.72v2.26h2.91c1.7-1.57 2.69-3.88 2.69-6.62Z"
      />
      <path
        fill="#34A853"
        d="M9 18c2.43 0 4.47-.8 5.96-2.18l-2.91-2.26c-.81.54-1.84.86-3.05.86-2.34 0-4.32-1.58-5.03-3.71H.96v2.34A9 9 0 0 0 9 18Z"
      />
      <path
        fill="#FBBC05"
        d="M3.97 10.71a5.41 5.41 0 0 1 0-3.42V4.96H.96a9 9 0 0 0 0 8.09l3.01-2.34Z"
      />
      <path
        fill="#EA4335"
        d="M9 3.58c1.32 0 2.5.45 3.44 1.35l2.58-2.59C13.46.89 11.43 0 9 0A9 9 0 0 0 .96 4.96l3.01 2.33C4.68 5.16 6.66 3.58 9 3.58Z"
      />
    </svg>
  );
}
