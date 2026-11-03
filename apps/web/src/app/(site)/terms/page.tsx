import { LegalPage } from "@/components/LegalPage";
import { CONTACT } from "@/lib/landing";

export const metadata = {
  title: "Terms & Conditions",
  description: "The rules for using AB Academy's website, app and courses.",
};

export default function TermsPage() {
  return (
    <LegalPage
      active="/terms"
      title="Terms & conditions"
      intro="These terms apply when you use the AB Academy website or app, or buy a course. By creating an account you agree to them. If you are under 18, a parent or guardian must agree to them for you."
      sections={[
        {
          heading: "Your account",
          body: [
            [
              "Sign in with your own mobile number or Google account and keep it to yourself. One account is for one student.",
              "Give correct details. You are responsible for what happens on your account.",
              "You can delete your account at any time from the app (More → Delete account or data) or on the website.",
            ],
          ],
        },
        {
          heading: "Courses and access",
          body: [
            "Each course gives you access to its recorded classes, live doubt sessions, notes and practice questions for the period shown on the course page. Class dates, lectures and teachers may change; we will tell you in the app when they do.",
            "We teach to the Bihar Board syllabus and pattern, but we cannot promise any particular marks or result.",
          ],
        },
        {
          heading: "Prices and payment",
          body: [
            "Prices are in Indian rupees and shown before you pay. Payments are processed by Razorpay. A course unlocks on your account once the payment is confirmed. Refunds follow our Refund policy.",
          ],
        },
        {
          heading: "Using our content",
          body: [
            "Lectures, notes and questions are for your personal study only. You must not:",
            [
              "record, screenshot, download, copy or share lectures or notes;",
              "share your account, or sell or give away access;",
              "try to get around the app's protections or reach lecture videos outside the app or website.",
            ],
            "Videos and notes carry your watermark. If we find content shared, we may suspend the account without a refund.",
          ],
        },
        {
          heading: "Doubts, comments and messages",
          body: [
            "Be respectful. Do not post anything abusive, hateful, sexual, misleading, or anyone's personal information, and do not advertise or spam. We may remove posts and suspend accounts that break these rules. To report a post or a user, use Help & support in the app or write to us.",
          ],
        },
        {
          heading: "Our responsibility",
          body: [
            "We work to keep the service available and accurate but cannot promise it will always be uninterrupted or error-free. To the extent the law allows, our liability for any claim about a course is limited to the amount you paid for that course.",
          ],
        },
        {
          heading: "Law and disputes",
          body: [
            `These terms are governed by the laws of India, and the courts of Bihar have jurisdiction. Before going to court, please write to us at ${CONTACT.email} so we can try to resolve it.`,
          ],
        },
      ]}
    />
  );
}
