import { LegalPage } from "@/components/LegalPage";
import { legalDoc } from "@/lib/i18n/legal";
import { getT } from "@/lib/i18n/server";

export async function generateMetadata() {
  const { locale } = await getT();
  const doc = legalDoc("terms", locale);
  return { title: doc.title, description: doc.description };
}

export default async function Page() {
  const { t, locale } = await getT();
  return <LegalPage active="/terms" doc={legalDoc("terms", locale)} t={t} locale={locale} />;
}
