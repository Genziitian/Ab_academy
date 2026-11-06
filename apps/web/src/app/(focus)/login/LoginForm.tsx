"use client";

import Link from "next/link";
import { useActionState, useRef, useState } from "react";
import { GoogleMark } from "@/components/icons";
import {
  sendPhoneOtp,
  signInWithGoogle,
  signInWithPassword,
  verifyPhoneOtp,
  type LoginState,
} from "./actions";

const initial: LoginState = {};

export const input =
  "h-[46px] rounded-lg border border-field px-3 text-[15px] font-normal outline-none focus:border-primary";
export const primaryButton =
  "flex h-12 w-full items-center justify-center rounded-full bg-primary text-[15px] font-semibold text-white hover:bg-primary-dark disabled:opacity-60";

/** Student sign-in: phone OTP or Google. Staff sign in at /access. */
export function LoginForm({ next, demo }: { next: string; demo: boolean }) {
  return <StudentLogin next={next} demo={demo} />;
}

function StudentLogin({
  next,
  demo,
}: {
  next: string;
  demo: boolean;
}) {
  const [sendState, sendAction, sending] = useActionState(sendPhoneOtp, initial);
  const [verifyState, verifyAction, verifying] = useActionState(verifyPhoneOtp, initial);
  const [googleState, googleAction, googlePending] = useActionState(signInWithGoogle, initial);
  // Lets "Change number" step back even after a code was sent.
  const [editingPhone, setEditingPhone] = useState(false);

  const otpStep = !editingPhone && Boolean(sendState.sent);
  const phone = sendState.phone ?? "";
  const error = otpStep
    ? verifyState.error
    : (sendState.error ?? googleState.error);

  return (
    <>
      <h2 className="text-[28px] font-bold tracking-[-0.02em] text-navy">
        {otpStep ? "Enter the 6-digit OTP" : "Log in or sign up"}
      </h2>
      <p className="mt-2 text-[15px] text-muted">
        {otpStep ? `Sent to ${formatPhone(phone)}` : "Use your mobile number or Google account."}
      </p>

      {otpStep ? (
        <form action={verifyAction} className="mt-7">
          <input type="hidden" name="phone" value={phone} />
          <input type="hidden" name="next" value={next} />
          <OtpBoxes />
          <ErrorNote message={error} />
          <button type="submit" disabled={verifying} className={`mt-4 ${primaryButton}`}>
            {verifying ? "Verifying…" : "Verify & continue"}
          </button>
          <button
            type="button"
            onClick={() => setEditingPhone(true)}
            className="mt-2.5 w-full text-sm text-muted hover:text-navy"
          >
            Change number
          </button>
        </form>
      ) : (
        <>
          <form
            action={(formData) => {
              setEditingPhone(false);
              sendAction(formData);
            }}
            className="mt-7"
          >
            <label className="flex flex-col gap-1.5 text-sm font-medium text-navy">
              Mobile number
              <div className="flex h-12 overflow-hidden rounded-full border border-field focus-within:border-primary">
                <span className="flex items-center border-r border-field bg-surface-grey px-3.5 text-[15px] text-ink">
                  +91
                </span>
                <input
                  name="phone"
                  inputMode="numeric"
                  autoComplete="tel-national"
                  required
                  placeholder="98765 43210"
                  className="min-w-0 flex-1 px-3 text-[15px] font-normal outline-none"
                />
              </div>
            </label>
            <ErrorNote message={error} />
            {demo ? (
              <Link href={next} className={`mt-3.5 ${primaryButton}`}>
                Continue to demo portal
              </Link>
            ) : (
              <button type="submit" disabled={sending} className={`mt-3.5 ${primaryButton}`}>
                {sending ? "Sending…" : "Send OTP"}
              </button>
            )}
          </form>

          <div className="my-[22px] flex items-center gap-3" aria-hidden>
            <span className="h-px flex-1 bg-border" />
            <span className="text-xs uppercase tracking-[0.08em] text-muted">or</span>
            <span className="h-px flex-1 bg-border" />
          </div>

          <form action={googleAction}>
            <input type="hidden" name="next" value={next} />
            <button
              type="submit"
              disabled={googlePending || demo}
              className="flex h-12 w-full items-center justify-center gap-2.5 rounded-full border border-field bg-white text-[15px] font-semibold text-navy hover:bg-surface-grey disabled:opacity-60"
            >
              <GoogleMark />
              {googlePending ? "Redirecting…" : "Continue with Google"}
            </button>
          </form>

          {demo ? null : <EmailLogin next={next} />}

          {demo ? <DemoNote /> : null}

          <p className="mt-[18px] text-center text-xs leading-[1.5] text-muted">
            By continuing you agree to our{" "}
            <Link href="/terms" className="text-primary">
              Terms
            </Link>{" "}
            and{" "}
            <Link href="/privacy" className="text-primary">
              Privacy Policy
            </Link>
            .
          </p>
        </>
      )}
    </>
  );
}

/**
 * Email + password, for accounts the academy creates (such as the Google Play
 * review account). Folded away: students sign in with phone or Google.
 */
function EmailLogin({ next }: { next: string }) {
  const [state, action, pending] = useActionState(signInWithPassword, initial);
  return (
    <details className="group mt-4" open={Boolean(state.error)}>
      <summary className="mx-auto w-fit cursor-pointer list-none text-sm font-semibold text-primary hover:underline [&::-webkit-details-marker]:hidden">
        Sign in with email
      </summary>
      <form action={action} className="mt-4 flex flex-col gap-3">
        <input type="hidden" name="next" value={next} />
        <label className="flex flex-col gap-1.5 text-sm font-medium text-navy">
          Email
          <input
            name="email"
            type="email"
            autoComplete="email"
            required
            className={`${input} h-12 rounded-full px-4`}
          />
        </label>
        <label className="flex flex-col gap-1.5 text-sm font-medium text-navy">
          Password
          <input
            name="password"
            type="password"
            autoComplete="current-password"
            required
            className={`${input} h-12 rounded-full px-4`}
          />
        </label>
        <ErrorNote message={state.error} />
        <button type="submit" disabled={pending} className={`mt-1 ${primaryButton}`}>
          {pending ? "Signing in…" : "Sign in"}
        </button>
        <p className="text-center text-xs text-muted">For accounts created by AB Academy.</p>
      </form>
    </details>
  );
}

/** Six single-digit boxes that auto-advance and accept a pasted code. */
function OtpBoxes() {
  const [digits, setDigits] = useState(["", "", "", "", "", ""]);
  const refs = useRef<(HTMLInputElement | null)[]>([]);

  function setAt(index: number, value: string) {
    const clean = value.replace(/\D/g, "");
    if (clean.length > 1) {
      // Pasted the whole code.
      const next = clean.slice(0, 6).split("");
      setDigits([...next, ...Array(6 - next.length).fill("")]);
      refs.current[Math.min(next.length, 5)]?.focus();
      return;
    }
    setDigits((prev) => prev.map((d, i) => (i === index ? clean : d)));
    if (clean && index < 5) refs.current[index + 1]?.focus();
  }

  return (
    <>
      <input type="hidden" name="token" value={digits.join("")} />
      <div className="flex gap-2">
        {digits.map((digit, index) => (
          <input
            key={index}
            ref={(el) => {
              refs.current[index] = el;
            }}
            value={digit}
            inputMode="numeric"
            autoComplete={index === 0 ? "one-time-code" : "off"}
            aria-label={`Digit ${index + 1}`}
            autoFocus={index === 0}
            onChange={(e) => setAt(index, e.target.value)}
            onKeyDown={(e) => {
              if (e.key === "Backspace" && !digit && index > 0) {
                refs.current[index - 1]?.focus();
              }
            }}
            className="h-14 min-w-0 flex-1 rounded-lg border border-field text-center text-[22px] font-semibold text-navy outline-none focus:border-primary"
          />
        ))}
      </div>
    </>
  );
}

export function ErrorNote({ message }: { message?: string }) {
  if (!message) return null;
  return (
    <p role="alert" className="mt-3 rounded-lg bg-danger-soft px-3 py-2.5 text-sm text-danger">
      {message}
    </p>
  );
}

export function DemoNote() {
  return (
    <p className="mt-4 rounded-lg bg-amber-soft px-3 py-2.5 text-xs leading-[1.5] text-navy">
      <strong className="font-semibold">Demo mode.</strong> No Supabase project
      is connected, so sign-in is skipped and pages show sample data.
    </p>
  );
}

function formatPhone(phone: string) {
  const digits = phone.replace(/^\+91/, "");
  return digits.length === 10 ? `+91 ${digits.slice(0, 5)} ${digits.slice(5)}` : phone;
}
