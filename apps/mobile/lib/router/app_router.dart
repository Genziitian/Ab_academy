import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/remote/payment_service.dart';
import '../screens/academics/academics_screen.dart';
import '../screens/calendar/calendar_screen.dart';
import '../screens/courses/course_details_screen.dart';
import '../screens/courses/curriculum_screen.dart';
import '../screens/courses/courses_screen.dart';
import '../screens/downloads/downloads_screen.dart';
import '../screens/home/app_shell.dart';
import '../screens/home/home_screen.dart';
import '../screens/lessons/lecture_screen.dart';
import '../screens/lessons/pdf_viewer_screen.dart';
import '../screens/live/live_classroom_screen.dart';
import '../screens/live/live_lobby_screen.dart';
import '../screens/notifications/notifications_screen.dart';
import '../screens/onboarding/login_screen.dart';
import '../screens/onboarding/otp_screen.dart';
import '../screens/onboarding/setup_class_screen.dart';
import '../screens/onboarding/setup_stream_screen.dart';
import '../screens/onboarding/splash_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/purchase/checkout_screen.dart';
import '../screens/purchase/payment_success_screen.dart';
import '../screens/tickets/new_ticket_screen.dart';
import '../screens/tickets/ticket_detail_screen.dart';
import '../screens/tickets/tickets_screen.dart';

abstract final class Routes {
  static const splash = '/';
  static const login = '/login';
  static const otp = '/otp';
  static const setupClass = '/setup/class';
  static const setupStream = '/setup/stream';

  // Bottom-nav tabs, in AppTab order.
  static const home = '/home';
  static const courses = '/courses';
  static const academics = '/academics';
  static const profile = '/profile';

  // Sections inside those tabs.
  static const store = '/courses?tab=store';
  static const myCourses = '/courses?tab=mine';
  static const live = '/academics?tab=live';
  static const notes = '/academics?tab=notes';

  // Pushed full-screen routes.
  static const calendar = '/calendar';
  static const downloads = '/downloads';
  static const notifications = '/notifications';
  static const curriculum = '/curriculum';
  static const liveLobby = '/live/lobby';
  static const liveRoom = '/live/room';
  static const tickets = '/tickets';
  static const newTicket = '/tickets/new';
  static const paymentSuccess = '/payment-success';

  static String courseDetails(String id) => '/course/$id';
  static String lesson(String id) => '/lesson/$id';

  /// A note by id, or with [lesson] the first note of a lesson.
  static String pdf(String id, {bool lesson = false}) =>
      lesson ? '/pdf/$id?lesson=1' : '/pdf/$id';
  static String ticket(String id) => '/ticket/$id';
  static String purchase(String id) => '/purchase/$id';
  static String checkout(String id) => '/checkout/$id';
}

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: Routes.splash,
    routes: [
      GoRoute(path: Routes.splash, builder: (_, _) => const SplashScreen()),
      GoRoute(path: Routes.login, builder: (_, _) => const LoginScreen()),
      GoRoute(path: Routes.otp, builder: (_, _) => const OtpScreen()),
      GoRoute(
        path: Routes.setupClass,
        builder: (_, _) => const SetupClassScreen(),
      ),
      GoRoute(
        path: Routes.setupStream,
        builder: (_, _) => const SetupStreamScreen(),
      ),

      // The four bottom-nav tabs share a shell and keep their own stacks.
      StatefulShellRoute.indexedStack(
        builder: (_, _, shell) => AppShell(navigationShell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(path: Routes.home, builder: (_, _) => const HomeScreen()),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.courses,
                builder: (_, state) =>
                    CoursesScreen(initialTab: state.uri.queryParameters['tab']),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.academics,
                builder: (_, state) => AcademicsScreen(
                  initialTab: state.uri.queryParameters['tab'],
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.profile,
                builder: (_, _) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),

      GoRoute(path: Routes.calendar, builder: (_, _) => const CalendarScreen()),
      GoRoute(
        path: Routes.downloads,
        builder: (_, _) => const DownloadsScreen(),
      ),
      GoRoute(
        path: Routes.notifications,
        builder: (_, _) => const NotificationsScreen(),
      ),
      // Old paths, kept so existing deep links and notifications still land.
      GoRoute(path: '/explore', redirect: (_, _) => Routes.store),
      GoRoute(path: '/live', redirect: (_, _) => Routes.live),
      GoRoute(path: '/notes', redirect: (_, _) => Routes.notes),
      GoRoute(path: '/materials', redirect: (_, _) => Routes.notes),
      GoRoute(
        path: Routes.curriculum,
        // The course id rides along as `extra`; absent opens the first course.
        builder: (_, state) =>
            CurriculumScreen(courseId: state.extra as String?),
      ),
      GoRoute(
        path: Routes.liveLobby,
        builder: (_, _) => const LiveLobbyScreen(),
      ),
      GoRoute(
        path: Routes.liveRoom,
        builder: (_, _) => const LiveClassroomScreen(),
      ),
      GoRoute(path: Routes.tickets, builder: (_, _) => const TicketsScreen()),
      GoRoute(
        path: Routes.newTicket,
        builder: (_, _) => const NewTicketScreen(),
      ),
      GoRoute(
        path: Routes.paymentSuccess,
        builder: (_, state) => PaymentSuccessScreen(
          receipt: state.extra is PaymentReceipt
              ? state.extra as PaymentReceipt
              : null,
        ),
      ),
      GoRoute(
        path: '/course/:id',
        builder: (_, state) =>
            CourseDetailsScreen(courseId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/lesson/:id',
        builder: (_, state) =>
            LectureScreen(lessonId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/pdf/:id',
        builder: (_, state) => PdfViewerScreen(
          id: state.pathParameters['id']!,
          byLesson: state.uri.queryParameters['lesson'] == '1',
          // Titles ride along in memory; they are never put in the URL.
          title: state.extra is String ? state.extra as String : null,
        ),
      ),
      GoRoute(
        path: '/ticket/:id',
        builder: (_, state) =>
            TicketDetailScreen(ticketId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/purchase/:id',
        // Kept for old deep links; the course page now carries the purchase.
        builder: (_, state) =>
            CourseDetailsScreen(courseId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/checkout/:id',
        builder: (_, state) =>
            CheckoutScreen(courseId: state.pathParameters['id']!),
      ),
    ],
  );
});
