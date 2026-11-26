import 'package:material_ui/material_ui.dart';

import '../core/screen_decor.dart';
import '../theme/rateel_theme.dart';

const _art = 'assets/ui/splash';

/// Screen 01 stays above the initial destination until startup has succeeded.
class StartupScreen extends StatefulWidget {
  const StartupScreen({
    super.key,
    required this.initialize,
    required this.child,
  });

  final Future<void> Function(BuildContext) initialize;
  final Widget child;

  @override
  State<StartupScreen> createState() => _StartupScreenState();
}

class _StartupScreenState extends State<StartupScreen>
    with TickerProviderStateMixin {
  late final _progress = AnimationController(vsync: this);
  late final _glow = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 750),
  );
  bool _failed = false;
  bool _ready = false;
  bool _dismissed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _start();
    });
  }

  Future<void> _start() async {
    if (_failed) setState(() => _failed = false);
    _progress.reset();
    final motion = !MediaQuery.disableAnimationsOf(context);
    if (motion) _glow.repeat(reverse: true);
    try {
      // Hold below 100% on slow devices. The final segment belongs to success.
      await Future.wait([
        _progress
            .animateTo(.9, duration: Duration(milliseconds: motion ? 1350 : 0))
            .orCancel,
        widget.initialize(context),
      ], eagerError: true);
      if (!mounted) return;
      await _progress
          .animateTo(1, duration: Duration(milliseconds: motion ? 150 : 0))
          .orCancel;
      if (!mounted) return;
      _glow.stop();
      setState(() {
        _ready = true;
        _dismissed = !motion;
      });
    } on TickerCanceled {
      // The startup widget was disposed.
    } catch (error, stack) {
      if (!mounted) return;
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stack,
          library: 'Rateel startup',
        ),
      );
      _progress.stop();
      _glow.stop();
      setState(() => _failed = true);
    }
  }

  @override
  void dispose() {
    _glow.dispose();
    _progress.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Stack(
    fit: StackFit.expand,
    children: [
      if (_ready) widget.child,
      if (!_dismissed)
        AnimatedOpacity(
          opacity: _ready ? 0 : 1,
          duration: const Duration(milliseconds: 300),
          onEnd: () {
            if (_ready) setState(() => _dismissed = true);
          },
          child: Material(
            color: const Color(0xFF023224),
            child: Stack(
              fit: StackFit.expand,
              children: [
                const RepaintBoundary(
                  child: Image(
                    image: AssetImage('$_art/background.webp'),
                    fit: BoxFit.fill,
                  ),
                ),
                // Keep the original proportions of the emblem and lettering,
                // independent of the phone's aspect ratio.
                Positioned.fill(
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: SizedBox(
                      width: 740,
                      height: 853,
                      child: Stack(
                        alignment: Alignment.topCenter,
                        children: [
                          Positioned(
                            top: -61,
                            width: 570,
                            height: 504,
                            child: FadeTransition(
                              opacity: _glow.drive(Tween(begin: .38, end: 1.0)),
                              child: const RepaintBoundary(
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    gradient: RadialGradient(
                                      colors: [
                                        Color(0x8AE9B339),
                                        Color(0x50C99B32),
                                        Color(0x00C99B32),
                                      ],
                                      stops: [0, .38, 1],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const Positioned(
                            top: 31,
                            width: 312,
                            height: 322,
                            child: Image(
                              image: AssetImage('$_art/emblem.webp'),
                              excludeFromSemantics: true,
                            ),
                          ),
                          const Positioned(
                            top: 356,
                            width: 416,
                            height: 163,
                            child: Image(
                              image: AssetImage('$_art/wordmark.webp'),
                              semanticLabel: 'رتّل، تعلّم أحكام التجويد',
                            ),
                          ),
                          const Positioned(
                            top: 526,
                            width: 530,
                            height: 47,
                            child: GoldDivider(u: 8.53, diamond: 2.25),
                          ),
                          if (_failed)
                            Positioned(
                              top: 589,
                              child: Column(
                                children: [
                                  Text('تعذّر تحميل المحتوى', style: cairo(29)),
                                  TextButton.icon(
                                    onPressed: () {
                                      if (_failed) _start();
                                    },
                                    icon: const Icon(Icons.refresh),
                                    label: Text(
                                      'إعادة المحاولة',
                                      style: cairo(
                                        29,
                                        color: RateelColors.gold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else ...[
                            Positioned(
                              top: 599,
                              width: 628,
                              child: _LoadingProgress(progress: _progress),
                            ),
                            Positioned(
                              top: 698,
                              height: 55,
                              child: Center(
                                child: Text(
                                  'جارٍ تحميل المحتوى…',
                                  style: cairo(
                                    30,
                                    color: const Color(0xFFADBF97),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
    ],
  );
}

class _LoadingProgress extends StatelessWidget {
  const _LoadingProgress({required this.progress});

  final Animation<double> progress;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: progress,
    builder: (context, _) {
      final percent = (progress.value * 100).round();
      return Semantics(
        label: 'تحميل المحتوى',
        value: '$percent%',
        excludeSemantics: true,
        child: Column(
          children: [
            Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: const Color(0xFF487F62), width: 2),
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF205C46),
                    Color(0xFF0B422F),
                    Color(0xFF18533D),
                  ],
                ),
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: progress.value,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0xFFFFD059),
                          Color(0xFFEEB224),
                          Color(0xFFD79B0C),
                        ],
                      ),
                    ),
                    child: const SizedBox.expand(),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 57,
              child: Center(
                child: Text(
                  '$percent%',
                  textDirection: TextDirection.ltr,
                  style: cairo(34, weight: 600, color: RateelColors.soonTitle),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}
