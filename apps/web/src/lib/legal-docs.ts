/** The legal pages, in menu order. Labels come from the dictionary (legalDocs). */
export const LEGAL_DOCS = [
  { href: "/privacy", key: "privacy" },
  { href: "/terms", key: "terms" },
  { href: "/refund", key: "refund" },
  { href: "/data-deletion", key: "deletion" },
] as const;

export type LegalHref = (typeof LEGAL_DOCS)[number]["href"];
