export const metadata = {
  title: "Terms of Service",
};

export default function TermsPage() {
  return (
    <LegalShell title="Terms of Service">
      <p>
        These placeholder terms apply to Akhand Bharat Academy&apos;s website and
        learning services. Final legal copy will be reviewed before production
        launch.
      </p>
      <p>
        By accessing courses you agree to use content for personal learning only,
        not to redistribute recordings, notes or live stream links.
      </p>
      <p>
        Payments, refunds and enrollment rules will follow the published refund
        policy once Razorpay checkout is enabled.
      </p>
    </LegalShell>
  );
}

function LegalShell({
  title,
  children,
}: {
  title: string;
  children: React.ReactNode;
}) {
  return (
    <div className="mx-auto max-w-3xl px-4 py-14 sm:px-6">
      <h1 className="font-display text-4xl font-semibold tracking-tight">
        {title}
      </h1>
      <div className="mt-8 space-y-4 text-sm leading-relaxed text-muted">
        {children}
      </div>
    </div>
  );
}
