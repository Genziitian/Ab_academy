import { PLAY_STORE_URL } from "@/lib/landing";

/** "Get it on Google Play". Renders nothing until the listing URL is set. */
export function PlayBadge({ tone = "dark", className = "" }: { tone?: "dark" | "light"; className?: string }) {
  if (!PLAY_STORE_URL) return null;
  const colors =
    tone === "dark" ? "bg-coal text-cream hover:bg-coal-line" : "bg-cream text-coal hover:bg-white";
  return (
    <a
      href={PLAY_STORE_URL}
      target="_blank"
      rel="noopener noreferrer"
      className={`flex h-[58px] shrink-0 flex-col justify-center rounded-2xl px-6 leading-[1.1] ${colors} ${className}`}
    >
      <span className="text-[11px] font-semibold uppercase tracking-[0.08em] opacity-70">Get it on</span>
      <span className="text-lg font-bold">Google Play</span>
    </a>
  );
}
