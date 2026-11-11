"use client";

import Link from "next/link";
import { useActionState, useRef, useState } from "react";
import { GoogleMark } from "@/components/icons";
import { btn } from "@/components/ui";
import { useT } from "@/lib/i18n/client";
import { sendPhoneOtp, signInWithGoogle, signInWithPassword, verifyPhoneOtp, type LoginState } from "./actions";

const initial: LoginState = {};

/** Also used by the staff sign-in at /access. */
export const input =
  "h-12 rounded-[10px] border border-ab-rule-strong bg-ab-panel px-3.5 text-[15px] font-normal text-ab-ink outline-none focus:border-ab-ink";
export const primaryButton = `${btn.primary} !h-12 w-full`;

/** Student sign-in: phone OTP, Google, or email for academy-made accounts. */
export function LoginForm({ next, demo }: { next: string; demo: boolean }) {
  const t = useT();
  const l = t.login;
  const [sendState, sendAction, sending] = useActionState(sendPhoneOtp, initial);
  const [verifyState, verifyAction, verifying] = useActionState(verifyPhoneOtp, initial);
  const [googleState, googleAction, googlePending] = useActionState(signInWithGoogle, initial);
  // Lets "Change number" step back even after a code was sent.
  const [editingPhone, setEditingPhone] = useState(false);

  const otpStep = !editingPhone && Boolean(sendState.sent);
  const phone = sendState.phone ?? "";
  const error = otpStep ? verifyState.error : (sendState.error ?? googleState.error);

  return (
    <>
      <h2 className="ab-title text-[30px]">{otpStep ? l.otpTitle : l.title}</h2>
      <p className="mt-2 text-[15px] text-ab-ink-2">{otpStep ? l.sentTo(formatPhone(phone)) : l.sub}</p>

      {otpStep ? (
        <form action={verifyAction} className="mt-8">
          <input type="hidden" name="phone" value={phone} />
          <input type="hidden" name="next" value={next} />
          <OtpBoxes />
          <ErrorNote message={error} />
          <button type="submit" disabled={verifying} className={`mt-4 ${primaryButton}`}>
            {verifying ? l.verifying : l.verify}
          </button>
          <button type="button" onClick={() => setEditingPhone(true)} className="mt-3 w-full text-sm text-ab-ink-2 hover:text-ab-ink">
            {l.changeNumber}
          </button>
        </form>
      ) : (
        <>
          <form
            action={(formData) => {
              setEditingPhone(false);
              sendAction(formData);
            }}
            className="mt-8"
          >
            <label className="flex flex-col gap-1.5 text-sm font-medium text-ab-ink">
              {l.mobile}
              <div className="flex h-12 overflow-hidden rounded-[10px] border border-ab-rule-strong bg-ab-panel focus-within:border-ab-ink">
                <span className="ab-num flex items-center border-r border-ab-rule bg-ab-canvas px-3.5 text-[15px] text-ab-ink-2">+91</span>
                <input
                  name="phone"
                  inputMode="numeric"
                  autoComplete="tel-national"
                  required
                  placeholder="98765 43210"
                  className="ab-num min-w-0 flex-1 px-3.5 text-[15px] font-normal outline-none"
                />
              </div>
            </label>
            <ErrorNote message={error} />
            {demo ? (
              <Link href={next} className={`mt-3.5 ${primaryButton}`}>
                {l.continueDemo}
              </Link>
            ) : (
              <button type="submit" disabled={sending} className={`mt-3.5 ${primaryButton}`}>
                {sending ? l.sending : l.sendOtp}
              </button>
            )}
          </form>

          <div className="my-6 flex items-center gap-3" aria-hidden>
            <span className="h-px flex-1 bg-ab-rule" />
            <span className="text-xs text-ab-ink-3">{l.or}</span>
            <span className="h-px flex-1 bg-ab-rule" />
          </div>

          <form action={googleAction}>
            <input type="hidden" name="next" value={next} />
            <button type="submit" disabled={googlePending || demo} className={`${btn.secondary} !h-12 w-full`}>
              <GoogleMark />
              {googlePending ? l.redirecting : l.google}
            </button>
          </form>

          {demo ? null : <EmailLogin next={next} />}
          {demo ? <DemoNote /> : null}

          <p className="mt-6 text-center text-xs leading-[1.6] text-ab-ink-3">
            {l.agree}{" "}
            <Link href="/terms" className="text-ab-ink underline underline-offset-2">
              {l.terms}
            </Link>{" "}
            {l.and}{" "}
            <Link href="/privacy" className="text-ab-ink underline underline-offset-2">
              {l.privacy}
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
  const l = useT().login;
  const [state, action, pending] = useActionState(signInWithPassword, initial);
  return (
    <details className="group mt-5" open={Boolean(state.error)}>
      <summary className="mx-auto w-fit cursor-pointer list-none text-sm text-ab-ink-2 underline decoration-ab-rule-strong underline-offset-4 hover:text-ab-ink">
        {l.emailToggle}
      </summary>
      <form action={action} className="mt-4 flex flex-col gap-3">
        <input type="hidden" name="next" value={next} />
        <label className="flex flex-col gap-1.5 text-sm font-medium text-ab-ink">
          {l.email}
          <input name="email" type="email" autoComplete="email" required className={input} />
        </label>
        <label className="flex flex-col gap-1.5 text-sm font-medium text-ab-ink">
          {l.password}
          <input name="password" type="password" autoComplete="current-password" required className={input} />
        </label>
        <ErrorNote message={state.error} />
        <button type="submit" disabled={pending} className={`mt-1 ${primaryButton}`}>
          {pending ? l.signingIn : l.signIn}
        </button>
        <p className="text-center text-xs text-ab-ink-3">{l.emailNote}</p>
      </form>
    </details>
  );
}

/** Six single-digit boxes that auto-advance and accept a pasted code. */
function OtpBoxes() {
  const l = useT().login;
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
            aria-label={l.digit(index + 1)}
            autoFocus={index === 0}
            onChange={(e) => setAt(index, e.target.value)}
            onKeyDown={(e) => {
              if (e.key === "Backspace" && !digit && index > 0) refs.current[index - 1]?.focus();
            }}
            className="ab-num h-14 min-w-0 flex-1 rounded-[10px] border border-ab-rule-strong bg-ab-panel text-center text-[22px] font-medium text-ab-ink outline-none focus:border-ab-ink"
          />
        ))}
      </div>
    </>
  );
}

export function ErrorNote({ message }: { message?: string }) {
  if (!message) return null;
  return (
    <p role="alert" className="mt-3 rounded-[10px] border border-[#f3cdc8] bg-ab-danger-soft px-3.5 py-2.5 text-sm text-ab-danger">
      {message}
    </p>
  );
}

export function DemoNote() {
  const l = useT().login;
  return (
    <p className="mt-5 rounded-[10px] border border-ab-rule bg-ab-canvas px-3.5 py-3 text-xs leading-[1.5] text-ab-ink-2">
      <strong className="font-medium text-ab-ink">{l.demoTitle}</strong> {l.demoBody}
    </p>
  );
}

function formatPhone(phone: string) {
  const digits = phone.replace(/^\+91/, "");
  return digits.length === 10 ? `+91 ${digits.slice(0, 5)} ${digits.slice(5)}` : phone;
}
