import Link from "next/link";
import { PageHeader } from "@/components/admin/AdminChrome";
import { IconExternal, IconFile, IconPencil, IconPlus } from "@/components/admin/AdminIcons";
import { ConfirmDelete, Modal, ModalActions, ModalForm } from "@/components/admin/Dialog";
import { CheckboxField, Field } from "@/components/admin/Fields";
import { getFreeNotes, type FreeNote } from "@/lib/notes";
import {
  addChapterAction,
  addSubjectAction,
  deleteChapterAction,
  deleteNoteAction,
  deleteSubjectAction,
  renameChapterAction,
  renameSubjectAction,
  saveNoteAction,
} from "./actions";

export const metadata = { title: "Free notes" };

const ghost =
  "inline-flex h-9 items-center gap-1.5 rounded-full border border-sand bg-cream px-3.5 text-sm font-semibold text-coal hover:border-clay hover:text-clay";
const primarySm =
  "inline-flex h-9 items-center gap-1.5 rounded-full bg-clay px-4 text-sm font-semibold text-white hover:bg-coal";

function NoteForm({ chapterId, note }: { chapterId: string; note?: FreeNote }) {
  return (
    <ModalForm action={saveNoteAction}>
      <input type="hidden" name="chapterId" value={chapterId} />
      {note ? <input type="hidden" name="id" value={note.id} /> : null}
      <Field label="Title" name="title" placeholder="Chapter notes + solved PYQs" defaultValue={note?.title} required />
      <Field
        label={note ? "Replace Google Drive link (optional)" : "Google Drive link of the PDF"}
        name="link"
        placeholder="https://drive.google.com/file/d/…"
        hint="In Drive: Share → General access → Anyone with the link."
      />
      <CheckboxField label="Published — visible on the Notes page" name="isPublished" defaultChecked={note ? note.isPublished : true} />
      <ModalActions>{note ? "Save notes" : "Add notes"}</ModalActions>
    </ModalForm>
  );
}

export default async function AdminFreeNotesPage() {
  const subjects = await getFreeNotes();
  const total = subjects.reduce((n, s) => n + s.chapters.reduce((m, c) => m + c.notes.length, 0), 0);

  return (
    <>
      <PageHeader
        title="Free notes"
        description="The public Notes page. Add a subject, its chapters, then a Google Drive PDF for each chapter."
        action={
          <div className="flex flex-wrap gap-2">
            <Link
              href="/notes"
              target="_blank"
              className="inline-flex h-12 items-center gap-2 rounded-full border border-sand px-5 text-[15px] font-semibold text-coal hover:border-clay"
            >
              <IconExternal size={17} />
              View Notes page
            </Link>
            <Modal
              title="Add a subject"
              triggerClassName="inline-flex h-12 items-center gap-2 rounded-full bg-clay px-6 text-[15px] font-semibold text-white hover:bg-coal"
              triggerLabel={
                <>
                  <IconPlus size={18} />
                  Add subject
                </>
              }
            >
              <ModalForm action={addSubjectAction}>
                <Field label="Subject" name="name" placeholder="Physics" required />
                <ModalActions>Add subject</ModalActions>
              </ModalForm>
            </Modal>
          </div>
        }
      />

      <p className="-mt-3 mb-6 text-sm text-taupe">
        {subjects.length} subject{subjects.length === 1 ? "" : "s"} · {total} PDF{total === 1 ? "" : "s"}. While there are
        no notes, the website shows “Notes are coming soon”.
      </p>

      {subjects.length === 0 ? (
        <div className="rounded-[22px] border border-dashed border-sand bg-cream px-6 py-14 text-center">
          <p className="font-serif text-3xl">No subjects yet</p>
          <p className="mt-2 text-taupe">Start with “Add subject” — for example Physics, Chemistry and Maths.</p>
        </div>
      ) : (
        <div className="grid gap-5 xl:grid-cols-2">
          {subjects.map((subject) => (
            <section key={subject.id} className="flex flex-col rounded-[22px] border border-sand bg-cream">
              <header className="flex flex-wrap items-center gap-2 border-b border-sand px-5 py-4">
                <h2 className="mr-auto font-serif text-[32px] leading-none">{subject.name}</h2>
                <Modal title={`Add a chapter to ${subject.name}`} triggerClassName={primarySm} triggerLabel={<><IconPlus size={16} />Chapter</>}>
                  <ModalForm action={addChapterAction}>
                    <input type="hidden" name="subjectId" value={subject.id} />
                    <Field label="Chapter name" name="title" placeholder="Electric Charges & Fields" required />
                    <ModalActions>Add chapter</ModalActions>
                  </ModalForm>
                </Modal>
                <Modal title="Rename subject" triggerClassName={ghost} triggerAriaLabel="Rename subject" triggerLabel={<IconPencil size={15} />}>
                  <ModalForm action={renameSubjectAction}>
                    <input type="hidden" name="id" value={subject.id} />
                    <Field label="Subject" name="name" defaultValue={subject.name} required />
                    <ModalActions>Save</ModalActions>
                  </ModalForm>
                </Modal>
                <ConfirmDelete
                  compact
                  label="Delete subject"
                  action={deleteSubjectAction}
                  fields={{ id: subject.id }}
                  title="Delete this subject?"
                  message={
                    <>
                      <strong className="text-coal">{subject.name}</strong>, its {subject.chapters.length} chapters and all
                      their notes will disappear from the Notes page. Files in Google Drive are not touched.
                    </>
                  }
                  confirmLabel="Delete subject"
                />
              </header>

              {subject.chapters.length === 0 ? (
                <p className="px-5 py-6 text-sm text-taupe">No chapters yet.</p>
              ) : (
                <ol className="divide-y divide-sand">
                  {subject.chapters.map((chapter, i) => (
                    <li key={chapter.id} className="px-5 py-3.5">
                      <div className="flex flex-wrap items-center gap-2">
                        <span className="w-7 font-semibold tabular-nums text-clay">{i + 1}.</span>
                        <span className="mr-auto min-w-0 flex-1 truncate font-semibold text-coal">{chapter.title}</span>
                        <Modal title={`Add notes to ${chapter.title}`} triggerClassName={ghost} triggerLabel={<><IconPlus size={15} />PDF</>}>
                          <NoteForm chapterId={chapter.id} />
                        </Modal>
                        <Modal title="Rename chapter" triggerClassName={ghost} triggerAriaLabel="Rename chapter" triggerLabel={<IconPencil size={15} />}>
                          <ModalForm action={renameChapterAction}>
                            <input type="hidden" name="id" value={chapter.id} />
                            <Field label="Chapter name" name="title" defaultValue={chapter.title} required />
                            <ModalActions>Save</ModalActions>
                          </ModalForm>
                        </Modal>
                        <ConfirmDelete
                          compact
                          label="Delete chapter"
                          action={deleteChapterAction}
                          fields={{ id: chapter.id }}
                          title="Delete this chapter?"
                          message={
                            <>
                              <strong className="text-coal">{chapter.title}</strong>
                              {chapter.notes.length ? ` and its ${chapter.notes.length} notes` : ""} will be removed from the
                              Notes page.
                            </>
                          }
                          confirmLabel="Delete chapter"
                        />
                      </div>
                      {chapter.notes.length ? (
                        <ul className="mt-2 flex flex-col gap-1 pl-9">
                          {chapter.notes.map((note) => (
                            <li key={note.id} className="flex items-center gap-2 rounded-xl bg-paper px-3 py-1.5 text-sm">
                              <IconFile size={15} />
                              <span className="min-w-0 flex-1 truncate text-coal">{note.title}</span>
                              {note.isPublished ? null : (
                                <span className="rounded-full bg-cream px-2 py-0.5 text-xs font-semibold text-taupe">Draft</span>
                              )}
                              <Modal title="Edit notes" triggerClassName="flex size-8 items-center justify-center rounded-full text-taupe hover:bg-cream hover:text-coal" triggerAriaLabel="Edit notes" triggerLabel={<IconPencil size={14} />}>
                                <NoteForm chapterId={chapter.id} note={note} />
                              </Modal>
                              <ConfirmDelete
                                compact
                                label="Delete notes"
                                action={deleteNoteAction}
                                fields={{ id: note.id }}
                                title="Delete these notes?"
                                message={
                                  <>
                                    <strong className="text-coal">{note.title}</strong> will be removed from the Notes page.
                                    The PDF in Google Drive is not touched.
                                  </>
                                }
                                confirmLabel="Delete notes"
                              />
                            </li>
                          ))}
                        </ul>
                      ) : null}
                    </li>
                  ))}
                </ol>
              )}
            </section>
          ))}
        </div>
      )}
    </>
  );
}
