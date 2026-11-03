import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/models/course.dart';
import '../router/app_router.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

/// Course artwork: the uploaded thumbnail when there is one, otherwise the
/// bundled subject art for single-subject Physics / Chemistry / Maths courses
/// and the free demo. Null falls back to the course's gradient.
String? courseArtwork(Course course) {
  final uploaded = course.thumbnailUrl;
  if (uploaded != null && uploaded.isNotEmpty) return uploaded;
  if (course.priceInr == 0) return 'assets/images/art/demo.png';
  if (course.subjects.length != 1) return null;
  return switch (course.subjects.first.toLowerCase()) {
    'physics' => 'assets/images/art/physics.png',
    'chemistry' => 'assets/images/art/chemistry.png',
    'mathematics' || 'maths' || 'math' => 'assets/images/art/maths.png',
    _ => null,
  };
}

class _Promo {
  const _Promo(this.asset, this.label, this.route);
  final String asset;
  final String label;
  final String route;
}

const _promos = [
  _Promo(
    'assets/images/promo/batch.png',
    'Class 12 Crash Course starts 16 November',
    Routes.store,
  ),
  _Promo(
    'assets/images/promo/doubts.png',
    'Ask doubts and get them solved',
    Routes.live,
  ),
  _Promo(
    'assets/images/promo/notes.png',
    'Free notes and solved PYQs',
    Routes.notes,
  ),
  _Promo(
    'assets/images/promo/courses.png',
    'Buy courses right in the app',
    Routes.store,
  ),
];

/// The app's own feature banners: an auto-advancing, swipeable carousel.
class PromoCarousel extends StatefulWidget {
  const PromoCarousel({super.key});

  @override
  State<PromoCarousel> createState() => _PromoCarouselState();
}

class _PromoCarouselState extends State<PromoCarousel> {
  static const _interval = Duration(seconds: 5);
  final _controller = PageController(viewportFraction: 0.92);
  Timer? _timer;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    _restart();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _restart() {
    _timer?.cancel();
    _timer = Timer.periodic(_interval, (_) {
      if (!_controller.hasClients) return;
      _controller.animateToPage(
        (_page + 1) % _promos.length,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AspectRatio(
          aspectRatio: 1260 / 714 / 0.92,
          child: PageView.builder(
            controller: _controller,
            padEnds: false,
            itemCount: _promos.length,
            onPageChanged: (p) {
              setState(() => _page = p);
              _restart();
            },
            itemBuilder: (context, i) {
              final promo = _promos[i];
              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Semantics(
                  button: true,
                  label: promo.label,
                  child: GestureDetector(
                    // The store is a tab, so switch to it; the rest open on top.
                    onTap: () => promo.route == Routes.store
                        ? context.go(promo.route)
                        : context.push(promo.route),
                    child: ClipRRect(
                      borderRadius: AppRadius.lg,
                      child: Image.asset(promo.asset, fit: BoxFit.cover),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < _promos.length; i++)
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: i == _page ? 22 : 7,
                height: 7,
                decoration: BoxDecoration(
                  color: i == _page ? AppColors.accent : AppColors.borderRadio,
                  borderRadius: AppRadius.pill,
                ),
              ),
          ],
        ),
      ],
    );
  }
}
