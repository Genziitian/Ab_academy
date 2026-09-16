import Link from "next/link";

export function SiteFooter() {
  return (
    <footer className="mt-auto border-t border-border bg-navy text-white">
      <div className="mx-auto grid max-w-6xl gap-10 px-4 py-12 sm:px-6 md:grid-cols-2 lg:grid-cols-4">
        <div>
          <p className="text-lg font-bold">Akhand Bharat Academy</p>
          <p className="mt-3 text-sm leading-relaxed text-white/70">
            Live classes, recordings and notes for ambitious students. Starting
            with Bihar Board — expanding to more domains soon.
          </p>
          <p className="mt-4 inline-flex rounded-full bg-white/10 px-3 py-1 text-xs font-semibold text-white/80">
            Trusted learning platform
          </p>
        </div>

        <div>
          <p className="text-xs font-semibold uppercase tracking-[0.14em] text-white/45">
            Academic portals
          </p>
          <ul className="mt-4 space-y-2 text-sm text-white/80">
            <li>
              <Link href="/courses?class=9" className="hover:text-white">
                Class 9 courses
              </Link>
            </li>
            <li>
              <Link href="/courses?class=10" className="hover:text-white">
                Class 10 courses
              </Link>
            </li>
            <li>
              <Link href="/courses?class=11" className="hover:text-white">
                Class 11 courses
              </Link>
            </li>
            <li>
              <Link href="/courses?class=12" className="hover:text-white">
                Class 12 courses
              </Link>
            </li>
          </ul>
        </div>

        <div>
          <p className="text-xs font-semibold uppercase tracking-[0.14em] text-white/45">
            Student services
          </p>
          <ul className="mt-4 space-y-2 text-sm text-white/80">
            <li>
              <Link href="/for-students" className="hover:text-white">
                How learning works
              </Link>
            </li>
            <li>
              <Link href="/login" className="hover:text-white">
                Student login
              </Link>
            </li>
            <li>
              <Link href="/contact" className="hover:text-white">
                Doubt / support
              </Link>
            </li>
            <li>
              <Link href="/about" className="hover:text-white">
                About academy
              </Link>
            </li>
          </ul>
        </div>

        <div>
          <p className="text-xs font-semibold uppercase tracking-[0.14em] text-white/45">
            Head office & support
          </p>
          <ul className="mt-4 space-y-2 text-sm text-white/80">
            <li>Patna, Bihar (placeholder)</li>
            <li>+91 90000 00000</li>
            <li>support@akhandbharatacademy.in</li>
            <li>Mon–Sat, 9 AM – 7 PM IST</li>
          </ul>
        </div>
      </div>
      <div className="border-t border-white/10">
        <div className="mx-auto flex max-w-6xl flex-col gap-2 px-4 py-4 text-xs text-white/40 sm:flex-row sm:items-center sm:justify-between sm:px-6">
          <p>
            © {new Date().getFullYear()} Akhand Bharat Academy. All rights
            reserved.
          </p>
          <div className="flex gap-4">
            <Link href="/privacy" className="hover:text-white/70">
              Privacy
            </Link>
            <Link href="/terms" className="hover:text-white/70">
              Terms
            </Link>
            <Link href="/contact" className="hover:text-white/70">
              Refund / Grievance
            </Link>
          </div>
        </div>
      </div>
    </footer>
  );
}
