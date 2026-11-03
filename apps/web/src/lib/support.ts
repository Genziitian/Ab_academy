// Where "Help" goes across the site. Set NEXT_PUBLIC_WHATSAPP_NUMBER (digits
// with country code, e.g. 919000000000) to open a WhatsApp chat; without it
// students land on the contact page.
const whatsapp = (process.env.NEXT_PUBLIC_WHATSAPP_NUMBER ?? "").replace(/\D/g, "");

export const helpIsWhatsApp = whatsapp.length > 0;

export const helpHref = helpIsWhatsApp
  ? `https://wa.me/${whatsapp}?text=${encodeURIComponent("Hi AB Academy, I need help choosing a course.")}`
  : "/contact";
