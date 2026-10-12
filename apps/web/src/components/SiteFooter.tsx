import Link from "next/link";

const columns = [
  {
    title: "Crash courses",
    links: [
      { href: "/courses?class=12", label: "Class 12 crash courses" },
      { href: "/courses?class=11", label: "Class 11 crash courses" },
      { href: "/notes", label: "Free notes" },
    ],
  },
  {
    title: "Student services",
    links: [
      { href: "/for-students", label: "How learning works" },
      { href: "/login", label: "Student login" },
      { href: "/contact", label: "Doubt / support" },
      { href: "/about", label: "About academy" },
    ],
  },
];

export function SiteFooter() {
  return (
    <footer className="mt-auto bg-navy text-white">
      <div className="mx-auto grid max-w-[1200px] gap-10 px-4 pb-10 pt-14 sm:px-6 md:grid-cols-2 lg:grid-cols-[1.4fr_1fr_1fr_1.2fr]">
        <div>
          <p className="text-[17px] font-bold">Akhand Bharat Academy</p>
          <p className="mt-3 max-w-[300px] text-sm leading-[1.65] text-pretty text-[#b7c1d6]">
            Live classes, recordings and notes for ambitious students. Starting
            with Bihar Board — expanding to more domains soon.
          </p>
          <p className="mt-[18px] inline-flex rounded-md border border-white/[0.18] px-2.5 py-[5px] text-xs font-medium text-[#d5dcea]">
            Trusted learning platform
          </p>
        </div>

        {columns.map((column) => (
          <div key={column.title}>
            <p className="text-xs font-semibold uppercase tracking-[0.08em] text-[#8592ad]">
              {column.title}
            </p>
            <div className="mt-4 flex flex-col gap-2.5 text-sm">
              {column.links.map((link) => (
                <Link
                  key={link.label}
                  href={link.href}
                  className="text-[#d5dcea] hover:text-white"
                >
                  {link.label}
                </Link>
              ))}
            </div>
          </div>
        ))}

        <div>
          <p className="text-xs font-semibold uppercase tracking-[0.08em] text-[#8592ad]">
            Head office &amp; support
          </p>
          <div className="mt-4 flex flex-col gap-2.5 text-sm text-[#d5dcea]">
            <span>Patna, Bihar (placeholder)</span>
            <span>+91 90000 00000</span>
            <span>support@akhandbharatacademy.in</span>
            <span>Mon–Sat, 9 AM – 7 PM IST</span>
          </div>
        </div>
      </div>
      <div className="border-t border-white/10">
        <div className="mx-auto flex max-w-[1200px] flex-col gap-3 px-4 py-[18px] text-[13px] text-[#8592ad] sm:flex-row sm:justify-between sm:px-6">
          <span>
            © {new Date().getFullYear()} Akhand Bharat Academy. All rights
            reserved.
          </span>
          <div className="flex gap-5">
            <Link href="/privacy" className="hover:text-white">
              Privacy
            </Link>
            <Link href="/terms" className="hover:text-white">
              Terms
            </Link>
            <Link href="/contact" className="hover:text-white">
              Refund / Grievance
            </Link>
          </div>
        </div>
      </div>
    </footer>
  );
}
