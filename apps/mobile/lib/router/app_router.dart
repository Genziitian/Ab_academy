import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../screens/calendar/calendar_screen.dart';
import '../screens/courses/course_details_screen.dart';
import '../screens/courses/curriculum_screen.dart';
import '../screens/courses/explore_screen.dart';
import '../screens/courses/my_courses_screen.dart';
import '../screens/downloads/downloads_screen.dart';
import '../screens/home/app_shell.dart';
import '../screens/home/home_screen.dart';
import '../screens/lessons/lecture_screen.dart';
import '../screens/lessons/pdf_viewer_screen.dart';
import '../screens/live/live_classroom_screen.dart';
import '../screens/live/live_lobby_screen.dart';
import '../screens/live/live_sessions_screen.dart';
import '../screens/materials/study_materials_screen.dart';
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
  static const live = '/live';
  static const notes = '/notes';
  static const profile = '/profile';

  // Pushed full-screen routes.
  static const calendar = '/calendar';
  static const downloads = '/downloads';
  static const notifications = '/notifications';
  static const explore = '/explore';
  static const curriculum = '/curriculum';
  static const liveLobby = '/live/lobby';
  static const liveRoom = '/live/room';
  static const tickets = '/tickets';
  static const newTicket = '/tickets/new';
  static const paymentSuccess = '/payment-success';

  static String courseDetails(String id) => '/course/$id';
  static String lesson(String id) => '/lesson/$id';
  static String pdf(String id) => '/pdf/$id';
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

      // The five bottom-nav tabs share a shell and keep their own stacks.
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
                builder: (_, _) => const MyCoursesScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.live,
                builder: (_, _) => const LiveSessionsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.notes,
                builder: (_, _) => const StudyMaterialsScreen(),
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
      GoRoute(path: Routes.explore, builder: (_, _) => const ExploreScreen()),
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
        builder: (_, state) =>
            PaymentSuccessScreen(courseId: state.extra as String?),
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
        builder: (_, state) =>
            PdfViewerScreen(attachmentId: state.pathParameters['id']!),
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
