import Link from "next/link";
import { notFound } from "next/navigation";
import { BrandMark } from "@/components/icons";
import { fetchCourseBySlug } from "@/lib/catalog";
import { getCourse } from "@/lib/courses";
import { getStudent } from "@/lib/portal/student";
import { CheckoutView } from "./CheckoutView";

export const metadata = {
  title: "Checkout",
  robots: { index: false, follow: false },
};

export default async function CheckoutPage({ params }: { params: Promise<{ slug: string }> }) {
  const { slug } = await params;
  // Signs the visitor in first; enrolment needs an account.
  await getStudent();

  const remote = await fetchCourseBySlug(slug);
  const local = getCourse(slug);
  const course = remote ? { ...local, ...remote } : local;
  if (!course) notFound();

  return (
    <div className="min-h-screen flex-1 bg-[#fafbfd]">
      <header className="h-16 border-b border-border bg-white">
        <div className="mx-auto flex h-full max-w-[1040px] items-center justify-between gap-4 px-4 sm:px-6">
          <Link href="/" className="flex items-center gap-2.5">
            <BrandMark size={32} />
            <span className="hidden text-[15px] font-bold text-navy sm:inline">Akhand Bharat Academy</span>
          </Link>
          <span className="text-[13px] text-muted">🔒 Secure checkout · Razorpay</span>
        </div>
      </header>
      <CheckoutView
        course={{
          slug: course.slug,
          title: course.title,
          stream: course.stream ?? course.subjects.join(" · "),
          teacher: course.teacher,
          hue: course.thumbnailHue,
          price: course.price,
          originalPrice: course.originalPrice ?? course.price,
          validity: course.validity ?? "Until 31 March 2027",
        }}
      />
    </div>
  );
}
