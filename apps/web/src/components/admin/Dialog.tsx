"use client";

import { createContext, useContext, useEffect, useRef, useState } from "react";
import { useFormStatus } from "react-dom";
import { IconTrash, IconX } from "./AdminIcons";

const CloseContext = createContext<() => void>(() => {});

/**
 * A pop-up built on <dialog>: focus stays inside, Escape closes it and the
 * page behind does not scroll. The trigger button is rendered here so server
 * pages can use it without passing functions.
 */
export function Modal({
  title,
  triggerLabel,
  triggerClassName,
  triggerAriaLabel,
  children,
  wide = false,
}: {
  title: string;
  triggerLabel: React.ReactNode;
  triggerClassName: string;
  triggerAriaLabel?: string;
  children: React.ReactNode;
  wide?: boolean;
}) {
  const ref = useRef<HTMLDialogElement>(null);
  const [open, setOpen] = useState(false);

  useEffect(() => {
    if (open && !ref.current?.open) ref.current?.showModal();
  }, [open]);

  const close = () => {
    ref.current?.close();
    setOpen(false);
  };

  return (
    <>
      <button
        type="button"
        onClick={() => setOpen(true)}
        className={triggerClassName}
        aria-label={triggerAriaLabel}
        title={triggerAriaLabel}
      >
        {triggerLabel}
      </button>
      {open ? (
        <dialog
          ref={ref}
          onClose={() => setOpen(false)}
          onClick={(e) => {
            if (e.target === ref.current) close();
          }}
          className={`m-auto max-h-[90vh] w-[calc(100%-32px)] overflow-y-auto rounded-[24px] border border-sand bg-cream p-0 text-left text-coal shadow-[0_30px_80px_rgba(28,24,20,0.3)] backdrop:bg-coal/50 ${
            wide ? "max-w-[720px]" : "max-w-[520px]"
          }`}
        >
          <div className="sticky top-0 z-10 flex items-center justify-between gap-4 border-b border-sand bg-cream px-6 py-4">
            <h2 className="font-serif text-[28px] leading-none">{title}</h2>
            <button
              type="button"
              onClick={close}
              aria-label="Close"
              className="flex size-9 shrink-0 items-center justify-center rounded-full border border-sand hover:bg-paper"
            >
              <IconX size={18} />
            </button>
          </div>
          <div className="px-6 py-5">
            <CloseContext.Provider value={close}>{children}</CloseContext.Provider>
          </div>
        </dialog>
      ) : null}
    </>
  );
}

/** A form inside a Modal: runs the server action, then closes the pop-up. */
export function ModalForm({
  action,
  children,
  className = "space-y-4",
}: {
  action: (formData: FormData) => void | Promise<void>;
  children: React.ReactNode;
  className?: string;
}) {
  const close = useContext(CloseContext);
  const [error, setError] = useState<string | null>(null);
  return (
    <form
      className={className}
      action={async (formData) => {
        setError(null);
        try {
          await action(formData);
          close();
        } catch (e) {
          // A redirect from the action is navigation, not a failure.
          if (typeof e === "object" && e && String((e as { digest?: string }).digest ?? "").startsWith("NEXT_REDIRECT")) throw e;
          setError(
            e instanceof Error && e.message && !e.message.includes("Server Components")
              ? e.message
              : "Could not save. Check the fields and try again.",
          );
        }
      }}
    >
      {children}
      {error ? (
        <p role="alert" className="rounded-xl border border-[#f2d6d6] bg-[#fdf1f1] px-4 py-3 text-sm text-[#9b2c2c]">
          {error}
        </p>
      ) : null}
    </form>
  );
}

export function CancelButton() {
  const close = useContext(CloseContext);
  return (
    <button
      type="button"
      onClick={close}
      className="h-11 rounded-full border border-sand px-5 text-sm font-semibold text-coal hover:bg-paper"
    >
      Cancel
    </button>
  );
}

export function SaveButton({ children, danger = false }: { children: React.ReactNode; danger?: boolean }) {
  const { pending } = useFormStatus();
  return (
    <button
      type="submit"
      disabled={pending}
      className={`h-11 rounded-full px-6 text-sm font-semibold text-white disabled:cursor-wait disabled:opacity-60 ${
        danger ? "bg-[#b23a26] hover:bg-[#8f2c1b]" : "bg-clay hover:bg-coal"
      }`}
    >
      {pending ? "Working…" : children}
    </button>
  );
}

/** Cancel + primary action, right-aligned at the bottom of a pop-up form. */
export function ModalActions({ children, danger = false }: { children: React.ReactNode; danger?: boolean }) {
  return (
    <div className="flex justify-end gap-2 pt-2">
      <CancelButton />
      <SaveButton danger={danger}>{children}</SaveButton>
    </div>
  );
}

/**
 * Delete with a confirmation pop-up. Nothing is deleted until the second,
 * clearly labelled click.
 */
export function ConfirmDelete({
  action,
  fields,
  title,
  message,
  confirmLabel = "Delete",
  compact = false,
  onDark = false,
  label = "Delete",
}: {
  action: (formData: FormData) => void | Promise<void>;
  fields: Record<string, string>;
  title: string;
  message: React.ReactNode;
  confirmLabel?: string;
  compact?: boolean;
  onDark?: boolean;
  label?: string;
}) {
  return (
    <Modal
      title={title}
      triggerAriaLabel={compact ? label : undefined}
      triggerClassName={
        compact
          ? "flex size-9 items-center justify-center rounded-full text-[#b23a26] hover:bg-[#fdf1f1]"
          : onDark
            ? "inline-flex h-10 items-center gap-1.5 rounded-full px-4 text-sm font-semibold text-[#f0a48a] hover:bg-white/10"
            : "inline-flex h-9 items-center gap-1.5 rounded-full px-3 text-sm font-semibold text-[#b23a26] hover:bg-[#fdf1f1]"
      }
      triggerLabel={
        compact ? (
          <IconTrash size={17} />
        ) : (
          <>
            <IconTrash size={16} />
            {label}
          </>
        )
      }
    >
      <ModalForm action={action}>
        {Object.entries(fields).map(([k, v]) => (
          <input key={k} type="hidden" name={k} value={v} />
        ))}
        <div className="text-[15px] leading-[1.6] text-taupe">{message}</div>
        <p className="text-sm font-semibold text-[#9b2c2c]">This cannot be undone.</p>
        <ModalActions danger>{confirmLabel}</ModalActions>
      </ModalForm>
    </Modal>
  );
}
