// Every interface string in the app, in English and Hindi.
//
// Each getter carries both languages side by side, so a string can never be
// added in one language and forgotten in the other. Hindi uses the words
// Class 12 students already say — कोर्स, लाइव क्लास, नोट्स — and matches
// the website (apps/web/src/lib/i18n/hi.ts).
//
// Read it anywhere as `tx.someString`. Course titles, lecture titles and
// anything else typed into the admin console stay as they were entered.

/// The strings for the language in use. Set by `applyLang()`.
abstract final class L10n {
  static S current = const S(hindi: false);
}

/// Shorthand: `tx.home`.
S get tx => L10n.current;

class S {
  const S({required this.hindi});

  final bool hindi;

  String _(String en, String hi) => hindi ? hi : en;

  // ------------------------------------------------------------ common
  String get appName => _('AB Academy', 'AB अकादमी');
  String get shortName => _('AB Academy', 'AB अकादमी');
  String get back => _('Back', 'वापस');
  String get close => _('Close', 'बंद करें');
  String get cancel => _('Cancel', 'रद्द करें');
  String get save => _('Save', 'सेव करें');
  String get saving => _('Saving…', 'सेव हो रहा है…');
  String get sending => _('Sending…', 'भेजा जा रहा है…');
  String get loading => _('Loading…', 'लोड हो रहा है…');
  String get pleaseWait => _('Please wait…', 'कृपया रुकें…');
  String get retry => _('Retry', 'फिर कोशिश करें');
  String get tryAgain => _('Try again', 'फिर कोशिश करें');
  String get open => _('Open', 'खोलें');
  String get watch => _('Watch', 'देखें');
  String get view => _('View', 'देखें');
  String get viewAll => _('View all', 'सभी देखें');
  String get seeAll => _('See all', 'सभी देखें');
  String get continueLabel => _('Continue', 'जारी रखें');
  String get edit => _('Edit', 'बदलें');
  String get all => _('All', 'सभी');
  String get free => _('Free', 'मुफ़्त');
  String get freeCaps => _('FREE', 'मुफ़्त');
  String get pro => _('PRO', 'PRO');
  String get enrolled => _('Enrolled', 'दाख़िला है');
  String get enroll => _('Enroll', 'दाख़िला लें');
  String get enrollNow => _('Enroll now', 'अभी दाख़िला लें');
  String get details => _('Details', 'विवरण');
  String get comingSoon => _('Coming soon', 'जल्द आ रहा है');
  String get comingSoonCaps => _('COMING SOON', 'जल्द आ रहा है');
  String get notes => _('Notes', 'नोट्स');
  String get lecture => _('Lecture', 'लेक्चर');
  String get recorded => _('Recorded', 'रिकॉर्डेड');
  String get liveClass => _('Live class', 'लाइव क्लास');
  String get test => _('Test', 'टेस्ट');
  String get you => _('You', 'आप');
  String get support => _('Support', 'सहायता');
  String get email => _('Email', 'ईमेल');
  String get password => _('Password', 'पासवर्ड');
  String get address => _('Address', 'पता');
  String get justNow => _('Just now', 'अभी');
  String get yesterday => _('Yesterday', 'कल');
  String get today => _('Today', 'आज');
  String get tomorrow => _('Tomorrow', 'कल');
  String get earlier => _('Earlier', 'पहले');
  String get faculty => _('Faculty Team', 'शिक्षक टीम');
  String get teacherName => _('Ajit Sir', 'अजीत सर');
  String get board => _('Class 12', 'कक्षा 12');
  String get hindiLang => _('Hindi', 'हिंदी');
  String get hinglishLang => _('Hinglish', 'हिंग्लिश');
  String get hindiPlusEnglish => _('Hindi + English', 'हिंदी + अंग्रेज़ी');
  String get checkConnection =>
      _('Check your connection and pull down to try again.', 'इंटरनेट जाँचें और फिर कोशिश करने के लिए नीचे खींचें।');
  String get couldNotSaveConnection =>
      _('Could not save. Check your connection and try again.', 'सेव नहीं हो सका। इंटरनेट जाँचें और फिर कोशिश करें।');
  String get couldNotSendTryAgain => _('Could not send. Try again.', 'भेजा नहीं जा सका। फिर कोशिश करें।');
  String get linkCopied => _('Link copied — share it with friends.', 'लिंक कॉपी हो गया — दोस्तों के साथ शेयर करें।');
  String get languageLabel => _('Language', 'भाषा');
  String get languageHint =>
      _('Changes the language of the whole app.', 'पूरे ऐप की भाषा बदलता है।');

  String classN(Object n) => _('Class $n', 'कक्षा $n');
  String classNCaps(Object n) => _('CLASS $n', 'कक्षा $n');
  String chapters(int n) => _('$n chapters', '$n अध्याय');
  String lectures(int n) => _('$n lectures', '$n लेक्चर');
  String lecturesPlus(int n) => _('$n+ lectures', '$n+ लेक्चर');
  String subjectsCount(int n) => _('$n subjects', '$n विषय');
  String days(int n) => _('$n days', '$n दिन');
  String percentOff(int n) => _('$n% off', '$n% छूट');
  String percentOffCaps(int n) => _('$n% OFF', '$n% छूट');
  String minutes(int n) => _('$n min', '$n मिनट');
  String hoursMinutes(int h, int m) => _('${h}h ${m}m', '$h घंटे $m मिनट');
  String mediumOf(String medium) => _('$medium medium', '$medium माध्यम');
  String openTickets(int n) => _('$n open', '$n खुले');

  /// Subject names: "Physics" → "भौतिकी". Unknown names pass through.
  String subject(String name) {
    if (!hindi) return name;
    return switch (name.toLowerCase()) {
      'physics' => 'भौतिकी',
      'chemistry' => 'रसायन विज्ञान',
      'mathematics' || 'maths' || 'math' => 'गणित',
      'biology' => 'जीव विज्ञान',
      'english' => 'अंग्रेज़ी',
      'hindi' => 'हिंदी',
      'science' => 'विज्ञान',
      'commerce' => 'वाणिज्य',
      'arts' => 'कला',
      'accountancy' => 'लेखाशास्त्र',
      'business studies' => 'व्यवसाय अध्ययन',
      'economics' => 'अर्थशास्त्र',
      'history' => 'इतिहास',
      'political science' => 'राजनीति विज्ञान',
      'geography' => 'भूगोल',
      'general' => 'सामान्य',
      _ => name,
    };
  }

  /// "Hindi", "Hinglish", "Hindi + English" as stored on a course.
  String language(String value) {
    if (!hindi) return value;
    return value
        .replaceAll('Hinglish', 'हिंग्लिश')
        .replaceAll('Hindi', 'हिंदी')
        .replaceAll('English', 'अंग्रेज़ी');
  }

  // ------------------------------------------------------- time labels
  String minutesAgo(int n) => _('${n}m ago', '$n मिनट पहले');
  String hoursAgo(int n) => _('${n}h ago', '$n घंटे पहले');
  String daysAgo(int n) => _('${n}d ago', '$n दिन पहले');
  List<String> get monthsShort => hindi
      ? const ['जन॰', 'फ़र॰', 'मार्च', 'अप्रैल', 'मई', 'जून', 'जुल॰', 'अग॰', 'सित॰', 'अक्टू॰', 'नव॰', 'दिस॰']
      : const ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  List<String> get weekdaysShort => hindi
      ? const ['सोम', 'मंगल', 'बुध', 'गुरु', 'शुक्र', 'शनि', 'रवि']
      : const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  String get am => _('AM', 'AM');
  String get pm => _('PM', 'PM');
  String todayAt(String time) => _('Today · $time', 'आज · $time');
  String tomorrowAt(String time) => _('Tomorrow · $time', 'कल · $time');

  // ------------------------------------------------------------ nav
  String get tabHome => _('Home', 'होम');
  String get tabAcademics => _('Academics', 'पढ़ाई');
  String get tabCourses => _('Courses', 'कोर्स');
  String get tabMore => _('More', 'और');

  // ------------------------------------------------------- onboarding
  String get introLiveTitle => _('Live & recorded classes', 'लाइव और रिकॉर्डेड क्लास');
  String get introLiveBody => _(
    'Join live doubt sessions with Ajit Sir, or watch every lecture again whenever you need it.',
    'अजीत सर के लाइव डाउट सेशन में जुड़ें, या कोई भी लेक्चर जब चाहें दोबारा देखें।',
  );
  String get introNotesTitle => _('Notes, practice & doubt support', 'नोट्स, अभ्यास और डाउट सहायता');
  String get introNotesBody => _(
    'Chapter notes, board-pattern practice and answers to your doubts — all in one app.',
    'अध्याय के नोट्स, बोर्ड पैटर्न का अभ्यास और आपके डाउट के जवाब — सब एक ऐप में।',
  );
  String get skip => _('Skip', 'छोड़ें');
  String get tagline => _('LEARN  •  PRACTISE  •  REVISE', 'सीखें  •  अभ्यास  •  दोहराएँ');
  String get taglineSub => _('CLASS 12 SCIENCE', 'कक्षा 12 विज्ञान');

  String get loginWelcome => _('Welcome back to AB Academy', 'AB अकादमी में आपका स्वागत है');
  String get loginLead =>
      _('Sign in to watch lectures, ask doubts and read notes.', 'लेक्चर देखने, डाउट पूछने और नोट्स पढ़ने के लिए साइन इन करें।');
  String get loginPanelEyebrow => _('CLASS 12 CRASH COURSE', 'कक्षा 12 क्रैश कोर्स');
  String get loginPanelTitle => _('Board-ready in 60 days.', '60 दिनों में बोर्ड की पूरी तैयारी।');
  String get loginPanelPoint => _('Recorded classes + live doubts', 'रिकॉर्डेड क्लास + लाइव डाउट');
  String get loginPhotoAlt => _('Two students learning with AB Academy', 'AB अकादमी से पढ़ते दो छात्र');
  String get signInWithEmail => _('Sign in with email', 'ईमेल से साइन इन करें');
  String get emailOnlyNote =>
      _('For accounts created by AB Academy. Students, please use Google.', 'AB अकादमी द्वारा बनाए गए अकाउंट के लिए। छात्र कृपया Google इस्तेमाल करें।');
  String get signIn => _('Sign in', 'साइन इन');
  String get signingIn => _('Signing in…', 'साइन इन हो रहा है…');
  String get continueWithGoogle => _('Continue with Google', 'Google से जारी रखें');
  String get signInWithMobile => _('Sign in with mobile number', 'मोबाइल नंबर से साइन इन');
  String get signInWithMobileSoon =>
      _('Sign in with mobile number, coming soon', 'मोबाइल नंबर से साइन इन, जल्द आ रहा है');
  String get mobileSoonSnack =>
      _('Sign-in with mobile number is coming soon. Use Google for now.', 'मोबाइल नंबर से साइन इन जल्द आ रहा है। अभी Google इस्तेमाल करें।');
  String get mobileNumber => _('Mobile number', 'मोबाइल नंबर');
  String get sendOtp => _('Send OTP', 'OTP भेजें');
  String get or => _('OR', 'या');
  String get agreePre => _('By continuing you agree to our ', 'आगे बढ़कर आप हमारी ');
  String get terms => _('Terms', 'शर्तों');
  String get and => _(' and ', ' और ');
  String get privacyPolicy => _('Privacy Policy', 'गोपनीयता नीति');
  String get agreePost => _('', ' से सहमत होते हैं');
  String get quickLogin => _('Quick login (skip OTP)', 'क्विक लॉग इन (OTP छोड़ें)');
  String get quickLoginNote =>
      _('Debug builds only — signs you in as the demo student.', 'सिर्फ़ डीबग बिल्ड — डेमो छात्र के रूप में साइन इन करता है।');
  String get otpSendFailed => _('Could not send the OTP. Try again.', 'OTP नहीं भेजा जा सका। फिर कोशिश करें।');
  String get quickLoginFailed => _('Quick login failed.', 'क्विक लॉग इन नहीं हुआ।');
  String get googleIncomplete => _(
    'Google sign-in did not complete. Try again or use your mobile number.',
    'Google साइन इन पूरा नहीं हुआ। फिर कोशिश करें।',
  );
  String get googleFailed => _('Google sign-in failed.', 'Google साइन इन नहीं हुआ।');
  String get signInFailed => _('Sign-in failed.', 'साइन इन नहीं हुआ।');
  String get wrongEmailPassword => _('Wrong email or password.', 'ईमेल या पासवर्ड ग़लत है।');
  String get googleNotSetUp => _(
    'Google sign-in is not set up for this app build yet.',
    'इस ऐप बिल्ड में Google साइन इन अभी सेट नहीं है।',
  );

  String get otpTitle => _('Enter the 6-digit OTP', '6 अंकों का OTP डालें');
  String otpSentTo(String phone) => _('Sent to +91 $phone · ', '+91 $phone पर भेजा गया · ');
  String otpResentTo(String phone) => _('OTP resent to +91 $phone', 'OTP फिर से +91 $phone पर भेजा गया');
  String get otpResendFailed => _('Could not resend the OTP.', 'OTP फिर से नहीं भेजा जा सका।');
  String get otpWrong => _('That code did not work.', 'यह कोड सही नहीं है।');
  String get otpResendIn => _("Didn't get it? Resend in ", 'नहीं मिला? फिर से भेजें ');
  String get otpDidntGet => _("Didn't get it? ", 'नहीं मिला? ');
  String get otpResend => _('Resend OTP', 'OTP फिर से भेजें');
  String get verifying => _('Verifying…', 'जाँच हो रही है…');
  String get verifyContinue => _('Verify & continue', 'पुष्टि करें और आगे बढ़ें');

  String get setupTitle => _('Class & stream', 'कक्षा और स्ट्रीम');
  String get step1of2 => _('Step 1 of 2', 'चरण 1 / 2');
  String get step2of2 => _('Step 2 of 2', 'चरण 2 / 2');
  String get whichClass => _('Which class are you in?', 'आप किस कक्षा में हैं?');
  String get whichClassLead => _("We'll show crash courses for your class.", 'हम आपकी कक्षा के क्रैश कोर्स दिखाएँगे।');
  String get class12Tagline => _('Board 2027 crash courses', 'बोर्ड 2027 क्रैश कोर्स');
  String get class11Tagline => _('Build a strong base for Class 12', 'कक्षा 12 के लिए मज़बूत नींव');
  String get chooseStream => _('Choose your stream', 'अपनी स्ट्रीम चुनें');
  String get mediumOfStudy => _('Medium of study', 'पढ़ाई का माध्यम');
  String get startLearning => _('Start learning', 'पढ़ाई शुरू करें');
  String get classStreamUpdated => _('Class & stream updated.', 'कक्षा और स्ट्रीम अपडेट हो गई।');
  String get streamScience => _('Science', 'विज्ञान');
  String get streamCommerce => _('Commerce', 'वाणिज्य');
  String get streamArts => _('Arts', 'कला');
  String get streamScienceSubjects =>
      _('Physics · Chemistry · Biology · Maths', 'भौतिकी · रसायन · जीव विज्ञान · गणित');
  String get streamCommerceSubjects =>
      _('Accountancy · Business Studies · Economics', 'लेखाशास्त्र · व्यवसाय अध्ययन · अर्थशास्त्र');
  String get streamArtsSubjects =>
      _('History · Political Science · Geography', 'इतिहास · राजनीति विज्ञान · भूगोल');
  String get hinglishHint => _('Hindi + English terms', 'हिंदी के साथ अंग्रेज़ी शब्द');
  String get hindiHint => _('Fully in Hindi', 'पूरी पढ़ाई हिंदी में');
  String mediumLabel(String name) => _('$name medium', '$name माध्यम');

  // -------------------------------------------------------------- home
  String get goodMorning => _('Good morning', 'सुप्रभात');
  String get goodAfternoon => _('Good afternoon', 'नमस्ते');
  String get goodEvening => _('Good evening', 'शुभ संध्या');
  String get continueLearning => _('CONTINUE LEARNING', 'पढ़ाई जारी रखें');
  String get coursesForYou => _('Courses for you', 'आपके लिए कोर्स');
  String get qaLiveDoubts => _('Live doubts', 'लाइव डाउट');
  String get qaFreeNotes => _('Free notes', 'मुफ़्त नोट्स');
  String get qaMyCourses => _('My courses', 'मेरे कोर्स');
  String get qaSupport => _('Support', 'सहायता');
  String get planTitle => _('Your 60-day plan', 'आपकी 60 दिन की योजना');
  String planStartsIn(int n) => n == 1 ? _('Starts tomorrow', 'कल से शुरू') : _('Starts in $n days', '$n दिन में शुरू');
  String planDayOf(int d) => _('Day $d of 60', '60 में से दिन $d');
  String get planDone => _('Plan complete', 'योजना पूरी');
  List<String> get planPhases => hindi ? const ['कॉन्सेप्ट', 'अभ्यास', 'रिवीज़न'] : const ['Concepts', 'Practice', 'Revision'];
  List<String> get planPhaseDays =>
      hindi ? const ['दिन 1–20', 'दिन 21–40', 'दिन 41–60'] : const ['Days 1–20', 'Days 21–40', 'Days 41–60'];
  String get planClassesStart => _('Classes start', 'क्लास शुरू');
  String get planBoardExam => _('Course target date', 'कोर्स का लक्ष्य दिनांक');
  String planDaysLeft(int n) => _('$n days left', '$n दिन बाकी');

  // ----------------------------------------------------------- promos
  String get promoBatch => _('Class 12 Crash Course starts 16 November', 'कक्षा 12 क्रैश कोर्स 16 नवंबर से शुरू');
  String get promoDoubts => _('Ask doubts and get them solved', 'डाउट पूछें और हल पाएँ');
  String get promoNotes => _('Free notes and solved PYQs', 'मुफ़्त नोट्स और हल किए गए PYQ');
  String get promoBuy => _('Buy courses right in the app', 'ऐप में ही कोर्स ख़रीदें');
  String get viewCourse => _('View course', 'कोर्स देखें');

  // ---------------------------------------------------------- courses
  String get explore => _('Explore', 'कोर्स देखें');
  String get myCourses => _('My courses', 'मेरे कोर्स');
  String enrolledCount(int n) => _('$n enrolled', '$n में दाख़िला');
  String get searchMyCourses => _('Search your courses…', 'अपने कोर्स खोजें…');
  String get searchCourses => _('Search crash courses…', 'क्रैश कोर्स खोजें…');
  String get couldNotLoadCourses => _('Could not load courses', 'कोर्स लोड नहीं हो सके');
  String get couldNotLoadMyCourses => _('Could not load your courses', 'आपके कोर्स लोड नहीं हो सके');
  String get newCoursesSoon =>
      _('New crash courses open here as soon as they are published.', 'नए क्रैश कोर्स प्रकाशित होते ही यहाँ दिखेंगे।');
  String noFilterCourses(String filter) => _('No $filter crash courses are open yet.', '$filter के क्रैश कोर्स अभी नहीं खुले हैं।');
  String get noCoursesYet => _('No courses yet', 'अभी कोई कोर्स नहीं');
  String get noMatches => _('No matches', 'कुछ नहीं मिला');
  String get pickCourse =>
      _('Pick a crash course for your class to get started.', 'शुरू करने के लिए अपनी कक्षा का क्रैश कोर्स चुनें।');
  String nothingMatches(String q) => _('Nothing in your courses matches “$q”.', 'आपके कोर्स में “$q” से कुछ नहीं मिला।');
  String get exploreMore => _('Explore more crash courses', 'और क्रैश कोर्स देखें');
  String get statChapters => _('Chapters', 'अध्याय');
  String get statLectures => _('Lectures', 'लेक्चर');
  String get statNotes => _('Notes', 'नोट्स');
  String get statDays => _('Days', 'दिन');
  String get statQuestions => _('Questions', 'सवाल');
  String get enrolledTick => _('✓ Enrolled', '✓ दाख़िला है');

  String get couldNotLoadCourse => _('Could not load this course.', 'यह कोर्स लोड नहीं हो सका।');
  String get courseNotAvailable => _('This course is not available.', 'यह कोर्स उपलब्ध नहीं है।');
  String get pickAnother => _('Go back and pick another crash course.', 'वापस जाएँ और दूसरा क्रैश कोर्स चुनें।');
  String crashCourseDays(int n) => _('$n-day crash course', '$n दिन का क्रैश कोर्स');
  String classBoard(Object level, String board) => _('Class $level', 'कक्षा $level');
  String subjectTeacher(String s) => _('${subject(s)} teacher', '${subject(s)} शिक्षक');
  String get courseTeacher => _('Course teacher', 'कोर्स शिक्षक');
  String get whatYouGet => _('What you get', 'कोर्स में क्या मिलेगा');
  String get aboutThisCourse => _('About this course', 'इस कोर्स के बारे में');
  String get goToCourse => _('Go to course', 'कोर्स पर जाएँ');
  String get notEnrolledNote => _(
    'Not enrolled yet. Courses on your account appear here automatically when you sign in.',
    'अभी दाख़िला नहीं है। साइन इन करने पर आपके अकाउंट के कोर्स अपने-आप यहाँ दिखेंगे।',
  );
  String get course => _('Course', 'कोर्स');
  String get myCourse => _('My course', 'मेरा कोर्स');
  String get overview => _('Overview', 'परिचय');
  String get curriculum => _('Curriculum', 'पाठ्यक्रम');
  String ratings(String n) => _('$n ratings', '$n रेटिंग');
  String get teachers => _('Teachers', 'शिक्षक');
  String get chaptersSoon => _('Chapters coming soon', 'अध्याय जल्द आ रहे हैं');
  String get teachersAdding => _('Teachers are still adding lessons.', 'शिक्षक अभी पाठ जोड़ रहे हैं।');
  String lectureCount(int n) => _(n == 1 ? '1 lecture' : '$n lectures', '$n लेक्चर');
  String noteCount(int n) => _(n == 1 ? '1 note' : '$n notes', '$n नोट्स');
  String chapterN(int n) => _('CHAPTER ${n.toString().padLeft(2, '0')}', 'अध्याय ${n.toString().padLeft(2, '0')}');
  String get enrolToUnlock => _('Enrol to unlock', 'खोलने के लिए दाख़िला लें');
  String recordedDetail(String d) => _('Recorded · $d', 'रिकॉर्डेड · $d');
  String get noNotesYet => _('No notes yet', 'अभी कोई नोट्स नहीं');
  String get chapterNotesAppear =>
      _('Chapter notes appear here as teachers add them.', 'शिक्षक जैसे-जैसे नोट्स जोड़ेंगे, यहाँ दिखेंगे।');
  String lessonsProgress(int done, int total) => _('$done / $total lessons', '$done / $total पाठ');
  String chaptersCompleted(int done, int total) =>
      _('$done of $total chapters completed', '$total में से $done अध्याय पूरे');
  String chaptersProgress(int done, int total) => _('$done / $total chapters', '$done / $total अध्याय');
  String get allSubjects => _('All subjects', 'सभी विषय');
  String get currentBatch => _('Current batch', 'वर्तमान बैच');
  String get chapter => _('Chapter', 'अध्याय');
  String get general => _('General', 'सामान्य');

  // ----------------------------------------------------------- lecture
  String get about => _('About', 'परिचय');
  String get discussion => _('Discussion', 'चर्चा');
  String get enrollToWatch => _('Enroll in this course to watch the lecture.', 'लेक्चर देखने के लिए इस कोर्स में दाख़िला लें।');
  String get couldNotLoadLecture =>
      _('Could not load the lecture. Check your connection and try again.', 'लेक्चर लोड नहीं हो सका। इंटरनेट जाँचें और फिर कोशिश करें।');
  String get noVideoYet => _('This lecture has no video yet.', 'इस लेक्चर का वीडियो अभी नहीं है।');
  String get inThisChapter => _('In this chapter', 'इस अध्याय में');
  String get aboutThisLesson => _('About this lesson', 'इस पाठ के बारे में');
  String get nowPlaying => _('Now playing', 'अभी चल रहा है');
  String get notesPdf => _('Notes  ·  PDF', 'नोट्स  ·  PDF');
  String lectureMinutes(int m) => m > 0 ? _('Lecture · $m min', 'लेक्चर · $m मिनट') : lecture;
  String get doubtQueueNote =>
      _("Questions about this lesson go to your teacher's doubt queue.", 'इस पाठ के सवाल सीधे आपके शिक्षक के पास जाते हैं।');
  String get askQuestion => _('Ask a question about this lesson…', 'इस पाठ के बारे में सवाल पूछें…');
  String get attachedNotes => _('Attached notes', 'जुड़े हुए नोट्स');
  String get openHereNoDownload => _('Open them here — no download needed.', 'यहीं खोलें — डाउनलोड की ज़रूरत नहीं।');
  String get noNotesAttached =>
      _('Your teacher has not attached notes to this lecture.', 'शिक्षक ने इस लेक्चर के साथ नोट्स नहीं जोड़े हैं।');
  String get playerUnavailable => _('Video playback is not available on this device.', 'इस डिवाइस पर वीडियो नहीं चल सकता।');
  String get playerMisconfigured =>
      _('This lecture is not set up correctly. Please tell support.', 'यह लेक्चर ठीक से सेट नहीं है। कृपया सहायता टीम को बताएँ।');
  String get playerBlocked => _(
    'This lecture cannot play right now. Our team has been notified — please try later.',
    'यह लेक्चर अभी नहीं चल सकता। टीम को सूचना दे दी गई है — थोड़ी देर बाद कोशिश करें।',
  );
  String get playerLoadFailed =>
      _('The video failed to load. Check your connection and try again.', 'वीडियो लोड नहीं हुआ। इंटरनेट जाँचें और फिर कोशिश करें।');
  String get back10 => _('Back 10 seconds', '10 सेकंड पीछे');
  String get forward10 => _('Forward 10 seconds', '10 सेकंड आगे');
  String get play => _('Play', 'चलाएँ');
  String get pause => _('Pause', 'रोकें');
  String get fullScreen => _('Full screen', 'फ़ुल स्क्रीन');
  String get exitFullScreen => _('Exit full screen', 'फ़ुल स्क्रीन बंद करें');

  String get classNotes => _('Class notes', 'क्लास नोट्स');
  String get noNotesForLesson => _('No notes have been added to this lesson yet.', 'इस पाठ में अभी कोई नोट्स नहीं जोड़े गए।');
  String pageOf(int p, int n) => _('Page $p of $n', 'पेज $p / $n');
  String get notesCouldNotOpen => _('These notes could not be opened.', 'ये नोट्स नहीं खुल सके।');
  String get notAPdf => _('This file is not a readable PDF.', 'यह फ़ाइल पढ़ने लायक PDF नहीं है।');
  String get prev => _('‹ Prev', '‹ पिछला');
  String get next => _('Next ›', 'अगला ›');

  // --------------------------------------------------------- academics
  String get academics => _('Academics', 'पढ़ाई');
  String get academicsLead => _('Everything for your learning journey', 'आपकी पढ़ाई का सब कुछ, एक जगह');
  String get liveSessions => _('Live sessions', 'लाइव सेशन');
  String get liveSessionsLead => _('Join live or catch the recording', 'लाइव जुड़ें या रिकॉर्डिंग देखें');
  String get classNotesTitle => _('Class notes', 'क्लास नोट्स');
  String get classNotesLead => _('Chapter PDFs from your courses', 'आपके कोर्स के अध्याय PDF');
  String get calendar => _('Calendar', 'कैलेंडर');
  String get calendarLead => _('Classes and tests by day', 'दिन के हिसाब से क्लास और टेस्ट');
  String get announcements => _('Announcements', 'घोषणाएँ');

  String get searchNotes => _('Search notes', 'नोट्स खोजें');
  String get noNotesFound => _('No notes found', 'कोई नोट्स नहीं मिले');
  String noFilterNotes(String f) => _('Teachers have not uploaded $f notes yet.', 'शिक्षकों ने अभी $f के नोट्स अपलोड नहीं किए हैं।');
  String nothingMatchesQuery(String q) => _('Nothing matches “$q”.', '“$q” से कुछ नहीं मिला।');
  String get freeNotesTitle => _('Free notes and solved PYQs', 'मुफ़्त नोट्स और हल किए गए PYQ');
  String get notesOnTheWay => _('Chapter notes are on the way.', 'अध्याय के नोट्स जल्द आ रहे हैं।');
  String get notesOnTheWayBody => _(
    'A notes PDF and solved PYQs for every Class 12 chapter, in Hindi and English. They will open right here in the secure viewer.',
    'कक्षा 12 के हर अध्याय का नोट्स PDF और हल किए गए PYQ, हिंदी और अंग्रेज़ी में। ये यहीं सुरक्षित व्यूअर में खुलेंगे।',
  );

  // -------------------------------------------------------------- live
  String get upcoming => _('Upcoming', 'आने वाली');
  String get recordings => _('Recordings', 'रिकॉर्डिंग');
  String get past => _('Past', 'पिछली');
  String reviseFormula(String c) => _('Revise the $c formula sheet', '$c की फ़ॉर्मूला शीट दोहरा लें');
  String get noClassesScheduled => _('No classes scheduled', 'कोई क्लास तय नहीं');
  String get noRecordingsYet => _('No recordings yet', 'अभी कोई रिकॉर्डिंग नहीं');
  String get newLiveClassesAppear =>
      _('New live classes appear here as teachers schedule them.', 'शिक्षक जैसे ही नई लाइव क्लास तय करेंगे, यहाँ दिखेंगी।');
  String get finishedClassesAppear =>
      _('Finished classes show up here with their recording.', 'पूरी हुई क्लास अपनी रिकॉर्डिंग के साथ यहाँ दिखेंगी।');
  String studentsCount(int n) => _('$n students', '$n छात्र');
  String studentsEnrolled(int n) => _('$n students enrolled', '$n छात्रों का दाख़िला');
  String watching(int n) => _('$n watching', '$n देख रहे हैं');
  String get joinLiveArrow => _('Join live class →', 'लाइव क्लास से जुड़ें →');
  String get joinLive => _('Join live class', 'लाइव क्लास से जुड़ें');
  String get remind => _('Remind', 'याद दिलाएँ');
  String get reminderSetShort => _('✓ Set', '✓ सेट');
  String get remindMe => _('Remind me', 'मुझे याद दिलाएँ');
  String get reminderSet => _('✓ Reminder set', '✓ रिमाइंडर सेट');
  String get notifyBefore => _("We'll notify you 5 minutes before class.", 'क्लास से 5 मिनट पहले हम आपको सूचना देंगे।');
  String get addToCalendar => _('Add to calendar', 'कैलेंडर में जोड़ें');
  String get classStarted => _('Class has started', 'क्लास शुरू हो गई है');
  String get classStartsIn => _('Class starts in', 'क्लास शुरू होने में');
  String get minCaps => _('MIN', 'मिनट');
  String get secCaps => _('SEC', 'सेकंड');
  String get beforeClass => _('Before class', 'क्लास से पहले');
  String reviseChapter(String c) => _('Revise the $c chapter', '$c अध्याय दोहरा लें');
  String get keepNotebook => _('Keep a notebook ready for practice questions', 'अभ्यास के सवालों के लिए कॉपी तैयार रखें');
  String get leave => _('← Leave', '← बाहर जाएँ');
  String liveTimer(String t) => _('● LIVE · $t', '● लाइव · $t');
  String get chat => _('Chat', 'चैट');
  String get questions => _('Questions', 'सवाल');
  String questionsN(int n) => _('Questions ($n)', 'सवाल ($n)');
  String get myNotes => _('My notes', 'मेरे नोट्स');
  String get askTeacher => _('Ask the teacher a question…', 'शिक्षक से सवाल पूछें…');
  String get writeNote => _('Write a note for yourself…', 'अपने लिए नोट लिखें…');
  String get messageClass => _('Message the class…', 'क्लास को संदेश भेजें…');
  String get handRaised => _('Hand raised — your teacher can see it.', 'हाथ उठाया — शिक्षक इसे देख सकते हैं।');
  String get handLowered => _('Hand lowered.', 'हाथ नीचे किया।');
  String get raiseHand => _('Raise hand', 'हाथ उठाएँ');
  String get lowerHand => _('Lower hand', 'हाथ नीचे करें');
  String get teacherCamera => _('Teacher camera', 'शिक्षक का कैमरा');
  String get askedByYou => _('Asked by you • 0 upvotes', 'आपने पूछा • 0 वोट');
  String myNoteAt(String t) => _('My note · $t', 'मेरा नोट · $t');
  String get liveCaps => _('LIVE', 'लाइव');
  String get liveNowCaps => _('LIVE NOW', 'अभी लाइव');
  String get teacherCaps => _('TEACHER', 'शिक्षक');
  String get joinNow => _('Join now', 'अभी जुड़ें');

  // ---------------------------------------------------------- calendar
  String get noClassesThisDay => _('No classes scheduled', 'इस दिन कोई क्लास नहीं');
  String get pickDayWithDot => _('Pick a day with a dot to see its classes.', 'क्लास देखने के लिए बिंदु वाला दिन चुनें।');
  String get previousMonth => _('Previous month', 'पिछला महीना');
  String get nextMonth => _('Next month', 'अगला महीना');

  // ---------------------------------------------------------- downloads
  String get downloads => _('Downloads', 'डाउनलोड');
  String get nothingDownloaded => _('Nothing downloaded', 'कुछ डाउनलोड नहीं हुआ');
  String get downloadOnWifi =>
      _('Download lectures and notes on wifi to study without data.', 'बिना डेटा पढ़ने के लिए वाई-फ़ाई पर लेक्चर और नोट्स डाउनलोड करें।');
  String get downloadsOffline => _(
    'Downloads play offline inside the app for as long as your course is active.',
    'जब तक कोर्स चालू है, डाउनलोड ऐप में बिना इंटरनेट चलते हैं।',
  );
  String get videos => _('Videos', 'वीडियो');
  String get removeDownload => _('Remove download', 'डाउनलोड हटाएँ');
  String pausedAt(int p) => _('Paused · $p%', 'रुका हुआ · $p%');
  String get resume => _('Resume', 'जारी रखें');
  String get more => _('More', 'और');

  // ------------------------------------------------------ notifications
  String get notifications => _('Notifications', 'सूचनाएँ');
  String unreadAlerts(int n) => _('$n unread · alerts & announcements', '$n नई · सूचनाएँ और घोषणाएँ');
  String get recentAlerts => _('Recent alerts & updates', 'हाल की सूचनाएँ');
  String get markAllRead => _('Mark all read', 'सभी पढ़ लिए');
  String get noNotifications => _('No notifications yet', 'अभी कोई सूचना नहीं');
  String get noNotificationsBody =>
      _('Class updates, announcements and support replies show up here.', 'क्लास अपडेट, घोषणाएँ और सहायता के जवाब यहाँ दिखेंगे।');

  // ------------------------------------------------------------ tickets
  String get replyWithinDay => _('We usually reply within a day', 'हम आमतौर पर एक दिन में जवाब देते हैं');
  String get raiseNewTicket => _('Raise a new ticket', 'नया टिकट बनाएँ');
  String get raiseTicketLead =>
      _('Payments, course content, the app or anything else', 'पेमेंट, कोर्स, ऐप या कुछ और');
  String get yourTickets => _('Your tickets', 'आपके टिकट');
  String get noTicketsYet => _('No tickets yet', 'अभी कोई टिकट नहीं');
  String get noTicketsBody => _('Raise one and our team will reply here.', 'टिकट बनाएँ, हमारी टीम यहीं जवाब देगी।');
  String get couldNotSendTicket => _('Could not send the ticket. Try again.', 'टिकट नहीं भेजा जा सका। फिर कोशिश करें।');
  String get raiseATicket => _('Raise a ticket', 'टिकट बनाएँ');
  String get category => _('Category', 'श्रेणी');
  String get subjectLabel => _('Subject', 'शीर्षक');
  String get subjectHint => _('Briefly describe the issue', 'समस्या संक्षेप में लिखें');
  String get detailsLabel => _('Details', 'विवरण');
  String get detailsHint =>
      _('Include order ID, course name or screenshots where helpful', 'ज़रूरत हो तो ऑर्डर ID, कोर्स का नाम या स्क्रीनशॉट जोड़ें');
  String get teamRepliesHere =>
      _('Our team replies here — you will also get a notification.', 'हमारी टीम यहीं जवाब देगी — आपको सूचना भी मिलेगी।');
  String get submitTicket => _('Submit ticket', 'टिकट भेजें');
  String ticketClosedNote(String status) =>
      _('This ticket is $status. Raise a new one if the problem comes back.', 'यह टिकट $status है। समस्या फिर आए तो नया टिकट बनाएँ।');
  String get writeReply => _('Write a reply…', 'जवाब लिखें…');
  String openedAgo(String when) => _('Opened $when', '$when खोला गया');
  String get statusOpen => _('Open', 'खुला');
  String get statusInProgress => _('In progress', 'जारी');
  String get statusResolved => _('Resolved', 'हल हुआ');
  String get statusClosed => _('Closed', 'बंद');
  String get catPayment => _('Payment', 'पेमेंट');
  String get catContent => _('Course content', 'कोर्स सामग्री');
  String get catTechnical => _('Technical', 'तकनीकी');
  String get catAccount => _('Account', 'अकाउंट');
  String get catOther => _('Other', 'अन्य');

  // ------------------------------------------------------------ profile
  String get profileSettings => _('Profile & settings', 'प्रोफ़ाइल और सेटिंग्स');
  String get accountCaps => _('ACCOUNT', 'अकाउंट');
  String get learningCaps => _('LEARNING', 'पढ़ाई');
  String get supportCaps => _('SUPPORT', 'सहायता');
  String get personalInfo => _('Personal information', 'निजी जानकारी');
  String get nameSetAtSignIn => _('Name and phone are set at sign-in.', 'नाम और फ़ोन साइन इन के समय से लिए जाते हैं।');
  String get studentId => _('Student ID', 'स्टूडेंट ID');
  String get studentIdCopied => _('Student ID copied.', 'स्टूडेंट ID कॉपी हो गई।');
  String get classAndStream => _('Class & stream', 'कक्षा और स्ट्रीम');
  String get myPurchases => _('My purchases', 'मेरी ख़रीदारी');
  String get videoQuality => _('Video quality', 'वीडियो क्वालिटी');
  String get videoQualityHint =>
      _('Lower quality saves mobile data and avoids buffering.', 'कम क्वालिटी से मोबाइल डेटा बचता है और वीडियो अटकता नहीं।');
  String get myTickets => _('My tickets', 'मेरे टिकट');
  String get privacyTerms => _('Privacy & terms', 'गोपनीयता और शर्तें');
  String get readAtSite => _('Read them at abacademy.in/privacy', 'abacademy.in/privacy पर पढ़ें');
  String get logOut => _('Log out', 'लॉग आउट');
  String get logOutQ => _('Log out?', 'लॉग आउट करें?');
  String get logOutBody =>
      _('You will need your mobile number or Google account to sign back in.', 'दोबारा साइन इन के लिए आपको अपना Google अकाउंट चाहिए होगा।');
  String get signOut => _('Sign out', 'साइन आउट');
  String get signOutQ => _('Sign out?', 'साइन आउट करें?');
  String get signOutBody => _('You will need your Google account to sign back in.', 'दोबारा साइन इन के लिए आपको अपना Google अकाउंट चाहिए होगा।');
  String get studentViewProfile => _('STUDENT · View profile', 'छात्र · प्रोफ़ाइल देखें');
  String codeViewProfile(String code) => _('$code · View profile', '$code · प्रोफ़ाइल देखें');
  String get groupGeneral => _('General', 'सामान्य');
  String get groupInformation => _('Information', 'जानकारी');
  String get groupAccount => _('Account', 'अकाउंट');
  String get settings => _('Settings', 'सेटिंग्स');
  String get shareApp => _('Share app', 'ऐप शेयर करें');
  String get checkUpdates => _('Check for updates', 'अपडेट देखें');
  String latestVersion(String v) => _('You are on the latest version$v', 'आप नए वर्ज़न पर हैं$v');
  String get aboutUs => _('About us', 'हमारे बारे में');
  String get termsConditions => _('Terms & conditions', 'नियम और शर्तें');
  String get refundPolicy => _('Refund policy', 'रिफ़ंड नीति');
  String get dataDeletion => _('Data & account deletion', 'डेटा और अकाउंट हटाना');
  String get contactUs => _('Contact us', 'संपर्क करें');
  String get deleteAccountOrData => _('Delete account or data', 'अकाउंट या डेटा हटाएँ');

  // ------------------------------------------------------- deletion
  String get deletionNeedsInternet => _('Deletion requests need an internet connection.', 'हटाने के अनुरोध के लिए इंटरनेट चाहिए।');
  String get deletionReceived => _('Request received. We will complete it within 3 days.', 'अनुरोध मिल गया। हम इसे 3 दिन में पूरा करेंगे।');
  String get deletionFailed =>
      _('Could not send your request. Try again, or email support@abacademy.in.', 'अनुरोध नहीं भेजा जा सका। फिर कोशिश करें, या support@abacademy.in पर ईमेल करें।');
  String get deletionCancelled => _('Your request was cancelled.', 'आपका अनुरोध रद्द हो गया।');
  String get couldNotCancel => _('Could not cancel. Try again.', 'रद्द नहीं हो सका। फिर कोशिश करें।');
  String get requestInProgress => _('Request in progress', 'अनुरोध जारी है');
  String accountDeletedBy(String d) => _('You asked us to delete your account. It will be deleted by $d.', 'आपने अकाउंट हटाने को कहा है। यह $d तक हट जाएगा।');
  String dataErasedBy(String d) => _('You asked us to delete your personal data. It will be erased by $d.', 'आपने निजी डेटा हटाने को कहा है। यह $d तक मिट जाएगा।');
  String get cancelMyRequest => _('Cancel my request', 'मेरा अनुरोध रद्द करें');
  String get chooseWhatToDelete =>
      _('Choose what you want us to delete. We complete every request within 3 days.', 'चुनें कि क्या हटाना है। हम हर अनुरोध 3 दिन में पूरा करते हैं।');
  String get deleteMyData => _('Delete my data', 'मेरा डेटा हटाएँ');
  String get deleteMyDataBody => _(
    'Erase my name, school, doubts, comments, support tickets and history. Keep my account and courses.',
    'मेरा नाम, स्कूल, डाउट, कमेंट, टिकट और हिस्ट्री मिटाएँ। अकाउंट और कोर्स रहने दें।',
  );
  String get deleteMyAccount => _('Delete my account', 'मेरा अकाउंट हटाएँ');
  String get deleteMyAccountBody => _(
    'Erase everything above and close my account for good, including access to courses I bought.',
    'ऊपर का सब कुछ मिटाएँ और अकाउंट हमेशा के लिए बंद करें, ख़रीदे गए कोर्स समेत।',
  );
  String get reasonOptional => _('Reason (optional)', 'कारण (वैकल्पिक)');
  String get ordersKept =>
      _('Orders and payment records are kept without your name, as Indian tax law requires.', 'भारतीय कर क़ानून के अनुसार ऑर्डर और पेमेंट रिकॉर्ड आपके नाम के बिना रखे जाते हैं।');
  String get confirmAccount =>
      _('I understand my account and course access will be permanently deleted.', 'मैं समझता/समझती हूँ कि मेरा अकाउंट और कोर्स हमेशा के लिए हट जाएँगे।');
  String get confirmData =>
      _('I understand my personal data will be permanently erased.', 'मैं समझता/समझती हूँ कि मेरा निजी डेटा हमेशा के लिए मिट जाएगा।');
  String get requestAccountDeletion => _('Request account deletion', 'अकाउंट हटाने का अनुरोध करें');
  String get requestDataDeletion => _('Request data deletion', 'डेटा हटाने का अनुरोध करें');
  String get requestDeletion => _('Request deletion', 'हटाने का अनुरोध करें');

  // ---------------------------------------------------------- purchase
  String get checkout => _('Checkout', 'चेकआउट');
  String get secure => _('Secure', 'सुरक्षित');
  String get completeEnrolment => _('COMPLETE YOUR ENROLMENT', 'अपना दाख़िला पूरा करें');
  String withTeacher(String t) => _('with $t', '$t के साथ');
  String get incRecorded => _('Recorded classes — watch anytime', 'रिकॉर्डेड क्लास — कभी भी देखें');
  String incLive(String t) => _('Live doubt sessions with $t', '$t के साथ लाइव डाउट सेशन');
  String get incAppWeb => _('On the app and the website', 'ऐप और वेबसाइट दोनों पर');
  String get incAccess => _('Access until 31 March 2027', '31 मार्च 2027 तक एक्सेस');
  String get payWith => _('Pay with', 'पेमेंट का तरीका');
  String paymentFinePrint(String email) => _(
    'Payments are processed securely by Razorpay — we never see your card or UPI details. 7-day refund if you have watched 3 lectures or fewer. Questions? $email',
    'पेमेंट Razorpay से सुरक्षित होता है — आपके कार्ड या UPI की जानकारी हम तक नहीं आती। 3 या कम लेक्चर देखे हों तो 7 दिन में रिफ़ंड। सवाल? $email',
  );
  String get total => _('Total', 'कुल');
  String get openingPayment => _('Opening payment…', 'पेमेंट खुल रहा है…');
  String get paySecurely => _('Pay securely', 'सुरक्षित पेमेंट करें');
  String get upiApps => _('Google Pay, PhonePe, Paytm or any UPI app', 'Google Pay, PhonePe, Paytm या कोई भी UPI ऐप');
  String get cardNetbanking => _('Card / Net banking', 'कार्ड / नेट बैंकिंग');
  String get cardBanks => _('Visa, Mastercard, RuPay and all major banks', 'Visa, Mastercard, RuPay और सभी बड़े बैंक');
  String get coursePrice => _('Course price', 'कोर्स की क़ीमत');
  String get discount => _('Discount', 'छूट');
  String get paymentNotCompleted => _('Payment could not be completed. Try again.', 'पेमेंट पूरा नहीं हुआ। फिर कोशिश करें।');
  String get paymentCancelled => _('Payment cancelled.', 'पेमेंट रद्द हुआ।');
  String get paymentFailedNothingCharged => _('Payment failed. Nothing was charged.', 'पेमेंट नहीं हुआ। कोई पैसा नहीं कटा।');
  String finishingIn(String wallet) =>
      _('Finishing payment in $wallet — your course unlocks as soon as it is confirmed.', '$wallet में पेमेंट पूरा हो रहा है — पुष्टि होते ही कोर्स खुल जाएगा।');
  String get orderId => _('Order ID', 'ऑर्डर ID');
  String get amountPaid => _('Amount paid', 'भुगतान राशि');
  String get method => _('Method', 'तरीका');
  String get paymentSuccessful => _('Payment successful', 'पेमेंट सफल');
  String enrolledIn(String title) => _("You're enrolled in $title.", 'आपका $title में दाख़िला हो गया।');
  String get testModeNothingCharged => _('Test mode — nothing was charged.', 'टेस्ट मोड — कोई पैसा नहीं कटा।');
  String get downloadReceipt => _('Download receipt', 'रसीद डाउनलोड करें');
  String get receiptsRealOnly => _('Receipts are issued for real payments only.', 'रसीद सिर्फ़ असली पेमेंट की मिलती है।');
  String get receiptEmailed => _('Razorpay has emailed your receipt.', 'Razorpay ने आपकी रसीद ईमेल कर दी है।');

  // -------------------------------------------------------------- info
  String updatedOn(String d) => _('Updated $d', 'अंतिम बदलाव $d');
  String get aboutEyebrow => _('ABOUT AB ACADEMY', 'AB अकादमी के बारे में');
  String get aboutTitle => _('Built for Class 12 students.', 'कक्षा 12 के छात्रों के लिए।');
  String aboutLead(int years) => _(
    'A teacher with $years years in the classroom and a developer, building the crash course they wish students had: affordable, focused and in your language.',
    '$years साल से पढ़ा रहे एक शिक्षक और एक डेवलपर — मिलकर वह क्रैश कोर्स बना रहे हैं जो वे छात्रों को देना चाहते थे: सस्ता, सीधा और आपकी भाषा में।',
  );
  String get peopleBehind => _('The people behind it', 'इसके पीछे के लोग');
  String get founders => _('Founders', 'संस्थापक');
  String get whatWeDo => _('What we do', 'हम क्या करते हैं');
  String get oneTeacherThree => _('One teacher. Three subjects.', 'एक शिक्षक। तीन विषय।');
  String get wwdPcm => _('Class 12 PCM crash courses', 'कक्षा 12 PCM क्रैश कोर्स');
  String get wwdPcmBody =>
      _('Physics, Chemistry and Maths for Class 12, chapter by chapter.', 'कक्षा 12 के लिए भौतिकी, रसायन और गणित — अध्याय दर अध्याय।');
  String get wwdRecorded => _('Recorded classes, live doubts', 'रिकॉर्डेड क्लास, लाइव डाउट');
  String get wwdRecordedBody => _(
    'Ajit Sir records every class and takes every live doubt session himself.',
    'हर क्लास अजीत सर ख़ुद रिकॉर्ड करते हैं और हर लाइव डाउट सेशन ख़ुद लेते हैं।',
  );
  String get wwdPriced => _('Priced for every student', 'हर छात्र की पहुँच में');
  String get wwdPricedBody => _('₹249 a subject, with a free demo class to try first.', '₹249 प्रति विषय, पहले आज़माने के लिए मुफ़्त डेमो क्लास।');
  String get roleFounder => _('Founder', 'संस्थापक');
  String get roleCofounder => _('Co-founder & Developer', 'सह-संस्थापक और डेवलपर');
  String role(String r) => switch (r) {
    'Founder' => roleFounder,
    'Co-founder & Developer' => roleCofounder,
    _ => r,
  };
  String get replyWithin2 => _('We reply within 2 working days', 'हम 2 कामकाजी दिनों में जवाब देते हैं');
  String get talkToUs => _('Talk to us.', 'हमसे बात करें।');
  String get contactLead => _(
    'For questions about a course, a payment or your account, raise a support ticket — it reaches the team fastest and you can follow the reply in the app.',
    'कोर्स, पेमेंट या अकाउंट से जुड़े सवालों के लिए सपोर्ट टिकट बनाएँ — यह टीम तक सबसे जल्दी पहुँचता है और जवाब ऐप में ही मिलता है।',
  );
  String get raiseSupportTicket => _('Raise a support ticket', 'सपोर्ट टिकट बनाएँ');
  String get emailCopied => _('Email address copied.', 'ईमेल पता कॉपी हो गया।');
  String get hindiLegalNote => _(
    '',
    'यह हिंदी अनुवाद आपकी सुविधा के लिए है। किसी भी अंतर की स्थिति में अंग्रेज़ी संस्करण मान्य होगा।',
  );

  // ------------------------------------------------------------ popups
  String get notNow => _('Not now', 'अभी नहीं');
  String get gotIt => _('Got it', 'ठीक है');

  // -------------------------------------------------------------- push
  String get pushChannel => _('Class and course updates', 'क्लास और कोर्स अपडेट');
  String get pushChannelBody =>
      _('Live class reminders, new recordings, notes and replies.', 'लाइव क्लास रिमाइंडर, नई रिकॉर्डिंग, नोट्स और जवाब।');
}
