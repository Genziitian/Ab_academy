import 'package:flutter/material.dart';

import '../data/models/popup.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_theme.dart';
import 'buttons.dart';

/// The interstitial card the admin console schedules in `popups`.
///
/// Shown through [showAppPopup], which counts the impression and the click so
/// the console's view/click numbers are real.
class PopupCard extends StatelessWidget {
  const PopupCard({
    super.key,
    required this.popup,
    required this.onDismiss,
    required this.onAction,
  });

  final AppPopup popup;
  final VoidCallback onDismiss;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.xl,
          boxShadow: AppShadow.modal,
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (popup.imageUrl != null)
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.network(
                  popup.imageUrl!,
                  fit: BoxFit.cover,
                  // A broken image must not break the popup.
                  errorBuilder: (_, _, _) =>
                      Container(color: AppColors.primaryTint),
                  loadingBuilder: (context, child, progress) => progress == null
                      ? child
                      : Container(color: AppColors.primaryTint),
                ),
              ),

            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(popup.title, style: AppText.h5),
                  if (popup.body.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(popup.body, style: AppText.body),
                  ],
                  const SizedBox(height: 18),

                  if (popup.hasCta)
                    PrimaryButton(
                      label: popup.ctaLabel!,
                      height: 48,
                      onPressed: onAction,
                    ),
                  if (popup.hasCta) const SizedBox(height: 8),

                  SecondaryButton(
                    label: popup.hasCta ? 'Not now' : 'Got it',
                    height: 46,
                    onPressed: onDismiss,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Presents [popup] and returns the CTA url if the student tapped through.
Future<String?> showAppPopup(
  BuildContext context,
  AppPopup popup, {
  required Future<void> Function() onShown,
  required Future<void> Function() onClicked,
  required Future<void> Function() onDismissed,
}) async {
  await onShown();

  if (!context.mounted) return null;

  return showDialog<String>(
    context: context,
    barrierDismissible: true,
    barrierColor: AppColors.ink.withValues(alpha: 0.45),
    builder: (dialogContext) => Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: EdgeInsets.zero,
      child: PopupCard(
        popup: popup,
        onDismiss: () {
          onDismissed();
          Navigator.of(dialogContext).pop();
        },
        onAction: () {
          onClicked();
          Navigator.of(dialogContext).pop(popup.ctaUrl);
        },
      ),
    ),
  );
}
