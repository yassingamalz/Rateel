import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/haptics.dart';
import '../../theme/rateel_theme.dart';
import '../lesson_shell.dart';
import '../lesson_widgets.dart';
import 'guided_content.dart';
import 'guided_scene.dart';

class GuidedPage extends StatefulWidget {
  const GuidedPage({super.key});

  @override
  State<GuidedPage> createState() => _GuidedPageState();
}

class _GuidedPageState extends State<GuidedPage> with WidgetsBindingObserver {
  int step = 0;
  String? answer;
  bool muted = false, menuOpen = false, inactive = false;
  bool verse = false, audioFailed = false;
  final position = ValueNotifier<int>(-1);
  AudioPlayer? player;
  Future<void> pending = Future.value();
  int generation = 0;
  bool get suspended => menuOpen || inactive;
  bool get correct => answer == correctId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  // Serialize native player calls. A late load or completion from the previous
  // scene must never start narration over the current one.
  void audio({bool recitation = false, bool stop = false}) {
    final token = ++generation;
    final file = recitation ? 'fatiha-excerpt' : guidedTracks[step].id;
    position.value = -1;
    pending = pending
        .then((_) async {
          final old = player;
          player = null;
          if (old != null) await old.dispose();
          if (!mounted || token != generation || stop || muted || suspended) {
            return;
          }
          final next = player = AudioPlayer();
          if (recitation) {
            next.onPositionChanged.listen((time) {
              if (mounted && token == generation) {
                position.value = time.inMilliseconds;
              }
            });
          }
          next.onPlayerComplete.listen((_) {
            if (!mounted || token != generation) return;
            setState(() => verse = false);
            position.value = -1;
            if (step == 5 && !recitation) playVerse();
          });
          await next.play(AssetSource('guided/$file.mp3'));
        })
        .catchError((Object error) {
          if (mounted && token == generation) {
            setState(() {
              audioFailed = true;
              verse = false;
            });
          }
        });
  }

  void playVerse() {
    setState(() {
      muted = false;
      verse = true;
      audioFailed = false;
    });
    audio(recitation: true);
  }

  void go(int index) {
    if (index < 0 || index >= guidedTracks.length) return;
    Haptics.tick();
    setState(() {
      step = index;
      verse = false;
      audioFailed = false;
      if (index == 0) answer = null;
    });
    audio();
  }

  void toggleMute() {
    setState(() {
      muted = !muted;
      verse = false;
      audioFailed = false;
    });
    audio(stop: muted);
  }

  void suspend() {
    // Keep the current position across the shared pause menu and app switches.
    final token = generation;
    final pause = suspended;
    pending = pending
        .then((_) async {
          final active = player;
          if (!mounted || active == null || token != generation || muted) {
            return;
          }
          if (pause && active.state == PlayerState.playing) {
            await active.pause();
          }
          if (!pause && active.state == PlayerState.paused) {
            await active.resume();
          }
        })
        .catchError((Object error) {
          if (mounted && token == generation) {
            setState(() => audioFailed = true);
          }
        });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    inactive = state != AppLifecycleState.resumed;
    suspend();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    generation++;
    pending.then((_) => player?.dispose());
    position.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: LessonShell(
      step: step + 1,
      total: guidedTracks.length,
      showCapsule: false,
      onPausedChanged: (paused) {
        menuOpen = paused;
        suspend();
      },
      onBack: () => Navigator.of(context).pop(),
      onRestart: () => go(0),
      child: Stack(
        fit: StackFit.expand,
        children: [
          const RepaintBoundary(
            child: Image(
              image: AssetImage('assets/guided/bg-glassy.webp'),
              fit: BoxFit.fill,
            ),
          ),
          FittedBox(
            fit: BoxFit.contain,
            child: SizedBox(
              width: 900,
              height: 400,
              child: Stack(
                alignment: Alignment.topCenter,
                children: [
                  Positioned(
                    top: step == 0 ? 5 : 25,
                    width: step == 0 ? 605 : 565,
                    height: step == 0 ? 155 : 110,
                    child: const Image(
                      image: AssetImage('assets/guided/header-arch.webp'),
                      fit: BoxFit.fill,
                      excludeFromSemantics: true,
                    ),
                  ),
                  if (step == 0 || step == 6)
                    const Positioned(
                      bottom: 1,
                      width: 220,
                      height: 54,
                      child: Opacity(
                        opacity: .45,
                        child: Image(
                          image: AssetImage(
                            'assets/guided/mosque-skyline.webp',
                          ),
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),
                  if (step != 0)
                    Positioned(
                      top: 6,
                      left: 75,
                      right: 90,
                      height: 36,
                      child: Semantics(
                        label: 'الخطوة ${step + 1} من ${guidedTracks.length}',
                        child: Row(
                          children: [
                            for (var i = 0; i < guidedTracks.length; i++)
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 3,
                                  ),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: i <= step
                                          ? RateelColors.gold
                                          : const Color(0xff315343),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ),
                            const SizedBox(width: 8),
                            Text(
                              '${step + 1}/${guidedTracks.length}',
                              textDirection: TextDirection.ltr,
                              style: cairo(16),
                            ),
                          ],
                        ),
                      ),
                    ),
                  Positioned(
                    left: 12,
                    top: 2,
                    child: IconButton(
                      tooltip: muted ? 'تشغيل الصوت' : 'كتم الصوت',
                      onPressed: toggleMute,
                      icon: Icon(
                        muted ? Icons.volume_off : Icons.volume_up,
                        color: RateelColors.cream,
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: Padding(
                      padding: EdgeInsets.only(
                        top: step == 0 ? 43 : 56,
                        bottom: step == 0 ? 42 : 83,
                        left: 34,
                        right: 34,
                      ),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 220),
                        child: GuidedScene(
                          key: ValueKey(step),
                          step: step,
                          answer: answer,
                          position: position,
                          verse: verse,
                          onStart: () => go(1),
                          onIntroAudio: () {
                            setState(() {
                              muted = false;
                              audioFailed = false;
                            });
                            audio();
                          },
                          onReplay: playVerse,
                          onAnswer: (id) {
                            if (!correct) {
                              Haptics.tick();
                              setState(() => answer = id);
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                  if (step > 0)
                    Positioned(
                      left: 25,
                      right: 25,
                      bottom: 24,
                      height: 53,
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 4,
                              ),
                              decoration: guidedPanel(),
                              alignment: Alignment.center,
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: SizedBox(
                                  width: 520,
                                  child: Text(
                                    audioFailed
                                        ? 'تعذّر تشغيل الصوت. ${guidedTracks[step].caption}'
                                        : guidedTracks[step].caption,
                                    textAlign: TextAlign.center,
                                    style: cairo(17),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          IconButton(
                            tooltip: 'السابق',
                            onPressed: () => go(step - 1),
                            icon: const Icon(
                              Icons.arrow_forward,
                              textDirection: TextDirection.ltr,
                            ),
                          ),
                          SizedBox(
                            width: 144,
                            height: 46,
                            child: IgnorePointer(
                              ignoring: step == 3 && !correct,
                              child: Opacity(
                                opacity: step == 3 && !correct ? .4 : 1,
                                child: LessonPill(
                                  u: 4,
                                  height: 10,
                                  fontSize: 4.6,
                                  gold: true,
                                  label: step == 6 ? 'إنهاء الدرس' : 'متابعة',
                                  glyph: step == 6
                                      ? PillGlyph.check
                                      : PillGlyph.forward,
                                  onTap: () {
                                    if (step == 6) {
                                      Navigator.of(context).pop();
                                    } else {
                                      go(step + 1);
                                    }
                                  },
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
