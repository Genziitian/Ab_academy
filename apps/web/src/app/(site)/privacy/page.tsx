import { LegalPage } from "@/components/LegalPage";
import { CONTACT } from "@/lib/landing";

export const metadata = {
  title: "Privacy Policy",
  description: "What AB Academy collects, why, who it is shared with, and how to delete it.",
};

export default function PrivacyPage() {
  return (
    <LegalPage
      active="/privacy"
      title="Privacy policy"
      intro="AB Academy (Akhand Bharat Academy) runs the website abacademy.in and the AB Academy app. This policy explains what we collect, why, who we share it with, and the choices you have. We do not sell your data and we do not show ads."
      sections={[
        {
          heading: "What we collect",
          body: [
            [
              "Account details: your mobile number (for OTP sign-in), or your name, email address and profile photo from Google if you sign in with Google.",
              "Study details you give us: class, stream, medium and, if you add it, your school.",
              "Purchases: which course you bought, the amount, and the payment status and reference from Razorpay. Your card, UPI or bank details go to Razorpay, never to us.",
              "Learning activity: lectures and notes you open, doubts and comments you post under lectures, lecture ratings, support tickets, and notification and pop-up history.",
              "Device details for the app: a push-notification token and the app version, used to deliver notifications and fix problems.",
            ],
          ],
        },
        {
          heading: "Why we use it",
          body: [
            [
              "To sign you in and keep your account secure.",
              "To give you the courses you bought and remember where you left off.",
              "To answer your doubts and support requests.",
              "To send notices about your classes, such as a new lecture or a doubt session.",
              "To protect our course content: your phone number or student code is shown faintly on videos and notes as a watermark.",
              "To keep transaction records that Indian tax law requires.",
            ],
          ],
        },
        {
          heading: "Who we share it with",
          body: [
            "Only with the services that run AB Academy, and only what each one needs:",
            [
              "Supabase: hosts our database, sign-in and files.",
              "Razorpay: processes payments.",
              "Google: Google sign-in, Firebase Cloud Messaging for notifications, Google Drive for hosting notes files, and YouTube, which streams our recorded lectures inside the app and website.",
              "Our teachers and support staff see your name, class and the doubts or tickets you send them.",
            ],
            "We share data with authorities only when Indian law requires it.",
          ],
        },
        {
          heading: "Students under 18",
          body: [
            "Our courses are for Class 11 and 12 students, most of whom are under 18. A parent or guardian should create the account or agree to the student using it, and should make any purchase. We do not use children's data for advertising, tracking or profiling.",
          ],
        },
        {
          heading: "How long we keep it",
          body: [
            "We keep your account data while your account is open. When you delete your account, your personal data and activity are erased within 3 days of your request. Orders and payment records are kept, separated from your name, for as long as Indian tax law requires (typically up to 8 years).",
          ],
        },
        {
          heading: "How we protect it",
          body: [
            "Data travels over encrypted connections. Each student can read only their own records, enforced in the database itself. Paid lectures and notes open only for enrolled students, and the app blocks screenshots on lecture and notes screens.",
          ],
        },
        {
          heading: "Your rights",
          body: [
            "You can see and correct your details in your profile. You can ask us for a copy of your data, to correct it, or to delete your data or your whole account — see Data & account deletion. You can withdraw consent at any time by deleting your account.",
          ],
        },
        {
          heading: "Grievances and contact",
          body: [
            `Write to ${CONTACT.email}, or to AB Academy, ${CONTACT.address.join(", ")}. We reply within 7 days. If we change this policy we will update the date above and tell you in the app for significant changes.`,
          ],
        },
      ]}
    />
  );
}
