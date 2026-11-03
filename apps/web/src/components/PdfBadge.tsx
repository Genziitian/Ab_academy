export function PdfBadge({ size = 40 }: { size?: number }) {
  return (
    <span
      className="flex shrink-0 items-center justify-center rounded-lg bg-pdf-soft text-[10px] font-bold text-danger"
      style={{ width: size, height: size }}
    >
      PDF
    </span>
  );
}
