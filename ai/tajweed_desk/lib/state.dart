// State of the desktop lab: model, ayah, the two takes (yours and al-Husary's), selection and playback.
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:tajweed_core/explain.dart';
import 'package:tajweed_core/features.dart';
import 'package:tajweed_core/timeline.dart';

import 'engine.dart';

enum Who { me, husary }

class Take {
  final Who who;
  final String label;
  final Float32List samples; // 16 kHz mono
  final Float32List peaks; // max |sample| per 10 ms
  TakeAnalysis? analysis;
  int featMs = 0, modelMs = 0;
  String? error;
  Take(this.who, this.label, this.samples) : peaks = _peaks(samples);
  double get seconds => samples.length / sampleRate;

  static Float32List _peaks(Float32List s) {
    const step = sampleRate ~/ 100;
    final n = (s.length / step).ceil();
    final p = Float32List(n);
    for (var i = 0; i < n; i++) {
      var m = 0.0;
      for (var k = i * step; k < math.min(s.length, (i + 1) * step); k++) {
        final v = s[k].abs();
        if (v > m) m = v;
      }
      p[i] = m;
    }
    return p;
  }
}

class _FeatIn {
  final Float32List wave, window, mel;
  _FeatIn(this.wave, this.window, this.mel);
}

Features _feat(_FeatIn j) => extractFeatures(j.wave, j.window, j.mel);

class LabState extends ChangeNotifier {
  late List<Ayah> ayat;
  late Map<int, String> vocab;
  late Float32List _window, _mel;
  final engine = Engine();
  final _player = AudioPlayer();
  final _rec = AudioRecorder();
  late Directory _dir;

  String? modelPath;
  int threads = math.max(1, math.min(8, Platform.numberOfProcessors));
  bool loadingModel = false;
  String? modelInfo;
  String? status;

  Ayah? ayah;
  Take? mine, husary;
  bool fixedReading = false;
  bool rtlTime = true;
  double pxPerSecond = 160;
  double speed = 1.0;

  int? selectedRef, hoveredRef;
  bool recording = false;
  DateTime? _recStart;
  Timer? _recTick;
  DateTime? get recStart => _recStart;
  bool get analysingMine => mine != null && mine!.analysis == null && mine!.error == null && engine.loaded;
  bool busy = false;

  // playback (the playhead is drawn from these values)
  Who? playing;
  double playFrom = 0, playTo = 0;
  DateTime? playStarted;
  VoidCallback? _afterPlay;

  final _husaryCache = <String, Take>{};

  Future<void> init() async {
    String a(String f) => 'packages/tajweed_core/assets/$f';
    ayat = parseAyat(await rootBundle.loadString(a('ayat.json')));
    final v = jsonDecode(await rootBundle.loadString(a('vocab.json'))) as Map<String, dynamic>;
    vocab = {for (final e in v.entries) int.parse(e.key): e.value as String};
    _window = (await rootBundle.load(a('window.f32'))).buffer.asFloat32List();
    _mel = (await rootBundle.load(a('mel.f32'))).buffer.asFloat32List();
    _dir = Directory('${(await getApplicationSupportDirectory()).path}/rateel_tajweed_desk');
    await _dir.create(recursive: true);
    final s = File('${_dir.path}/settings.json');
    if (await s.exists()) {
      final j = jsonDecode(await s.readAsString()) as Map<String, dynamic>;
      modelPath = j['modelPath'] as String?;
      threads = (j['threads'] as int?) ?? threads;
    }
    modelPath = Platform.environment['LAB_MODEL'] ?? modelPath; // review aid
    _player.onPlayerComplete.listen((_) => _donePlaying());
    if (modelPath != null && await File(modelPath!).exists()) unawaited(loadModel());
    notifyListeners();
  }

  Future<void> _saveSettings() =>
      File('${_dir.path}/settings.json').writeAsString(jsonEncode({'modelPath': modelPath, 'threads': threads}));

  void say(String? s) {
    status = s;
    notifyListeners();
  }

  // ---------------------------------------------------------------- model
  Future<void> setModel(String path) async {
    modelPath = path;
    await _saveSettings();
    await loadModel();
  }

  Future<void> setThreads(int t) async {
    threads = t;
    await _saveSettings();
    if (engine.loaded) await loadModel();
    notifyListeners();
  }

  Future<void> loadModel() async {
    if (modelPath == null) return;
    loadingModel = true;
    modelInfo = 'Carico il modello…';
    notifyListeners();
    try {
      final ms = await engine.load(modelPath!, threads: threads);
      modelInfo = 'Modello pronto: caricato in ${(ms / 1000).toStringAsFixed(1)} s · $threads thread · '
          'RAM ${(ProcessInfo.currentRss / 1048576).round()} MB';
      if (ayah != null) {
        await _analyse(husary);
        await _analyse(mine);
      }
    } catch (e) {
      modelInfo = 'Errore nel caricare il modello: $e';
    } finally {
      loadingModel = false;
      notifyListeners();
    }
  }

  // ---------------------------------------------------------------- ayah and takes
  String _key(Ayah a) => '${a.sura.toString().padLeft(3, '0')}${a.aya.toString().padLeft(3, '0')}';

  Future<void> openAyah(Ayah a) async {
    await stop();
    ayah = a;
    mine = null;
    selectedRef = null;
    hoveredRef = null;
    status = null;
    final cached = _husaryCache[_key(a)];
    if (cached != null) {
      husary = cached;
      notifyListeners();
      if (cached.analysis == null) await _analyse(cached);
      return;
    }
    final data = await rootBundle.load('assets/husary/${_key(a)}.wav');
    final w = parseWav(data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
    husary = Take(Who.husary, 'al-Husary', resampleTo16k(w.samples, w.rate));
    _husaryCache[_key(a)] = husary!;
    notifyListeners();
    await _analyse(husary);
  }

  Future<void> _analyse(Take? t) async {
    if (t == null || ayah == null) return;
    if (!engine.loaded) {
      t.error = null;
      notifyListeners();
      return;
    }
    try {
      busy = true;
      notifyListeners();
      final sw = Stopwatch()..start();
      final f = await compute(_feat, _FeatIn(t.samples, _window, _mel));
      t.featMs = sw.elapsedMilliseconds;
      final r = await engine.run(f.values, f.mask);
      t.modelMs = r.ms;
      final d = decodeWithFrames(r.logits, r.frames, r.classes, vocab, t.seconds);
      t.analysis = TakeAnalysis.of(d, ayah!, t.seconds, fixed: fixedReading);
      t.error = null;
    } catch (e) {
      t.error = '$e';
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  void setFixedReading(bool v) {
    fixedReading = v;
    for (final t in [mine, husary]) {
      final a = t?.analysis;
      if (a != null) t!.analysis = TakeAnalysis.of(a.decoded, ayah!, t.seconds, fixed: v);
    }
    notifyListeners();
  }

  Future<void> openWav(String path, {String? label}) async {
    try {
      final w = parseWav(await File(path).readAsBytes());
      mine = Take(Who.me, label ?? path.split(Platform.pathSeparator).last, resampleTo16k(w.samples, w.rate));
      selectedRef = null;
      notifyListeners();
      await _analyse(mine);
    } catch (e) {
      say('Non riesco ad aprire il file: $e (solo WAV PCM 16 bit)');
    }
  }

  Future<void> toggleRecord() async {
    if (recording) return _stopRecord();
    if (ayah == null) return say('Scegli prima un\'ayah.');
    try {
      if (!await _rec.hasPermission()) return say('Serve il permesso del microfono.');
      await stop();
      final path = '${_dir.path}/take_${DateTime.now().millisecondsSinceEpoch}.wav';
      await _rec.start(const RecordConfig(encoder: AudioEncoder.wav, sampleRate: 16000, numChannels: 1), path: path);
      recording = true;
      _recStart = DateTime.now();
      mine = null;
      _recTick?.cancel();
      _recTick = Timer.periodic(const Duration(milliseconds: 250), (_) => notifyListeners());
      say('Registro… recita l\'ayah e premi di nuovo R (o il pulsante) per fermare. Massimo 15 s.');
      Future.delayed(const Duration(seconds: 15), () {
        if (recording && DateTime.now().difference(_recStart!).inSeconds >= 15) _stopRecord();
      });
    } catch (e) {
      recording = false;
      say('Errore del microfono: $e');
    }
  }

  Future<void> _stopRecord() async {
    _recTick?.cancel();
    try {
      final path = await _rec.stop();
      recording = false;
      say(null);
      if (path != null) {
        await openWav(path.startsWith('file://') ? Uri.parse(path).toFilePath() : path, label: 'La tua registrazione');
      }
    } catch (e) {
      recording = false;
      say('Errore allo stop: $e');
    }
  }

  // ---------------------------------------------------------------- selection
  void hover(int? ref) {
    if (ref == hoveredRef) return;
    hoveredRef = ref;
    notifyListeners();
  }

  void select(int? ref, {bool play = false, Who who = Who.me}) {
    selectedRef = ref;
    notifyListeners();
    if (play && ref != null) playRef(who, ref);
  }

  int get refCount => (mine?.analysis ?? husary?.analysis)?.refGroups.length ?? 0;

  void moveSelection(int delta) {
    final n = refCount;
    if (n == 0) return;
    select(((selectedRef ?? (delta > 0 ? -1 : n)) + delta).clamp(0, n - 1));
  }

  /// Time span of reference group [r] in a take (null if the group was not heard).
  (double, double)? spanOf(Take? t, int r) {
    final a = t?.analysis;
    if (a == null || r >= a.refToPred.length) return null;
    final p = a.refToPred[r];
    if (p < 0) return null;
    final g = a.groups[p];
    return (g.start, g.end);
  }

  /// Span of the whole word that contains reference group [r].
  (double, double)? wordSpanOf(Take? t, int r) {
    final a = t?.analysis;
    if (a == null) return null;
    final text = ayah!.uthmani;
    final (u0, u1) = a.uthmaniOfRef(r);
    var s = u0, e = u1;
    while (s > 0 && text[s - 1] != ' ') {
      s--;
    }
    while (e < text.length && text[e] != ' ') {
      e++;
    }
    final refs = a.refGroupsInUthmani(s, e);
    double? from, to;
    for (final x in refs) {
      final sp = spanOf(t, x);
      if (sp == null) continue;
      from = from == null ? sp.$1 : math.min(from, sp.$1);
      to = to == null ? sp.$2 : math.max(to, sp.$2);
    }
    return from == null ? null : (from, to!);
  }

  // ---------------------------------------------------------------- playback
  Take? take(Who w) => w == Who.me ? mine : husary;

  Future<void> play(Who who, double from, double to, {VoidCallback? then}) async {
    final t = take(who);
    if (t == null) return;
    await _player.stop();
    final a = (from * sampleRate).floor().clamp(0, t.samples.length);
    final b = (to * sampleRate).ceil().clamp(a, t.samples.length);
    if (b - a < 160) return;
    final f = File('${_dir.path}/play_${who.name}.wav');
    await f.writeAsBytes(wavBytes(Float32List.sublistView(t.samples, a, b), sampleRate));
    playing = who;
    playFrom = a / sampleRate;
    playTo = b / sampleRate;
    _afterPlay = then;
    await _player.setPlaybackRate(speed);
    await _player.play(DeviceFileSource(f.path));
    playStarted = DateTime.now();
    notifyListeners();
  }

  void _donePlaying() {
    playing = null;
    playStarted = null;
    final then = _afterPlay;
    _afterPlay = null;
    notifyListeners();
    then?.call();
  }

  Future<void> stop() async {
    _afterPlay = null;
    await _player.stop();
    playing = null;
    playStarted = null;
    notifyListeners();
  }

  double? playheadOf(Who w) {
    if (playing != w || playStarted == null) return null;
    final p = playFrom + DateTime.now().difference(playStarted!).inMicroseconds / 1e6 * speed;
    return p > playTo ? playTo : p;
  }

  Future<void> togglePlay(Who who) async {
    if (playing != null) return stop();
    final t = take(who);
    if (t == null) return;
    await play(who, 0, t.seconds);
  }

  Future<void> playRef(Who who, int r, {bool word = false}) async {
    final sp = word ? wordSpanOf(take(who), r) : spanOf(take(who), r);
    if (sp == null) return say(who == Who.me ? 'Questa lettera non si sente nella tua registrazione.' : null);
    // a little margin so short letters are audible
    await play(who, math.max(0, sp.$1 - 0.06), sp.$2 + 0.06);
  }

  /// Your version, then al-Husary's, of the selected group (or word).
  Future<void> playAB(int r, {bool word = false}) async {
    final other = word ? wordSpanOf(husary, r) : spanOf(husary, r);
    Future<void> second() async {
      if (other != null) await play(Who.husary, math.max(0, other.$1 - 0.06), other.$2 + 0.06);
    }

    final mineSpan = word ? wordSpanOf(mine, r) : spanOf(mine, r);
    if (mineSpan == null) return second();
    await play(Who.me, math.max(0, mineSpan.$1 - 0.06), mineSpan.$2 + 0.06, then: () => unawaited(second()));
  }

  void setSpeed(double s) {
    speed = s;
    _player.setPlaybackRate(s);
    notifyListeners();
  }

  void zoom(double factor) {
    pxPerSecond = (pxPerSecond * factor).clamp(40, 1200);
    notifyListeners();
  }

  void setRtl(bool v) {
    rtlTime = v;
    notifyListeners();
  }

  @override
  void dispose() {
    _player.dispose();
    _rec.dispose();
    engine.close();
    super.dispose();
  }
}
