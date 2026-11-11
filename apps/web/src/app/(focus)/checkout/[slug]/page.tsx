import Link from "next/link";
import { notFound } from "next/navigation";
import { BrandMark, Wordmark } from "@/components/icons";
import { LanguageSwitch } from "@/components/LanguageSwitch";
import { fetchCourseBySlug } from "@/lib/catalog";
import { courseArt, getCourse, isCourseLanguage } from "@/lib/courses";
import { courseTitle, validityText } from "@/lib/i18n/content";
import { getT } from "@/lib/i18n/server";
import { TEACHER } from "@/lib/landing";
import { getStudent } from "@/lib/portal/student";
import { createServerClient } from "@/lib/supabase/server";
import { CheckoutView } from "./CheckoutView";

export const metadata = {
  title: "Checkout",
  robots: { index: false, follow: false },
};

async function isEnrolled(courseId: string | undefined) {
  if (!courseId) return false;
  const supabase = await createServerClient();
  if (!supabase) return false;
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) return false;
  const { data } = await supabase
    .from("enrollments")
    .select("id")
    .eq("student_id", user.id)
    .eq("course_id", courseId)
    .eq("status", "active")
    .maybeSingle();
  return Boolean(data);
}

export default async function CheckoutPage({
  params,
  searchParams,
}: {
  params: Promise<{ slug: string }>;
  searchParams: Promise<{ lang?: string }>;
}) {
  const { slug } = await params;
  const { lang } = await searchParams;
  // Signs the visitor in first; enrolment needs an account.
  const student = await getStudent();

  const remote = await fetchCourseBySlug(slug);
  const local = getCourse(slug);
  const course = remote ? { ...local, ...remote } : local;
  if (!course) notFound();

  const [enrolled, { t, locale }] = await Promise.all([isEnrolled(course.id), getT()]);

  return (
    <div className="ab flex min-h-screen flex-1 flex-col">
      <header className="border-b border-ab-rule bg-ab-panel">
        <div className="mx-auto flex h-16 max-w-[1120px] items-center justify-between gap-4 px-4 sm:px-6">
          <Link href="/" className="flex items-center gap-2.5" aria-label={t.common.brand}>
            <BrandMark size={32} />
            <Wordmark size="sm" />
          </Link>
          <div className="flex items-center gap-3">
            <span className="hidden items-center gap-1.5 text-[13px] text-ab-ink-2 sm:flex">
              <LockGlyph />
              {t.checkout.secure}
            </span>
            <LanguageSwitch />
          </div>
        </div>
      </header>
      <CheckoutView
        enrolled={enrolled}
        initialLanguage={isCourseLanguage(lang) ? lang : "Hindi"}
        student={{ name: student.name, contact: student.email ?? student.phone ?? "" }}
        course={{
          id: course.id ?? null,
          slug: course.slug,
          title: courseTitle(course, locale),
          teacher: course.teacher === TEACHER.name ? t.common.teacherName : course.teacher,
          art: courseArt(course),
          price: course.price,
          originalPrice: course.originalPrice ?? course.price,
          validity: validityText(course.validity, locale),
        }}
      />
    </div>
  );
}

function LockGlyph() {
  return (
    <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.2" aria-hidden>
      <rect x="4" y="11" width="16" height="10" rx="2" />
      <path d="M8 11V7a4 4 0 0 1 8 0v4" />
    </svg>
  );
}
