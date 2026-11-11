/**
 * A same-site path to send someone to after sign-in, or the fallback.
 *
 * `next` comes from the URL, so it must not be able to leave the site. A
 * leading "//" or "/\" is read by browsers as another host, and control
 * characters can be used to smuggle one in, so all of those are refused.
 */
export function safeNext(value: unknown, fallback: string): string {
  const next = typeof value === "string" ? value : "";
  if (!next.startsWith("/")) return fallback;
  if (next.startsWith("//") || next.includes("\\")) return fallback;
  if (/[\u0000-\u001f\u007f]/.test(next)) return fallback;
  if (next.length > 512) return fallback;
  return next;
}
