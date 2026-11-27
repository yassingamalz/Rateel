import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:audioplayers/audioplayers.dart';
import 'package:material_ui/material_ui.dart';

import '../core/haptics.dart';
import '../core/sounds.dart';
import '../theme/rateel_theme.dart';
import 'lesson_data.dart';
import 'lesson_decor.dart';
import 'lesson_shell.dart';
import 'lesson_widgets.dart';
import 'listening_data.dart';
import 'reading_data.dart' show readingLight, TajweedColors;
import 'reading_lesson_page.dart' show readingStartLight, ReadMetrics;

/// Review aids (screen 22): `?listenQ=2` opens question 2 (0-based),
/// `?listenPick=0` selects that option, `?listenState=ok|ko` shows the
/// feedback, `?listenAt=0.4` stops the audio at 40% (waveform and lit word,
/// no autoplay); with `?readTheme=light` for the light theme.
int listenStartQuestion = 0;
int? listenStartPick;
String? listenStartState;
double? listenStartAt;

/// Review aid: `?logAudio=1` prints the audio events to the console, so the
/// demo video can get its sound track back (`listening-demo.js`).
bool listenLogAudio = false;

/// Where the play button sits (owner, 2026-11-26: below the card it takes the
/// room the verse, its light box and the waveform need). Variants for the
/// owner's choice, review `?playPos=`: `below` (reference), `a` inside the
/// card on the left of the verse, `b` in line with the waveform (player),
/// `c` in the bottom row next to «تأكيد». In a, b, c the card grows down to
/// the line.
String listenPlayPos = 'b'; // owner's choice B (2026-11-26)
bool get _playBelow => listenPlayPos == 'below';

/// Review aid `?litAll=1`: every word shows its light box (to check that the
/// boxes hold the whole words, harakat included).
bool listenLitAll = false;

/// Header variant under review (`?headerV=`, see [ListenMetrics.header]).
String listenHeaderV =
    'c'; // owner's choice (2026-11-27): no line under the title

/// How the recited word lights up (owner, 2026-11-26, to compare): `box` a
/// soft gold box around the word, `glow` the letters themselves light up
/// (brighter gold with a halo), no box. Review `?wordLight=glow`.
String listenWordLight =
    'glow'; // owner's choice (2026-11-26); 'box' kept for a future user setting
bool get _glow => listenWordLight == 'glow';

void _logAudio(String e) {
  // ignore: avoid_print
  if (listenLogAudio) print('AUDIO $e');
}

/// Geometry of screen 22 in u (1% of the screen height), measured on
/// `screens/22-listening-lesson/22-lezione-ascolto.webp` (1844×853,
/// u = 8.53 px). Card values from the card edges; bottom row from the screen
/// edges; header = the 08 header with the headphones in the book box.
class ListenMetrics {
  ListenMetrics._();
  static const side = 4.6;
  static HeaderSpec get header => _header(listenHeaderV);

  /// Header variants for the owner (2026-11-27, `?headerV=`): a current;
  /// b without the arch; c without the line under the title; d arch closer
  /// to the title, no headphones, line under the title fixed; e line under
  /// the title fixed (lower and shorter, clear of the title), headphones
  /// kept; f only the headphones and the title, with a small diamond;
  /// g (owner, 2026-11-27, with the H1 headphones) the line with its diamond
  /// back under the title, clear of the title's ink (ع) and of the card:
  /// headphones and title 0.3–0.4u higher.
  static HeaderSpec _header(String v) {
    final g = v == 'g';
    final noArch = v == 'b' || v == 'f';
    final fixedLine = v == 'd' || v == 'e';
    return HeaderSpec(
      archW: noArch ? 0 : (v == 'd' ? 86.0 : ReadMetrics.archW),
      archH: v == 'd' ? 17.5 : ReadMetrics.archH,
      archTop: v == 'd' ? 3.6 : ReadMetrics.archTop,
      archClipDx: v == 'd' ? -31.0 : ReadMetrics.archClipDx,
      mosqueDx: ReadMetrics.mosqueDx,
      mosqueTop: ReadMetrics.mosqueTop,
      mosqueW: ReadMetrics.mosqueW,
      crescentDx: ReadMetrics.crescentDx,
      crescentTop: ReadMetrics.crescentTop,
      crescentH: ReadMetrics.crescentH,
      starDx: ReadMetrics.starDx,
      starTop: ReadMetrics.starTop,
      starH: ReadMetrics.starH,
      titleCentre: v == 'd'
          ? 15.6
          : (v == 'f' ? 17.8 : (g ? 16.9 : titleCentre)),
      titleSize: titleSize,
      dividerTop: g
          ? 25.0
          : (fixedLine ? 25.4 : (v == 'f' ? 24.6 : ReadMetrics.dividerTop)),
      dividerW: v == 'c'
          ? 0
          : (g
                ? 56.0
                : (fixedLine ? 52.0 : (v == 'f' ? 9.0 : ReadMetrics.dividerW))),
      dividerDiamond: v == 'f' ? 1.2 : (g ? 1.3 : ReadMetrics.dividerDiamond),
      book: v != 'd',
      bookW: headW,
      bookH: headH,
      bookTop: v == 'f' ? 4.4 : (g ? 4.9 : headTop),
      emblem: 'assets/ui/listening/headphones.webp',
    );
  }

  // Title larger than 08 (reference: ink 727–1117 px wide, centre 17.6u).
  static const titleCentre = 17.3;
  static const titleSize = 7.0;
  static const headW = 9.0;
  static const headH = 7.9; // owner's H1 (2026-11-27): almost square, so a little taller than the reference box
  static const headTop = 5.2;
  // Card.
  static const cardTop = 27.55;
  static double get cardBottom => _playBelow ? 66.7 : 79.0;
  static const cardRadius = 3.6;
  static double get bandTop =>
      _playBelow ? 24.0 : 35.0; // lattice band, from the card top
  static const badgeRight = 11.0; // card right edge → badge centre
  static const badgeCy = 7.7; // from the card top
  static const badgeH = 9.4;
  static const surahLeft = 4.9; // card left edge → text
  static const surahCy = 5.3;
  static const surahSize = 4.1;
  static double get verseCy => _playBelow ? 15.2 : 20.6;
  static const verseSize = 11.5;
  static double get waveCy => _playBelow ? 30.5 : 41.0;
  static const bars = 51;
  static const barStep = 2.6;
  static const barW = 1.4;
  static const barMin = 1.9;
  static const barMax = 7.0;
  // Play button under the card.
  static const playCy = 73.6;
  static const playD = 12.1;
  // Half width of the waveform (51 bars, step 2.6u, bar 1.4u).
  static const waveHalf = 65.7;
  // Line above the bottom row.
  static const lineY = 82.0;
  static const lineInset = 7.0;
  // Bottom row.
  static const rowCy = 89.6;
  static const qRight = 7.2; // screen right → question text
  static const qSize = 4.5;
  static const pillsRight = 72.6; // screen right → first answer pill
  static const pillW = 27.2;
  static const pillH = 9.6;
  static const pillGap = 3.9;
  static const pillText = 4.2;
  // Letter pills of the «find» question (phase 2).
  static const letterW = 11.5;
  static const letterGap = 2.2;
  static const pillRim = 0.25;
  static const confirmLeft = 6.8;
  static const confirmW = 32.5;
  static const confirmH = 11.8;
  static const confirmCy = 89.0;
}

Route<bool> listeningLessonRoute(
  Lesson lesson,
  int index,
  int count, {
  bool completed = false,
}) => lessonRoute<bool>(
  (context) => ListeningLessonPage(lesson: lesson, completed: completed),
);

class ListeningLessonPage extends StatefulWidget {
  const ListeningLessonPage({
    super.key,
    required this.lesson,
    this.completed = false,
  });

  final Lesson lesson;
  final bool completed;

  @override
  State<ListeningLessonPage> createState() => _ListeningLessonPageState();
}

class _ListeningLessonPageState extends State<ListeningLessonPage>
    with TickerProviderStateMixin {
  final _shell = GlobalKey<LessonShellState>();
  late final _entry = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );
  late final _theme = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 450),
    value: readingLight.value ? 1 : 0,
  );
  // Question change: card content and bottom row slide (RTL: next from the
  // left), as 08/10.
  late final _swap = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 360),
    value: 1,
  );
  // Feedback: the waveform gives way to the explanation strip.
  late final _fb = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 380),
  );
  // Wrong answer: the chosen pill shakes.
  late final _shake = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 420),
  );

  final _player = AudioPlayer()..setReleaseMode(ReleaseMode.stop);

  /// Guided voice (Gemini TTS «Orus», calm style, owner 2026-11-26): short
  /// lines that help without giving the answer; never Quran text.
  final _voice = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  Completer<void>? _voiceDone;
  int _praise = 0;
  final _subs = <StreamSubscription<Object?>>[];

  /// Audio position (ms): drives only the waveform painter and the lit word.
  final _pos = ValueNotifier<int>(0);
  final _playing = ValueNotifier<bool>(false);
  final _lit = ValueNotifier<int>(-1);
  String? _source;
  int? _stopAt;
  int? _seekTo;

  ListenContent? _content;
  bool _loaded = false;
  int _index = 0;
  int _dir = 1;
  int? _pick;
  bool? _ok;
  // «Find» page: 0 = tap the word, 1 = choose its letter.
  int _phase = 0;
  int? _fWord;
  bool? _fWordOk;
  int? _fLetter;
  bool? _fLetterOk;
  int _fEarned = 0;
  int _points = 0;
  int _answered = 0;
  bool _finishing = false;
  bool _left = false;

  // Pages: the ayat of the rule first (rule lesson), then the questions.
  int get _nSteps => _content?.steps.length ?? 0;
  int get _nFinds => _content?.finds.length ?? 0;
  int get _total => _nSteps + _nFinds + (_content?.questions.length ?? 0);
  bool get _isStep => _index < _nSteps;
  bool get _isFind => _index >= _nSteps && _index < _nSteps + _nFinds;
  ListenStep? get _step => _isStep ? _content?.steps[_index] : null;
  ListenStep? get _find => _isFind ? _content!.finds[_index - _nSteps] : null;
  ListenQuestion? get _q => _content == null || _index < _nSteps + _nFinds
      ? null
      : _content!.questions[_index - _nSteps - _nFinds];
  ListenAyah? get _ayah => _step?.ayah ?? _find?.ayah ?? _q?.ayah;

  /// The rule mark of the current «find» page and its letter clusters.
  ListenMark? get _fMark => _find?.marks.first;
  List<(int, int)> get _fClusters {
    final m = _fMark;
    return m == null ? const [] : letterClusters(_ayah!.words[m.word].text);
  }

  int get _fRightLetter => _fClusters.indexWhere((c) => c.$1 == _fMark!.from);

  /// Colour of the rule's words (the tajweed wheel, `DESIGN-SYSTEM.md`).
  Color get _ruleColour => switch (_content?.rule?.colour) {
    'cyan' => TajweedColors.qalqala,
    'red' => TajweedColors.maddWajib,
    'orange' => TajweedColors.maddArid,
    'purple' => TajweedColors.maddLazim,
    'yellow' => TajweedColors.maddSila,
    'blue' => TajweedColors.tafkhim,
    'grey' => TajweedColors.silent,
    _ => TajweedColors.ghunna,
  };

  /// Points earned in this lesson (for the end of lesson, screen 24).
  int get points => _points;

  @override
  void initState() {
    super.initState();
    if (readingStartLight) {
      readingLight.value = true;
      _theme.value = 1;
    }
    readingLight.addListener(_onTheme);
    _subs
      ..add(
        _player.onPositionChanged.listen((d) {
          final ms = d.inMilliseconds;
          final seek = _seekTo;
          if (seek != null) {
            if (ms < seek - 300) {
              _player.seek(Duration(milliseconds: seek));
              return;
            }
            _seekTo = null;
          }
          _pos.value = ms;
          _logAudio('pos $_source $ms');
          final a = _ayah;
          if (a != null) _lit.value = a.wordAt(ms);
          final stop = _stopAt;
          if (stop != null && ms >= stop) {
            _stopAt = null;
            _player.pause();
            _playing.value = false;
            _lit.value = -1;
          }
        }),
      )
      ..add(
        _voice.onPlayerComplete.listen((_) {
          final d = _voiceDone;
          if (d != null && !d.isCompleted) d.complete();
        }),
      )
      ..add(
        _player.onPlayerComplete.listen((_) {
          final a = _ayah;
          _playing.value = false;
          _lit.value = -1;
          _stopAt = null;
          if (a != null) _pos.value = a.durationMs;
        }),
      );
    ListenContent.load(widget.lesson.id).then((c) {
      if (!mounted) return;
      setState(() {
        _content = c;
        _loaded = true;
        if (c != null) _applyReviewAids(c);
      });
      if (c != null && listenStartAt == null && listenStartState == null) {
        // The guide speaks, then the verse plays by itself.
        Future<void>.delayed(const Duration(milliseconds: 700), () async {
          if (!mounted || _shell.currentState?.paused == true) return;
          await _say(c.narration['intro']);
          if (mounted && _index == 0 && _shell.currentState?.paused != true) {
            _play();
          }
        });
      }
    });
  }

  void _applyReviewAids(ListenContent c) {
    _index = listenStartQuestion.clamp(0, _total - 1);
    _answered = _index;
    final a = _ayah!;
    final at = listenStartAt;
    if (at != null) {
      _pos.value = (a.durationMs * at).round();
      _lit.value = a.wordAt(_pos.value);
    }
    final m = _fMark;
    if (m != null) {
      final s = listenStartState;
      if (s == 'word' || s == 'ok' || s == 'ko') {
        _fWord = m.word;
        _fWordOk = true;
        _fEarned = c.points;
        _phase = 1;
      } else if (listenStartPick != null) {
        _fWord = listenStartPick;
      }
      if (s == 'ok' || s == 'ko') {
        final right = _fRightLetter;
        _fLetter = s == 'ok' ? right : (right + 1) % _fClusters.length;
        _fLetterOk = s == 'ok';
        if (_fLetterOk!) _fEarned += c.points;
        _answered++;
        _fb.value = 1;
      }
      return;
    }
    final q = _q;
    if (q == null) return;
    final pick = listenStartPick;
    if (pick != null && pick < q.options.length) _pick = pick;
    final s = listenStartState;
    if (s == 'ok' || s == 'ko') {
      _pick ??= s == 'ok'
          ? q.options.indexOf(q.correct)
          : q.options.indexWhere((o) => o != q.correct);
      _ok = q.options[_pick!] == q.correct;
      if (_ok!) _points += c.points;
      _answered++;
      _fb.value = 1;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_entry.value > 0 || _entry.isAnimating) return;
    Future.any([
      Future.wait([
        for (final a in const [
          'assets/ui/reading/lattice_tile.webp',
          'assets/ui/reading/badge_line.webp',
          'assets/ui/reading/badge_fill.webp',
          'assets/ui/reading/arch.webp',
          'assets/ui/listening/headphones.webp',
          'assets/ui/decor/mosque.webp',
        ])
          precacheImage(AssetImage(a), context),
      ]),
      Future<void>.delayed(const Duration(milliseconds: 400)),
    ]).whenComplete(() {
      if (mounted && !_entry.isAnimating && _entry.value == 0) {
        _entry.forward();
      }
    });
  }

  @override
  void dispose() {
    readingLight.removeListener(_onTheme);
    for (final s in _subs) {
      s.cancel();
    }
    _player.dispose();
    _voice.dispose();
    _pos.dispose();
    _playing.dispose();
    _lit.dispose();
    _entry.dispose();
    _theme.dispose();
    _swap.dispose();
    _fb.dispose();
    _shake.dispose();
    super.dispose();
  }

  void _onTheme() => readingLight.value ? _theme.forward() : _theme.reverse();

  void _leave(bool done) {
    if (_left || !mounted) return;
    if (ModalRoute.of(context)?.isCurrent != true) return;
    _left = true;
    _player.stop();
    _voice.stop();
    Navigator.of(context).pop(done);
  }

  // ---- Audio ---------------------------------------------------------------

  /// Plays the verse of the current question from [fromMs]; with [toMs] it
  /// stops there (the asked word after an answer).
  Future<void> _play({int fromMs = 0, int? toMs}) async {
    final a = _ayah;
    // A replay still pending when the lesson ends must not cover the guide's
    // closing line (owner, 2026-11-26: the two voices overlapped at the end).
    if (a == null || _finishing || _left) return;
    _stopAt = toMs;
    _playing.value = true;
    _seekTo = fromMs > 0 ? fromMs : null;
    try {
      // play(position:) starts there; a seek before resume() was sometimes
      // ignored after the end of the verse (the word replay restarted the
      // verse). [_seekTo] corrects a late start in the position listener.
      _source = a.audio;
      // A new start while the verse is still playing stalled on web: stop
      // first (the word replay right after an answer).
      await _player.stop();
      await _player.play(
        AssetSource(a.audio),
        position: Duration(milliseconds: fromMs),
      );
    } catch (_) {
      _playing.value = false;
    }
  }

  void _togglePlay() {
    final a = _ayah;
    if (a == null) return;
    _stopVoice();
    if (_playing.value) {
      _player.pause();
      _playing.value = false;
      _stopAt = null;
      return;
    }
    // From the start when it had ended (or after the word replay).
    final atEnd = _pos.value >= a.durationMs - 150 || _pos.value == 0;
    if (atEnd || _ok != null || _fWordOk != null) {
      _play();
    } else {
      _playing.value = true;
      _player.resume();
    }
  }

  // ---- Question flow -------------------------------------------------------

  void _select(int i) {
    if (_ok != null || _finishing) return;
    Haptics.tick();
    setState(() => _pick = i);
  }

  void _selectWord(int i) {
    if (!_isFind || _phase != 0 || _fWordOk != null || _finishing) return;
    Haptics.tick();
    setState(() => _fWord = i);
  }

  void _selectLetter(int k) {
    if (!_isFind || _phase != 1 || _fLetterOk != null || _finishing) return;
    Haptics.tick();
    setState(() => _fLetter = k);
  }

  void _answerFeedback(bool ok) {
    if (ok) {
      Sounds.correct();
      _logAudio('sfx test_correct');
      Haptics.success();
    } else {
      Sounds.wrong();
      _logAudio('sfx test_wrong');
      Haptics.denied();
      _shake.forward(from: 0);
    }
  }

  void _replayRuleWord({String? voice}) {
    final w = _ayah!.words[_fMark!.word];
    final page = _index;
    Future<void>.delayed(const Duration(milliseconds: 650), () async {
      if (voice != null) await _say(voice);
      if (mounted && _isFind && _index == page) {
        _play(fromMs: w.startMs, toMs: w.endMs + 150);
      }
    });
  }

  /// The guide says line [key] (`audio/narration/orus/<key>.mp3`); completes
  /// when it has finished (at most 9 s), at once when there is no line.
  Future<void> _say(String? key) async {
    if (key == null || !mounted || (_finishing && key != 'done')) return;
    _player.pause();
    _playing.value = false;
    final done = _voiceDone = Completer<void>();
    _logAudio('voice $key');
    try {
      await _voice.play(AssetSource('audio/narration/orus/$key.mp3'));
    } catch (_) {
      return;
    }
    await done.future.timeout(const Duration(seconds: 9), onTimeout: () {});
  }

  void _stopVoice() {
    _voice.stop();
    final d = _voiceDone;
    if (d != null && !d.isCompleted) d.complete();
  }

  /// Praise after a right answer (two lines in turn), or the gentle «listen
  /// again» after a wrong one.
  String _feedbackLine(bool ok) {
    if (!ok) return 'wrong-1';
    return (_praise++).isEven ? 'correct-1' : 'correct-2';
  }

  /// «Find» page: first the word (then the letter question appears at once,
  /// on the right word), then the letter.
  void _confirmFind() {
    final c = _content!, m = _fMark!;
    if (_phase == 0) {
      final w = _fWord;
      if (w == null) {
        Haptics.denied();
        return;
      }
      final ok = w == m.word;
      setState(() {
        _fWordOk = ok;
        if (ok) _fEarned += c.points;
      });
      _answerFeedback(ok);
      _replayRuleWord();
      final page = _index;
      Future<void>.delayed(const Duration(milliseconds: 1300), () {
        if (mounted && _isFind && _phase == 0) setState(() => _phase = 1);
      });
      // Then the guide asks for the letter, once the word has been heard.
      final rw = _ayah!.words[_fMark!.word];
      Future<void>.delayed(
        Duration(milliseconds: 900 + rw.endMs - rw.startMs + 300),
        () {
          if (mounted && _index == page && _fLetterOk == null) {
            _say(_content!.narration['letter']);
          }
        },
      );
      return;
    }
    if (_fLetterOk != null) {
      _next();
      return;
    }
    final k = _fLetter;
    if (k == null) {
      Haptics.denied();
      return;
    }
    final ok = k == _fRightLetter;
    setState(() {
      _fLetterOk = ok;
      _answered++;
      if (ok) _fEarned += c.points;
      _points += _fEarned;
    });
    _answerFeedback(ok);
    _fb.forward(from: 0);
    _replayRuleWord(voice: _feedbackLine(ok));
  }

  void _confirm() {
    if (_isStep) {
      _next();
      return;
    }
    if (_isFind) {
      _confirmFind();
      return;
    }
    final c = _content, q = _q;
    if (c == null || q == null) return;
    if (_ok != null) {
      _next();
      return;
    }
    final pick = _pick;
    if (pick == null) {
      Haptics.denied();
      return;
    }
    final ok = q.options[pick] == q.correct;
    setState(() {
      _ok = ok;
      _answered++;
      if (ok) _points += c.points;
    });
    if (ok) {
      Sounds.correct();
      _logAudio('sfx test_correct');
      Haptics.success();
    } else {
      Sounds.wrong();
      _logAudio('sfx test_wrong');
      Haptics.denied();
      _shake.forward(from: 0);
    }
    _fb.forward(from: 0);
    // The guide answers, then the asked word plays again.
    final w = q.ayah.words[q.word];
    final page = _index;
    Future<void>.delayed(const Duration(milliseconds: 650), () async {
      await _say(_feedbackLine(ok));
      if (mounted && _ok != null && _index == page) {
        _play(fromMs: w.startMs, toMs: w.endMs + 150);
      }
    });
  }

  void _next() {
    final c = _content;
    if (c == null || _finishing) return;
    if (_isStep) _answered++; // an ayah of the rule has been heard
    if (_index >= _total - 1) {
      _complete();
      return;
    }
    Haptics.tick();
    _player.stop();
    _stopVoice();
    setState(() {
      _dir = 1;
      _index++;
      _pick = null;
      _ok = null;
      _resetFind();
    });
    _pos.value = 0;
    _lit.value = -1;
    _playing.value = false;
    _fb.value = 0;
    _swap.forward(from: 0);
    final page = _index;
    Future<void>.delayed(const Duration(milliseconds: 450), () async {
      if (!mounted || _shell.currentState?.paused == true) return;
      // Entering the questions: the guide explains them first.
      if (_index == _nSteps && _nFinds > 0) {
        await _say(_content!.narration['find']);
      }
      if (mounted && _index == page && _shell.currentState?.paused != true) {
        _play();
      }
    });
  }

  void _restart() {
    _player.stop();
    _stopVoice();
    setState(() {
      _index = 0;
      _answered = 0;
      _points = 0;
      _pick = null;
      _ok = null;
      _resetFind();
      _dir = -1;
    });
    _pos.value = 0;
    _lit.value = -1;
    _playing.value = false;
    _fb.value = 0;
    _swap.forward(from: 0);
    Future<void>.delayed(const Duration(milliseconds: 450), () {
      if (mounted) _play();
    });
  }

  void _resetFind() {
    _phase = 0;
    _fWord = null;
    _fWordOk = null;
    _fLetter = null;
    _fLetterOk = null;
    _fEarned = 0;
  }

  Future<void> _complete() async {
    if (_finishing || _left) return;
    _finishing = true;
    _player.stop();
    _stopVoice();
    Sounds.passed();
    _logAudio('sfx test_passed');
    Haptics.lessonDone();
    // The guide closes the lesson while the light runs along the capsule.
    await Future.wait([
      Future<void>.delayed(
        const Duration(milliseconds: 700),
        () => _say('done'),
      ),
      _shell.currentState?.celebrate() ?? Future<void>.value(),
    ]);
    _leave(true);
  }

  // Entry: header, card, play button, bottom row (70 ms steps), as 08.
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

  Widget _swapIn(Widget child) => AnimatedBuilder(
    animation: _swap,
    child: child,
    builder: (context, child) {
      final t = Curves.easeOutCubic.transform(_swap.value);
      return Opacity(
        opacity: t,
        child: Transform.translate(
          offset: Offset(-40 * (1 - t) * _dir, 0),
          child: child,
        ),
      );
    },
  );

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _theme,
      builder: (context, _) {
        final light = Curves.easeInOut.transform(_theme.value);
        return LessonShell(
          key: _shell,
          step: _answered,
          total: math.max(1, _total),
          light: light,
          onBack: () => _leave(false),
          onRestart: _restart,
          onPausedChanged: (p) {
            if (p) _stopVoice();
            if (p && _playing.value) {
              _player.pause();
              _playing.value = false;
            }
          },
          child: LayoutBuilder(
            builder: (context, box) =>
                _page(box, LessonPal(light), box.maxHeight / 100),
          ),
        );
      },
    );
  }

  Widget _page(BoxConstraints box, LessonPal p, double u) {
    final w = box.maxWidth;
    final cx = w / 2;
    final card = Rect.fromLTRB(
      u * ListenMetrics.side,
      u * ListenMetrics.cardTop,
      w - u * ListenMetrics.side,
      u * ListenMetrics.cardBottom,
    );
    final q = _q;
    final step = _step;
    final last = _index >= _total - 1;
    final playRect = switch (listenPlayPos) {
      'a' => Rect.fromCircle(
        center: Offset(
          card.left + u * 12,
          card.top + u * ListenMetrics.verseCy,
        ),
        radius: u * 5.5,
      ),
      'b' => Rect.fromCircle(
        center: Offset(
          cx - u * (ListenMetrics.waveHalf + 7.5),
          card.top + u * ListenMetrics.waveCy,
        ),
        radius: u * 4.6,
      ),
      'c' => Rect.fromCircle(
        center: Offset(
          u * (ListenMetrics.confirmLeft + ListenMetrics.confirmW + 8.5),
          u * ListenMetrics.confirmCy,
        ),
        radius: u * 5.3,
      ),
      _ => Rect.fromCircle(
        center: Offset(cx, u * ListenMetrics.playCy),
        radius: u * ListenMetrics.playD / 2,
      ),
    };
    final pending = _find != null
        ? _fLetterOk == null
        : step == null && _ok == null;
    return Stack(
      fit: StackFit.expand,
      clipBehavior: Clip.hardEdge,
      children: [
        RepaintBoundary(
          key: const ValueKey('bg'),
          child: LessonBackground(p: p, u: u),
        ),
        RepaintBoundary(
          key: const ValueKey('header'),
          child: _enter(
            0,
            LessonHeader(
              p: p,
              u: u,
              cx: cx,
              s: ListenMetrics.header,
              title: _content?.title ?? widget.lesson.title,
            ),
          ),
        ),
        Positioned.fromRect(
          key: const ValueKey('card'),
          rect: card,
          child: _enter(1, _card(p, u, card)),
        ),
        Positioned(
          key: const ValueKey('play'),
          left: playRect.left,
          top: playRect.top,
          width: playRect.width,
          height: playRect.height,
          child: _enter(
            2,
            ValueListenableBuilder<bool>(
              valueListenable: _playing,
              builder: (context, playing, _) => LessonRoundButton(
                u: u,
                label: playing ? 'إيقاف' : 'استمع',
                glyph: PillGlyph.play,
                glyphSize: 4.6,
                light: p.t,
                onTap: _togglePlay,
                child: playing
                    ? SizedBox(
                        width: u * 3.6,
                        height: u * 4.2,
                        child: CustomPaint(
                          painter: _PausePainter(
                            p.c(titleCream, RateelColors.readLInk),
                          ),
                        ),
                      )
                    : null,
              ),
            ),
          ),
        ),
        Positioned(
          key: const ValueKey('line'),
          left: u * ListenMetrics.lineInset,
          right: u * ListenMetrics.lineInset,
          top: u * ListenMetrics.lineY - math.max(1, u * 0.12) / 2,
          height: math.max(1, u * 0.12),
          child: _enter(
            3,
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    p
                        .c(RateelColors.listenLine, RateelColors.readLSeparator)
                        .withValues(alpha: 0),
                    p.c(RateelColors.listenLine, RateelColors.readLSeparator),
                    p.c(RateelColors.listenLine, RateelColors.readLSeparator),
                    p
                        .c(RateelColors.listenLine, RateelColors.readLSeparator)
                        .withValues(alpha: 0),
                  ],
                  stops: const [0, 0.08, 0.92, 1],
                ),
              ),
            ),
          ),
        ),
        if (step != null)
          Positioned(
            key: const ValueKey('rule'),
            right: u * ListenMetrics.qRight,
            left:
                u *
                (ListenMetrics.confirmLeft +
                    ListenMetrics.confirmW +
                    (listenPlayPos == 'c' ? 16 : 4)),
            top: u * (ListenMetrics.rowCy - ListenMetrics.pillH / 2),
            height: u * ListenMetrics.pillH,
            child: _enter(3, _swapIn(_ruleRow(p, u, step))),
          ),
        if (_find != null) ..._findRow(p, u),
        if (q != null) ...[
          Positioned(
            key: const ValueKey('question'),
            right: u * ListenMetrics.qRight,
            width:
                u *
                (ListenMetrics.pillsRight -
                    ListenMetrics.qRight -
                    ListenMetrics.pillGap),
            top: u * (ListenMetrics.rowCy - 6.45),
            height: u * 12,
            child: _enter(
              3,
              _swapIn(
                Align(
                  alignment: Alignment.centerRight,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerRight,
                    child: Text(
                      q.prompt,
                      textDirection: TextDirection.rtl,
                      maxLines: 1,
                      style: readex(
                        u * ListenMetrics.qSize,
                        weight: 600,
                        color: p.c(
                          RateelColors.leaderText,
                          RateelColors.readLInk,
                        ),
                      ).copyWith(height: 1.3),
                    ),
                  ),
                ),
              ),
            ),
          ),
          for (var i = 0; i < q.options.length; i++)
            Positioned(
              key: ValueKey('pill$i'),
              right:
                  u *
                  (ListenMetrics.pillsRight +
                      i * (ListenMetrics.pillW + ListenMetrics.pillGap)),
              top: u * (ListenMetrics.rowCy - ListenMetrics.pillH / 2),
              width: u * ListenMetrics.pillW,
              height: u * ListenMetrics.pillH,
              child: _enter(3, _swapIn(_answerPill(p, u, q, i))),
            ),
        ],
        Positioned(
          key: const ValueKey('confirm'),
          left: u * ListenMetrics.confirmLeft,
          top: u * (ListenMetrics.confirmCy - ListenMetrics.confirmH / 2),
          width: u * ListenMetrics.confirmW,
          height: u * ListenMetrics.confirmH,
          child: _enter(
            3,
            LessonPill(
              u: u,
              label: pending ? 'تأكيد' : (last ? 'إنهاء' : 'التالي'),
              glyph: pending || last ? PillGlyph.check : PillGlyph.forward,
              height: ListenMetrics.confirmH,
              light: p.t,
              onTap: _confirm,
            ),
          ),
        ),
      ],
    );
  }

  /// Bottom row of a «find» page (owner, 2026-11-26): the question on the
  /// right; phase 0 one wide pill with the word tapped in the verse, phase 1
  /// the letters of the word, one pill each.
  List<Widget> _findRow(LessonPal p, double u) {
    final rule = _content!.rule!;
    final a = _ayah!;
    final m = _fMark!;
    Widget question(String t) => Align(
      alignment: Alignment.centerRight,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerRight,
        child: Text(
          t,
          textDirection: TextDirection.rtl,
          maxLines: 1,
          style: readex(
            u * ListenMetrics.qSize,
            weight: 600,
            color: p.c(RateelColors.leaderText, RateelColors.readLInk),
          ).copyWith(height: 1.3),
        ),
      ),
    );
    final top = u * (ListenMetrics.rowCy - ListenMetrics.pillH / 2);
    return [
      Positioned(
        key: const ValueKey('question'),
        right: u * ListenMetrics.qRight,
        width:
            u *
            (ListenMetrics.pillsRight -
                ListenMetrics.qRight -
                ListenMetrics.pillGap),
        top: u * (ListenMetrics.rowCy - 6.45),
        height: u * 12,
        child: _enter(
          3,
          _swapIn(
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: KeyedSubtree(
                key: ValueKey(_phase),
                child: question(
                  _phase == 0
                      ? 'في أيّ كلمة سمعت ${rule.name}؟'
                      : 'أيّ حرف فيه ${rule.name}؟',
                ),
              ),
            ),
          ),
        ),
      ),
      if (_phase == 0)
        Positioned(
          key: const ValueKey('fword'),
          right: u * ListenMetrics.pillsRight,
          top: top,
          width: u * (ListenMetrics.pillW * 2 + ListenMetrics.pillGap),
          height: u * ListenMetrics.pillH,
          child: _enter(
            3,
            _swapIn(
              _AnswerPill(
                u: u,
                p: p,
                label: _fWord == null
                    ? 'اضغط على الكلمة في الآية'
                    : a.words[_fWord!].text,
                quran: _fWord != null,
                hint: _fWord == null,
                state: _fWordOk == null
                    ? (_fWord == null ? _PillState.idle : _PillState.selected)
                    : (_fWordOk! ? _PillState.right : _PillState.wrong),
                onTap: () {},
              ),
            ),
          ),
        )
      else
        for (final (k, c) in _fClusters.indexed)
          Positioned(
            key: ValueKey('fletter$k'),
            right:
                u *
                (ListenMetrics.pillsRight +
                    k * (ListenMetrics.letterW + ListenMetrics.letterGap)),
            top: top,
            width: u * ListenMetrics.letterW,
            height: u * ListenMetrics.pillH,
            child: _LetterIn(
              delay: k,
              child: _letterPill(
                p,
                u,
                k,
                a.words[m.word].text.substring(c.$1, c.$2),
              ),
            ),
          ),
    ];
  }

  Widget _letterPill(LessonPal p, double u, int k, String letter) {
    final answered = _fLetterOk != null;
    final state = !answered
        ? (_fLetter == k ? _PillState.selected : _PillState.idle)
        : k == _fRightLetter
        ? _PillState.right
        : k == _fLetter
        ? _PillState.wrong
        : _PillState.dim;
    final pill = _AnswerPill(
      u: u,
      p: p,
      label: letter,
      quran: true,
      letter: true,
      state: state,
      mark: false,
      onTap: () => _selectLetter(k),
    );
    if (state != _PillState.wrong) return pill;
    return AnimatedBuilder(
      animation: _shake,
      child: pill,
      builder: (context, child) => Transform.translate(
        offset: Offset(
          math.sin(_shake.value * math.pi * 6) * u * 1.0 * (1 - _shake.value),
          0,
        ),
        child: child,
      ),
    );
  }

  // ---- Card ------------------------------------------------------------------

  Widget _card(LessonPal p, double u, Rect card) {
    final r = u * ListenMetrics.cardRadius;
    final q = _q;
    final a = _ayah;
    return Stack(
      fit: StackFit.expand,
      children: [
        RepaintBoundary(child: CustomPaint(painter: GoldCardPainter(p, u, r))),
        Positioned(
          left: 0,
          right: 0,
          top: u * ListenMetrics.bandTop,
          bottom: 0,
          child: RepaintBoundary(
            child: ClipRRect(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(r)),
              child: LatticeField(
                p: p,
                u: u,
                cell: ReadMetrics.cell,
                opacity: p.d(0.2, 0.4),
                mask: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x00000000), Color(0xFF000000)],
                  stops: [0.0, 0.85],
                ),
              ),
            ),
          ),
        ),
        if (a == null)
          Center(
            child: Text(
              _loaded ? 'عذراً، لا يمكن تحميل محتوى الدرس' : '',
              textDirection: TextDirection.rtl,
              style: readex(
                u * 4.2,
                weight: 400,
                color: p.c(RateelColors.cream, RateelColors.readLInk),
              ),
            ),
          )
        else ...[
          Positioned(
            right: u * (ListenMetrics.badgeRight - ListenMetrics.badgeH / 2),
            top: u * (ListenMetrics.badgeCy - ListenMetrics.badgeH / 2),
            width: u * ListenMetrics.badgeH,
            height: u * ListenMetrics.badgeH,
            child: _swapIn(LessonBadge(p: p, u: u, number: _index + 1)),
          ),
          Positioned(
            left: u * ListenMetrics.surahLeft,
            top: u * (ListenMetrics.surahCy - 3),
            height: u * 6,
            child: Center(
              child: Text(
                '${a.surah} · ${_content!.reciter}',
                textDirection: TextDirection.rtl,
                style: readex(
                  u * ListenMetrics.surahSize,
                  weight: 500,
                  color: p.c(RateelColors.leaderText, RateelColors.readLInk),
                ).copyWith(height: 1.2),
              ),
            ),
          ),
          Positioned(
            left: u * (listenPlayPos == 'a' ? 22 : 16),
            right: u * 16,
            top: u * (ListenMetrics.verseCy - (_playBelow ? 10 : 12.8)),
            height: u * (_playBelow ? 20 : 25.6),
            child: _swapIn(
              RepaintBoundary(
                child: Center(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: ValueListenableBuilder<int>(
                      valueListenable: _lit,
                      builder: (context, lit, _) => _verse(p, u, a, lit),
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Waveform, then the explanation after the answer.
          Positioned(
            left: 0,
            right: 0,
            top: u * (ListenMetrics.waveCy - 4.5),
            height: u * 9,
            child: AnimatedBuilder(
              animation: _fb,
              builder: (context, _) {
                final f = Curves.easeOut.transform(_fb.value);
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    if (f < 1)
                      Opacity(
                        opacity: 1 - f,
                        child: RepaintBoundary(
                          child: CustomPaint(
                            painter: _WavePainter(
                              pos: _pos,
                              ayah: a,
                              u: u,
                              played: p.c(
                                RateelColors.listenWavePlayed,
                                RateelColors.readLCopper,
                              ),
                              rest: p.c(
                                RateelColors.listenWaveRest,
                                RateelColors.readLDotOff,
                              ),
                            ),
                          ),
                        ),
                      ),
                    if (f > 0 && _ok != null && q != null)
                      Opacity(
                        opacity: f,
                        child: Transform.translate(
                          offset: Offset(0, u * 2 * (1 - f)),
                          child: _explanation(
                            p,
                            u,
                            ok: _ok!,
                            lead: _ok!
                                ? 'أحسنت.'
                                : 'الإجابة الصحيحة: ${q.correct}.',
                            text: q.explanation,
                            points: _ok! ? _content!.points : 0,
                          ),
                        ),
                      ),
                    if (f > 0 && _fLetterOk != null)
                      Opacity(
                        opacity: f,
                        child: Transform.translate(
                          offset: Offset(0, u * 2 * (1 - f)),
                          child: _findExplanation(p, u),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  /// The verse word by word (RTL). Rule lesson: the letters that carry the
  /// rule in their tajweed colour from the start (owner, 2026-11-26: the
  /// letter, not the word); quiz: the asked word in gold (a colour would give
  /// the answer away). Every word lights up in a soft gold box while it is
  /// recited (lesson-production video); the rule letter then glows with its
  /// own, brighter light.
  Widget _verse(LessonPal p, double u, ListenAyah a, int lit) {
    final ink = p.c(RateelColors.leaderText, RateelColors.readLInk);
    final gold = p.c(RateelColors.listenWord, RateelColors.readLTitle);
    final step = _step;
    final asked = _q?.word;
    final rule = _ruleColour;
    TextStyle base(Color c) => TextStyle(
      fontFamily: 'AmiriQuran',
      fontSize: u * ListenMetrics.verseSize,
      // With the room freed below the card the light box takes the whole
      // word, harakat above and kasra below included (owner, 2026-11-26).
      height: _playBelow ? 1.3 : 1.8,
      color: c,
      shadows: p.t > 0.5 ? null : titleShadows(u),
    );
    final fm = _fMark;
    // «Find» page: no colours until the answer; then the right letter in the
    // rule colour, a wrong one red; the chosen letter gold before.
    Color? findLetter(int k) {
      if (_fLetterOk == null) return k == _fLetter ? gold : null;
      if (k == _fRightLetter) return rule;
      if (k == _fLetter) return RateelColors.testKoDiscTop;
      return null;
    }

    // Glow mode: the recited word's letters light up themselves.
    final glowInk = Color.lerp(gold, Colors.white, p.t > 0.5 ? 0 : 0.3)!;
    List<Shadow>? glowShadows() => p.t > 0.5
        ? [Shadow(color: gold.withValues(alpha: 0.55), blurRadius: u * 1.4)]
        : [
            Shadow(color: gold.withValues(alpha: 0.95), blurRadius: u * 1.0),
            Shadow(color: gold.withValues(alpha: 0.6), blurRadius: u * 2.8),
          ];
    TextStyle wordStyle(bool on, Color colour) => on && _glow
        ? base(glowInk).copyWith(shadows: glowShadows())
        : base(colour);

    InlineSpan word(int i, String text) {
      final on = i == lit;
      final colour = i == asked || on ? gold : ink;
      if (fm != null) {
        if (_phase == 1 && i == fm.word) {
          return TextSpan(
            style: wordStyle(on, colour),
            children: [
              for (final (k, c) in letterClusters(text).indexed)
                TextSpan(
                  text: text.substring(c.$1, c.$2),
                  style: TextStyle(
                    color: findLetter(k),
                    shadows: _fLetterOk != null && k == _fRightLetter
                        ? [
                            Shadow(color: rule, blurRadius: u * 1.2),
                            Shadow(
                              color: rule.withValues(alpha: 0.8),
                              blurRadius: u * 2.6,
                            ),
                          ]
                        : null,
                  ),
                ),
            ],
          );
        }
        return TextSpan(text: text, style: wordStyle(on, colour));
      }
      final m = step?.markOf(i);
      if (m == null) return TextSpan(text: text, style: wordStyle(on, colour));
      // The rule letter: wheel colour; recited → lighter, with a halo.
      final letter = on ? Color.lerp(rule, Colors.white, 0.35)! : rule;
      return TextSpan(
        style: wordStyle(on, colour),
        children: [
          TextSpan(text: text.substring(0, m.from)),
          TextSpan(
            text: text.substring(m.from, m.to),
            style: TextStyle(
              color: letter,
              shadows: on
                  ? [
                      Shadow(color: rule, blurRadius: u * 1.2),
                      Shadow(
                        color: rule.withValues(alpha: 0.8),
                        blurRadius: u * 2.6,
                      ),
                    ]
                  : (p.t > 0.5 ? null : titleShadows(u)),
            ),
          ),
          TextSpan(text: text.substring(m.to)),
        ],
      );
    }

    // Light box of a word: recited (gold); on a «find» page also the word
    // tapped (gold), then the right word green and a wrong one red.
    Color box(int i) {
      if (fm != null && _fWordOk != null) {
        if (i == fm.word) return RateelColors.testOkRim;
        if (i == _fWord) return RateelColors.testKoRim;
      }
      return RateelColors.listenWord;
    }

    bool boxOn(int i) =>
        listenLitAll ||
        (i == lit && !_glow) ||
        (fm != null &&
            ((_fWordOk == null && i == _fWord) ||
                (_fWordOk != null && (i == fm.word || i == _fWord))));

    return Row(
      mainAxisSize: MainAxisSize.min,
      textDirection: TextDirection.rtl,
      children: [
        for (final (i, w) in a.words.indexed) ...[
          if (i > 0) SizedBox(width: u * 3.0),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: fm == null ? null : () => _selectWord(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              // Amiri draws the tails (س، ن) and the kasra below its line box
              // and to the left: the light box gets room on those sides, so
              // the whole word sits inside it (owner, 2026-11-26).
              padding: _playBelow
                  ? EdgeInsets.symmetric(horizontal: u * 1.0)
                  : EdgeInsets.fromLTRB(u * 3.4, u * 0.4, u * 1.8, u * 3.2),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(u * 1.6),
                color: box(i).withValues(
                  alpha: boxOn(i) ? 0.18 * (1 - p.t) + 0.2 * p.t : 0,
                ),
                border: Border.all(
                  color: box(i).withValues(alpha: boxOn(i) ? 0.55 : 0),
                  width: math.max(1, u * 0.18),
                ),
                boxShadow: [
                  if (boxOn(i) && p.t < 0.5)
                    BoxShadow(
                      color: box(i).withValues(alpha: 0.25),
                      blurRadius: u * 1.6,
                    ),
                ],
              ),
              child: _withHarakat(p, u, word(i, w.text), step?.markOf(i)),
            ),
          ),
        ],
      ],
    );
  }

  Widget _findExplanation(LessonPal p, double u) {
    final m = _fMark!;
    final w = _ayah!.words[m.word].text;
    final letter = _plain(w.substring(m.from, m.to), keepShadda: true);
    final word = _plain(w, keepShadda: true);
    final rule = _content!.rule!.name;
    return _explanation(
      p,
      u,
      ok: _fLetterOk!,
      lead: _fLetterOk! ? 'أحسنت.' : 'الحرف الصحيح:',
      text: _fLetterOk!
          ? '$rule في حرف «$letter» من كلمة «$word».'
          : '«$letter» من كلمة «$word».',
      points: _fEarned,
    );
  }

  /// Uthmani word for a line in Readex: without its small marks and with a
  /// plain alif for the alif wasla.
  static String _plain(String w, {bool keepShadda = false}) {
    final b = StringBuffer();
    for (final c in w.runes) {
      if (c == 0x0671) {
        b.writeCharCode(0x0627);
      } else if (c == 0x0651 && keepShadda) {
        b.writeCharCode(c);
      } else if ((c >= 0x064B && c <= 0x065F) ||
          c == 0x0670 ||
          (c >= 0x06D6 && c <= 0x06ED)) {
        continue;
      } else {
        b.writeCharCode(c);
      }
    }
    return b.toString();
  }

  /// The word, and over its rule letter one dot per haraka that lights up in
  /// turn while the rule is held in the recitation (owner, 2026-11-27: shows
  /// that the ghunna lasts longer than the other letters).
  Widget _withHarakat(LessonPal p, double u, InlineSpan span, ListenMark? m) {
    final text = Text.rich(span, textDirection: TextDirection.rtl);
    if (m == null || m.harakat == 0 || m.holdStart == null) return text;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        text,
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(
              painter: _HarakatDots(
                span: span,
                mark: m,
                pos: _pos,
                u: u,
                colour: _ruleColour,
                dim: p
                    .c(RateelColors.leaderText, RateelColors.readLInk)
                    .withValues(alpha: 0.22),
                light: p.t > 0.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Bottom row of a rule ayah: the rule pill (its colour dot and name) and
  /// one line saying where the rule is.
  Widget _ruleRow(LessonPal p, double u, ListenStep step) {
    final rule = _content!.rule!;
    final ink = p.c(RateelColors.leaderText, RateelColors.readLInk);
    final h = u * ListenMetrics.pillH;
    return Row(
      textDirection: TextDirection.rtl,
      children: [
        Container(
          height: h,
          padding: EdgeInsets.symmetric(horizontal: u * 3.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(h / 2),
            color: p.c(RateelColors.listenPillFill, RateelColors.readLPillFill),
            border: Border.all(
              color: _ruleColour,
              width: math.max(1, u * ListenMetrics.pillRim),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            textDirection: TextDirection.rtl,
            children: [
              Container(
                width: u * 2.6,
                height: u * 2.6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _ruleColour,
                  boxShadow: [
                    if (p.t < 0.5)
                      BoxShadow(
                        color: _ruleColour.withValues(alpha: 0.5),
                        blurRadius: u * 1.0,
                      ),
                  ],
                ),
              ),
              SizedBox(width: u * 1.6),
              Padding(
                padding: EdgeInsets.only(bottom: u * 0.45),
                child: Text(
                  rule.name,
                  textDirection: TextDirection.rtl,
                  style: readex(
                    u * ListenMetrics.pillText,
                    weight: 600,
                    color: ink,
                  ).copyWith(height: 1.2),
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: u * 3.0),
        Expanded(
          child: Align(
            alignment: Alignment.centerRight,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
              child: Text(
                step.note,
                textDirection: TextDirection.rtl,
                maxLines: 1,
                style: readex(
                  u * ListenMetrics.qSize * 0.9,
                  weight: 500,
                  color: ink,
                ).copyWith(height: 1.3),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _explanation(
    LessonPal p,
    double u, {
    required bool ok,
    required String lead,
    required String text,
    required int points,
  }) {
    final ink = p.c(RateelColors.leaderText, RateelColors.readLInk);
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: u * 8),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            textDirection: TextDirection.rtl,
            children: [
              _MarkDisc(u: u, ok: ok, size: 5.2),
              SizedBox(width: u * 1.8),
              Text(
                lead,
                textDirection: TextDirection.rtl,
                style: readex(
                  u * 3.6,
                  weight: 600,
                  color: ok
                      ? p.c(RateelColors.testOkText, RateelColors.testLOkRim)
                      : p.c(
                          RateelColors.testKoDiscTop,
                          RateelColors.testLKoRim,
                        ),
                ),
              ),
              SizedBox(width: u * 1.4),
              Text(
                text,
                textDirection: TextDirection.rtl,
                style: readex(u * 3.6, weight: 400, color: ink),
              ),
              if (points > 0) ...[
                SizedBox(width: u * 2.2),
                Container(
                  height: u * 5.6,
                  padding: EdgeInsets.symmetric(horizontal: u * 2.0),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(u * 2.8),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        p.c(
                          RateelColors.testPillTop,
                          RateelColors.testLGoldTop,
                        ),
                        p.c(
                          RateelColors.testPillBottom,
                          RateelColors.testLGoldBottom,
                        ),
                      ],
                    ),
                    border: Border.all(
                      color: p.c(
                        RateelColors.testPillRimBottom,
                        RateelColors.testLGoldRimBottom,
                      ),
                      width: math.max(1, u * 0.22),
                    ),
                  ),
                  child: Text(
                    '\u2066+$points\u2069 نقطة',
                    textDirection: TextDirection.rtl,
                    style: readex(
                      u * 3.2,
                      weight: 600,
                      color: p.c(RateelColors.testPillText, Colors.white),
                    ).copyWith(height: 1.1),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ---- Answer pills ----------------------------------------------------------

  Widget _answerPill(LessonPal p, double u, ListenQuestion q, int i) {
    final answered = _ok != null;
    final isPick = _pick == i;
    final isRight = q.options[i] == q.correct;
    final state = !answered
        ? (isPick ? _PillState.selected : _PillState.idle)
        : isRight
        ? _PillState.right
        : isPick
        ? _PillState.wrong
        : _PillState.dim;
    final pill = _AnswerPill(
      u: u,
      p: p,
      label: q.options[i],
      state: state,
      onTap: () => _select(i),
    );
    if (state != _PillState.wrong) return pill;
    return AnimatedBuilder(
      animation: _shake,
      child: pill,
      builder: (context, child) => Transform.translate(
        offset: Offset(
          math.sin(_shake.value * math.pi * 6) * u * 1.0 * (1 - _shake.value),
          0,
        ),
        child: child,
      ),
    );
  }
}

enum _PillState { idle, selected, right, wrong, dim }

/// Answer pill of the bottom row (reference): dark glass with a thin pale
/// gold rim; selected = lesson gold with dark ink; after the answer the right
/// one turns jewel green ✓, a wrong choice red ✕ (lesson-production video,
/// owner 2026-11-26, Q6), the others fade.
class _AnswerPill extends StatelessWidget {
  const _AnswerPill({
    required this.u,
    required this.p,
    required this.label,
    required this.state,
    required this.onTap,
    this.quran = false,
    this.hint = false,
    this.mark = true,
    this.letter = false,
  });

  /// A single letter (larger).
  final bool letter;

  final double u;
  final LessonPal p;
  final String label;

  /// Quran text (a word or a letter of the verse): Amiri Quran.
  final bool quran;

  /// Instruction instead of an answer (softer text).
  final bool hint;

  /// ✓ / ✕ disc after the answer (not on the small letter pills).
  final bool mark;
  final _PillState state;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final h = u * ListenMetrics.pillH;
    final List<Color> fill;
    final Color rim;
    final Color ink;
    switch (state) {
      case _PillState.selected:
        fill = [
          p.c(RateelColors.listenGoldTop, RateelColors.testLGoldTop),
          p.c(RateelColors.listenGoldBottom, RateelColors.testLGoldBottom),
        ];
        rim = p.c(RateelColors.listenGoldRim, RateelColors.testLGoldRimBottom);
        ink = p.c(RateelColors.countText, Colors.white);
      case _PillState.right:
        fill = [
          p.c(RateelColors.testOkTop, RateelColors.testLGreenTop),
          p.c(RateelColors.testOkBottom, RateelColors.testLGreenBottom),
        ];
        rim = p.c(RateelColors.testOkRim, RateelColors.testLGreenRimTop);
        ink = Colors.white;
      case _PillState.wrong:
        fill = [
          p.c(RateelColors.testKoTop, RateelColors.testLRedTop),
          p.c(RateelColors.testKoBottom, RateelColors.testLRedBottom),
        ];
        rim = p.c(RateelColors.testKoRim, RateelColors.testLRedRimTop);
        ink = Colors.white;
      case _PillState.idle:
      case _PillState.dim:
        fill = [
          p.c(RateelColors.listenPillFill, RateelColors.readLPillFill),
          p.c(RateelColors.listenPillFill, RateelColors.readLPillFill),
        ];
        rim = p.c(RateelColors.listenPillRim, RateelColors.readLPillRim);
        ink = p.c(RateelColors.leaderText, RateelColors.readLInk);
    }
    final mark =
        this.mark && (state == _PillState.right || state == _PillState.wrong);
    return Semantics(
      button: true,
      selected: state == _PillState.selected,
      label: label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedOpacity(
          opacity: state == _PillState.dim ? 0.45 : 1,
          duration: const Duration(milliseconds: 250),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(h / 2),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: fill,
              ),
              border: Border.all(
                color: rim,
                width: math.max(1, u * ListenMetrics.pillRim),
              ),
              boxShadow: [
                if (state == _PillState.selected && p.t < 0.5)
                  BoxShadow(
                    color: RateelColors.listenGoldBottom.withValues(
                      alpha: 0.35,
                    ),
                    blurRadius: u * 1.6,
                  ),
                if (p.t > 0)
                  BoxShadow(
                    color: const Color(0xFF6B4A2A)
                        .withValues(alpha: 0.18 * p.t),
                    blurRadius: u * 1.0,
                    offset: Offset(0, u * 0.4),
                  ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: u * 2.2),
              child: Row(
                textDirection: TextDirection.rtl,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (quran)
                    // Letters and words of the verse: centred on their real
                    // ink (س، ل، ن… go below the line), so they stay inside
                    // the pill (owner, 2026-11-26).
                    Expanded(
                      child: _InkCentered(
                        text: label,
                        style: TextStyle(
                          fontFamily: 'AmiriQuran',
                          fontSize:
                              u *
                              ListenMetrics.pillText *
                              (letter ? 1.35 : 1.15),
                          height: 1.0,
                          color: ink,
                        ),
                        maxHeight: letter ? 0.6 : 0.7,
                        maxWidth: letter ? 0.75 : 1.0,
                      ),
                    )
                  else
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Padding(
                          // Readex sets Arabic low in its line box (lift).
                          // Amiri sits low in a pill: lift it a little.
                          padding: EdgeInsets.only(
                            bottom: u * (quran ? 0.9 : 0.45),
                          ),
                          child: Text(
                            label,
                            textDirection: TextDirection.rtl,
                            maxLines: 1,
                            style: quran
                                ? TextStyle(
                                    fontFamily: 'AmiriQuran',
                                    fontSize:
                                        u *
                                        ListenMetrics.pillText *
                                        (letter ? 1.35 : 1.15),
                                    // Amiri's line box is tall: height 1 keeps
                                    // the letter and its marks inside the pill.
                                    height: 1.0,
                                    color: ink,
                                  )
                                : readex(
                                    u *
                                        ListenMetrics.pillText *
                                        (hint ? 0.82 : 1),
                                    weight: state == _PillState.selected
                                        ? 700
                                        : (hint ? 400 : 500),
                                    color: hint
                                        ? ink.withValues(alpha: 0.7)
                                        : ink,
                                  ).copyWith(height: 1.2),
                          ),
                        ),
                      ),
                    ),
                  if (mark) ...[
                    SizedBox(width: u * 1.6),
                    _MarkDisc(
                      u: u,
                      ok: state == _PillState.right,
                      size: 4.6,
                      onFill: true,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// ✓ / ✕ disc (jewel green / red as screen 10).
class _MarkDisc extends StatelessWidget {
  const _MarkDisc({
    required this.u,
    required this.ok,
    required this.size,
    this.onFill = false,
  });

  final double u;
  final bool ok;
  final double size;

  /// On a coloured pill: a white disc with a coloured mark.
  final bool onFill;

  @override
  Widget build(BuildContext context) {
    final d = u * size;
    final col = ok ? RateelColors.testOkDisc : RateelColors.testKoDisc;
    return Container(
      width: d,
      height: d,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: onFill
            ? null
            : LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: ok
                    ? const [
                        RateelColors.testOkDiscTop,
                        RateelColors.testOkDisc,
                      ]
                    : const [
                        RateelColors.testKoDiscTop,
                        RateelColors.testKoDisc,
                      ],
              ),
        color: onFill ? Colors.white.withValues(alpha: 0.92) : null,
      ),
      padding: EdgeInsets.all(d * 0.26),
      child: CustomPaint(
        painter: ok
            ? PillGlyphPainter(PillGlyph.check, onFill ? col : Colors.white)
            : _CrossPainter(onFill ? col : Colors.white),
      ),
    );
  }
}

class _CrossPainter extends CustomPainter {
  _CrossPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final s = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.height * 0.18
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(size.width * 0.15, size.height * 0.15),
      Offset(size.width * 0.85, size.height * 0.85),
      s,
    );
    canvas.drawLine(
      Offset(size.width * 0.85, size.height * 0.15),
      Offset(size.width * 0.15, size.height * 0.85),
      s,
    );
  }

  @override
  bool shouldRepaint(_CrossPainter o) => o.color != color;
}

class _PausePainter extends CustomPainter {
  _PausePainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width * 0.32;
    final paint = Paint()..color = color;
    for (final x in [0.0, size.width - w]) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, 0, w, size.height),
          Radius.circular(w * 0.35),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_PausePainter o) => o.color != color;
}

/// Waveform of the verse (51 bars, reference): played part gold, the rest dim
/// green. Repaints with the audio position only ([pos]).
class _WavePainter extends CustomPainter {
  _WavePainter({
    required this.pos,
    required this.ayah,
    required this.u,
    required this.played,
    required this.rest,
  }) : super(repaint: pos);

  final ValueNotifier<int> pos;
  final ListenAyah ayah;
  final double u;
  final Color played;
  final Color rest;

  @override
  void paint(Canvas canvas, Size size) {
    const n = ListenMetrics.bars;
    final step = u * ListenMetrics.barStep;
    final bw = u * ListenMetrics.barW;
    final total = step * (n - 1) + bw;
    final x0 = size.width / 2 - total / 2;
    final cy = size.height / 2;
    final progress = (pos.value / ayah.durationMs).clamp(0.0, 1.0);
    final on = Paint()..color = played;
    final off = Paint()..color = rest;
    for (var i = 0; i < n; i++) {
      final peak = i < ayah.peaks.length ? ayah.peaks[i] : 0.2;
      final h =
          u * ListenMetrics.barMin +
          u * (ListenMetrics.barMax - ListenMetrics.barMin) * peak;
      // RTL reading, but the reference fills from the left (as the 02
      // capsule, owner 2026-11-24): bar i lit when the progress passes it.
      final lit = (i + 0.5) / n <= progress;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(x0 + i * step + bw / 2, cy),
            width: bw,
            height: h,
          ),
          Radius.circular(bw / 2),
        ),
        lit ? on : off,
      );
    }
  }

  @override
  bool shouldRepaint(_WavePainter o) =>
      o.ayah != ayah || o.u != u || o.played != played || o.rest != rest;
}

/// Letter pills appear one after another when the letter question shows up.
class _LetterIn extends StatefulWidget {
  const _LetterIn({required this.delay, required this.child});

  final int delay;
  final Widget child;

  @override
  State<_LetterIn> createState() => _LetterInState();
}

class _LetterInState extends State<_LetterIn>
    with SingleTickerProviderStateMixin {
  late final _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 320),
  );

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(Duration(milliseconds: 60 * widget.delay), () {
      if (mounted) _c.forward();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _c,
    child: widget.child,
    builder: (context, child) {
      final t = Curves.easeOutBack.transform(_c.value);
      return Opacity(
        opacity: _c.value,
        child: Transform.scale(scale: 0.7 + 0.3 * t, child: child),
      );
    },
  );
}

/// Quran text drawn centred on its **ink** (the glyphs and their marks), not
/// on its line box: Arabic letters such as س، ل، ن، ي go below the line and
/// the harakat above it, so a line-box centre puts some of them out of a pill.
/// The ink is measured once per text and size (drawn off-screen), then the
/// text is scaled to at most [maxHeight] × [maxWidth] of the box.
class _InkCentered extends StatefulWidget {
  const _InkCentered({
    required this.text,
    required this.style,
    this.maxHeight = 0.6,
    this.maxWidth = 0.8,
  });

  final String text;
  final TextStyle style;
  final double maxHeight;
  final double maxWidth;

  static final _cache = <String, Rect>{};

  @override
  State<_InkCentered> createState() => _InkCenteredState();
}

class _InkCenteredState extends State<_InkCentered> {
  Rect? _ink;

  String get _key => '${widget.text}|${widget.style.fontSize}';

  TextPainter _painter() => TextPainter(
    text: TextSpan(text: widget.text, style: widget.style),
    textDirection: TextDirection.rtl,
  )..layout();

  @override
  void initState() {
    super.initState();
    _ink = _InkCentered._cache[_key];
    if (_ink == null) _measure();
  }

  @override
  void didUpdateWidget(_InkCentered old) {
    super.didUpdateWidget(old);
    if (old.text != widget.text ||
        old.style.fontSize != widget.style.fontSize) {
      _ink = _InkCentered._cache[_key];
      if (_ink == null) _measure();
    }
  }

  Future<void> _measure() async {
    final key = _key;
    final tp = _painter();
    final pad = (widget.style.fontSize ?? 20) * 0.8;
    const k = 2.0; // measuring resolution
    final w = ((tp.width + pad * 2) * k).ceil();
    final h = ((tp.height + pad * 2) * k).ceil();
    final rec = ui.PictureRecorder();
    final c = Canvas(rec)..scale(k);
    tp.paint(c, Offset(pad, pad));
    final img = await rec.endRecording().toImage(w, h);
    final data = await img.toByteData(format: ui.ImageByteFormat.rawRgba);
    img.dispose();
    if (data == null || !mounted) return;
    var x0 = w, y0 = h, x1 = -1, y1 = -1;
    for (var y = 0; y < h; y++) {
      for (var x = 0; x < w; x++) {
        if (data.getUint8((y * w + x) * 4 + 3) > 24) {
          if (x < x0) x0 = x;
          if (x > x1) x1 = x;
          if (y < y0) y0 = y;
          if (y > y1) y1 = y;
        }
      }
    }
    if (x1 < 0) return;
    final ink = Rect.fromLTRB(
      x0 / k - pad,
      y0 / k - pad,
      (x1 + 1) / k - pad,
      (y1 + 1) / k - pad,
    );
    _InkCentered._cache[key] = ink;
    if (mounted && key == _key) setState(() => _ink = ink);
  }

  @override
  Widget build(BuildContext context) {
    final ink = _ink;
    if (ink == null) return const SizedBox.expand();
    return SizedBox.expand(
      child: CustomPaint(
        painter: _InkTextPainter(
          _painter(),
          ink,
          widget.maxWidth,
          widget.maxHeight,
        ),
      ),
    );
  }
}

class _InkTextPainter extends CustomPainter {
  _InkTextPainter(this.tp, this.ink, this.maxW, this.maxH);

  final TextPainter tp;
  final Rect ink;
  final double maxW;
  final double maxH;

  @override
  void paint(Canvas canvas, Size size) {
    final s = math.min(
      1.0,
      math.min(size.width * maxW / ink.width, size.height * maxH / ink.height),
    );
    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    canvas.scale(s);
    canvas.translate(-ink.center.dx, -ink.center.dy);
    tp.paint(canvas, Offset.zero);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_InkTextPainter o) =>
      o.ink != ink || o.tp.text != tp.text || o.maxW != maxW || o.maxH != maxH;
}

/// Dots of the harakat over a rule letter: dim until the rule is held, then
/// one lights up per haraka (rule colour, small halo); they stay lit until the
/// ayah starts again. Repaints with the audio position only.
class _HarakatDots extends CustomPainter {
  _HarakatDots({
    required this.span,
    required this.mark,
    required this.pos,
    required this.u,
    required this.colour,
    required this.dim,
    required this.light,
  }) : super(repaint: pos);

  final InlineSpan span;
  final ListenMark mark;
  final ValueNotifier<int> pos;
  final double u;
  final Color colour;
  final Color dim;
  final bool light;

  @override
  void paint(Canvas canvas, Size size) {
    final tp = TextPainter(text: span, textDirection: TextDirection.rtl)
      ..layout(maxWidth: size.width + 1);
    final boxes = tp.getBoxesForSelection(
      TextSelection(baseOffset: mark.from, extentOffset: mark.to),
    );
    if (boxes.isEmpty) return;
    var r = boxes.first.toRect();
    for (final b in boxes.skip(1)) {
      r = r.expandToInclude(b.toRect());
    }
    final n = mark.harakat;
    final start = mark.holdStart!, end = mark.holdEnd!;
    final step = (end - start) / n;
    final now = pos.value;
    final d = u * 1.45;
    final gap = u * 2.4;
    // Just above the letter and its harakat (shadda + fatha reach about one
    // font size above the baseline in Amiri Quran).
    final lm = tp.computeLineMetrics();
    final base = lm.isEmpty ? r.bottom : lm.first.baseline;
    final y = base - u * ListenMetrics.verseSize * 1.24;
    final x0 = r.center.dx - gap * (n - 1) / 2;
    for (var k = 0; k < n; k++) {
      final on = now >= start + step * k && now > 0;
      final c = Offset(x0 + gap * k, y);
      if (on && !light) {
        canvas.drawCircle(
          c,
          d * 1.3,
          Paint()
            ..color = colour.withValues(alpha: 0.55)
            ..maskFilter = MaskFilter.blur(BlurStyle.normal, u * 0.6),
        );
      }
      canvas.drawCircle(
        c,
        d / 2 * (on ? 1.15 : 1),
        Paint()..color = on ? colour : dim,
      );
    }
  }

  @override
  bool shouldRepaint(_HarakatDots o) =>
      o.mark != mark || o.u != u || o.colour != colour || o.span != span;
}
