import { NotesBrowser } from "@/components/NotesBrowser";
import { publicNotes } from "@/lib/notes";

export const metadata = {
  title: "Notes",
  description:
    "Chapter-wise PDF notes, formula sheets and syllabus for Bihar Board Class 11 & 12.",
};

export default function NotesPage() {
  return <NotesBrowser notes={publicNotes} />;
}
