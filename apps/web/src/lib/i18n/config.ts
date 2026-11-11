// Shared by server and client code: the two site languages and how dates,
// times and subject names are written in each.

export const LOCALES = ["en", "hi"] as const;
export type Locale = (typeof LOCALES)[number];

/** Remembers the visitor's choice for a year. Read on the server, set in the browser. */
export const LOCALE_COOKIE = "ab_lang";

export function isLocale(value: unknown): value is Locale {
  return value === "en" || value === "hi";
}

/** The Intl locale used for dates and numbers. Hindi keeps Latin digits. */
export function intlLocale(locale: Locale) {
  return locale === "hi" ? "hi-IN" : "en-IN";
}

const IST = "Asia/Kolkata";

/** "16 Nov 2026" / "16 नव॰ 2026". */
export function formatDate(
  value: Date | string | number,
  locale: Locale,
  options: Intl.DateTimeFormatOptions = { day: "numeric", month: "short", year: "numeric" },
) {
  return new Date(value).toLocaleDateString(intlLocale(locale), { timeZone: IST, ...options });
}

/** "Mon, 16 Nov · 6:00 pm". */
export function formatDateTime(value: Date | string | number, locale: Locale) {
  const d = new Date(value);
  const day = d.toLocaleDateString(intlLocale(locale), { weekday: "short", day: "numeric", month: "short", timeZone: IST });
  const time = d.toLocaleTimeString(intlLocale(locale), { hour: "numeric", minute: "2-digit", timeZone: IST });
  return `${day} · ${time}`;
}

export function formatTime(value: Date | string | number, locale: Locale) {
  return new Date(value).toLocaleTimeString(intlLocale(locale), { hour: "numeric", minute: "2-digit", timeZone: IST });
}

/** Hour of the day in India, for greetings. */
export function istHour(now = Date.now()) {
  return Number(new Date(now).toLocaleString("en-US", { hour: "numeric", hour12: false, timeZone: IST })) % 24;
}
