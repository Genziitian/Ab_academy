import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../theme/app_colors.dart';

/// The Akhand Bharat Academy mark — a mortarboard in a rounded square, the same
/// tile the website header uses. [inverted] draws it white-on-blue's opposite
/// for the blue splash screen.
class AcademyMark extends StatelessWidget {
  const AcademyMark({super.key, this.size = 84, this.inverted = false});

  final double size;
  final bool inverted;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: inverted ? Colors.white : AppColors.primary,
        borderRadius: BorderRadius.circular(size * 0.26),
      ),
      child: Icon(
        LucideIcons.graduationCap,
        size: size / 2,
        color: inverted ? AppColors.primary : Colors.white,
      ),
    );
  }
}
