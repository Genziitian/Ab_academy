import { ModalActions, ModalForm } from "@/components/admin/Dialog";
import { CheckboxField, Field, SelectField } from "@/components/admin/Fields";
import type { AdminLesson } from "@/lib/admin/types";
import { saveLectureAction } from "./actions";

const TYPES = [
  { value: "VIDEO", label: "Recorded lecture / practice session" },
  { value: "LIVE", label: "Live class recording" },
  { value: "TEST", label: "Test" },
  { value: "PDF", label: "PDF only" },
];

/** Add or edit one lecture. Only the fields a teacher needs, in one column. */
export function LectureForm({
  courseId,
  chapterId,
  lesson,
}: {
  courseId: string;
  chapterId: string;
  lesson?: AdminLesson;
}) {
  const hasVideo = Boolean(lesson?.videoRef || lesson?.storagePath);
  return (
    <ModalForm action={saveLectureAction}>
      <input type="hidden" name="courseId" value={courseId} />
      <input type="hidden" name="chapterId" value={chapterId} />
      {lesson ? <input type="hidden" name="id" value={lesson.id} /> : null}

      <Field label="Lecture title" name="title" placeholder="Lecture — Electric Charges & Fields" defaultValue={lesson?.title} required />

      <div className="rounded-2xl border border-sand bg-paper p-4">
        <p className="text-[13px] font-semibold text-coal">Video</p>
        {hasVideo ? (
          <p className="mt-1 text-sm text-[#1d6b3d]">
            ✓ Video linked{lesson?.videoProvider === "youtube" ? " (YouTube)" : " (uploaded file)"}. Paste a new link only
            to replace it.
          </p>
        ) : (
          <p className="mt-1 text-sm text-taupe">Paste an unlisted YouTube link, or upload an mp4.</p>
        )}
        <div className="mt-3 space-y-3">
          <Field label="YouTube link" name="youtube" placeholder="https://youtu.be/…" />
          <label className="block">
            <span className="text-[13px] font-semibold text-coal">…or upload an mp4</span>
            <input type="file" name="videoFile" accept="video/mp4,video/webm" className="mt-1.5 block w-full text-sm text-taupe" />
          </label>
        </div>
      </div>

      <div className="grid grid-cols-[1fr_120px] gap-3">
        <SelectField label="Type" name="lessonType" defaultValue={lesson?.lessonType ?? "VIDEO"} options={TYPES} />
        <Field
          label="Minutes"
          name="minutes"
          type="number"
          min="0"
          defaultValue={lesson?.durationSeconds ? String(Math.round(lesson.durationSeconds / 60)) : ""}
        />
      </div>

      <details className="rounded-2xl border border-sand bg-paper p-4" open={!lesson}>
        <summary className="cursor-pointer text-[13px] font-semibold text-coal">
          Attach notes PDF {lesson?.resources.length ? `(${lesson.resources.length} attached)` : "(optional)"}
        </summary>
        <div className="mt-3 space-y-3">
          <Field label="Google Drive link" name="notesLink" placeholder="https://drive.google.com/file/d/…" hint="Share the file as 'Anyone with the link'." />
          <Field label="Notes title" name="notesTitle" placeholder="Chapter notes" />
        </div>
      </details>

      <div className="flex flex-wrap gap-x-6">
        <CheckboxField label="Published — students can watch it" name="isPublished" defaultChecked={lesson ? lesson.isPublished : true} />
        <CheckboxField label="Free preview for everyone" name="isDemo" defaultChecked={lesson?.isDemo} />
      </div>

      <ModalActions>{lesson ? "Save lecture" : "Add lecture"}</ModalActions>
    </ModalForm>
  );
}
