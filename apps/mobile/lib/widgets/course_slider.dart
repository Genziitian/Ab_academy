import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/models/banner.dart';
import '../data/providers/remote_providers.dart';
import '../router/app_router.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_theme.dart';
import 'common.dart';

/// Auto-advancing course slider fed by `course_banners` (admin → App slider).
/// Renders nothing when there are no live slides.
class CourseSlider extends ConsumerWidget {
  const CourseSlider({super.key, this.padding = EdgeInsets.zero});

  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final banners = ref.watch(bannersProvider).value ?? const <CourseBanner>[];
    if (banners.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: padding,
      child: _Slider(banners: banners),
    );
  }
}

class _Slider extends StatefulWidget {
  const _Slider({required this.banners});

  final List<CourseBanner> banners;

  @override
  State<_Slider> createState() => _SliderState();
}

class _SliderState extends State<_Slider> {
  static const _interval = Duration(seconds: 5);

  final _controller = PageController();
  Timer? _timer;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    _restartTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _restartTimer() {
    _timer?.cancel();
    if (widget.banners.length < 2) return;
    _timer = Timer.periodic(_interval, (_) {
      if (!_controller.hasClients) return;
      final next = (_page + 1) % widget.banners.length;
      _controller.animateToPage(
        next,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final banners = widget.banners;
    return Column(
      children: [
        AspectRatio(
          aspectRatio: 16 / 7,
          child: PageView.builder(
            controller: _controller,
            itemCount: banners.length,
            onPageChanged: (page) {
              setState(() => _page = page);
              // A manual swipe resets the countdown so it doesn't jump away.
              _restartTimer();
            },
            itemBuilder: (context, i) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: _Slide(banner: banners[i]),
            ),
          ),
        ),
        if (banners.length > 1) ...[
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 0; i < banners.length; i++)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: i == _page ? 20 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: i == _page
                        ? AppColors.primary
                        : AppColors.borderRadio,
                    borderRadius: AppRadius.pill,
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }
}

class _Slide extends StatelessWidget {
  const _Slide({required this.banner});

  final CourseBanner banner;

  @override
  Widget build(BuildContext context) {
    final onTap = banner.courseId == null
        ? null
        : () => context.push(Routes.courseDetails(banner.courseId!));

    return Semantics(
      button: onTap != null,
      label: banner.title,
      child: GestureDetector(
        onTap: onTap,
        child: ClipRRect(
          borderRadius: AppRadius.lg,
          child: Stack(
            fit: StackFit.expand,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(gradient: courseGradient(banner.hue)),
              ),
              if (banner.imageUrl != null)
                Image.network(
                  banner.imageUrl!,
                  fit: BoxFit.cover,
                  // Fall back to the gradient if the artwork fails to load.
                  errorBuilder: (_, _, _) => const SizedBox.shrink(),
                ),
              if (banner.imageUrl != null)
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        AppColors.primaryDeep.withValues(alpha: 0.75),
                      ],
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      banner.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.tabular(
                        18,
                        FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    if (banner.subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        banner.subtitle!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppText.tabular(
                          13,
                          FontWeight.w400,
                          color: const Color(0xFFDBE6FF),
                        ),
                      ),
                    ],
                    if (onTap != null) ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 7,
                        ),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: AppRadius.xs,
                        ),
                        child: Text(
                          '${banner.ctaLabel} →',
                          style: AppText.tabular(
                            13,
                            FontWeight.w600,
                            color: AppColors.primaryDeep,
                          ),
                        ),
                      ),
                    ],
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
