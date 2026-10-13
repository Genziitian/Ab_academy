import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../mock/mock_data.dart';
import '../models/content.dart';
import '../models/lesson_extras.dart';
import '../models/schedule.dart';
import '../models/ticket.dart';
import '../remote/auth_repository.dart';
import '../remote/repositories.dart';
import 'app_providers.dart';

// ----------------------------------------------------------- live sessions

final liveSessionsProvider = Provider<List<LiveSession>>(
  (ref) => MockData.liveSessions,
);

final liveSessionByIdProvider = Provider.family<LiveSession, String>((ref, id) {
  return MockData.liveSessions.firstWhere(
    (s) => s.id == id,
    orElse: () => MockData.liveSessions.first,
  );
});

/// Sessions grouped the way the Live screen renders them.
final groupedLiveSessionsProvider =
    Provider<Map<LiveStatus, List<LiveSession>>>((ref) {
      final all = ref.watch(liveSessionsProvider);
      return {
        for (final status in LiveStatus.values)
          status: all.where((s) => s.status == status).toList(),
      };
    });

// --------------------------------------------------------------- lectures

/// Discussion under a lecture. Keyed by lesson so each lecture has its own thread.
class LessonCommentsNotifier extends Notifier<List<LessonComment>> {
  LessonCommentsNotifier(this.lessonId);

  final String lessonId;

  @override
  List<LessonComment> build() => MockData.lessonComments;

  void post(String body) {
    final student = ref.read(studentProvider);
    state = [
      ...state,
      LessonComment(
        id: 'c${DateTime.now().microsecondsSinceEpoch}',
        author: student.fullName,
        initials: student.initials,
        body: body,
        timeLabel: 'Just now',
        isMe: true,
      ),
    ];
  }
}

final lessonCommentsProvider =
    NotifierProvider.family<
      LessonCommentsNotifier,
      List<LessonComment>,
      String
    >(LessonCommentsNotifier.new);

class LessonFeedbackNotifier extends Notifier<LessonFeedback> {
  LessonFeedbackNotifier(this.lessonId);

  final String lessonId;

  @override
  LessonFeedback build() => MockData.lessonFeedback;

  void rate(int rating, {String? comment}) {
    state = state.copyWith(myRating: rating, myComment: comment);
  }
}

final lessonFeedbackProvider =
    NotifierProvider.family<LessonFeedbackNotifier, LessonFeedback, String>(
      LessonFeedbackNotifier.new,
    );

// --------------------------------------------------------------- tickets

/// Support tickets. With a backend: the student's `tickets` with their
/// `ticket_messages`, replies from the admin console included; without one,
/// the sample tickets kept in memory.
class TicketsNotifier extends Notifier<List<Ticket>> {
  @override
  List<Ticket> build() {
    if (!AuthRepo.enabled) return MockData.tickets;
    ref.watch(sessionProvider);
    Future.microtask(refresh);
    return const [];
  }

  bool loaded = false;

  Future<void> refresh() async {
    if (!AuthRepo.enabled) return;
    if (!AuthRepo.isSignedIn) {
      state = const [];
      return;
    }
    try {
      state = await Repo.tickets();
      loaded = true;
    } catch (_) {}
  }

  /// Opens a ticket with its first message; returns the new ticket's id.
  Future<String> open({
    required String subject,
    required TicketCategory category,
    required String body,
  }) async {
    if (AuthRepo.enabled) {
      final id = await Repo.createTicket(
        subject: subject,
        category: category,
        body: body,
      );
      await refresh();
      if (id == null) throw StateError('Not signed in');
      return id;
    }
    final id = 't${DateTime.now().microsecondsSinceEpoch}';
    state = [
      Ticket(
        id: id,
        reference: 'ABA-T-${1043 + state.length}',
        subject: subject,
        category: category,
        status: TicketStatus.open,
        openedLabel: 'Opened just now',
        messages: [
          TicketMessage(
            id: '${id}m1',
            body: body,
            timeLabel: 'Just now',
            fromSupport: false,
          ),
        ],
      ),
      ...state,
    ];
    return id;
  }

  Future<void> reply(String ticketId, String body) async {
    // Show it straight away; the refresh replaces it with the stored row.
    state = [
      for (final ticket in state)
        if (ticket.id != ticketId)
          ticket
        else
          ticket.copyWith(
            messages: [
              ...ticket.messages,
              TicketMessage(
                id: 'tm${DateTime.now().microsecondsSinceEpoch}',
                body: body,
                timeLabel: 'Just now',
                fromSupport: false,
              ),
            ],
          ),
    ];
    if (AuthRepo.enabled) {
      await Repo.replyToTicket(ticketId, body);
      await refresh();
    }
  }
}

final ticketsProvider = NotifierProvider<TicketsNotifier, List<Ticket>>(
  TicketsNotifier.new,
);

final ticketByIdProvider = Provider.family<Ticket?, String>((ref, id) {
  return ref.watch(ticketsProvider).where((t) => t.id == id).firstOrNull;
});

final openTicketCountProvider = Provider<int>(
  (ref) => ref.watch(ticketsProvider).where((t) => !t.isClosed).length,
);

// ------------------------------------------------------ simulated realtime

/// Stands in for a Supabase realtime subscription on `notifications`: pushes one
/// admin-sent notification a few seconds in, so the bell badge and the list
/// update while you watch. Swap this single provider for the real stream when
/// the backend lands.
final realtimeNotificationProvider = Provider<void>((ref) {
  if (AuthRepo.enabled) {
    // Supabase realtime: any change to `notifications` reloads the feed.
    final sub = Repo.notificationStream().listen(
      (_) => ref.read(notificationsProvider.notifier).refresh(),
      onError: (_) {},
    );
    ref.onDispose(sub.cancel);
    return;
  }
  final timer = Timer(const Duration(seconds: 6), () {
    ref
        .read(notificationsProvider.notifier)
        .push(
          const AppNotification(
            id: 'rt-1',
            title: 'New notice from Amit Sir',
            body: "Tomorrow's Mathematics class moves to 7:00 PM.",
            kind: NotificationKind.live,
            group: NotificationGroup.today,
            timeAgo: 'now',
            isUnread: true,
          ),
        );
  });
  ref.onDispose(timer.cancel);
});
