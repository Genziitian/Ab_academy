import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/lang.dart';
import '../theme/app_colors.dart';

/// EN | हिं — switches the whole app between English and Hindi.
class LanguageToggle extends ConsumerWidget {
  const LanguageToggle({super.key, this.onDark = false});

  final bool onDark;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(langProvider);
    return Semantics(
      label: 'Language · भाषा',
      child: Container(
        height: 36,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: onDark ? Colors.white.withValues(alpha: 0.06) : AppColors.surface,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: onDark ? Colors.white.withValues(alpha: 0.16) : AppColors.rule),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final (value, label) in const [(AppLang.en, 'EN'), (AppLang.hi, 'हिं')])
              _Segment(
                label: label,
                selected: lang == value,
                onDark: onDark,
                onTap: () {
                  if (lang == value) return;
                  HapticFeedback.selectionClick();
                  ref.read(langProvider.notifier).set(value);
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({required this.label, required this.selected, required this.onDark, required this.onTap});

  final String label;
  final bool selected;
  final bool onDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bg = selected ? (onDark ? Colors.white : AppColors.ink) : Colors.transparent;
    final fg = selected
        ? (onDark ? AppColors.ink : Colors.white)
        : (onDark ? Colors.white.withValues(alpha: 0.65) : AppColors.textMuted);
    return Semantics(
      button: true,
      selected: selected,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          constraints: const BoxConstraints(minWidth: 40),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          alignment: Alignment.center,
          decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Geist',
              fontFamilyFallback: const ['Mukta'],
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: fg,
            ),
          ),
        ),
      ),
    );
  }
}
