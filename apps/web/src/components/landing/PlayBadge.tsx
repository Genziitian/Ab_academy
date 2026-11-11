import { PLAY_STORE_URL } from "@/lib/landing";

/** "Google Play" download button. Renders nothing until the listing URL is set. */
export function PlayBadge({ tone = "dark", className = "" }: { tone?: "dark" | "light"; className?: string }) {
  if (!PLAY_STORE_URL) return null;
  const colors = tone === "dark" ? "bg-ab-ink text-white hover:bg-black" : "bg-white text-ab-ink hover:bg-ab-canvas";
  return (
    <a
      href={PLAY_STORE_URL}
      target="_blank"
      rel="noopener noreferrer"
      className={`inline-flex h-12 shrink-0 items-center gap-2.5 rounded-[10px] px-4 ${colors} ${className}`}
    >
      <svg width="18" height="18" viewBox="0 0 24 24" aria-hidden fill="currentColor">
        <path d="M4 2.8v18.4c0 .5.5.8.9.6l15.6-9.2c.4-.3.4-.9 0-1.2L4.9 2.2c-.4-.2-.9.1-.9.6Z" />
      </svg>
      <span className="flex flex-col leading-[1.1]">
        <span className="text-[10px] opacity-70">GET IT ON</span>
        <span className="text-[15px] font-medium">Google Play</span>
      </span>
    </a>
  );
}
