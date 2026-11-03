import { ModalActions, ModalForm } from "@/components/admin/Dialog";
import { CheckboxField, Field, SelectField, TextAreaField } from "@/components/admin/Fields";
import type { AdminCourse } from "@/lib/admin/types";
import { saveCourseAction } from "./actions";

/** Course details, in a pop-up. Used for "New course" and "Edit details". */
export function CourseForm({ course }: { course?: AdminCourse }) {
  return (
    <ModalForm action={saveCourseAction}>
      {course ? <input type="hidden" name="id" value={course.id} /> : null}
      <Field label="Course title" name="title" placeholder="Class 12 Physics Crash Course" defaultValue={course?.title} required />
      <div className="grid grid-cols-2 gap-3">
        <Field label="Class" name="classLevel" type="number" defaultValue={String(course?.classLevel ?? 12)} required />
        <SelectField
          label="Language"
          name="medium"
          defaultValue={course?.medium ?? "Hindi · Hinglish"}
          options={["Hindi · Hinglish", "Hindi", "Hinglish", "English"]}
        />
      </div>
      <div className="grid grid-cols-2 gap-3">
        <Field label="Price (₹)" name="priceInr" type="number" min="0" defaultValue={String(course?.priceInr ?? 249)} required />
        <Field
          label="Price before discount (₹)"
          name="originalPriceInr"
          type="number"
          min="0"
          defaultValue={String(course?.originalPriceInr ?? 0)}
          hint="0 shows no discount"
        />
      </div>
      <div className="grid grid-cols-2 gap-3">
        <Field label="Subjects" name="subjects" placeholder="Physics" defaultValue={course?.subjects.join(", ")} hint="Comma separated" />
        <Field label="Teacher" name="teachers" placeholder="Ajit Sir" defaultValue={course?.teachers.join(", ") ?? "Ajit Sir"} />
      </div>
      <TextAreaField
        label="Short description"
        name="description"
        placeholder="What the course covers, in one or two sentences."
        defaultValue={course?.description}
      />
      <TextAreaField
        label="Highlights"
        name="highlights"
        placeholder={"Recorded class for every chapter\nLive doubt sessions with Ajit Sir"}
        defaultValue={course?.highlights.join("\n")}
        hint="One per line"
        rows={3}
      />
      <label className="block">
        <span className="text-[13px] font-semibold text-coal">Thumbnail image</span>
        <input type="file" name="thumbnail" accept="image/png,image/jpeg,image/webp" className="mt-1.5 block w-full text-sm text-taupe" />
        <span className="mt-1 block text-xs text-taupe">16:9, up to 5 MB. Leave empty to keep the current one.</span>
      </label>
      {course?.thumbnailUrl ? <CheckboxField label="Remove current thumbnail" name="removeThumbnail" /> : null}
      <CheckboxField
        label={course ? "Published — visible on the website and app" : "Publish now"}
        name="isPublished"
        defaultChecked={course ? course.isPublished : false}
      />
      <ModalActions>{course ? "Save changes" : "Create course"}</ModalActions>
    </ModalForm>
  );
}
