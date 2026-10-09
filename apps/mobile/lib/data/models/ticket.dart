/// Mirrors `public.ticket_status`.
enum TicketStatus {
  open('Open'),
  inProgress('In progress'),
  resolved('Resolved'),
  closed('Closed');

  const TicketStatus(this.label);

  final String label;
}

enum TicketCategory {
  payment('Payment'),
  content('Course content'),
  technical('Technical'),
  account('Account'),
  other('Other');

  const TicketCategory(this.label);

  final String label;
}

/// Mirrors `public.tickets`.
class Ticket {
  const Ticket({
    required this.id,
    required this.reference,
    required this.subject,
    required this.category,
    required this.status,
    required this.openedLabel,
    required this.messages,
  });

  final String id;

  /// Human-facing id shown to the student, e.g. "ABA-T-1042".
  final String reference;
  final String subject;
  final TicketCategory category;
  final TicketStatus status;

  /// "Opened 2 days ago"
  final String openedLabel;
  final List<TicketMessage> messages;

  TicketMessage? get latest => messages.isEmpty ? null : messages.last;

  bool get isClosed => status == TicketStatus.resolved || status == TicketStatus.closed;

  Ticket copyWith({TicketStatus? status, List<TicketMessage>? messages}) => Ticket(
    id: id,
    reference: reference,
    subject: subject,
    category: category,
    status: status ?? this.status,
    openedLabel: openedLabel,
    messages: messages ?? this.messages,
  );
}

/// Mirrors `public.ticket_messages`.
class TicketMessage {
  const TicketMessage({
    required this.id,
    required this.body,
    required this.timeLabel,
    required this.fromSupport,
    this.authorName,
  });

  final String id;
  final String body;
  final String timeLabel;
  final bool fromSupport;

  /// Support agent's name; null for the student's own messages.
  final String? authorName;
}
