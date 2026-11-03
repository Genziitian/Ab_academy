import '../../config/academy.dart';

/// One block of a policy section: a paragraph, or a bulleted list.
sealed class PolicyBlock {
  const PolicyBlock();
}

class Para extends PolicyBlock {
  const Para(this.text);
  final String text;
}

class Bullets extends PolicyBlock {
  const Bullets(this.items);
  final List<String> items;
}

class PolicySection {
  const PolicySection(this.heading, this.blocks);
  final String heading;
  final List<PolicyBlock> blocks;
}

class PolicyDoc {
  const PolicyDoc({
    required this.title,
    required this.intro,
    required this.sections,
  });

  final String title;
  final String intro;
  final List<PolicySection> sections;
}

/// The same policies as abacademy.in (/privacy, /terms, /refund,
/// /data-deletion), built into the app so they open offline and always match
/// this version of the app. Update both together.
abstract final class Policies {
  static final _address = '${Academy.name}, ${Academy.address.join(', ')}';

  static final privacy = PolicyDoc(
    title: 'Privacy policy',
    intro:
        '${Academy.name} (${Academy.fullName}) runs the website ${Academy.site} '
        'and the ${Academy.name} app. This policy explains what we collect, why, '
        'who we share it with, and the choices you have. We do not sell your '
        'data and we do not show ads.',
    sections: [
      const PolicySection('What we collect', [
        Bullets([
          'Account details: your mobile number (for OTP sign-in), or your name, email address and profile photo from Google if you sign in with Google.',
          'Study details you give us: class, stream, medium and, if you add it, your school.',
          'Purchases: which course you bought, the amount, and the payment status and reference from Razorpay. Your card, UPI or bank details go to Razorpay, never to us.',
          'Learning activity: lectures and notes you open, doubts and comments you post under lectures, lecture ratings, support tickets, and notification and pop-up history.',
          'Device details for the app: a push-notification token and the app version, used to deliver notifications and fix problems.',
        ]),
      ]),
      const PolicySection('Why we use it', [
        Bullets([
          'To sign you in and keep your account secure.',
          'To give you the courses you bought and remember where you left off.',
          'To answer your doubts and support requests.',
          'To send notices about your classes, such as a new lecture or a doubt session.',
          'To protect our course content: your phone number or student code is shown faintly on videos and notes as a watermark.',
          'To keep transaction records that Indian tax law requires.',
        ]),
      ]),
      PolicySection('Who we share it with', [
        Para(
          'Only with the services that run ${Academy.name}, and only what each one needs:',
        ),
        const Bullets([
          'Supabase: hosts our database, sign-in and files.',
          'Razorpay: processes payments.',
          'Google: Google sign-in, Firebase Cloud Messaging for notifications, Google Drive for hosting notes files, and YouTube, which streams our recorded lectures inside the app and website.',
          'Our teachers and support staff see your name, class and the doubts or tickets you send them.',
        ]),
        const Para(
          'We share data with authorities only when Indian law requires it.',
        ),
      ]),
      const PolicySection('Students under 18', [
        Para(
          'Our courses are for Class 11 and 12 students, most of whom are under 18. A parent or guardian should create the account or agree to the student using it, and should make any purchase. We do not use children\'s data for advertising, tracking or profiling.',
        ),
      ]),
      const PolicySection('How long we keep it', [
        Para(
          'We keep your account data while your account is open. When you delete your account, your personal data and activity are erased within 3 days of your request. Orders and payment records are kept, separated from your name, for as long as Indian tax law requires (typically up to 8 years).',
        ),
      ]),
      const PolicySection('How we protect it', [
        Para(
          'Data travels over encrypted connections. Each student can read only their own records, enforced in the database itself. Paid lectures and notes open only for enrolled students, and the app blocks screenshots on lecture and notes screens.',
        ),
      ]),
      const PolicySection('Your rights', [
        Para(
          'You can see and correct your details in your profile. You can ask us for a copy of your data, to correct it, or to delete your data or your whole account — see More → Delete account or data. You can withdraw consent at any time by deleting your account.',
        ),
      ]),
      PolicySection('Grievances and contact', [
        Para(
          'Write to ${Academy.email}, or to $_address. We reply within 7 days. If we change this policy we will update the date above and tell you in the app for significant changes.',
        ),
      ]),
    ],
  );

  static final terms = PolicyDoc(
    title: 'Terms & conditions',
    intro:
        'These terms apply when you use the ${Academy.name} website or app, or '
        'buy a course. By creating an account you agree to them. If you are '
        'under 18, a parent or guardian must agree to them for you.',
    sections: [
      const PolicySection('Your account', [
        Bullets([
          'Sign in with your own mobile number or Google account and keep it to yourself. One account is for one student.',
          'Give correct details. You are responsible for what happens on your account.',
          'You can delete your account at any time from the app (More → Delete account or data) or on the website.',
        ]),
      ]),
      const PolicySection('Courses and access', [
        Para(
          'Each course gives you access to its recorded classes, live doubt sessions, notes and practice questions for the period shown on the course page. Class dates, lectures and teachers may change; we will tell you in the app when they do.',
        ),
        Para(
          'We teach to the Bihar Board syllabus and pattern, but we cannot promise any particular marks or result.',
        ),
      ]),
      const PolicySection('Prices and payment', [
        Para(
          'Prices are in Indian rupees and shown before you pay. Payments are processed by Razorpay. A course unlocks on your account once the payment is confirmed. Refunds follow our Refund policy.',
        ),
      ]),
      const PolicySection('Using our content', [
        Para(
          'Lectures, notes and questions are for your personal study only. You must not:',
        ),
        Bullets([
          'record, screenshot, download, copy or share lectures or notes;',
          'share your account, or sell or give away access;',
          'try to get around the app\'s protections or reach lecture videos outside the app or website.',
        ]),
        Para(
          'Videos and notes carry your watermark. If we find content shared, we may suspend the account without a refund.',
        ),
      ]),
      const PolicySection('Doubts, comments and messages', [
        Para(
          'Be respectful. Do not post anything abusive, hateful, sexual, misleading, or anyone\'s personal information, and do not advertise or spam. We may remove posts and suspend accounts that break these rules. To report a post or a user, use Support in the app or write to us.',
        ),
      ]),
      const PolicySection('Our responsibility', [
        Para(
          'We work to keep the service available and accurate but cannot promise it will always be uninterrupted or error-free. To the extent the law allows, our liability for any claim about a course is limited to the amount you paid for that course.',
        ),
      ]),
      PolicySection('Law and disputes', [
        Para(
          'These terms are governed by the laws of India, and the courts of Bihar have jurisdiction. Before going to court, please write to us at ${Academy.email} so we can try to resolve it.',
        ),
      ]),
    ],
  );

  static final refund = PolicyDoc(
    title: 'Refund policy',
    intro:
        'We want you to buy a course only when you are sure it suits you, so '
        'every course has a free demo. If something still goes wrong, here is '
        'how refunds work.',
    sections: [
      const PolicySection('When you can get a refund', [
        Bullets([
          'Within 7 days of purchase, if you have watched no more than 3 lectures of the course.',
          'If you were charged twice for the same course — the extra payment is refunded in full.',
          'If you paid but the course did not unlock and we cannot fix it within 2 working days.',
        ]),
      ]),
      const PolicySection('When refunds are not given', [
        Bullets([
          'After 7 days from purchase, or after more than 3 lectures have been watched.',
          'If the account was suspended for sharing content or breaking our Terms.',
        ]),
      ]),
      PolicySection('How to ask', [
        Para(
          'Raise a ticket in the app (More → Support → Payment) or write to ${Academy.email} with your registered phone number or email and the order ID. We reply within 2 working days.',
        ),
      ]),
      const PolicySection('How you are paid back', [
        Para(
          'Approved refunds go back to the original payment method through Razorpay. Banks usually take 5–7 working days to show the money. If a payment failed but money left your account, your bank normally reverses it automatically within 7 working days.',
        ),
      ]),
      PolicySection('Grievances', [
        Para(
          'If you are not satisfied with a refund decision, write to ${Academy.email} with “Grievance” in the subject, or to $_address.',
        ),
      ]),
    ],
  );

  static final dataDeletion = PolicyDoc(
    title: 'Data & account deletion',
    intro:
        'You can ask us to delete your personal data, or your whole '
        '${Academy.name} account, at any time — right here in the app or on '
        '${Academy.site}/data-deletion. We complete every request within 3 days.',
    sections: [
      const PolicySection('What “Delete my data” removes', [
        Bullets([
          'Your name, profile photo and school.',
          'Doubts and comments you posted, lecture ratings and support tickets.',
          'Notification and pop-up history, and the app\'s push-notification tokens.',
        ]),
        Para(
          'Your account, sign-in and the courses you bought stay, so you can keep studying.',
        ),
      ]),
      const PolicySection('What “Delete my account” removes', [
        Para(
          'Everything above, plus your sign-in, profile, class details, enrolments and progress. The account cannot be restored, and access to courses you bought ends.',
        ),
      ]),
      const PolicySection('What we keep, and why', [
        Para(
          'Orders and payment records are kept, separated from your name, for as long as Indian tax law requires (typically up to 8 years). A short record that you asked for deletion is kept, with your contact details masked.',
        ),
      ]),
      PolicySection('Can\'t sign in?', [
        Para(
          'Email ${Academy.email} from the email address on your account, or include the mobile number you sign in with, and write “Delete my account” or “Delete my data”. We verify it is you and complete the request within 3 days.',
        ),
      ]),
    ],
  );
}
