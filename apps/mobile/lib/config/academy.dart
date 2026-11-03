/// Facts about the academy shown on About, Contact and the policy pages.
/// Kept in step with `apps/web/src/lib/landing.ts`.
abstract final class Academy {
  static const name = 'AB Academy';
  static const fullName = 'Akhand Bharat Academy';
  static const email = 'contact@abacademy.in';
  static const site = 'abacademy.in';
  static const address = [
    'Moldiyar Tola, near Gayatri Bhawan',
    'Mokama, Bihar 803302',
  ];

  static const teacher = 'Ajit Sir';
  static const teacherYears = 10;

  static const founders = [
    (name: 'Ajit Sir', role: 'Founder'),
    (name: 'Sriram', role: 'Co-founder & Developer'),
  ];

  /// Date shown on the policy pages; matches LEGAL_UPDATED on the website.
  static const policiesUpdated = '3 November 2026';
}
