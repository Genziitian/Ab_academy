import { LegalPage } from "@/components/LegalPage";
import { CONTACT } from "@/lib/landing";

export const metadata = {
  title: "Refund Policy",
  description: "When and how AB Academy refunds a course purchase.",
};

export default function RefundPage() {
  return (
    <LegalPage
      active="/refund"
      title="Refund policy"
      intro="We want you to buy a course only when you are sure it suits you, so every course has a free demo. If something still goes wrong, here is how refunds work."
      sections={[
        {
          heading: "When you can get a refund",
          body: [
            [
              "Within 7 days of purchase, if you have watched no more than 3 lectures of the course.",
              "If you were charged twice for the same course — the extra payment is refunded in full.",
              "If you paid but the course did not unlock and we cannot fix it within 2 working days.",
            ],
          ],
        },
        {
          heading: "When refunds are not given",
          body: [
            [
              "After 7 days from purchase, or after more than 3 lectures have been watched.",
              "If the account was suspended for sharing content or breaking our Terms.",
            ],
          ],
        },
        {
          heading: "How to ask",
          body: [
            `Raise a ticket in the app (Help & support → Payment) or write to ${CONTACT.email} with your registered phone number or email and the order ID. We reply within 2 working days.`,
          ],
        },
        {
          heading: "How you are paid back",
          body: [
            "Approved refunds go back to the original payment method through Razorpay. Banks usually take 5–7 working days to show the money. If a payment failed but money left your account, your bank normally reverses it automatically within 7 working days.",
          ],
        },
        {
          heading: "Grievances",
          body: [
            `If you are not satisfied with a refund decision, write to ${CONTACT.email} with “Grievance” in the subject, or to AB Academy, ${CONTACT.address.join(", ")}.`,
          ],
        },
      ]}
    />
  );
}
