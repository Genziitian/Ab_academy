import "server-only";
import { cookies, headers } from "next/headers";
import { cache } from "react";
import { LOCALE_COOKIE, isLocale, type Locale } from "./config";
import { dictionaries } from "./dictionaries";

/**
 * The visitor's language: their saved choice, else Hindi when the browser asks
 * for Hindi first, else English.
 */
export const getLocale = cache(async (): Promise<Locale> => {
  const saved = (await cookies()).get(LOCALE_COOKIE)?.value;
  if (isLocale(saved)) return saved;
  const accept = (await headers()).get("accept-language") ?? "";
  return /^\s*hi\b/i.test(accept) ? "hi" : "en";
});

/** The dictionary for this request, plus the locale it belongs to. */
export async function getT() {
  const locale = await getLocale();
  return { t: dictionaries[locale], locale };
}
