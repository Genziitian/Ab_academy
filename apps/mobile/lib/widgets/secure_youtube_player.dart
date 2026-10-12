import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../utils/secure_screen.dart';

/// Origin the player page is served from. YouTube refuses embeds without a
/// referrer, and checks it against the `origin` player variable.
const _origin = 'https://akhandbharatacademy.in';

/// A YouTube video played as if it were our own: YouTube's controls, title,
/// logo, share and "watch on YouTube" are never reachable, and the video id
/// never appears on screen, in a link, or in an error.
///
/// How the id stays inside the app:
/// * the YouTube iframe sits under an opaque Flutter layer that takes every
///   touch, so nothing YouTube draws can be tapped;
/// * the WebView may only load our page and YouTube embeds — any
///   attempt to open youtube.com or the YouTube app is cancelled;
/// * our own controls drive the iframe through the IFrame Player API;
/// * on Android, FLAG_SECURE blocks screenshots and screen recording while
///   the player is on screen, and a moving watermark marks every frame with
///   the student's identity on both platforms.
class SecureYouTubePlayer extends StatefulWidget {
  const SecureYouTubePlayer({
    super.key,
    required this.videoId,
    required this.watermark,
    this.fullscreen = false,
    this.onToggleFullscreen,
    this.onBack,
  });

  final String videoId;

  /// Text stamped faintly across the video, e.g. the student's phone number.
  final String watermark;
  final bool fullscreen;
  final VoidCallback? onToggleFullscreen;
  final VoidCallback? onBack;

  @override
  State<SecureYouTubePlayer> createState() => _SecureYouTubePlayerState();
}

class _SecureYouTubePlayerState extends State<SecureYouTubePlayer>
    with WidgetsBindingObserver {
  static const _speeds = [1.0, 1.25, 1.5, 2.0, 0.75];
  static final _idPattern = RegExp(r'^[A-Za-z0-9_-]{11}$');

  /// Null where no WebView exists (widget tests, desktop).
  WebViewController? _web;
  bool _ready = false;
  bool _playing = false;
  bool _ended = false;

  /// Play was tapped before the YouTube player finished loading (it can take
  /// several seconds on a slow connection); start as soon as it is ready.
  bool _playWhenReady = false;

  bool _buffering = false;
  bool _controlsVisible = true;
  String? _error;
  double _position = 0;
  double _duration = 0;
  double _buffered = 0;
  double? _dragValue;
  int _speed = 0;
  Timer? _hideTimer;
  Timer? _watermarkTimer;
  Alignment _watermarkAt = const Alignment(-0.6, -0.5);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    SecureScreen.enable();
    _watermarkTimer = Timer.periodic(
      const Duration(seconds: 7),
      (_) => _moveWatermark(),
    );
    if (WebViewPlatform.instance == null) {
      _error = 'Video playback is not available on this device.';
    } else if (!_idPattern.hasMatch(widget.videoId)) {
      // Never echo the bad value back; it may be a whole URL.
      _error = 'This lecture is not set up correctly. Please tell support.';
    } else {
      _web = _createController()
        ..loadHtmlString(_page(widget.videoId), baseUrl: '$_origin/');
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _hideTimer?.cancel();
    _watermarkTimer?.cancel();
    SecureScreen.disable();
    // Drop the page so nothing about the video lingers in the WebView.
    _web?.loadHtmlString('<html></html>');
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed && _playing) {
      _js('player.pauseVideo()');
    }
  }

  WebViewController _createController() {
    final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    final controller = WebViewController.fromPlatformCreationParams(params)
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.black)
      ..enableZoom(false)
      ..addJavaScriptChannel(
        'Player',
        onMessageReceived: (m) => _onMessage(m.message),
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (request) {
            final url = request.url;
            final allowed =
                url == 'about:blank' ||
                url.startsWith('$_origin/') ||
                url.startsWith('https://www.youtube-nocookie.com/embed/') ||
                url.startsWith('https://www.youtube.com/embed/');
            // Logo, title, share, "watch on YouTube", end-screen videos: all
            // of these try to navigate away, and all of them stop here.
            return allowed
                ? NavigationDecision.navigate
                : NavigationDecision.prevent;
          },
        ),
      );

    if (controller.platform is AndroidWebViewController) {
      final android = controller.platform as AndroidWebViewController;
      // Our play button is a Flutter tap, not a tap inside the page.
      android.setMediaPlaybackRequiresUserGesture(false);
    }
    return controller;
  }

  void _onMessage(String raw) {
    final Map<String, dynamic> m;
    try {
      m = jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return;
    }
    if (!mounted) return;
    setState(() {
      switch (m['t']) {
        case 'ready':
          _ready = true;
          _duration = (m['d'] as num?)?.toDouble() ?? 0;
          if (_playWhenReady) {
            _playWhenReady = false;
            _js('player.playVideo()');
          }
        case 'tick':
          _position = (m['c'] as num?)?.toDouble() ?? _position;
          final d = (m['d'] as num?)?.toDouble() ?? 0;
          if (d > 0) _duration = d;
          _buffered = (m['b'] as num?)?.toDouble() ?? _buffered;
        case 'state':
          final s = m['s'] as int?;
          _playing = s == 1;
          _buffering = s == 3;
          _ended = s == 0;
          if (_playing) {
            _scheduleHide();
          } else {
            _controlsVisible = true;
          }
        case 'error':
          _error = switch (m['c']) {
            101 || 150 || 152 || 153 =>
              'This lecture cannot play right now. Our team has been notified — please try later.',
            _ =>
              'The video failed to load. Check your connection and try again.',
          };
      }
    });
  }

  Future<void> _js(String code) async {
    final web = _web;
    if (!_ready || web == null) return;
    try {
      await web.runJavaScript(code);
    } catch (_) {}
  }

  void _togglePlay() {
    if (!_ready) {
      setState(() => _playWhenReady = true);
      return;
    }
    if (_ended) {
      _seek(0);
      _js('player.playVideo()');
    } else {
      _js(_playing ? 'player.pauseVideo()' : 'player.playVideo()');
    }
    _scheduleHide();
  }

  void _seek(double seconds) {
    final target = seconds
        .clamp(0, _duration > 0 ? _duration : seconds)
        .toDouble();
    setState(() {
      _position = target;
      _ended = false;
    });
    _js('player.seekTo(${target.toStringAsFixed(1)}, true)');
  }

  void _cycleSpeed() {
    setState(() => _speed = (_speed + 1) % _speeds.length);
    _js('player.setPlaybackRate(${_speeds[_speed]})');
    _scheduleHide();
  }

  void _scheduleHide() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 3), () {
      if (mounted && _playing && _dragValue == null) {
        setState(() => _controlsVisible = false);
      }
    });
  }

  void _moveWatermark() {
    if (!mounted) return;
    final r = Random();
    setState(() {
      _watermarkAt = Alignment(
        r.nextDouble() * 1.4 - 0.7,
        r.nextDouble() * 1.4 - 0.7,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final showControls = _controlsVisible || !_playing;
    return ColoredBox(
      color: Colors.black,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (_web != null && _error == null) WebViewWidget(controller: _web!),
          // Hides YouTube's own title bar and logo strip.
          const _EdgeShade(top: true),
          const _EdgeShade(top: false),
          // Whenever the video is not actually playing — before the first
          // play, paused, or ended — YouTube draws its title, channel and
          // "Watch on YouTube" over the frame. Cover it completely.
          if (!_playing && !_buffering)
            const ColoredBox(color: AppColors.classroom),
          if (_error == null && (!_ready || _buffering))
            const Center(
              child: SizedBox.square(
                dimension: 34,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              ),
            ),
          if (widget.watermark.isNotEmpty)
            AnimatedAlign(
              duration: const Duration(seconds: 2),
              curve: Curves.easeInOut,
              alignment: _watermarkAt,
              child: IgnorePointer(
                child: Text(
                  widget.watermark,
                  style: AppText.tabular(
                    12,
                    FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.28),
                  ),
                ),
              ),
            ),
          // Takes every touch, so nothing YouTube renders is ever tappable.
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                setState(() => _controlsVisible = !_controlsVisible);
                if (_controlsVisible) _scheduleHide();
              },
              onDoubleTapDown: (d) {
                final width = context.size?.width ?? 1;
                _seek(_position + (d.localPosition.dx < width / 2 ? -10 : 10));
              },
              onLongPress: () {},
            ),
          ),
          if (_error != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: AppText.tabular(
                    13,
                    FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
            )
          else
            AnimatedOpacity(
              opacity: showControls ? 1 : 0,
              duration: const Duration(milliseconds: 200),
              child: IgnorePointer(ignoring: !showControls, child: _controls()),
            ),
          if (widget.onBack != null)
            Positioned(
              left: 4,
              top: 4,
              child: AnimatedOpacity(
                opacity: showControls || _error != null ? 1 : 0,
                duration: const Duration(milliseconds: 200),
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
            ),
        ],
      ),
    );
  }

  Widget _controls() {
    final value = _dragValue ?? _position;
    final max = _duration > 0 ? _duration : 1.0;
    return Stack(
      children: [
        Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _RoundButton(
                icon: LucideIcons.rotateCcw,
                tooltip: 'Back 10 seconds',
                onTap: () => _seek(_position - 10),
              ),
              const SizedBox(width: 24),
              _RoundButton(
                icon: _ended
                    ? Icons.replay_rounded
                    : (_playing
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded),
                tooltip: _playing ? 'Pause' : 'Play',
                big: true,
                onTap: _togglePlay,
              ),
              const SizedBox(width: 24),
              _RoundButton(
                icon: LucideIcons.rotateCw,
                tooltip: 'Forward 10 seconds',
                onTap: () => _seek(_position + 10),
              ),
            ],
          ),
        ),
        Positioned(
          left: 12,
          right: 12,
          bottom: 4,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SliderTheme(
                data: SliderThemeData(
                  trackHeight: 3,
                  activeTrackColor: AppColors.primary,
                  inactiveTrackColor: Colors.white.withValues(alpha: 0.3),
                  secondaryActiveTrackColor: Colors.white.withValues(
                    alpha: 0.55,
                  ),
                  thumbColor: Colors.white,
                  overlayShape: SliderComponentShape.noOverlay,
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 6,
                  ),
                ),
                child: Slider(
                  value: value.clamp(0, max).toDouble(),
                  max: max,
                  secondaryTrackValue: (_buffered * max)
                      .clamp(0, max)
                      .toDouble(),
                  onChangeStart: (v) => setState(() => _dragValue = v),
                  onChanged: (v) => setState(() => _dragValue = v),
                  onChangeEnd: (v) {
                    setState(() => _dragValue = null);
                    _seek(v);
                    _scheduleHide();
                  },
                ),
              ),
              Row(
                children: [
                  Text(
                    '${_stamp(value)} / ${_stamp(_duration)}',
                    style: AppText.tabular(
                      11,
                      FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: _cycleSpeed,
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 6,
                      ),
                      child: Text(
                        '${_speeds[_speed]}×',
                        style: AppText.tabular(
                          12,
                          FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  if (widget.onToggleFullscreen != null)
                    IconButton(
                      tooltip: widget.fullscreen
                          ? 'Exit full screen'
                          : 'Full screen',
                      visualDensity: VisualDensity.compact,
                      onPressed: widget.onToggleFullscreen,
                      icon: Icon(
                        widget.fullscreen
                            ? LucideIcons.minimize
                            : LucideIcons.maximize,
                        size: 17,
                        color: Colors.white,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  static String _stamp(double seconds) {
    final s = seconds.isFinite ? seconds.round() : 0;
    final h = s ~/ 3600;
    final m = (s % 3600) ~/ 60;
    final sec = (s % 60).toString().padLeft(2, '0');
    return h > 0 ? '$h:${m.toString().padLeft(2, '0')}:$sec' : '$m:$sec';
  }

  /// The player page. The id has already been checked against [_idPattern],
  /// so it cannot inject script.
  static String _page(String id) =>
      '''
<!doctype html>
<html>
<head>
<meta name="viewport" content="width=device-width,initial-scale=1,maximum-scale=1,user-scalable=no">
<meta name="referrer" content="strict-origin-when-cross-origin">
<style>
  html,body{margin:0;height:100%;background:#000;overflow:hidden;
    -webkit-user-select:none;user-select:none;-webkit-touch-callout:none}
  /* The iframe is 120px taller than the player and shifted up by 60px.
     The 16:9 video letterboxes inside it, so the picture stays whole while
     YouTube's title bar (top) and "Watch on YouTube" strip (bottom) fall
     outside the visible area. */
  #p{position:absolute;left:0;top:-60px;width:100%;height:calc(100% + 120px);
     pointer-events:none}
</style>
</head>
<body>
<div id="p"></div>
<script>
  var player, timer;
  function send(o){ try { Player.postMessage(JSON.stringify(o)); } catch(e) {} }
  function onYouTubeIframeAPIReady(){
    player = new YT.Player('p', {
      videoId: '$id',
      playerVars: { controls:0, disablekb:1, fs:0, rel:0, modestbranding:1,
        iv_load_policy:3, playsinline:1, cc_load_policy:0, origin:'$_origin' },
      events: {
        onReady: function(){
          send({t:'ready', d: player.getDuration()});
          timer = setInterval(function(){
            if (player && player.getCurrentTime) {
              send({t:'tick', c: player.getCurrentTime(), d: player.getDuration(),
                    b: player.getVideoLoadedFraction()});
            }
          }, 500);
        },
        onStateChange: function(e){ send({t:'state', s: e.data}); },
        onError: function(e){ send({t:'error', c: e.data}); }
      }
    });
  }
  document.addEventListener('contextmenu', function(e){ e.preventDefault(); });
</script>
<script src="https://www.youtube.com/iframe_api"></script>
</body>
</html>
''';
}

/// Dark gradient along the top or bottom edge, under our controls.
class _EdgeShade extends StatelessWidget {
  const _EdgeShade({required this.top});

  final bool top;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: top ? Alignment.topCenter : Alignment.bottomCenter,
      child: IgnorePointer(
        child: Container(
          height: 64,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: top ? Alignment.topCenter : Alignment.bottomCenter,
              end: top ? Alignment.bottomCenter : Alignment.topCenter,
              colors: [Colors.black.withValues(alpha: 0.9), Colors.transparent],
            ),
          ),
        ),
      ),
    );
  }
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.big = false,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final bool big;

  @override
  Widget build(BuildContext context) {
    final size = big ? 56.0 : 42.0;
    return Semantics(
      button: true,
      label: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: big
                ? Colors.white.withValues(alpha: 0.95)
                : Colors.black.withValues(alpha: 0.35),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: big ? 30 : 20,
            color: big ? AppColors.primary : Colors.white,
          ),
        ),
      ),
    );
  }
}
