import { LegalPage } from "@/components/LegalPage";

export const metadata = {
  title: "Privacy Policy",
};

export default function PrivacyPage() {
  return (
    <LegalPage
      active="/privacy"
      title="Privacy Policy"
      paragraphs={[
        "Akhand Bharat Academy collects account details such as name, phone number, class, board and learning progress to deliver courses.",
        "Payment data is processed by Razorpay. We do not store full card details on our servers.",
        "This is placeholder policy text for V1 website launch. A complete privacy policy will be published before production enrollment.",
      ]}
    />
  );
}
