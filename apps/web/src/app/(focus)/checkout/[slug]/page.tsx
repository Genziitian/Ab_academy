import Link from "next/link";
import { notFound } from "next/navigation";
import { BrandMark } from "@/components/icons";
import { fetchCourseBySlug } from "@/lib/catalog";
import { courseArt, getCourse, isCourseLanguage } from "@/lib/courses";
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

  const enrolled = await isEnrolled(course.id);

  return (
    <div className="theme-saffron flex min-h-screen flex-1 flex-col bg-paper">
      <header className="border-b border-sand bg-cream">
        <div className="mx-auto flex h-16 max-w-[1080px] items-center justify-between gap-4 px-4 sm:px-6">
          <Link href="/" className="flex items-center gap-2.5">
            <BrandMark size={34} />
            <span className="font-serif text-2xl leading-none text-coal">AB Academy</span>
          </Link>
          <span className="flex items-center gap-1.5 text-[13px] font-semibold text-taupe">
            <LockGlyph />
            Secure checkout
          </span>
        </div>
      </header>
      <CheckoutView
        enrolled={enrolled}
        initialLanguage={isCourseLanguage(lang) ? lang : "Hindi"}
        student={{ name: student.name, contact: student.email ?? student.phone ?? "" }}
        course={{
          id: course.id ?? null,
          slug: course.slug,
          title: course.title,
          teacher: course.teacher,
          art: courseArt(course),
          price: course.price,
          originalPrice: course.originalPrice ?? course.price,
          validity: course.validity ?? "Until 31 March 2027",
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
