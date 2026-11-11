"use client";

import { createContext, useContext } from "react";
import type { Locale } from "./config";
import { dictionaries } from "./dictionaries";

const LocaleContext = createContext<Locale>("en");

/** Set once in the root layout from the server's reading of the cookie. */
export function LocaleProvider({ locale, children }: { locale: Locale; children: React.ReactNode }) {
  return <LocaleContext.Provider value={locale}>{children}</LocaleContext.Provider>;
}

export function useLocale() {
  return useContext(LocaleContext);
}

export function useT() {
  return dictionaries[useContext(LocaleContext)];
}
