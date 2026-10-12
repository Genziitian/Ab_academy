import { LegalPage } from "@/components/LegalPage";

export const metadata = {
  title: "Terms of Service",
};

export default function TermsPage() {
  return (
    <LegalPage
      active="/terms"
      title="Terms of Service"
      paragraphs={[
        "These placeholder terms apply to Akhand Bharat Academy's website and learning services. Final legal copy will be reviewed before production launch.",
        "By accessing courses you agree to use content for personal learning only, not to redistribute recordings, notes or live stream links.",
        "Payments, refunds and enrollment rules will follow the published refund policy once Razorpay checkout is enabled.",
      ]}
    />
  );
}
