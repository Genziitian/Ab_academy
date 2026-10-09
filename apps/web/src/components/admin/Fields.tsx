// Shared form primitives. Each admin page previously declared its own copy of
// Field/SelectField; these are the one definition they all import.

export function Field({
  label,
  name,
  type = "text",
  placeholder,
  defaultValue,
  required,
  hint,
  step,
  min,
}: {
  label: string;
  name: string;
  type?: string;
  placeholder?: string;
  defaultValue?: string | number;
  required?: boolean;
  hint?: string;
  step?: string;
  min?: string;
}) {
  return (
    <label className="block">
      <span className="text-xs font-medium text-navy">{label}</span>
      <input
        name={name}
        type={type}
        placeholder={placeholder}
        defaultValue={defaultValue}
        required={required}
        step={step}
        min={min}
        className="mt-1 w-full rounded-xl border border-border bg-surface px-3 py-2 text-sm text-navy outline-none focus:border-primary"
      />
      {hint ? <span className="mt-1 block text-xs text-muted">{hint}</span> : null}
    </label>
  );
}

export function TextAreaField({
  label,
  name,
  placeholder,
  defaultValue,
  rows = 3,
  required,
  hint,
}: {
  label: string;
  name: string;
  placeholder?: string;
  defaultValue?: string;
  rows?: number;
  required?: boolean;
  hint?: string;
}) {
  return (
    <label className="block">
      <span className="text-xs font-medium text-navy">{label}</span>
      <textarea
        name={name}
        rows={rows}
        placeholder={placeholder}
        defaultValue={defaultValue}
        required={required}
        className="mt-1 w-full resize-y rounded-xl border border-border bg-surface px-3 py-2 text-sm text-navy outline-none focus:border-primary"
      />
      {hint ? <span className="mt-1 block text-xs text-muted">{hint}</span> : null}
    </label>
  );
}

export type Option = { value: string; label: string };

export function SelectField({
  label,
  name,
  options,
  defaultValue,
  hint,
  id,
}: {
  label: string;
  name: string;
  options: Array<string | Option>;
  defaultValue?: string;
  hint?: string;
  id?: string;
}) {
  const normalised: Option[] = options.map((o) =>
    typeof o === "string" ? { value: o, label: o } : o,
  );

  return (
    <label className="block">
      <span className="text-xs font-medium text-navy">{label}</span>
      <select
        id={id}
        name={name}
        defaultValue={defaultValue}
        className="mt-1 w-full rounded-xl border border-border bg-surface px-3 py-2 text-sm text-navy outline-none focus:border-primary"
      >
        {normalised.map((option) => (
          <option key={option.value} value={option.value}>
            {option.label}
          </option>
        ))}
      </select>
      {hint ? <span className="mt-1 block text-xs text-muted">{hint}</span> : null}
    </label>
  );
}

export function CheckboxField({
  label,
  name,
  defaultChecked,
}: {
  label: string;
  name: string;
  defaultChecked?: boolean;
}) {
  return (
    <label className="flex items-center gap-2 pt-1 text-sm text-navy">
      <input
        type="checkbox"
        name={name}
        defaultChecked={defaultChecked}
        className="size-4"
      />
      {label}
    </label>
  );
}

export function SubmitButton({
  children,
  variant = "primary",
}: {
  children: React.ReactNode;
  variant?: "primary" | "ghost" | "danger";
}) {
  const styles = {
    primary: "bg-primary text-white hover:bg-primary-dark",
    ghost: "border border-border bg-surface text-navy hover:bg-surface-soft",
    danger: "bg-pink text-white hover:opacity-90",
  }[variant];

  return (
    <button
      type="submit"
      className={`mt-2 w-full rounded-xl px-4 py-2.5 text-sm font-semibold transition-colors ${styles}`}
    >
      {children}
    </button>
  );
}
