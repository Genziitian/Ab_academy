import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../mock/mock_data.dart';
import '../models/community.dart';
import '../models/content.dart';
import '../models/lesson_extras.dart';
import '../models/schedule.dart';
import '../models/ticket.dart';
import 'app_providers.dart';

// ----------------------------------------------------------- live sessions

final liveSessionsProvider = Provider<List<LiveSession>>((ref) => MockData.liveSessions);

final liveSessionByIdProvider = Provider.family<LiveSession, String>((ref, id) {
  return MockData.liveSessions.firstWhere(
    (s) => s.id == id,
    orElse: () => MockData.liveSessions.first,
  );
});

/// Sessions grouped the way the Live screen renders them.
final groupedLiveSessionsProvider = Provider<Map<LiveStatus, List<LiveSession>>>((ref) {
  final all = ref.watch(liveSessionsProvider);
  return {
    for (final status in LiveStatus.values) status: all.where((s) => s.status == status).toList(),
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
    NotifierProvider.family<LessonCommentsNotifier, List<LessonComment>, String>(
      LessonCommentsNotifier.new,
    );

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

final lessonAttachmentsProvider = Provider<List<LessonAttachment>>(
  (ref) => MockData.lessonAttachments,
);

// ------------------------------------------------------------ communities

/// One community per enrolled course — the real schema creates these by trigger
/// and auto-joins students on enrolment.
class CommunitiesNotifier extends Notifier<List<Community>> {
  @override
  List<Community> build() => MockData.communities;

  void post(String communityId, String body) {
    final student = ref.read(studentProvider);
    state = [
      for (final community in state)
        if (community.id != communityId)
          community
        else
          Community(
            id: community.id,
            courseId: community.courseId,
            name: community.name,
            subject: community.subject,
            memberCount: community.memberCount,
            messages: [
              ...community.messages,
              CommunityMessage(
                id: 'm${DateTime.now().microsecondsSinceEpoch}',
                author: student.fullName,
                initials: student.initials,
                body: body,
                timeLabel: 'Just now',
                isMe: true,
              ),
            ],
          ),
    ];
  }
}

final communitiesProvider = NotifierProvider<CommunitiesNotifier, List<Community>>(
  CommunitiesNotifier.new,
);

final communityByIdProvider = Provider.family<Community, String>((ref, id) {
  final communities = ref.watch(communitiesProvider);
  return communities.firstWhere((c) => c.id == id, orElse: () => communities.first);
});

// --------------------------------------------------------------- tickets

class TicketsNotifier extends Notifier<List<Ticket>> {
  @override
  List<Ticket> build() => MockData.tickets;

  /// Returns the new ticket's id so the caller can open it.
  String open({required String subject, required TicketCategory category, required String body}) {
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
          TicketMessage(id: '${id}m1', body: body, timeLabel: 'Just now', fromSupport: false),
        ],
      ),
      ...state,
    ];
    return id;
  }

  void reply(String ticketId, String body) {
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
  }

  void close(String ticketId) {
    state = [
      for (final ticket in state)
        if (ticket.id != ticketId) ticket else ticket.copyWith(status: TicketStatus.closed),
    ];
  }
}

final ticketsProvider = NotifierProvider<TicketsNotifier, List<Ticket>>(TicketsNotifier.new);

final ticketByIdProvider = Provider.family<Ticket, String>((ref, id) {
  final tickets = ref.watch(ticketsProvider);
  return tickets.firstWhere((t) => t.id == id, orElse: () => tickets.first);
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
