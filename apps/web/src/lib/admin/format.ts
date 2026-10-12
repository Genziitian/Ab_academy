export function formatWhen(value: string) {
  const date = new Date(value);
  if (Number.isNaN(date.getTime())) return value;
  return date.toLocaleString("en-IN", {
    day: "numeric",
    month: "short",
    hour: "numeric",
    minute: "2-digit",
    hour12: true,
    // The academy runs on India time whatever zone the server is in.
    timeZone: "Asia/Kolkata",
  });
}

export function describeAudience(kind: string, value: string | null) {
  switch (kind) {
    case "all":
      return "Everyone";
    case "class":
      return `Class ${value}`;
    case "course":
      return `Course: ${value}`;
    case "student":
      return `Student: ${value}`;
    default:
      return kind;
  }
}

export const formatRupees = (amount: number) =>
  new Intl.NumberFormat("en-IN", {
    style: "currency",
    currency: "INR",
    maximumFractionDigits: 0,
  }).format(amount);
