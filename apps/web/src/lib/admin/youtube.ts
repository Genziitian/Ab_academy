/**
 * The 11-character YouTube id from whatever staff paste: a bare id, or a
 * watch / youtu.be / embed / shorts / live link. Null when it is not one.
 */
export function youtubeId(input: string): string | null {
  const value = input.trim();
  if (/^[A-Za-z0-9_-]{11}$/.test(value)) return value;
  try {
    const url = new URL(value.startsWith("http") ? value : `https://${value}`);
    const host = url.hostname.replace(/^www\.|^m\./, "");
    if (host === "youtu.be") return clean(url.pathname.slice(1));
    if (host.endsWith("youtube.com") || host.endsWith("youtube-nocookie.com")) {
      const v = url.searchParams.get("v");
      if (v) return clean(v);
      const match = url.pathname.match(/^\/(?:embed|shorts|live|v)\/([^/?#]+)/);
      if (match) return clean(match[1]);
    }
  } catch {
    // Not a URL.
  }
  return null;
}

const clean = (id: string) => (/^[A-Za-z0-9_-]{11}$/.test(id) ? id : null);
