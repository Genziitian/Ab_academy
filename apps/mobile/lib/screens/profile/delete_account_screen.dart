import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../config/env.dart';
import '../../data/remote/supabase_client.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_theme.dart';
import '../../widgets/buttons.dart';
import '../../widgets/common.dart';

/// More → Delete account or data. Files a request that a super admin
/// completes within 3 days (Google Play's in-app account deletion).
class DeleteAccountScreen extends StatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  State<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

typedef _Request = ({String id, String kind, String status, DateTime dueAt});

class _DeleteAccountScreenState extends State<DeleteAccountScreen> {
  final _reason = TextEditingController();
  String _kind = 'data';
  bool _confirmed = false;
  bool _busy = false;
  bool _loading = true;
  _Request? _pending;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    if (!Env.hasBackend) {
      setState(() => _loading = false);
      return;
    }
    try {
      final uid = Api.client.auth.currentUser?.id;
      final rows = uid == null
          ? const []
          : await Api.client
                .from('deletion_requests')
                .select('id, kind, status, due_at')
                .eq('user_id', uid)
                .eq('status', 'pending')
                .limit(1);
      if (!mounted) return;
      setState(() {
        _pending = rows.isEmpty
            ? null
            : (
                id: rows.first['id'] as String,
                kind: rows.first['kind'] as String,
                status: rows.first['status'] as String,
                dueAt: DateTime.parse(rows.first['due_at'] as String).toLocal(),
              );
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _snack(String message) => ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));

  Future<void> _submit() async {
    if (_busy || !_confirmed) return;
    if (!Env.hasBackend) {
      _snack('Deletion requests need an internet connection.');
      return;
    }
    setState(() => _busy = true);
    try {
      await Api.client.rpc(
        'request_deletion',
        params: {'p_kind': _kind, 'p_reason': _reason.text.trim()},
      );
      await _load();
      if (mounted) {
        _snack('Request received. We will complete it within 3 days.');
      }
    } catch (_) {
      if (mounted) {
        _snack(
          'Could not send your request. Try again, or email support@abacademy.in.',
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _cancel() async {
    final pending = _pending;
    if (pending == null || _busy) return;
    setState(() => _busy = true);
    try {
      await Api.client.rpc(
        'cancel_deletion_request',
        params: {'p_id': pending.id},
      );
      await _load();
      if (mounted) _snack('Your request was cancelled.');
    } catch (_) {
      if (mounted) _snack('Could not cancel. Try again.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppTopBar(title: 'Delete account or data'),
      body: _loading
          ? const Center(child: CircularProgressIndicator(strokeWidth: 2.5))
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
              children: _pending != null ? _pendingView(_pending!) : _form(),
            ),
    );
  }

  List<Widget> _pendingView(_Request r) => [
    Text('Request in progress', style: AppText.h3),
    const SizedBox(height: 10),
    Text(
      r.kind == 'account'
          ? 'You asked us to delete your account. It will be deleted by '
                '${DateFormat('d MMM yyyy').format(r.dueAt)}.'
          : 'You asked us to delete your personal data. It will be erased by '
                '${DateFormat('d MMM yyyy').format(r.dueAt)}.',
      style: AppText.bodyLg,
    ),
    const SizedBox(height: 24),
    SecondaryButton(
      label: 'Cancel my request',
      onPressed: _busy ? null : _cancel,
    ),
  ];

  List<Widget> _form() => [
    Text(
      'Choose what you want us to delete. We complete every request within 3 days.',
      style: AppText.bodyLg,
    ),
    const SizedBox(height: 18),
    _Option(
      selected: _kind == 'data',
      title: 'Delete my data',
      body:
          'Erase my name, school, doubts, comments, support tickets and history. '
          'Keep my account and courses.',
      onTap: () => setState(() => _kind = 'data'),
    ),
    const SizedBox(height: 10),
    _Option(
      selected: _kind == 'account',
      title: 'Delete my account',
      body:
          'Erase everything above and close my account for good, including '
          'access to courses I bought.',
      onTap: () => setState(() => _kind = 'account'),
    ),
    const SizedBox(height: 18),
    TextField(
      controller: _reason,
      maxLength: 1000,
      maxLines: 3,
      decoration: const InputDecoration(
        labelText: 'Reason (optional)',
        border: OutlineInputBorder(borderRadius: AppRadius.sm),
      ),
    ),
    const SizedBox(height: 4),
    Text(
      'Orders and payment records are kept without your name, as Indian tax '
      'law requires.',
      style: AppText.meta,
    ),
    const SizedBox(height: 14),
    CheckboxListTile(
      contentPadding: EdgeInsets.zero,
      controlAffinity: ListTileControlAffinity.leading,
      value: _confirmed,
      onChanged: (v) => setState(() => _confirmed = v ?? false),
      title: Text(
        _kind == 'account'
            ? 'I understand my account and course access will be permanently deleted.'
            : 'I understand my personal data will be permanently erased.',
        style: AppText.body,
      ),
    ),
    const SizedBox(height: 14),
    PrimaryButton(
      label: _busy
          ? 'Sending…'
          : _kind == 'account'
          ? 'Request account deletion'
          : 'Request data deletion',
      enabled: _confirmed && !_busy,
      onPressed: _submit,
    ),
  ];
}

class _Option extends StatelessWidget {
  const _Option({
    required this.selected,
    required this.title,
    required this.body,
    required this.onTap,
  });

  final bool selected;
  final String title;
  final String body;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: selected,
      button: true,
      child: InkWell(
        borderRadius: AppRadius.md,
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: selected ? AppColors.primaryTint : AppColors.surface,
            borderRadius: AppRadius.md,
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.border,
              width: selected ? 2 : 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                selected ? Icons.radio_button_checked : Icons.radio_button_off,
                color: selected ? AppColors.primary : AppColors.textSubtle,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppText.cardTitleLg),
                    const SizedBox(height: 4),
                    Text(body, style: AppText.body),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
