import 'dart:async';
import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import '../core/haptics.dart';
import '../core/screen_decor.dart';
import '../theme/rateel_theme.dart';
import 'lesson_data.dart';
import 'lesson_shell.dart';
import 'lesson_widgets.dart';

/// Review aids (screen 07): `?video=demo` plays a simulated video (the
/// lesson's thumbnail, no network), `?video=none` shows the "video not
/// available" state, `?videoAt=0.37` starts the demo at 37%.
String? videoMode;
double videoStartAt = 0;

/// Sections of a lesson video (owner, 2026-11-24): the video stops at the end
/// of each section with «أعد» (repeat) / «تابع» (continue), and the learner
/// can go back to an earlier section. The data has no sections yet (MOCK,
/// `SCREENS.md`): every video is split in [videoSectionCount] equal parts.
/// Planned data: `sections: [{start, end}]` in seconds per video lesson.
int videoSectionCount = 3;

/// How to go back to an earlier section, both built for the owner's choice
/// (review `?sectionNav=dots|button`): dots under the video or a ‹ button.
String videoSectionNav = 'dots';

/// Thumbnails bundled for the posters (real YouTube thumbnails of the lesson
/// videos; the other links of the data are dead, 404 on YouTube).
const _posters = {'BqFxf-WspTc', 'XfDdA9UgOVQ'};

/// Geometry of screen 07 in u (1% of the screen height), measured on
/// `07-lezione-video.webp` and `reference-playing.webp` (1842×854, u = 8.54
/// px). x values are offsets from the screen's centre (921 px).
class VideoMetrics {
  VideoMetrics._();
  // Lobed arch frame (fitted on the reference line: 163–1679 × 16–508 px).
  static const archDx = -88.8;
  static const archW = 177.5;
  static const archTop = 1.9;
  static const archH = 57.6;
  // Not available state.
  static const mosqueDx = -47.5;
  static const mosqueTop = 25.0;
  static const mosqueW = 36.0;
  static const iconCx = 1.2;
  static const iconTop = 23.9;
  static const iconW = 28.1;
  static const iconH = 21.9;
  static const titleTop = 47.2;
  static const titleSize = 7.6;
  static const dividerTop = 59.8;
  static const dividerW = 85.0;
  static const dividerH = 4.0;
  static const textTop = 66.4;
  static const textSize = 4.52;
  // Playing state (full screen, owner 2026-11-24).
  static const barCentre = 10.75; // 02: margin 3 + button 15.5 / 2
  static const playTitleSize = 5.0;
  static const navY = 82.45; // dots: centred on «تخطي»
  static const dot = 2.8; // reference 08 dots: 2.8u, pitch 5.5u
  static const dotPitch = 5.5;
  static const endPillW = 30.0;
  // Corners (cell size and start of the band matched on zoomed crops).
  static const cornerSize = 39.0;
  static const cornerTop = 60.0;
  static const topCornerSize = 30.0;
  static const bandH = 19.6;
  static const bandBottom = 96.0;
  static const bandOpacity = 0.14;
}

Route<bool> videoLessonRoute(
  Lesson lesson,
  int index,
  int count, {
  bool completed = false,
}) => lessonRoute<bool>(
  (context) => VideoLessonPage(
    lesson: lesson,
    index: index,
    count: count,
    completed: completed,
  ),
);

/// Screen 07, video lesson (owner, 2026-11-24): the YouTube video of the
/// lesson inside the gold arch frame, the shared top bar of screen 02 (the
/// capsule follows the video: «n/100»), «تخطي» completes the lesson, the end
/// of the video completes it by itself (Angular). No link, a dead link, an
/// embed error or no network → the reference's «الفيديو غير متاح» state.
/// Returns `true` when the lesson is finished (contract of `lesson_page.dart`).
class VideoLessonPage extends StatefulWidget {
  const VideoLessonPage({
    super.key,
    required this.lesson,
    required this.index,
    required this.count,
    this.completed = false,
  });

  final Lesson lesson;
  final int index;
  final int count;

  /// The lesson was already completed: the button reads «إكمال ✓».
  final bool completed;

  @override
  State<VideoLessonPage> createState() => _VideoLessonPageState();
}

class _VideoLessonPageState extends State<VideoLessonPage>
    with TickerProviderStateMixin {
  final _shell = GlobalKey<LessonShellState>();
  late final _entry = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );
  // Cross-fade not available ↔ playing.
  late final _state = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 400),
  );

  YoutubePlayerController? _yt;
  String? _videoId;
  final _subs = <StreamSubscription<Object?>>[];
  Timer? _timeout;
  Timer? _demo;

  bool _unavailable = false;
  bool _started = false; // the video has played at least once
  bool _playing = false;
  bool _paused = false; // pause menu of screen 02 open
  bool _finishing = false;
  bool _left = false;
  double _pos = 0; // seconds
  double _dur = 0;
  int _section = 0; // current section (0-based)
  int _reached = 0; // furthest section reached
  bool _sectionEnd = false; // stopped at the end of [_section]

  bool get _demoMode => videoMode == 'demo';

  @override
  void initState() {
    super.initState();
    final url = widget.lesson.videoUrl;
    _videoId = url == null ? null : YoutubePlayerController.convertUrlToId(url);
    if (videoMode == 'none' || _videoId == null) {
      _unavailable = true;
    } else if (_demoMode) {
      _dur = 320;
      _pos = videoStartAt * _dur;
      _section = _sectionAt(_pos);
      _reached = _section;
      _started = true;
      _playing = true;
      _demo = Timer.periodic(const Duration(milliseconds: 250), (_) {
        if (!_playing || _paused || _finishing || _sectionEnd) return;
        setState(() => _pos = (_pos + 0.25).clamp(0, _dur));
        _checkSectionEnd();
      });
    } else {
      _openPlayer(_videoId!);
    }
    _state.value = _unavailable ? 0 : 1;
  }

  bool _precached = false;

  // Raster assets are decoded before the entry runs (a black player or a
  // missing arch popped in after the slide, seen in the demo).
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_precached) return;
    _precached = true;
    final id = _videoId;
    final assets = [
      'assets/ui/video/arch_frame.webp',
      'assets/ui/video/unavailable_icon.webp',
      'assets/ui/video/corner_bottom_left.webp',
      'assets/ui/video/corner_bottom_right.webp',
      'assets/ui/decor/mosque.webp',
      if (id != null && _posters.contains(id))
        'assets/ui/video/thumbs/$id.webp',
    ];
    _entry.stop();
    Future.wait([for (final a in assets) precacheImage(AssetImage(a), context)])
        .whenComplete(() {
          if (mounted) _entry.forward();
        });
  }

  void _openPlayer(String id) {
    final yt = YoutubePlayerController.fromVideoId(
      videoId: id,
      autoPlay: true,
      params: const YoutubePlayerParams(
        showControls: false,
        showFullscreenButton: false,
        enableCaption: false,
        showVideoAnnotations: false,
        strictRelatedVideos: true,
        pointerEvents: PointerEvents.none,
        interfaceLanguage: 'ar',
        playsInline: true,
      ),
    );
    _yt = yt;
    _subs.add(
      yt.stream.listen((v) {
        if (!mounted) return;
        if (v.hasError) return _setUnavailable();
        final playing = v.playerState == PlayerState.playing;
        if (playing && !_started) {
          _timeout?.cancel();
          _started = true;
        }
        if (playing != _playing) setState(() => _playing = playing);
        if (v.playerState == PlayerState.ended) _endSection();
      }),
    );
    _subs.add(
      yt.videoStateStream.listen((s) async {
        if (!mounted) return;
        if (_dur <= 0) {
          final d = await yt.duration;
          if (d > 0 && mounted) _dur = d;
        }
        if (!mounted || _sectionEnd) return;
        setState(() => _pos = s.position.inMilliseconds / 1000);
        _checkSectionEnd();
      }),
    );
    // No network or a blocked embed never reaches «playing».
    _timeout = Timer(const Duration(seconds: 15), () {
      if (!_started) _setUnavailable();
    });
  }

  void _setUnavailable() {
    if (_unavailable || !mounted) return;
    _timeout?.cancel();
    _yt?.pauseVideo();
    setState(() => _unavailable = true);
    _state.reverse();
  }

  @override
  void dispose() {
    for (final s in _subs) {
      s.cancel();
    }
    _timeout?.cancel();
    _demo?.cancel();
    _yt?.close();
    _entry.dispose();
    _state.dispose();
    super.dispose();
  }

  int get _sections => videoSectionCount;
  double _start(int k) => _dur * k / _sections;
  double _end(int k) => _dur * (k + 1) / _sections;
  int _sectionAt(double pos) =>
      _dur <= 0 ? 0 : (pos / _dur * _sections).floor().clamp(0, _sections - 1);

  /// The capsule counts sections «n/N» (owner, 2026-11-24).
  int get _step => _finishing ? _sections : _section + 1;

  void _checkSectionEnd() {
    if (_dur <= 0 || _sectionEnd || _finishing) return;
    if (_pos >= _end(_section) - 0.2) _endSection();
  }

  /// End of a section: the video stops on its last frame, «أعد» / «تابع».
  void _endSection() {
    if (_sectionEnd || _finishing || !mounted) return;
    _yt?.pauseVideo();
    Haptics.tick();
    setState(() {
      _sectionEnd = true;
      _playing = false;
    });
  }

  void _playFrom(int k) {
    final t = _start(k);
    setState(() {
      _section = k;
      _reached = math.max(_reached, k);
      _sectionEnd = false;
      _pos = t;
      _playing = true;
    });
    if (!_demoMode) {
      _yt?.seekTo(seconds: t, allowSeekAhead: true);
      _yt?.playVideo();
    }
  }

  void _repeat() => _playFrom(_section);

  /// «تابع»: next section; after the last one the lesson is complete.
  void _continue() {
    if (_section >= _sections - 1) {
      _finish();
    } else {
      _playFrom(_section + 1);
    }
  }

  /// Back to an earlier section (dots: any section reached; button: the
  /// previous one, or the start of the first).
  void _goTo(int k) {
    if (_unavailable || _finishing || k > _reached) return;
    _playFrom(k);
  }

  void _leave(bool done) {
    if (_left || !mounted) return;
    if (ModalRoute.of(context)?.isCurrent != true) return;
    _left = true;
    Navigator.of(context).pop(done);
  }

  /// End of the video or «تخطي»: the fill reaches 100, the light runs along
  /// the capsule (screen 02), then the lesson leaves with `true`.
  Future<void> _finish() async {
    if (_finishing || _left) return;
    _finishing = true;
    _yt?.pauseVideo();
    _shell.currentState?.lock();
    setState(() {});
    await Future<void>.delayed(const Duration(milliseconds: 320));
    await _shell.currentState?.celebrate();
    _leave(true);
  }

  void _togglePlay() {
    if (_unavailable || _finishing || _sectionEnd) return;
    Haptics.tap();
    if (_demoMode) {
      setState(() => _playing = !_playing);
    } else if (_playing) {
      _yt?.pauseVideo();
    } else {
      _yt?.playVideo();
    }
  }

  bool _resumeAfterMenu = false;

  void _onPaused(bool p) {
    setState(() => _paused = p);
    if (p) {
      _resumeAfterMenu = _playing;
      if (!_demoMode) _yt?.pauseVideo();
    } else if (_resumeAfterMenu && !_finishing && !_sectionEnd) {
      if (!_demoMode) _yt?.playVideo();
    }
  }

  void _restart() {
    Haptics.tick();
    _playFrom(0);
  }

  // Entry: frame and arch first, then icon/player, then texts (60 ms steps).
  Widget _enter(int k, Widget child) => AnimatedBuilder(
    animation: _entry,
    child: child,
    builder: (context, child) {
      final t = Curves.easeOutCubic.transform(
        ((_entry.value - k * 0.07) / 0.6).clamp(0.0, 1.0),
      );
      return Opacity(
        opacity: t,
        child: Transform.translate(
          offset: Offset(0, (1 - t) * 12),
          child: child,
        ),
      );
    },
  );

  @override
  Widget build(BuildContext context) {
    return LessonShell(
      key: _shell,
      step: _step,
      total: _sections,
      onBack: () => _leave(false),
      onRestart: _restart,
      onPausedChanged: _onPaused,
      child: LayoutBuilder(
        builder: (context, box) {
          final u = box.maxHeight / 100;
          final cx = box.maxWidth / 2;
          const m = VideoMetrics.cornerSize;
          return Stack(
            fit: StackFit.expand,
            clipBehavior: Clip.hardEdge,
            children: [
              const _VideoBackground(key: ValueKey('bg')),
              const Positioned.fill(
                key: ValueKey('girih'),
                child: IgnorePointer(child: ScreenGirih(fadeTop: false)),
              ),
              // Faint lattice band along the bottom (owner's V5, seamless
              // tile; reference: period 89 px = 10.4u, ends at ≈ 96u).
              Positioned(
                key: const ValueKey('band'),
                left: 0,
                right: 0,
                top: u * (VideoMetrics.bandBottom - VideoMetrics.bandH),
                height: u * VideoMetrics.bandH,
                child: IgnorePointer(
                  // The reference's upper row fades out upwards.
                  child: ShaderMask(
                    blendMode: BlendMode.dstIn,
                    shaderCallback: (r) => const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: [0, 0.25, 0.45],
                      colors: [
                        Color(0x26000000),
                        Color(0x99000000),
                        Color(0xFF000000),
                      ],
                    ).createShader(r),
                    child: Opacity(
                      opacity: VideoMetrics.bandOpacity,
                      child: ColorFiltered(
                        colorFilter: _cornerTone,
                        child: Image.asset(
                          'assets/ui/video/bottom_band.webp',
                          repeat: ImageRepeat.repeatX,
                          fit: BoxFit.none,
                          scale: 256 / (u * VideoMetrics.bandH),
                          alignment: Alignment.center,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // Faint lattice in the top corners too (reference: x ≤ 18u,
              // y ≤ 21u, ≈ 35% of the bottom corners): the bottom corners
              // flipped.
              for (final (k, left) in [('cornerTL', true), ('cornerTR', false)])
                Positioned(
                  key: ValueKey(k),
                  left: left ? 0 : null,
                  right: left ? null : 0,
                  top: 0,
                  width: u * VideoMetrics.topCornerSize,
                  height: u * VideoMetrics.topCornerSize,
                  child: IgnorePointer(
                    child: Opacity(
                      opacity: 0.38,
                      child: Transform.flip(
                        flipY: true,
                        child: ColorFiltered(
                          colorFilter: _cornerTone,
                          child: Image.asset(
                            'assets/ui/video/corner_bottom_${left ? 'left' : 'right'}.webp',
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              Positioned(
                key: const ValueKey('cornerL'),
                left: 0,
                top: u * VideoMetrics.cornerTop,
                width: u * m,
                height: u * m,
                child: IgnorePointer(
                  // The reference's lattice dims towards the bottom edge
                  // (visible to ≈ 89u, gone at the edge).
                  child: ShaderMask(
                    blendMode: BlendMode.dstIn,
                    shaderCallback: (r) => const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: [0.7, 0.79, 0.87, 0.97],
                      colors: [
                        Color(0xFF000000),
                        Color(0x8C000000),
                        Color(0x33000000),
                        Color(0x00000000),
                      ],
                    ).createShader(r),
                    child: ColorFiltered(
                      colorFilter: _cornerTone,
                      child: Image.asset(
                        'assets/ui/video/corner_bottom_left.webp',
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                key: const ValueKey('cornerR'),
                right: 0,
                top: u * VideoMetrics.cornerTop,
                width: u * m,
                height: u * m,
                child: IgnorePointer(
                  // The reference's lattice dims towards the bottom edge
                  // (visible to ≈ 89u, gone at the edge).
                  child: ShaderMask(
                    blendMode: BlendMode.dstIn,
                    shaderCallback: (r) => const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: [0.7, 0.79, 0.87, 0.97],
                      colors: [
                        Color(0xFF000000),
                        Color(0x8C000000),
                        Color(0x33000000),
                        Color(0x00000000),
                      ],
                    ).createShader(r),
                    child: ColorFiltered(
                      colorFilter: _cornerTone,
                      child: Image.asset(
                        'assets/ui/video/corner_bottom_right.webp',
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                key: const ValueKey('arch'),
                left: cx + u * VideoMetrics.archDx,
                top: u * VideoMetrics.archTop,
                width: u * VideoMetrics.archW,
                height: u * VideoMetrics.archH,
                child: _enter(
                  0,
                  // The reference's line is bright at the apex and dims
                  // down the lobes (#FFE48F → #B68C2D → #404622).
                  IgnorePointer(
                    child: ShaderMask(
                      blendMode: BlendMode.dstIn,
                      shaderCallback: (r) => const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: [0, 0.2, 0.36, 0.55, 0.8, 1],
                        colors: [
                          Color(0xFF000000),
                          Color(0xF2000000),
                          Color(0xA6000000),
                          Color(0x38000000),
                          Color(0x1A000000),
                          Color(0x00000000),
                        ],
                      ).createShader(r),
                      child: Image.asset(
                        'assets/ui/video/arch_frame.webp',
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                ),
              ),
              // Not available.
              ..._fade(false, _unavailableLayer(u, cx)),
              // Playing.
              ..._fade(true, _playingLayer(u, cx)),
              Positioned(
                key: const ValueKey('skip'),
                right: u * SkipMetrics.right,
                top: u * SkipMetrics.top,
                width: u * SkipMetrics.width,
                height: u * SkipMetrics.height,
                child: _enter(
                  4,
                  SkipButton(u: u, completed: widget.completed, onTap: _finish),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Wraps the layer's children in the not-available ↔ playing cross-fade.
  List<Widget> _fade(bool playing, List<Widget> layer) => [
    for (final w in layer)
      if (w is Positioned)
        Positioned(
          key: w.key,
          left: w.left,
          top: w.top,
          right: w.right,
          bottom: w.bottom,
          width: w.width,
          height: w.height,
          child: AnimatedBuilder(
            animation: _state,
            child: w.child,
            builder: (context, child) {
              final v = playing ? _state.value : 1 - _state.value;
              if (v == 0) return const SizedBox.shrink();
              return IgnorePointer(
                ignoring: v < 1,
                child: Opacity(opacity: v, child: child),
              );
            },
          ),
        ),
  ];

  List<Widget> _unavailableLayer(double u, double cx) {
    final iconW = u * VideoMetrics.iconW;
    return [
      Positioned(
        key: const ValueKey('mosque'),
        left: cx + u * VideoMetrics.mosqueDx,
        top: u * VideoMetrics.mosqueTop,
        width: u * VideoMetrics.mosqueW,
        child: _enter(
          1,
          IgnorePointer(
            child: ShaderMask(
              blendMode: BlendMode.dstIn,
              shaderCallback: (r) => const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.7, 1],
                colors: [Color(0xFF000000), Color(0x00000000)],
              ).createShader(r),
              child: ColorFiltered(
                colorFilter: _mosqueTone,
                child: Image.asset('assets/ui/decor/mosque.webp'),
              ),
            ),
          ),
        ),
      ),
      Positioned(
        key: const ValueKey('icon'),
        left: cx + u * VideoMetrics.iconCx - iconW / 2,
        top: u * VideoMetrics.iconTop,
        width: iconW,
        height: u * VideoMetrics.iconH,
        child: _enter(
          2,
          ColorFiltered(
            colorFilter: _iconTone,
            child: Image.asset(
              'assets/ui/video/unavailable_icon.webp',
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
      Positioned(
        key: const ValueKey('naTitle'),
        left: 0,
        right: 0,
        top: u * VideoMetrics.titleTop,
        child: _enter(
          3,
          Text(
            'الفيديو غير متاح',
            textAlign: TextAlign.center,
            textDirection: TextDirection.rtl,
            style: readex(
              u * VideoMetrics.titleSize,
              weight: 600,
              color: titleCream,
            ).copyWith(shadows: titleShadows(u)),
          ),
        ),
      ),
      Positioned(
        key: const ValueKey('divider'),
        left: cx - u * VideoMetrics.dividerW / 2,
        top: u * VideoMetrics.dividerTop,
        width: u * VideoMetrics.dividerW,
        height: u * VideoMetrics.dividerH,
        child: _enter(3, GoldDivider(u: u)),
      ),
      Positioned(
        key: const ValueKey('naText'),
        left: 0,
        right: 0,
        top: u * VideoMetrics.textTop,
        child: _enter(
          4,
          Text(
            'عذرًا، هذا الفيديو غير متاح حاليًا.',
            textAlign: TextAlign.center,
            textDirection: TextDirection.rtl,
            style: readex(
              u * VideoMetrics.textSize,
              weight: 340,
              color: RateelColors.cream.withValues(alpha: 0.82),
            ),
          ),
        ),
      ),
    ];
  }

  /// Playing (owner, 2026-11-24, «as Simply Piano»): the video fills the
  /// screen, whole (16:9 at the full height, dark bands at the sides), no
  /// time line; controls always visible on soft dark gradients: the 02 bar,
  /// the lesson title, «تخطي», the way back to earlier sections; at the end
  /// of each section «أعد» / «تابع».
  List<Widget> _playingLayer(double u, double cx) {
    const nav = VideoMetrics.navY;
    return [
      Positioned.fill(key: const ValueKey('video'), child: _player(u)),
      // Legibility of the controls on any video frame.
      Positioned.fill(
        key: const ValueKey('shade'),
        child: const IgnorePointer(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0, 0.26, 0.66, 1],
                colors: [
                  Color(0xC7000000),
                  Color(0x00000000),
                  Color(0x00000000),
                  Color(0x8C000000),
                ],
              ),
            ),
          ),
        ),
      ),
      Positioned(
        key: const ValueKey('playTitle'),
        left: u * (LessonBarMetrics.margin + LessonBarMetrics.capsuleW + 3),
        right: u * (LessonBarMetrics.margin + LessonBarMetrics.button + 3),
        top: u * (VideoMetrics.barCentre - VideoMetrics.playTitleSize * 0.66),
        child: _enter(
          1,
          IgnorePointer(
            child: Text(
              widget.lesson.title,
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: readex(
                u * VideoMetrics.playTitleSize,
                weight: 560,
                color: titleCream,
              ).copyWith(shadows: titleShadows(u)),
            ),
          ),
        ),
      ),
      if (videoSectionNav == 'dots')
        Positioned(
          key: const ValueKey('dots'),
          left: 0,
          right: 0,
          top: u * (nav - 4),
          height: u * 8,
          child: _enter(3, Center(child: _dots(u))),
        )
      else
        Positioned(
          key: const ValueKey('prev'),
          right: u * (SkipMetrics.right + SkipMetrics.width + 3),
          top: u * SkipMetrics.top,
          width: u * SkipMetrics.height,
          height: u * SkipMetrics.height,
          child: _enter(
            3,
            LessonRoundButton(
              u: u,
              label: 'القسم السابق',
              glyph: PillGlyph.previous,
              enabled: _section > 0 || _pos > _start(0) + 1,
              onTap: () => _goTo(math.max(0, _section - 1)),
            ),
          ),
        ),
      // End of a section: the frame stays, a veil and «أعد» / «تابع».
      Positioned.fill(
        key: const ValueKey('sectionEnd'),
        child: IgnorePointer(
          ignoring: !_sectionEnd,
          child: AnimatedOpacity(
            opacity: _sectionEnd ? 1 : 0,
            duration: const Duration(milliseconds: 260),
            child: ColoredBox(
              color: const Color(0x73000000),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  textDirection: TextDirection.rtl,
                  children: [
                    SizedBox(
                      width: u * VideoMetrics.endPillW,
                      height: u * SkipMetrics.height,
                      child: LessonPill(
                        u: u,
                        label: 'أعد',
                        glyph: PillGlyph.replay,
                        onTap: _repeat,
                      ),
                    ),
                    SizedBox(width: u * 5),
                    SizedBox(
                      width: u * VideoMetrics.endPillW,
                      height: u * SkipMetrics.height,
                      child: LessonPill(
                        u: u,
                        label: 'تابع',
                        glyph: PillGlyph.play,
                        gold: true,
                        onTap: _continue,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ];
  }

  /// One dot per section (reference 08's dots): reached sections gold (tap =
  /// watch again from its start), the current one larger with a glow, the
  /// next ones dim. RTL: the first section on the right.
  Widget _dots(double u) => Row(
    mainAxisSize: MainAxisSize.min,
    textDirection: TextDirection.rtl,
    children: [
      for (var k = 0; k < _sections; k++)
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            if (k <= _reached) {
              Haptics.tap();
              _goTo(k);
            } else {
              Haptics.denied();
            }
          },
          child: Semantics(
            button: true,
            label: 'القسم ${k + 1}',
            child: SizedBox(
              width: u * VideoMetrics.dotPitch,
              height: u * 8,
              child: Center(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: u * (k == _section ? 3.4 : VideoMetrics.dot),
                  height: u * (k == _section ? 3.4 : VideoMetrics.dot),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: k == _section
                        ? RateelColors.videoFill
                        : k <= _reached
                        ? RateelColors.videoFillEnd.withValues(alpha: 0.75)
                        : RateelColors.videoTrack.withValues(alpha: 0.8),
                    boxShadow: k == _section
                        ? [
                            BoxShadow(
                              color: RateelColors.videoFill.withValues(
                                alpha: 0.5,
                              ),
                              blurRadius: u * 1.4,
                            ),
                          ]
                        : null,
                  ),
                ),
              ),
            ),
          ),
        ),
    ],
  );

  /// The whole video, 16:9 at the full screen height, centred on dark
  /// bands. The poster stays on top until the video plays and while the pause
  /// menu is open (the platform view cannot be blurred by the 02 veil).
  Widget _player(double u) {
    final poster = _videoId != null && _posters.contains(_videoId)
        ? Image.asset(
            'assets/ui/video/thumbs/$_videoId.webp',
            fit: BoxFit.contain,
          )
        : const SizedBox.expand();
    final showPoster = _demoMode || !_started || _paused;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _togglePlay,
      child: ColoredBox(
        color: Colors.black,
        child: Center(
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (_yt != null && !_unavailable)
                  IgnorePointer(
                    child: YoutubePlayer(
                      controller: _yt!,
                      autoFullScreen: false,
                      enableFullScreenOnVerticalDrag: false,
                      backgroundColor: Colors.black,
                    ),
                  ),
                AnimatedOpacity(
                  opacity: showPoster ? 1 : 0,
                  duration: const Duration(milliseconds: 250),
                  child: poster,
                ),
                // Paused by a tap on the video: a play disc.
                AnimatedOpacity(
                  opacity: !_playing && !_paused && !_finishing && !_sectionEnd
                      ? 1
                      : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Center(
                    child: SizedBox(
                      width: u * 13,
                      height: u * 13,
                      child: const CustomPaint(painter: _PlayDiscPainter()),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Background of the lesson screens: radial, lighter in the centre (ref 07).
class _VideoBackground extends StatelessWidget {
  const _VideoBackground({super.key});

  @override
  Widget build(BuildContext context) => const DecoratedBox(
    decoration: BoxDecoration(
      gradient: RadialGradient(
        radius: 0.9,
        colors: [RateelColors.videoBgCentre, RateelColors.videoBgEdge],
      ),
    ),
  );
}

/// Play disc shown on the paused video: cream glass disc, gold triangle.
class _PlayDiscPainter extends CustomPainter {
  const _PlayDiscPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.width / 2;
    canvas.drawCircle(
      c,
      r,
      Paint()..color = const Color(0xFF00140E).withValues(alpha: 0.55),
    );
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * 0.06
        ..color = RateelColors.videoPlayerRimTop,
    );
    final s = r * 0.42;
    final tri = Path()
      ..moveTo(c.dx - s * 0.7, c.dy - s)
      ..lineTo(c.dx + s, c.dy)
      ..lineTo(c.dx - s * 0.7, c.dy + s)
      ..close();
    canvas.drawPath(tri, Paint()..color = RateelColors.videoKnob);
  }

  @override
  bool shouldRepaint(_PlayDiscPainter o) => false;
}

/// Tones measured on reference 07 (owner's assets are brighter than the
/// reference): icon clapper #E7D8B4 → #CFAE65, badge #CD9C38; corners olive
/// gold #A5933C fading out; mosque dome #4E7743.
ColorFilter _scale(double r, double g, double b, {double sat = 1}) {
  const lr = 0.2126, lg = 0.7152, lb = 0.0722;
  final s = sat, t = 1 - sat;
  return ColorFilter.matrix([
    r * (t * lr + s), r * t * lg, r * t * lb, 0, 0, //
    g * t * lr, g * (t * lg + s), g * t * lb, 0, 0, //
    b * t * lr, b * t * lg, b * (t * lb + s), 0, 0, //
    0, 0, 0, 1, 0, //
  ]);
}

final _iconTone = _scale(0.9, 0.88, 0.9, sat: 0.82);
final _cornerTone = _scale(0.66, 0.64, 0.8);
final _mosqueTone = _scale(1.32, 1.21, 1.08);
