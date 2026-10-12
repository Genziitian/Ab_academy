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
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: AppRadius.pill,
                ),
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
        style: AppText.tabular(
          fontSize ?? size * 0.33,
          FontWeight.w600,
          color: foreground,
        ),
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
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: card,
    );
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
  Widget build(BuildContext context) =>
      Text(text.toUpperCase(), style: AppText.eyebrow(letterSpacing: 0.9));
}

/// Horizontally scrolling row of filter chips.
class ChipRow extends StatelessWidget {
  const ChipRow({
    super.key,
    required this.children,
    this.padding = EdgeInsets.zero,
  });

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
              padding: const EdgeInsets.only(top: 14, bottom: 10),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: tabs[i] == selected
                        ? AppColors.primary
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
              ),
              child: Text(
                tabs[i],
                style: AppText.tabular(
                  14,
                  tabs[i] == selected ? FontWeight.w600 : FontWeight.w400,
                  color: tabs[i] == selected
                      ? AppColors.primary
                      : AppColors.textMuted,
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
        color: AppColors.surface,
        borderRadius: AppRadius.card,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(icon, size: 30, color: AppColors.textDisabled),
          const SizedBox(height: 12),
          Text(title, style: AppText.tabular(13.5, FontWeight.w700)),
          const SizedBox(height: 8),
          Text(
            body,
            textAlign: TextAlign.center,
            style: AppText.meta.copyWith(height: 1.5),
          ),
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
        hintStyle: AppText.tabular(
          13.5,
          FontWeight.w400,
          color: AppColors.textSubtle,
        ),
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 13,
        ),
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
  const AppTopBar({
    super.key,
    required this.title,
    this.actions = const [],
    this.subtitle,
    this.closeIcon = false,
    this.bottom,
  });

  final String title;
  final List<Widget> actions;

  /// Small line above the title, e.g. the course name on Curriculum.
  final String? subtitle;

  /// Shows ✕ instead of ← — for modal-style screens such as "Raise a ticket".
  final bool closeIcon;

  /// Extra content under the title row, e.g. subject tabs.
  final Widget? bottom;

  /// Height below the status bar; Scaffold adds the top inset itself.
  @override
  Size get preferredSize => Size.fromHeight(bottom == null ? 64 : 112);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(8, 6, 16, bottom == null ? 8 : 0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    tooltip: closeIcon ? 'Close' : 'Back',
                    icon: Icon(
                      closeIcon ? Icons.close : Icons.arrow_back,
                      size: 22,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (subtitle != null)
                          Text(
                            subtitle!,
                            overflow: TextOverflow.ellipsis,
                            style: AppText.meta,
                          ),
                        Text(
                          title,
                          overflow: TextOverflow.ellipsis,
                          style: AppText.tabular(17, FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                  ...actions,
                ],
              ),
              if (bottom != null)
                Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: bottom!,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Grey track with a white sliding pill — "Enrolled / Completed", "Upcoming / Past".
class SegmentedTabs extends StatelessWidget {
  const SegmentedTabs({
    super.key,
    required this.tabs,
    required this.selected,
    required this.onSelected,
  });

  final List<String> tabs;
  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: const BoxDecoration(
        color: AppColors.fillMutedAlt,
        borderRadius: AppRadius.sm,
      ),
      child: Row(
        children: [
          for (var i = 0; i < tabs.length; i++) ...[
            if (i > 0) const SizedBox(width: 6),
            Expanded(
              child: GestureDetector(
                onTap: () => onSelected(tabs[i]),
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  height: 34,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: tabs[i] == selected
                        ? AppColors.surface
                        : Colors.transparent,
                    borderRadius: const BorderRadius.all(Radius.circular(7)),
                    boxShadow: tabs[i] == selected
                        ? AppShadow.cardRaised
                        : null,
                  ),
                  child: Text(
                    tabs[i],
                    style: AppText.tabular(
                      13,
                      tabs[i] == selected ? FontWeight.w600 : FontWeight.w500,
                      color: tabs[i] == selected
                          ? AppColors.ink
                          : AppColors.textMuted,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Diagonal gradient used for course thumbnails, from the course's hue.
LinearGradient courseGradient(int hue) => LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [
    HSLColor.fromAHSL(1, hue % 360, 0.70, 0.48).toColor(),
    HSLColor.fromAHSL(1, (hue + 22) % 360, 0.65, 0.34).toColor(),
  ],
);

/// Red "PDF" tile in front of every note.
class PdfBadge extends StatelessWidget {
  const PdfBadge({super.key, this.width = 38, this.height = 38});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: AppColors.pdfTint,
        borderRadius: AppRadius.xs,
      ),
      child: Text(
        'PDF',
        style: AppText.tabular(9, FontWeight.w700, color: AppColors.liveInk),
      ),
    );
  }
}

/// Text field + square send button, used by lecture doubts, the live
/// classroom chat and ticket replies.
class MessageComposer extends StatefulWidget {
  const MessageComposer({
    super.key,
    required this.hint,
    required this.onSend,
    this.leading,
    this.padding = const EdgeInsets.fromLTRB(16, 10, 16, 12),
  });

  final String hint;
  final ValueChanged<String> onSend;
  final Widget? leading;
  final EdgeInsetsGeometry padding;

  @override
  State<MessageComposer> createState() => _MessageComposerState();
}

class _MessageComposerState extends State<MessageComposer> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _send() {
    final body = _controller.text.trim();
    if (body.isEmpty) return;
    widget.onSend(body);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      padding: widget.padding,
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            if (widget.leading != null) ...[
              widget.leading!,
              const SizedBox(width: 8),
            ],
            Expanded(
              child: SizedBox(
                height: 44,
                child: TextField(
                  controller: _controller,
                  onSubmitted: (_) => _send(),
                  textInputAction: TextInputAction.send,
                  cursorColor: AppColors.primary,
                  style: AppText.tabular(14, FontWeight.w400),
                  decoration: InputDecoration(
                    hintText: widget.hint,
                    hintStyle: AppText.tabular(
                      14,
                      FontWeight.w400,
                      color: AppColors.textSubtle,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                    enabledBorder: const OutlineInputBorder(
                      borderRadius: AppRadius.sm,
                      borderSide: BorderSide(color: AppColors.borderInput),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderRadius: AppRadius.sm,
                      borderSide: BorderSide(
                        color: AppColors.primary,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Material(
              color: AppColors.primary,
              borderRadius: AppRadius.sm,
              child: InkWell(
                onTap: _send,
                borderRadius: AppRadius.sm,
                child: const SizedBox.square(
                  dimension: 44,
                  child: Icon(
                    Icons.send_rounded,
                    size: 18,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Bordered white box holding rows separated by hairlines.
class ListCard extends StatelessWidget {
  const ListCard({super.key, required this.children, this.dividerIndent = 0});

  final List<Widget> children;
  final double dividerIndent;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.card,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0)
              Divider(
                height: 1,
                thickness: 1,
                color: AppColors.divider,
                indent: dividerIndent,
              ),
            children[i],
          ],
        ],
      ),
    );
  }
}

/// Feedback for actions that would need a backend in the real app.
void showDemoSnack(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
}
