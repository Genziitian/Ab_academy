import '../models/community.dart';
import '../models/content.dart';
import '../models/course.dart';
import '../models/lesson_extras.dart';
import '../models/schedule.dart';
import '../models/ticket.dart';
import '../models/user.dart';

/// Static seed data reproducing the content shown in the Bihar Board App design.
/// Shaped after the Supabase schema so a real data source can drop in later.
abstract final class MockData {
  static const student = Student(
    fullName: 'Rahul Kumar',
    phone: '+91 98765 43210',
    classLevel: 10,
    board: 'Bihar Board',
    medium: 'Hindi',
  );

  static const amitSir = Teacher(
    displayName: 'Amit Sir',
    subject: 'Mathematics',
    yearsExperience: 11,
  );
  static const nehaMaam = Teacher(
    displayName: "Neha Ma'am",
    subject: 'Science',
    yearsExperience: 8,
  );

  static const allSubjects = ['Mathematics', 'Science', 'Hindi', 'English', 'Social Science'];

  // ---------------------------------------------------------------- courses

  static const completeBatch = Course(
    id: 'class-10-complete-batch',
    title: 'Class 10 Complete Batch',
    subtitle: "All subjects • Amit Sir, Neha Ma'am +4",
    board: 'Bihar Board',
    classLevel: 10,
    batchLabel: 'BIHAR BOARD • 2027 BATCH',
    progressPercent: 42,
    chaptersCompleted: 12,
    chaptersTotal: 28,
    subjects: allSubjects,
    teachers: [amitSir, nehaMaam],
    priceInr: 2999,
    originalPriceInr: 4999,
    description:
        'Complete Bihar Board Class 10 preparation in Hindi medium. Daily live classes, '
        'chapter-wise recorded lessons, NCERT-aligned notes and weekly tests up to the '
        'board exam in February 2027.',
    nextUpLabel: 'Next: Mathematics • Quadratic Equations',
    lessonsCount: 156,
    notesCount: 38,
    liveClassesCount: 24,
    highlights: [
      '156+ recorded classes',
      '50+ live classes with doubt solving',
      'Chapter-wise PDF notes',
      'Weekly tests and board-pattern papers',
      'Offline downloads for low-network areas',
    ],
    validityNote:
        'Access until 31 March 2027, including the full board revision series in January.',
  );

  static const boardBooster = Course(
    id: 'mathematics-board-booster',
    title: 'Mathematics Board Booster',
    subtitle: 'Class 10 • Amit Sir',
    board: 'Bihar Board',
    classLevel: 10,
    batchLabel: 'BIHAR BOARD • 2027 BATCH',
    progressPercent: 65,
    chaptersCompleted: 13,
    chaptersTotal: 20,
    subjects: ['Mathematics'],
    teachers: [amitSir],
    priceInr: 1499,
    originalPriceInr: 2499,
    description: 'Focused Mathematics revision for the Bihar Board Class 10 paper.',
    nextUpLabel: 'Next: Trigonometry revision',
    lessonsCount: 84,
    notesCount: 22,
    liveClassesCount: 16,
  );

  static const courses = [completeBatch, boardBooster];

  // ------------------------------------------------------------- curriculum

  static const chapterOne = Chapter(
    number: 1,
    title: 'Real Numbers',
    lessonsCompleted: 3,
    lessonsTotal: 4,
    lessons: [
      Lesson(
        id: 'ch1-l1',
        title: 'Class 1 · Introduction to Real Numbers',
        kind: LessonKind.recorded,
        state: LessonState.completed,
        durationLabel: 'Recorded • 32 min',
      ),
      Lesson(
        id: 'ch1-l2',
        title: "Class 2 · Euclid's Division Lemma",
        kind: LessonKind.recorded,
        state: LessonState.completed,
        durationLabel: 'Recorded • 48 min',
      ),
      Lesson(
        id: 'ch1-l3',
        title: 'Class 3 · Fundamental Theorem of Arithmetic',
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
    Chapter(number: 2, title: 'Polynomials', lessonsCompleted: 1, lessonsTotal: 5),
    Chapter(number: 3, title: 'Pair of Linear Equations', lessonsCompleted: 0, lessonsTotal: 6),
    Chapter(
      number: 4,
      title: 'Quadratic Equations',
      lessonsCompleted: 0,
      lessonsTotal: 5,
      trailingNote: '0 / 5 lessons · live today',
    ),
    Chapter(number: 5, title: 'Arithmetic Progressions', lessonsCompleted: 0, lessonsTotal: 4),
    Chapter(
      number: 6,
      title: 'Triangles',
      lessonsCompleted: 0,
      lessonsTotal: 5,
      isLocked: true,
      unlockLabel: 'Unlocks 22 Sept',
    ),
  ];

  // --------------------------------------------------------------- schedule

  static const todaySchedule = [
    ScheduleItem(
      timeLabel: '4:00 PM',
      title: 'Hindi Grammar Revision',
      subtitle: 'Recorded • 45 min',
      kind: SessionKind.recorded,
      subject: 'Hindi',
    ),
    ScheduleItem(
      timeLabel: '6:00 PM',
      title: 'Mathematics',
      subtitle: 'Quadratic Equations • Amit Sir',
      kind: SessionKind.live,
      subject: 'Mathematics',
      isNow: true,
      joinable: true,
    ),
    ScheduleItem(
      timeLabel: '7:30 PM',
      title: 'Science',
      subtitle: 'Carbon & Compounds • 52 min',
      kind: SessionKind.recorded,
      subject: 'Science',
    ),
  ];

  static const calendarAgenda = [
    ScheduleItem(
      timeLabel: '6:00 PM',
      title: 'Mathematics',
      subtitle: 'Quadratic Equations • Amit Sir',
      kind: SessionKind.live,
      subject: 'Mathematics',
      isNow: true,
      joinable: true,
    ),
    ScheduleItem(
      timeLabel: '7:30 PM',
      title: 'Science',
      subtitle: "Carbon & Compounds • Neha Ma'am",
      kind: SessionKind.live,
      subject: 'Science',
    ),
    ScheduleItem(
      timeLabel: '8:30 PM',
      title: 'Physics Test',
      subtitle: '15 questions • 30 min',
      kind: SessionKind.test,
      subject: 'Science',
    ),
  ];

  /// Event dots in the September 2026 grid, keyed by day-of-month.
  static const calendarMarks = <int, SessionKind>{
    14: SessionKind.live,
    16: SessionKind.recorded,
    18: SessionKind.test,
    21: SessionKind.recorded,
    24: SessionKind.live,
    28: SessionKind.recorded,
  };

  static const liveNow = LiveSession(
    id: 'live-quadratic',
    subject: 'Mathematics',
    title: 'Quadratic Equations',
    teacherName: 'Amit Sir',
    teacherInitials: 'AS',
    scheduleLabel: 'Today • 6:00 PM',
    studentsEnrolled: 327,
    startsInSeconds: 0,
  );

  static const upcomingLive = LiveSession(
    id: 'live-trigonometry',
    subject: 'Mathematics',
    title: 'Trigonometry',
    teacherName: 'Amit Sir',
    teacherInitials: 'AS',
    scheduleLabel: 'Today • 6:00 PM',
    studentsEnrolled: 327,
    startsInSeconds: 872, // 14:32
  );

  // --------------------------------------------------------- live classroom

  static const liveChat = [
    LiveMessage(author: 'Rahul', initials: 'RK', body: 'Sir please explain Question 5.'),
    LiveMessage(author: 'Priya', initials: 'PS', body: 'Will this come in board exam?'),
    LiveMessage(
      author: 'Amit Sir',
      initials: 'AS',
      body: 'Yes Priya — 2 marks almost every year. Rahul, doing Q5 now.',
      isTeacher: true,
    ),
    LiveMessage(author: 'Ankit', initials: 'AK', body: 'धन्यवाद सर 🙏'),
  ];

  static const liveQuestions = [
    LiveMessage(
      author: 'Priya',
      initials: 'PS',
      body: 'Is √2 rational or irrational?',
      meta: 'Asked by Priya • 12 upvotes',
    ),
    LiveMessage(
      author: 'Rahul',
      initials: 'RK',
      body: "Sir, will you share today's PDF?",
      meta: 'Answered',
    ),
  ];

  static const liveSlideTitle = 'Trigonometric Ratios';
  static const liveSlideLabel = 'SLIDE 12 / 24';
  static const liveSlideBody = [
    'sin θ = Perpendicular / Hypotenuse',
    'cos θ = Base / Hypotenuse',
    'tan θ = Perpendicular / Base',
  ];
  static const liveNoteTitle = 'My notes · 6:14 PM';
  static const liveNoteBody = 'tan θ = sin θ / cos θ — revise identity list before test.';

  // -------------------------------------------------------- study materials

  static const materials = [
    StudyMaterial(
      id: 'm1',
      title: 'Chapter 04 Notes — Carbon and its Compounds',
      subject: 'Science',
      kind: MaterialKind.pdf,
      sizeLabel: 'PDF • 4.2 MB',
      updatedLabel: 'Updated 12 Sept',
      showActions: true,
    ),
    StudyMaterial(
      id: 'm2',
      title: 'Quadratic Equations — formula sheet',
      subject: 'Mathematics',
      kind: MaterialKind.pdf,
      sizeLabel: 'PDF • 1.1 MB',
      updatedLabel: 'Updated 09 Sept',
      isOffline: true,
    ),
    StudyMaterial(
      id: 'm3',
      title: 'व्याकरण — समास और संधि',
      subject: 'Hindi',
      kind: MaterialKind.pdf,
      sizeLabel: 'PDF • 2.6 MB',
    ),
    StudyMaterial(
      id: 'm4',
      title: 'English — Letter Writing formats',
      subject: 'English',
      kind: MaterialKind.doc,
      sizeLabel: 'PDF • 0.8 MB',
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
      title: 'Mathematics · Quadratic Equations',
      subject: 'Mathematics',
      kind: DownloadKind.video,
      state: DownloadState.available,
      metaLabel: '48 min • 320 MB',
    ),
    DownloadItem(
      id: 'd2',
      title: 'Science · Carbon and its Compounds',
      subject: 'Science',
      kind: DownloadKind.video,
      state: DownloadState.downloading,
      metaLabel: 'Downloading • 62% of 280 MB',
      progress: 0.62,
    ),
    DownloadItem(
      id: 'd3',
      title: 'Quadratic Equations — formula sheet',
      subject: 'Mathematics',
      kind: DownloadKind.pdf,
      state: DownloadState.available,
      metaLabel: '1.1 MB',
    ),
    DownloadItem(
      id: 'd4',
      title: 'व्याकरण — समास और संधि',
      subject: 'Hindi',
      kind: DownloadKind.pdf,
      state: DownloadState.available,
      metaLabel: '2.6 MB',
    ),
  ];

  // ---------------------------------------------------------- notifications

  static const notifications = [
    AppNotification(
      id: 'n1',
      title: 'Live class starting soon',
      body: 'Mathematics starts in 5 minutes.',
      kind: NotificationKind.live,
      group: NotificationGroup.today,
      timeAgo: '5m',
      actionLabel: 'Join Class →',
      isUnread: true,
    ),
    AppNotification(
      id: 'n2',
      title: 'Test reminder',
      body: 'Your Physics test is due today.',
      kind: NotificationKind.test,
      group: NotificationGroup.today,
      timeAgo: '2h',
    ),
    AppNotification(
      id: 'n3',
      title: 'New recording available',
      body: "Yesterday's Science class recording is now available.",
      kind: NotificationKind.recording,
      group: NotificationGroup.yesterday,
      actionLabel: 'Watch Now →',
    ),
    AppNotification(
      id: 'n4',
      title: 'New notes uploaded',
      body: 'Chapter 04 notes — Carbon and its Compounds.',
      kind: NotificationKind.notes,
      group: NotificationGroup.yesterday,
    ),
    AppNotification(
      id: 'n5',
      title: 'Weekly test result',
      body: 'Maths Weekly Test 06 — you scored 17 / 20.',
      kind: NotificationKind.result,
      group: NotificationGroup.earlier,
    ),
  ];

  // ------------------------------------------------------------- continue

  static const continueLesson = (
    subject: 'Science',
    title: 'Chapter 4 · Carbon and its Compounds',
    progress: 0.68,
    durationLabel: '18:42',
  );

  static const upcomingTest = (
    title: 'Science test on Sunday',
    detail: '20 questions • Chapter 1–4',
  );

  // -------------------------------------------------------------- checkout

  static const paymentMethods = [
    PaymentMethodOption(name: 'UPI', subtitle: 'Pay by any UPI app', short: 'UPI'),
    PaymentMethodOption(name: 'Google Pay', subtitle: 'rahul@okaxis', short: 'GP'),
    PaymentMethodOption(name: 'PhonePe', subtitle: 'Linked account', short: 'PP'),
    PaymentMethodOption(
      name: 'Debit / Credit Card',
      subtitle: 'Visa, Mastercard, RuPay',
      short: '💳',
    ),
  ];

  static const orderId = 'ABA-2026-84172';
  static const discountInr = 2000;

  // ----------------------------------------------------------- live sessions

  /// Everything the Live screen groups into Live now / Upcoming / Past.
  static const liveSessions = [
    LiveSession(
      id: 'live-quadratic',
      subject: 'Mathematics',
      title: 'Quadratic Equations',
      teacherName: 'Amit Sir',
      teacherInitials: 'AS',
      scheduleLabel: 'Today • 6:00 PM',
      studentsEnrolled: 327,
      startsInSeconds: 0,
      status: LiveStatus.liveNow,
      chapterLabel: 'Chapter 04 · Quadratic Equations',
    ),
    LiveSession(
      id: 'live-trigonometry',
      subject: 'Mathematics',
      title: 'Trigonometry',
      teacherName: 'Amit Sir',
      teacherInitials: 'AS',
      scheduleLabel: 'Today • 8:00 PM',
      studentsEnrolled: 327,
      startsInSeconds: 872,
      chapterLabel: 'Chapter 08 · Introduction to Trigonometry',
    ),
    LiveSession(
      id: 'live-carbon',
      subject: 'Science',
      title: 'Carbon and its Compounds',
      teacherName: "Neha Ma'am",
      teacherInitials: 'NM',
      scheduleLabel: 'Tomorrow • 5:00 PM',
      studentsEnrolled: 294,
      startsInSeconds: 82800,
      chapterLabel: 'Chapter 04 · Carbon and its Compounds',
    ),
    LiveSession(
      id: 'live-grammar',
      subject: 'Hindi',
      title: 'व्याकरण — समास',
      teacherName: 'Ravi Sir',
      teacherInitials: 'RS',
      scheduleLabel: 'Thursday • 4:00 PM',
      studentsEnrolled: 256,
      startsInSeconds: 176400,
    ),
    LiveSession(
      id: 'live-real-numbers',
      subject: 'Mathematics',
      title: 'Real Numbers — doubt session',
      teacherName: 'Amit Sir',
      teacherInitials: 'AS',
      scheduleLabel: 'Yesterday • 6:00 PM',
      studentsEnrolled: 311,
      startsInSeconds: 0,
      status: LiveStatus.ended,
      chapterLabel: 'Chapter 01 · Real Numbers',
      durationLabel: '58 min',
    ),
    LiveSession(
      id: 'live-light',
      subject: 'Science',
      title: 'Light — Reflection and Refraction',
      teacherName: "Neha Ma'am",
      teacherInitials: 'NM',
      scheduleLabel: '14 Sept • 5:00 PM',
      studentsEnrolled: 288,
      startsInSeconds: 0,
      status: LiveStatus.ended,
      chapterLabel: 'Chapter 10 · Light',
      durationLabel: '1 h 04 min',
    ),
  ];

  // -------------------------------------------------------------- lectures

  /// PDFs attached to a lecture. The asset is bundled so the viewer works offline.
  static const lessonAttachments = [
    LessonAttachment(
      id: 'att-1',
      title: 'Class 03 — worked examples',
      sizeLabel: 'PDF • 1.8 MB',
      assetPath: 'assets/sample-notes.pdf',
    ),
    LessonAttachment(
      id: 'att-2',
      title: 'Quadratic Equations — formula sheet',
      sizeLabel: 'PDF • 1.1 MB',
      assetPath: 'assets/sample-notes.pdf',
    ),
  ];

  static const lessonComments = [
    LessonComment(
      id: 'c1',
      author: 'Priya Sharma',
      initials: 'PS',
      body: 'Sir, in example 3 why do we take the positive root only?',
      timeLabel: '2h ago',
      replies: [
        LessonComment(
          id: 'c1r1',
          author: 'Amit Sir',
          initials: 'AS',
          body:
              'Good question Priya — the negative root gives a negative length, '
              'which is not possible here, so we discard it.',
          timeLabel: '1h ago',
          isTeacher: true,
        ),
      ],
    ),
    LessonComment(
      id: 'c2',
      author: 'Ankit Kumar',
      initials: 'AK',
      body: 'धन्यवाद सर, अब समझ आ गया 🙏',
      timeLabel: '45m ago',
    ),
    LessonComment(
      id: 'c3',
      author: 'Rahul Kumar',
      initials: 'RK',
      body: 'Can we get more board-pattern questions on completing the square?',
      timeLabel: '20m ago',
      isMe: true,
    ),
  ];

  static const lessonFeedback = LessonFeedback(averageRating: 4.6, ratingCount: 128);

  // ------------------------------------------------------------ communities

  /// One per enrolled course — created by trigger in the real schema.
  static const communities = [
    Community(
      id: 'comm-class-10',
      courseId: 'class-10-complete-batch',
      name: 'Class 10 Complete Batch',
      subject: 'Mathematics',
      memberCount: 327,
      messages: [
        CommunityMessage(
          id: 'm1',
          author: 'Amit Sir',
          initials: 'AS',
          body: "Tomorrow's live class moves to 7:00 PM. Please note the change.",
          timeLabel: '3h ago',
          pinned: true,
          isTeacher: true,
        ),
        CommunityMessage(
          id: 'm2',
          author: 'Priya Sharma',
          initials: 'PS',
          body: 'Has anyone finished the Chapter 4 worksheet?',
          timeLabel: '2h ago',
        ),
        CommunityMessage(
          id: 'm3',
          author: 'Ankit Kumar',
          initials: 'AK',
          body: 'Yes, question 7 was the tricky one.',
          timeLabel: '1h ago',
        ),
        CommunityMessage(
          id: 'm4',
          author: 'Rahul Kumar',
          initials: 'RK',
          body: 'Same here. Sir explained it in the doubt session recording.',
          timeLabel: '25m ago',
          isMe: true,
        ),
      ],
    ),
    Community(
      id: 'comm-booster',
      courseId: 'mathematics-board-booster',
      name: 'Mathematics Board Booster',
      subject: 'Mathematics',
      memberCount: 184,
      messages: [
        CommunityMessage(
          id: 'm5',
          author: 'Amit Sir',
          initials: 'AS',
          body: 'Trigonometry revision sheet is up in Study Materials.',
          timeLabel: 'Yesterday',
          pinned: true,
          isTeacher: true,
        ),
        CommunityMessage(
          id: 'm6',
          author: 'Sneha Verma',
          initials: 'SV',
          body: 'Thank you sir!',
          timeLabel: 'Yesterday',
        ),
      ],
    ),
  ];

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
              'I paid ₹2,999 by UPI yesterday but the Class 10 batch still shows as locked. '
              'The amount has left my account.',
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
