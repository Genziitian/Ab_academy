import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// The Akhand Bharat Academy mark — an open book in indigo//accent inside a
/// rounded square, recreated from the design's inline SVG.
class AcademyMark extends StatelessWidget {
  const AcademyMark({super.key, this.size = 76, this.strokeWidth = 2.4});

  final double size;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(painter: _MarkPainter(strokeWidth: strokeWidth)),
    );
  }
}

class _MarkPainter extends CustomPainter {
  const _MarkPainter({required this.strokeWidth});

  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    // The source artwork is authored on a 76x76 grid.
    final scale = size.width / 76;
    canvas.scale(scale);

    final frame = RRect.fromRectAndRadius(
      Rect.fromLTWH(1.2, 1.2, 73.6, 73.6),
      const Radius.circular(22),
    );
    canvas.drawRRect(
      frame,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..color = AppColors.primary,
    );

    final left = Path()
      ..moveTo(22, 27)
      ..lineTo(35, 27)
      ..arcToPoint(const Offset(42, 34), radius: const Radius.circular(7))
      ..lineTo(42, 53)
      ..arcToPoint(const Offset(36, 47), radius: const Radius.circular(6), clockwise: false)
      ..lineTo(22, 47)
      ..close();
    canvas.drawPath(left, Paint()..color = AppColors.primary);

    final right = Path()
      ..moveTo(54, 27)
      ..lineTo(41, 27)
      ..arcToPoint(const Offset(34, 34), radius: const Radius.circular(7), clockwise: false)
      ..lineTo(34, 53)
      ..arcToPoint(const Offset(40, 47), radius: const Radius.circular(6))
      ..lineTo(54, 47)
      ..close();
    canvas.drawPath(right, Paint()..color = AppColors.accent);
  }

  @override
  bool shouldRepaint(_MarkPainter oldDelegate) => oldDelegate.strokeWidth != strokeWidth;
}
