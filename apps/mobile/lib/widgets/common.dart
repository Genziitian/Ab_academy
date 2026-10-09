import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_theme.dart';

/// Thin rounded progress track used across cards, chapters and storage meters.
class ProgressBar extends StatelessWidget {
  const ProgressBar({
    super.key,
    required this.value,
    this.height = 6,
    this.color = AppColors.primary,
    this.track = AppColors.trackMuted,
    this.width,
  });

  final double value;
  final double height;
  final Color color;
  final Color track;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: ClipRRect(
        borderRadius: AppRadius.pill,
        child: Stack(
          children: [
            Container(color: track),
            FractionallySizedBox(
              widthFactor: value.clamp(0.0, 1.0),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 600),
                decoration: BoxDecoration(color: color, borderRadius: AppRadius.pill),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Circular initials avatar — students, teachers, chat authors.
class InitialsAvatar extends StatelessWidget {
  const InitialsAvatar({
    super.key,
    required this.initials,
    this.size = 40,
    this.background = AppColors.primaryTint,
    this.foreground = AppColors.primary,
    this.fontSize,
    this.border,
  });

  final String initials;
  final double size;
  final Color background;
  final Color foreground;
  final double? fontSize;
  final Color? border;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: background,
        shape: BoxShape.circle,
        border: border == null ? null : Border.all(color: border!),
      ),
      child: Text(
        initials,
        style: AppText.tabular(fontSize ?? size * 0.32, FontWeight.w700, color: foreground),
      ),
    );
  }
}

/// Rounded square tile holding an icon or a Devanagari glyph.
class IconTile extends StatelessWidget {
  const IconTile({
    super.key,
    required this.background,
    this.icon,
    this.iconColor,
    this.label,
    this.labelStyle,
    this.size = 38,
    this.radius = 12,
    this.iconSize = 18,
  });

  final Color background;
  final IconData? icon;
  final Color? iconColor;
  final String? label;
  final TextStyle? labelStyle;
  final double size;
  final double radius;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.all(Radius.circular(radius)),
      ),
      child: icon != null
          ? Icon(icon, size: iconSize, color: iconColor)
          : Text(label ?? '', style: labelStyle),
    );
  }
}

/// White hairline card — the default container for almost every list item.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius = AppRadius.card,
    this.color = AppColors.surface,
    this.borderColor = AppColors.border,
    this.shadow = AppShadow.card,
    this.onTap,
    this.clip = false,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final BorderRadius borderRadius;
  final Color color;
  final Color? borderColor;
  final List<BoxShadow>? shadow;
  final VoidCallback? onTap;
  final bool clip;

  @override
  Widget build(BuildContext context) {
    final card = Container(
      padding: clip ? EdgeInsets.zero : padding,
      clipBehavior: clip ? Clip.antiAlias : Clip.none,
      decoration: BoxDecoration(
        color: color,
        borderRadius: borderRadius,
        border: borderColor == null ? null : Border.all(color: borderColor!),
        boxShadow: shadow,
      ),
      child: child,
    );
    if (onTap == null) return card;
    return GestureDetector(onTap: onTap, behavior: HitTestBehavior.opaque, child: card);
  }
}

/// Section heading with an optional trailing action, e.g. "My courses  See all".
class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title, this.trailing});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: AppText.sectionTitle),
        if (trailing != null) trailing!,
      ],
    );
  }
}

/// Uppercase group label — "TODAY", "VIDEOS", "ACCOUNT".
class GroupLabel extends StatelessWidget {
  const GroupLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) => Text(text, style: AppText.eyebrow());
}

/// Horizontally scrolling row of filter chips.
class ChipRow extends StatelessWidget {
  const ChipRow({super.key, required this.children, this.padding = EdgeInsets.zero});

  final List<Widget> children;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: padding,
      child: Row(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            children[i],
          ],
        ],
      ),
    );
  }
}

/// Underlined tab bar used on Course details and the live classroom panel.
class UnderlineTabs extends StatelessWidget {
  const UnderlineTabs({
    super.key,
    required this.tabs,
    required this.selected,
    required this.onSelected,
    this.gap = 22,
  });

  final List<String> tabs;
  final String selected;
  final ValueChanged<String> onSelected;
  final double gap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < tabs.length; i++) ...[
          if (i > 0) SizedBox(width: gap),
          GestureDetector(
            onTap: () => onSelected(tabs[i]),
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding: const EdgeInsets.only(top: 14, bottom: 12),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: tabs[i] == selected ? AppColors.primary : Colors.transparent,
                    width: 2,
                  ),
                ),
              ),
              child: Text(
                tabs[i],
                style: AppText.tabular(
                  13.5,
                  tabs[i] == selected ? FontWeight.w700 : FontWeight.w500,
                  color: tabs[i] == selected ? AppColors.primary : AppColors.textSubtle,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// Dashed placeholder for a list with nothing in it yet.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.body,
    this.action,
  });

  final IconData icon;
  final String title;
  final String body;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
      decoration: BoxDecoration(
        color: AppColors.surfaceHover,
        borderRadius: AppRadius.card,
        border: Border.all(color: AppColors.borderInput),
      ),
      child: Column(
        children: [
          Icon(icon, size: 30, color: AppColors.textDisabled),
          const SizedBox(height: 12),
          Text(title, style: AppText.tabular(13.5, FontWeight.w700)),
          const SizedBox(height: 8),
          Text(body, textAlign: TextAlign.center, style: AppText.meta.copyWith(height: 1.5)),
          if (action != null) ...[const SizedBox(height: 16), action!],
        ],
      ),
    );
  }
}

/// Multiline text field styled like the design's inputs — composers and forms.
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.controller,
    required this.hint,
    this.maxLines = 1,
    this.minLines,
    this.onSubmitted,
    this.autofocus = false,
  });

  final TextEditingController controller;
  final String hint;
  final int maxLines;
  final int? minLines;
  final ValueChanged<String>? onSubmitted;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      minLines: minLines,
      autofocus: autofocus,
      onSubmitted: onSubmitted,
      cursorColor: AppColors.primary,
      style: AppText.tabular(13.5, FontWeight.w500).copyWith(height: 1.5),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppText.tabular(13.5, FontWeight.w400, color: AppColors.textSubtle),
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        border: OutlineInputBorder(
          borderRadius: AppRadius.sm,
          borderSide: const BorderSide(color: AppColors.borderInput),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.sm,
          borderSide: const BorderSide(color: AppColors.borderInput),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.sm,
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }
}

/// Back arrow + title, the standard header for every pushed screen.
class AppTopBar extends StatelessWidget implements PreferredSizeWidget {
  const AppTopBar({super.key, required this.title, this.actions = const [], this.subtitle});

  final String title;
  final List<Widget> actions;
  final String? subtitle;

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.divider)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _BackButton(),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.tabular(17, FontWeight.w700),
                ),
                if (subtitle != null)
                  Text(subtitle!, overflow: TextOverflow.ellipsis, style: AppText.metaSm),
              ],
            ),
          ),
          ...actions,
        ],
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 40,
      child: Material(
        color: Colors.transparent,
        borderRadius: AppRadius.xs,
        child: InkWell(
          onTap: () => Navigator.of(context).maybePop(),
          borderRadius: AppRadius.xs,
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: AppRadius.xs,
              border: Border.all(color: AppColors.border),
            ),
            child: const Icon(Icons.chevron_left, size: 22, color: AppColors.ink),
          ),
        ),
      ),
    );
  }
}

/// Feedback for actions that would need a backend in the real app.
void showDemoSnack(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message), duration: const Duration(seconds: 2)));
}
