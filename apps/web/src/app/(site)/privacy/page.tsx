export const metadata = {
  title: "Privacy Policy",
};

export default function PrivacyPage() {
  return (
    <div className="mx-auto max-w-3xl px-4 py-14 sm:px-6">
      <h1 className="font-display text-4xl font-semibold tracking-tight">
        Privacy Policy
      </h1>
      <div className="mt-8 space-y-4 text-sm leading-relaxed text-muted">
        <p>
          Akhand Bharat Academy collects account details such as name, phone
          number, class, board and learning progress to deliver courses.
        </p>
        <p>
          Payment data is processed by Razorpay. We do not store full card
          details on our servers.
        </p>
        <p>
          This is placeholder policy text for V1 website launch. A complete
          privacy policy will be published before production enrollment.
        </p>
      </div>
    </div>
  );
}
