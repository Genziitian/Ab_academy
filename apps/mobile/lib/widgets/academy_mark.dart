import 'package:flutter/material.dart';

/// The Akhand Bharat Academy logo, as a round badge.
class AcademyMark extends StatelessWidget {
  const AcademyMark({super.key, this.size = 84});

  final double size;

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: Image.asset(
        'assets/images/logo.png',
        width: size,
        height: size,
        fit: BoxFit.cover,
        semanticLabel: 'Akhand Bharat Academy logo',
      ),
    );
  }
}
