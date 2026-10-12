import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/common.dart';

/// Player chrome for a recorded lecture. Playback itself is not wired yet —
/// the controls drive local state so the screen behaves, and the real player
/// drops in behind this same surface.
class LecturePlayer extends StatefulWidget {
  const LecturePlayer({
    super.key,
    required this.onBack,
    this.durationSeconds = 3120,
  });

  final VoidCallback onBack;
  final int durationSeconds;

  @override
  State<LecturePlayer> createState() => _LecturePlayerState();
}

class _LecturePlayerState extends State<LecturePlayer> {
  static const _speeds = [1.0, 1.25, 1.5, 2.0];

  bool _playing = false;
  double _progress = 0.73;
  int _speed = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.classroom,
      child: SafeArea(
        bottom: false,
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Opacity(
                opacity: 0.55,
                child: Image.asset(
                  'assets/images/feature-live-class.png',
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                left: 4,
                top: 4,
                child: IconButton(
                  tooltip: 'Back',
                  onPressed: widget.onBack,
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),
              Center(
                child: Semantics(
                  button: true,
                  label: _playing ? 'Pause' : 'Play',
                  child: GestureDetector(
                    onTap: () => setState(() => _playing = !_playing),
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.95),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _playing
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        size: 28,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 12,
                right: 12,
                bottom: 10,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onHorizontalDragUpdate: (d) =>
                          _seekTo(d.localPosition.dx, context),
                      onTapDown: (d) => _seekTo(d.localPosition.dx, context),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: ProgressBar(
                          value: _progress,
                          height: 3,
                          track: Colors.white.withValues(alpha: 0.3),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${_stamp(_progress * widget.durationSeconds)} / ${_stamp(widget.durationSeconds.toDouble())}',
                          style: AppText.tabular(
                            11,
                            FontWeight.w400,
                            color: Colors.white,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => setState(
                            () => _speed = (_speed + 1) % _speeds.length,
                          ),
                          child: Text(
                            '480p · ${_speeds[_speed]}×',
                            style: AppText.tabular(
                              11,
                              FontWeight.w400,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _seekTo(double dx, BuildContext context) {
    final width = (context.size?.width ?? 1) - 24;
    setState(() => _progress = (dx / width).clamp(0.0, 1.0));
  }

  static String _stamp(double seconds) {
    final s = seconds.round();
    return '${s ~/ 60}:${(s % 60).toString().padLeft(2, '0')}';
  }
}
