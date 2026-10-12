export type PublicNote = {
  classLevel: 11 | 12;
  subject: string;
  title: string;
  meta: string;
  /** Free notes open for anyone signed in; the rest unlock with a course. */
  free?: boolean;
};

export const publicNotes: PublicNote[] = [
  { classLevel: 12, subject: "Physics", title: "Electric Charges and Fields", meta: "18 pages · 2.4 MB", free: true },
  { classLevel: 12, subject: "Physics", title: "Current Electricity — formula sheet", meta: "4 pages · 0.9 MB", free: true },
  { classLevel: 12, subject: "Chemistry", title: "Solutions & Electrochemistry", meta: "22 pages · 3.1 MB" },
  { classLevel: 12, subject: "Mathematics", title: "Integrals — important questions", meta: "16 pages · 1.6 MB" },
  { classLevel: 12, subject: "Biology", title: "Reproduction in Organisms", meta: "20 pages · 2.8 MB", free: true },
  { classLevel: 12, subject: "Accountancy", title: "Partnership Accounts", meta: "14 pages · 1.2 MB" },
  { classLevel: 12, subject: "Economics", title: "Macroeconomics — National Income", meta: "12 pages · 1.1 MB", free: true },
  { classLevel: 12, subject: "All subjects", title: "Bihar Board 2027 syllabus", meta: "PDF · 0.6 MB", free: true },
  { classLevel: 11, subject: "Physics", title: "Units and Measurements", meta: "10 pages · 1.0 MB", free: true },
  { classLevel: 11, subject: "Chemistry", title: "Structure of Atom", meta: "16 pages · 2.0 MB" },
  { classLevel: 11, subject: "Mathematics", title: "Sets and Functions", meta: "12 pages · 1.3 MB" },
  { classLevel: 11, subject: "Accountancy", title: "Journal and Ledger", meta: "14 pages · 1.4 MB", free: true },
];
