enum MaterialKind { pdf, doc }

enum DownloadKind { video, pdf }

enum DownloadState { available, downloading }

enum NotificationKind {
  live,
  test,
  recording,
  notes,
  result,
  announcement,
  support,
}

enum NotificationGroup { today, yesterday, earlier }

/// Mirrors `public.lesson_resources`.
class StudyMaterial {
  const StudyMaterial({
    required this.id,
    required this.title,
    required this.subject,
    required this.kind,
    required this.sizeLabel,
    this.updatedLabel,
    this.isOffline = false,
    this.showActions = false,
  });

  final String id;
  final String title;
  final String subject;
  final MaterialKind kind;

  /// "PDF • 4.2 MB"
  final String sizeLabel;

  /// "Updated 12 Sept"
  final String? updatedLabel;
  final bool isOffline;

  /// Renders the View / Download button pair rather than a single download icon.
  final bool showActions;

  String get badge => kind == MaterialKind.pdf ? 'PDF' : 'DOC';

  String get metaLine =>
      [sizeLabel, if (updatedLabel != null) updatedLabel!].join(' • ');
}

class DownloadItem {
  const DownloadItem({
    required this.id,
    required this.title,
    required this.subject,
    required this.kind,
    required this.state,
    required this.metaLabel,
    this.progress = 1,
  });

  final String id;
  final String title;
  final String subject;
  final DownloadKind kind;
  final DownloadState state;

  /// "48 min • 320 MB" or "Downloading • 62% of 280 MB"
  final String metaLabel;
  final double progress;
}

class AppNotification {
  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.kind,
    required this.group,
    this.timeAgo,
    this.actionLabel,
    this.isUnread = false,
    this.deepLink,
  });

  final String id;
  final String title;
  final String body;
  final NotificationKind kind;
  final NotificationGroup group;

  /// "5m" / "2h"
  final String? timeAgo;

  /// "Join Class →" / "Watch Now →"
  final String? actionLabel;
  final bool isUnread;

  /// In-app route the admin attached, e.g. `/course/<id>`.
  final String? deepLink;

  AppNotification copyWith({bool? isUnread}) => AppNotification(
    id: id,
    title: title,
    body: body,
    kind: kind,
    group: group,
    timeAgo: timeAgo,
    actionLabel: actionLabel,
    isUnread: isUnread ?? this.isUnread,
    deepLink: deepLink,
  );
}

class PaymentMethodOption {
  const PaymentMethodOption({
    required this.name,
    required this.subtitle,
    required this.short,
  });

  final String name;

  /// "Pay by any UPI app" / "rahul@okaxis"
  final String subtitle;

  /// Badge text: "UPI", "GP", "PP", "💳"
  final String short;
}
