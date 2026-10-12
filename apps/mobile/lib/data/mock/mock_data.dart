import '../models/banner.dart';
import '../models/content.dart';
import '../models/course.dart';
import '../models/lesson_extras.dart';
import '../models/schedule.dart';
import '../models/ticket.dart';
import '../models/user.dart';

/// Static seed data reproducing the content shown in the 2026 app redesign
/// (Class 11 & 12 crash courses). Shaped after the Supabase schema so the real
/// data source drops in without touching screens.
abstract final class MockData {
  static const student = Student(
    fullName: 'Rahul Kumar',
    phone: '+91 98765 43210',
    classLevel: 12,
    board: 'Bihar Board',
    medium: 'Hindi',
    stream: 'Science',
    studentCode: 'ABA-S-4MZT8KQ2',
  );

  static const amitSir = Teacher(
    displayName: 'Amit Sir',
    subject: 'Physics',
    yearsExperience: 11,
  );
  static const nehaMaam = Teacher(
    displayName: "Neha Ma'am",
    subject: 'Chemistry',
    yearsExperience: 8,
  );
  static const raviSir = Teacher(
    displayName: 'Ravi Sir',
    subject: 'Biology',
    yearsExperience: 9,
  );

  static const scienceSubjects = [
    'Physics',
    'Chemistry',
    'Mathematics',
    'Biology',
  ];

  /// Every crash course runs on the same plan length.
  static const planDays = 90;

  static const _crashHighlights = [
    'Daily live classes with doubt solving',
    'Recordings for every chapter',
    'Chapter-wise PDF notes',
    'Weekly board-pattern tests',
    'Offline downloads for low network',
  ];

  static const _validity =
      'Access until 31 March 2027, including the full board revision series in January.';

  // ---------------------------------------------------------------- courses

  static const scienceCrash = Course(
    id: 'class-12-science-crash-course-2027',
    title: 'Class 12 Science Crash Course',
    subtitle: "PCM + PCB • Amit Sir, Neha Ma'am +2",
    board: 'Bihar Board',
    classLevel: 12,
    batchLabel: 'BIHAR BOARD • 2027 BATCH',
    progressPercent: 42,
    chaptersCompleted: 12,
    chaptersTotal: 28,
    subjects: scienceSubjects,
    teachers: [amitSir, nehaMaam, raviSir],
    priceInr: 2499,
    originalPriceInr: 4999,
    description:
        'Complete Class 12 Science revision in 90 days with live classes, chapter '
        'recordings, notes and board-pattern tests.',
    nextUpLabel: 'Next: Physics • Electric Charges',
    lessonsCount: 120,
    notesCount: 38,
    liveClassesCount: 24,
    highlights: _crashHighlights,
    validityNote: _validity,
    stream: 'Science · PCM + PCB',
    tagline: 'Physics · Chemistry · Maths · Biology',
    badge: 'Bestseller',
    rating: 4.8,
    reviewCount: 1260,
    questionsCount: 3000,
    thumbnailHue: 214,
    planDay: 38,
  );

  static const physicsCrash = Course(
    id: 'class-12-physics-crash-course',
    title: 'Physics Crash Course',
    subtitle: 'Class 12 • Amit Sir',
    board: 'Bihar Board',
    classLevel: 12,
    batchLabel: 'CLASS 12 • PHYSICS',
    progressPercent: 65,
    chaptersCompleted: 9,
    chaptersTotal: 14,
    subjects: ['Physics'],
    teachers: [amitSir],
    priceInr: 999,
    originalPriceInr: 1799,
    description:
        'Electrostatics to Semiconductors with numericals, derivations and important '
        'board questions.',
    nextUpLabel: 'Next: Ray Optics revision',
    lessonsCount: 48,
    notesCount: 22,
    liveClassesCount: 16,
    highlights: _crashHighlights,
    validityNote: _validity,
    stream: 'Physics',
    tagline: 'Full Physics syllabus',
    badge: 'Top rated',
    language: 'Hindi',
    rating: 4.9,
    reviewCount: 842,
    questionsCount: 1200,
    thumbnailHue: 198,
    planDay: 52,
  );

  static const commerceCrash = Course(
    id: 'class-12-commerce-crash-course',
    title: 'Commerce Crash Course',
    subtitle: 'Class 12 • Ravi Sir',
    board: 'Bihar Board',
    classLevel: 12,
    batchLabel: 'CLASS 12 • COMMERCE',
    progressPercent: 0,
    chaptersCompleted: 0,
    chaptersTotal: 24,
    subjects: ['Accountancy', 'Business Studies', 'Economics'],
    teachers: [raviSir],
    priceInr: 1999,
    originalPriceInr: 3499,
    description:
        'Fast revision of Accountancy, Business Studies and Economics with solved board papers.',
    isEnrolled: false,
    lessonsCount: 90,
    highlights: _crashHighlights,
    validityNote: _validity,
    stream: 'Commerce',
    tagline: 'Accountancy · BST · Economics',
    badge: 'Popular',
    language: 'Hindi',
    rating: 4.7,
    reviewCount: 540,
    questionsCount: 1800,
    thumbnailHue: 320,
  );

  static const artsCrash = Course(
    id: 'class-12-arts-crash-course',
    title: 'Arts Crash Course',
    subtitle: 'Class 12 • Faculty Team',
    board: 'Bihar Board',
    classLevel: 12,
    batchLabel: 'CLASS 12 • ARTS',
    progressPercent: 0,
    chaptersCompleted: 0,
    chaptersTotal: 20,
    subjects: ['History', 'Political Science', 'Geography'],
    teachers: [],
    priceInr: 1799,
    originalPriceInr: 2999,
    description:
        'Chapter summaries, map work and answer-writing practice for Class 12 Arts boards.',
    isEnrolled: false,
    lessonsCount: 80,
    highlights: _crashHighlights,
    validityNote: _validity,
    stream: 'Arts',
    tagline: 'History · Pol. Science · Geography',
    badge: 'New',
    language: 'Hindi',
    rating: 4.6,
    reviewCount: 310,
    questionsCount: 1400,
    thumbnailHue: 28,
  );

  static const science11Crash = Course(
    id: 'class-11-science-crash-course',
    title: 'Class 11 Science Crash Course',
    subtitle: "Class 11 • Neha Ma'am",
    board: 'Bihar Board',
    classLevel: 11,
    batchLabel: 'CLASS 11 • SCIENCE',
    progressPercent: 0,
    chaptersCompleted: 0,
    chaptersTotal: 26,
    subjects: scienceSubjects,
    teachers: [nehaMaam],
    priceInr: 1999,
    originalPriceInr: 3499,
    description:
        'Cover Class 11 Science quickly so Class 12 and entrance prep feel manageable.',
    isEnrolled: false,
    lessonsCount: 100,
    highlights: _crashHighlights,
    validityNote: _validity,
    stream: 'Science · PCM + PCB',
    tagline: 'PCM + PCB · Strong base',
    badge: 'Foundation',
    rating: 4.7,
    reviewCount: 420,
    questionsCount: 2200,
    thumbnailHue: 162,
  );

  static const commerce11Crash = Course(
    id: 'class-11-commerce-crash-course',
    title: 'Class 11 Commerce Crash Course',
    subtitle: 'Class 11 • Ravi Sir',
    board: 'Bihar Board',
    classLevel: 11,
    batchLabel: 'CLASS 11 • COMMERCE',
    progressPercent: 0,
    chaptersCompleted: 0,
    chaptersTotal: 18,
    subjects: ['Accountancy', 'Business Studies', 'Economics'],
    teachers: [raviSir],
    priceInr: 1499,
    originalPriceInr: 2499,
    description:
        'Clear Class 11 Commerce concepts with numerical practice and Hindi notes.',
    isEnrolled: false,
    lessonsCount: 72,
    highlights: _crashHighlights,
    validityNote: _validity,
    stream: 'Commerce',
    tagline: 'Accountancy · BST · Economics',
    badge: 'New',
    language: 'Hindi',
    rating: 4.5,
    reviewCount: 210,
    questionsCount: 900,
    thumbnailHue: 250,
  );

  /// The student's enrolments.
  static const courses = [scienceCrash, physicsCrash];

  /// Everything on sale, for the Explore screen.
  static const catalog = [
    scienceCrash,
    physicsCrash,
    commerceCrash,
    artsCrash,
    science11Crash,
    commerce11Crash,
  ];

  // ---------------------------------------------------------------- slider

  /// Course slider slides — `course_banners` rows, managed from the admin.
  static const banners = [
    CourseBanner(
      id: 'b1',
      title: 'Class 12 Science Crash Course',
      subtitle: 'Finish the syllabus in 90 days · 50% off',
      courseId: 'class-12-science-crash-course-2027',
      ctaLabel: 'Enroll now',
      hue: 214,
    ),
    CourseBanner(
      id: 'b2',
      title: 'Commerce Crash Course',
      subtitle: 'Accountancy · BST · Economics — ₹1,999',
      courseId: 'class-12-commerce-crash-course',
      ctaLabel: 'View course',
      hue: 320,
    ),
    CourseBanner(
      id: 'b3',
      title: 'Class 11 Science foundation',
      subtitle: 'Build a strong base for Class 12',
      courseId: 'class-11-science-crash-course',
      ctaLabel: 'Explore',
      hue: 162,
    ),
  ];

  // ------------------------------------------------------------- curriculum

  static const chapterOne = Chapter(
    number: 1,
    title: 'Electric Charges and Fields',
    lessonsCompleted: 3,
    lessonsTotal: 4,
    lessons: [
      Lesson(
        id: 'ch1-l1',
        title: "Class 1 · Coulomb's Law",
        kind: LessonKind.recorded,
        state: LessonState.completed,
        durationLabel: 'Recorded • 32 min',
      ),
      Lesson(
        id: 'ch1-l2',
        title: 'Class 2 · Electric Field Lines',
        kind: LessonKind.recorded,
        state: LessonState.completed,
        durationLabel: 'Recorded • 48 min',
      ),
      Lesson(
        id: 'ch1-l3',
        title: "Class 3 · Gauss's Law",
        kind: LessonKind.recorded,
        state: LessonState.current,
        durationLabel: 'Recorded • 52 min',
        resumeLabel: 'Resume at 38:14',
      ),
      Lesson(
        id: 'ch1-l4',
        title: 'Class 4 · Practice Session',
        kind: LessonKind.live,
        state: LessonState.live,
        scheduleLabel: 'LIVE • Today 6:00 PM',
      ),
      Lesson(
        id: 'ch1-notes',
        title: 'Chapter 01 Notes',
        kind: LessonKind.notes,
        state: LessonState.notes,
        sizeLabel: 'PDF • 2.4 MB',
      ),
    ],
  );

  static const chapters = [
    chapterOne,
    Chapter(
      number: 2,
      title: 'Electrostatic Potential',
      lessonsCompleted: 1,
      lessonsTotal: 5,
    ),
    Chapter(
      number: 3,
      title: 'Current Electricity',
      lessonsCompleted: 0,
      lessonsTotal: 6,
    ),
    Chapter(
      number: 4,
      title: 'Moving Charges and Magnetism',
      lessonsCompleted: 0,
      lessonsTotal: 5,
      trailingNote: '0 / 5 lessons · live this week',
    ),
    Chapter(
      number: 5,
      title: 'Electromagnetic Induction',
      lessonsCompleted: 0,
      lessonsTotal: 4,
    ),
    Chapter(
      number: 6,
      title: 'Ray Optics',
      lessonsCompleted: 0,
      lessonsTotal: 5,
      isLocked: true,
      unlockLabel: 'Unlocks 22 Oct',
    ),
  ];

  // --------------------------------------------------------------- schedule

  static const todaySchedule = [
    ScheduleItem(
      timeLabel: '4:00 PM',
      title: 'English Revision',
      subtitle: 'Recorded • 45 min',
      kind: SessionKind.recorded,
      subject: 'English',
    ),
    ScheduleItem(
      timeLabel: '6:00 PM',
      title: 'Physics',
      subtitle: 'Electric Charges • Amit Sir',
      kind: SessionKind.live,
      subject: 'Physics',
      isNow: true,
      joinable: true,
    ),
    ScheduleItem(
      timeLabel: '7:30 PM',
      title: 'Chemistry',
      subtitle: 'Solutions • 52 min',
      kind: SessionKind.recorded,
      subject: 'Chemistry',
    ),
  ];

  static const calendarAgenda = [
    ScheduleItem(
      timeLabel: '6:00 PM',
      title: 'Physics',
      subtitle: 'Electric Charges • Amit Sir',
      kind: SessionKind.live,
      subject: 'Physics',
      isNow: true,
      joinable: true,
    ),
    ScheduleItem(
      timeLabel: '7:30 PM',
      title: 'Chemistry',
      subtitle: "Solutions • Neha Ma'am",
      kind: SessionKind.recorded,
      subject: 'Chemistry',
    ),
    ScheduleItem(
      timeLabel: '8:30 PM',
      title: 'Physics weekly test',
      subtitle: '15 questions • 30 min',
      kind: SessionKind.test,
      subject: 'Physics',
    ),
  ];

  /// Event dots in the calendar, keyed by day offset from today.
  static const calendarMarks = <int, SessionKind>{
    0: SessionKind.live,
    2: SessionKind.recorded,
    4: SessionKind.test,
    7: SessionKind.recorded,
    10: SessionKind.live,
    14: SessionKind.recorded,
    -3: SessionKind.recorded,
    -6: SessionKind.live,
  };

  static const liveNow = LiveSession(
    id: 'live-electric-charges',
    subject: 'Physics',
    title: 'Electric Charges and Fields',
    teacherName: 'Amit Sir',
    teacherInitials: 'AS',
    scheduleLabel: 'Today • 6:00 PM',
    studentsEnrolled: 327,
    startsInSeconds: 0,
    status: LiveStatus.liveNow,
    chapterLabel: 'Chapter 01 · Electric Charges and Fields',
  );

  static const upcomingLive = LiveSession(
    id: 'live-integrals',
    subject: 'Mathematics',
    title: 'Integrals',
    teacherName: 'Amit Sir',
    teacherInitials: 'AS',
    scheduleLabel: 'Today • 8:00 PM',
    studentsEnrolled: 327,
    startsInSeconds: 872, // 14:32
    chapterLabel: 'Chapter 07 · Integrals',
  );

  // --------------------------------------------------------- live classroom

  static const liveChat = [
    LiveMessage(
      author: 'Rahul',
      initials: 'RK',
      body: 'Sir please explain Question 5.',
    ),
    LiveMessage(
      author: 'Priya',
      initials: 'PS',
      body: 'Will this come in board exam?',
    ),
    LiveMessage(
      author: 'Amit Sir',
      initials: 'AS',
      body: 'Yes Priya — 2 marks almost every year.',
      isTeacher: true,
    ),
    LiveMessage(author: 'Ankit', initials: 'AK', body: 'धन्यवाद सर 🙏'),
  ];

  static const liveQuestions = [
    LiveMessage(
      author: 'Priya',
      initials: 'PS',
      body: 'Is the field zero at the centre of a dipole?',
      meta: 'Asked by Priya • 12 upvotes',
    ),
    LiveMessage(
      author: 'Rahul',
      initials: 'RK',
      body: "Sir, will you share today's PDF?",
      meta: 'Answered',
    ),
  ];

  static const liveSlideTitle = 'Electric Field due to a Dipole';
  static const liveSlideLabel = 'SLIDE 12 / 24';
  static const liveSlideBody = [
    'E(axial) = 2kp / r³',
    'E(equatorial) = kp / r³',
    'p = q × 2a',
  ];
  static const liveNoteTitle = 'My notes · 6:14 PM';
  static const liveNoteBody =
      'Axial field is twice the equatorial field at the same distance.';

  // -------------------------------------------------------- study materials

  static const materials = [
    StudyMaterial(
      id: 'm1',
      title: 'Electric Charges — notes',
      subject: 'Physics',
      kind: MaterialKind.pdf,
      sizeLabel: 'PDF • 2.4 MB',
      updatedLabel: 'Updated 12 Oct',
      showActions: true,
    ),
    StudyMaterial(
      id: 'm2',
      title: 'Current Electricity — formulas',
      subject: 'Physics',
      kind: MaterialKind.pdf,
      sizeLabel: 'PDF • 1.1 MB',
      isOffline: true,
    ),
    StudyMaterial(
      id: 'm3',
      title: 'Solutions & Electrochemistry',
      subject: 'Chemistry',
      kind: MaterialKind.pdf,
      sizeLabel: 'PDF • 3.1 MB',
    ),
    StudyMaterial(
      id: 'm4',
      title: 'Integrals — important questions',
      subject: 'Mathematics',
      kind: MaterialKind.pdf,
      sizeLabel: 'PDF • 1.6 MB',
    ),
    StudyMaterial(
      id: 'm5',
      title: 'Reproduction in Organisms',
      subject: 'Biology',
      kind: MaterialKind.pdf,
      sizeLabel: 'PDF • 2.8 MB',
    ),
  ];

  // ------------------------------------------------------------- downloads

  static const downloadsUsedLabel = '1.8 GB used';
  static const downloadsFreeLabel = '4.2 GB free';
  static const downloadsVideoShare = 0.26;
  static const downloadsNotesShare = 0.07;

  static const downloads = [
    DownloadItem(
      id: 'd1',
      title: 'Physics · Electric Charges',
      subject: 'Physics',
      kind: DownloadKind.video,
      state: DownloadState.available,
      metaLabel: '48 min • 320 MB',
    ),
    DownloadItem(
      id: 'd2',
      title: 'Chemistry · Solutions',
      subject: 'Chemistry',
      kind: DownloadKind.video,
      state: DownloadState.downloading,
      metaLabel: 'Downloading • 62% of 280 MB',
      progress: 0.62,
    ),
    DownloadItem(
      id: 'd3',
      title: 'Current Electricity — formula sheet',
      subject: 'Physics',
      kind: DownloadKind.pdf,
      state: DownloadState.available,
      metaLabel: '1.1 MB',
    ),
    DownloadItem(
      id: 'd4',
      title: 'Integrals — important questions',
      subject: 'Mathematics',
      kind: DownloadKind.pdf,
      state: DownloadState.available,
      metaLabel: '1.6 MB',
    ),
  ];

  // ---------------------------------------------------------- notifications

  static const notifications = [
    AppNotification(
      id: 'n1',
      title: 'Live class starting soon',
      body: 'Physics starts in 5 minutes.',
      kind: NotificationKind.live,
      group: NotificationGroup.today,
      timeAgo: '5m',
      actionLabel: 'Join Class →',
      isUnread: true,
    ),
    AppNotification(
      id: 'n2',
      title: 'Test reminder',
      body: 'Your Physics weekly test is due today.',
      kind: NotificationKind.test,
      group: NotificationGroup.today,
      timeAgo: '2h',
      isUnread: true,
    ),
    AppNotification(
      id: 'n3',
      title: 'New recording available',
      body: "Yesterday's Chemistry class is now available.",
      kind: NotificationKind.recording,
      group: NotificationGroup.yesterday,
      actionLabel: 'Watch Now →',
    ),
    AppNotification(
      id: 'n4',
      title: 'New notes uploaded',
      body: 'Chapter 02 — Electrochemistry.',
      kind: NotificationKind.notes,
      group: NotificationGroup.yesterday,
    ),
    AppNotification(
      id: 'n5',
      title: 'Weekly test result',
      body: 'Physics Weekly Test 06 — you scored 17 / 20.',
      kind: NotificationKind.result,
      group: NotificationGroup.earlier,
    ),
  ];

  // ------------------------------------------------------------- continue

  static const continueLesson = (
    subject: 'Chemistry',
    title: 'Ch 2 · Electrochemistry',
    progress: 0.68,
    durationLabel: '18:42',
  );

  static const upcomingTest = (
    title: 'Physics test on Sunday',
    detail: '20 questions • Chapters 1–3',
  );

  // -------------------------------------------------------------- checkout

  static const paymentMethods = [
    PaymentMethodOption(
      name: 'UPI',
      subtitle: 'Pay by any UPI app',
      short: 'UPI',
    ),
    PaymentMethodOption(
      name: 'Google Pay',
      subtitle: 'rahul@okaxis',
      short: 'GP',
    ),
    PaymentMethodOption(
      name: 'PhonePe',
      subtitle: 'Linked account',
      short: 'PP',
    ),
    PaymentMethodOption(
      name: 'Debit / Credit Card',
      subtitle: 'Visa, Mastercard, RuPay',
      short: 'CARD',
    ),
  ];

  static const orderId = 'ABA-2026-84172';

  // ----------------------------------------------------------- live sessions

  /// Everything the Live screen groups into Live now / Upcoming / Past.
  static const liveSessions = [
    liveNow,
    upcomingLive,
    LiveSession(
      id: 'live-solutions',
      subject: 'Chemistry',
      title: 'Solutions',
      teacherName: "Neha Ma'am",
      teacherInitials: 'NM',
      scheduleLabel: 'Tomorrow • 5:00 PM',
      studentsEnrolled: 294,
      startsInSeconds: 82800,
      chapterLabel: 'Chapter 02 · Solutions',
    ),
    LiveSession(
      id: 'live-genetics',
      subject: 'Biology',
      title: 'Genetics',
      teacherName: 'Ravi Sir',
      teacherInitials: 'RS',
      scheduleLabel: 'Thursday • 4:00 PM',
      studentsEnrolled: 256,
      startsInSeconds: 176400,
      chapterLabel: 'Chapter 05 · Principles of Inheritance',
    ),
    LiveSession(
      id: 'live-potential-doubts',
      subject: 'Physics',
      title: 'Electrostatic Potential — doubt session',
      teacherName: 'Amit Sir',
      teacherInitials: 'AS',
      scheduleLabel: 'Yesterday • 6:00 PM',
      studentsEnrolled: 311,
      startsInSeconds: 0,
      status: LiveStatus.ended,
      chapterLabel: 'Chapter 02 · Electrostatic Potential',
      durationLabel: '58 min',
    ),
    LiveSession(
      id: 'live-colligative',
      subject: 'Chemistry',
      title: 'Colligative Properties',
      teacherName: "Neha Ma'am",
      teacherInitials: 'NM',
      scheduleLabel: '8 Oct • 5:00 PM',
      studentsEnrolled: 288,
      startsInSeconds: 0,
      status: LiveStatus.ended,
      chapterLabel: 'Chapter 02 · Solutions',
      durationLabel: '1 h 04 min',
    ),
  ];

  // -------------------------------------------------------------- lectures

  /// Plays in the lecture player on mock data: Blender's "Big Buck Bunny",
  /// a Creative Commons film that allows embedding.
  static const demoYoutubeId = 'aqz-KE-bpKQ';

  static const lectureTitle = "Gauss's Law — Class 03";
  static const lectureEyebrow = 'PHYSICS · CHAPTER 01';
  static const lectureAbout =
      "Electric flux and Gauss's law with applications to a line charge, a plane sheet "
      'and a spherical shell. Includes four board-pattern derivations.';

  /// PDFs attached to a lecture. The asset is bundled so the viewer works offline.
  static const lessonAttachments = [
    LessonAttachment(
      id: 'att-1',
      title: 'Chapter 01 Notes',
      sizeLabel: 'PDF • 2.4 MB',
      assetPath: 'assets/sample-notes.pdf',
    ),
    LessonAttachment(
      id: 'att-2',
      title: "Gauss's Law — worked examples",
      sizeLabel: 'PDF • 1.8 MB',
      assetPath: 'assets/sample-notes.pdf',
    ),
  ];

  static const lessonComments = [
    LessonComment(
      id: 'c1',
      author: 'Priya Sharma',
      initials: 'PS',
      body: 'Sir, why is the flux zero for a charge outside the surface?',
      timeLabel: '2h',
      replies: [
        LessonComment(
          id: 'c1r1',
          author: 'Amit Sir',
          initials: 'AS',
          body:
              'Every field line that enters also leaves, so the net flux cancels to zero.',
          timeLabel: '1h',
          isTeacher: true,
        ),
      ],
    ),
    LessonComment(
      id: 'c2',
      author: 'Ankit Kumar',
      initials: 'AK',
      body: 'धन्यवाद सर, अब समझ आ गया 🙏',
      timeLabel: '45m',
    ),
    LessonComment(
      id: 'c3',
      author: 'Rahul Kumar',
      initials: 'RK',
      body: 'Can we get more board-pattern derivations on the spherical shell?',
      timeLabel: '20m',
      isMe: true,
    ),
  ];

  static const lessonFeedback = LessonFeedback(
    averageRating: 4.6,
    ratingCount: 128,
  );

  // --------------------------------------------------------------- tickets

  static const tickets = [
    Ticket(
      id: 't1',
      reference: 'ABA-T-1042',
      subject: 'Payment deducted but course not unlocked',
      category: TicketCategory.payment,
      status: TicketStatus.inProgress,
      openedLabel: 'Opened 2 days ago',
      messages: [
        TicketMessage(
          id: 'tm1',
          body:
              'I paid ₹2,499 by UPI yesterday but the Class 12 Science crash course still '
              'shows as locked.',
          timeLabel: '2 days ago',
          fromSupport: false,
        ),
        TicketMessage(
          id: 'tm2',
          body:
              'Thanks for writing in Rahul. We can see the payment and are reconciling it '
              'with the bank. Your access will be unlocked within 24 hours.',
          timeLabel: '1 day ago',
          fromSupport: true,
          authorName: 'Support · Kavita',
        ),
      ],
    ),
    Ticket(
      id: 't2',
      reference: 'ABA-T-1017',
      subject: 'Video keeps buffering on mobile data',
      category: TicketCategory.technical,
      status: TicketStatus.resolved,
      openedLabel: 'Opened 1 week ago',
      messages: [
        TicketMessage(
          id: 'tm3',
          body: 'Lectures buffer constantly on 4G but work on wifi.',
          timeLabel: '1 week ago',
          fromSupport: false,
        ),
        TicketMessage(
          id: 'tm4',
          body:
              'Set Video Quality to 480p under Profile → Learning for mobile data, '
              'and download lessons overnight on wifi. Closing this — reopen if it persists.',
          timeLabel: '5 days ago',
          fromSupport: true,
          authorName: 'Support · Manish',
        ),
      ],
    ),
  ];
}
