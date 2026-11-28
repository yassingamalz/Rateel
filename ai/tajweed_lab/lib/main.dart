// Rateel tajweed lab: a small test app (not Rateel) to try the Quran Muaalem model on the phone.
// Records one ayah, runs the int8 ONNX model on the device, compares with every allowed reading of the
// ayah and shows the errors, the timings and the memory used. Owner's request 2026-11-28.
import 'dart:convert';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_onnxruntime/flutter_onnxruntime.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import 'explain.dart';
import 'features.dart';
import 'model_store.dart';

const aiNoticeAr =
    'هذا المعلّم القرآني نموذج ذكاء اصطناعي قد يخطئ؛ فهو للإعانة فقط ولا يُعتمد عليه، وليس بديلاً عن معلّمٍ مُتقِنٍ مُجاز؛ لأنّ القرآن لا يُؤخذ إلا بالمشافهة.';
const aiNoticeIt =
    "Questo Insegnante del Corano è un modello di intelligenza artificiale che può commettere errori. "
    "È destinato solo all'assistenza e non deve essere considerato affidabile. Non sostituisce un insegnante "
    "competente e debitamente autorizzato, poiché il Corano si riceve solo attraverso la trasmissione orale (mushafahah).";

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const LabApp());
}

class LabApp extends StatelessWidget {
  const LabApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Rateel tajweed lab',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1F6B4F), brightness: Brightness.dark),
          useMaterial3: true,
        ),
        home: const HomePage(),
      );
}

/// Everything shared by the pages.
class Lab {
  final store = ModelStore();
  late List<Ayah> ayat;
  late Float32List window, mel;
  late Map<int, String> vocab;
  OrtSession? session;
  int threads = 4;
  String? loadInfo;

  Future<void> init() async {
    await store.init();
    ayat = parseAyat(await rootBundle.loadString('assets/ayat.json'));
    window = (await rootBundle.load('assets/window.f32')).buffer.asFloat32List();
    mel = (await rootBundle.load('assets/mel.f32')).buffer.asFloat32List();
    final v = jsonDecode(await rootBundle.loadString('assets/vocab.json')) as Map<String, dynamic>;
    vocab = {for (final e in v.entries) int.parse(e.key): e.value as String};
  }

  Future<void> loadModel() async {
    await session?.close();
    session = null;
    final rss0 = ProcessInfo.currentRss;
    final sw = Stopwatch()..start();
    session = await OnnxRuntime().createSession(store.model.path,
        options: OrtSessionOptions(intraOpNumThreads: threads, interOpNumThreads: 1));
    sw.stop();
    loadInfo = 'caricato in ${(sw.elapsedMilliseconds / 1000).toStringAsFixed(1)} s, '
        'RAM +${_mb(ProcessInfo.currentRss - rss0)} MB (ora ${_mb(ProcessInfo.currentRss)} MB), $threads thread';
  }
}

String _mb(int bytes) => (bytes / (1024 * 1024)).toStringAsFixed(0);

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final lab = Lab();
  bool _ready = false, _modelOk = false, _busy = false;
  String? _status;
  final _url = TextEditingController(text: defaultManifestUrl);

  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    await lab.init();
    _modelOk = await lab.store.ready;
    setState(() => _ready = true);
    final flag = File('${lab.store.dir.path}/../ai-notice-accepted');
    if (!await flag.exists() && mounted) {
      await showNotice(context, firstTime: true);
      await flag.writeAsString(DateTime.now().toIso8601String());
    }
  }

  Future<void> _run(String label, Future<void> Function() job) async {
    setState(() {
      _busy = true;
      _status = label;
    });
    try {
      await job();
    } catch (e) {
      _status = 'Errore: $e';
    }
    _modelOk = await lab.store.ready;
    if (mounted) setState(() => _busy = false);
  }

  Future<void> _download() => _run('Scarico il modello…', () async {
        await lab.store.download(_url.text.trim(), (done, total) {
          if (mounted) {
            setState(() => _status = 'Scarico: ${_mb(done)} / ${_mb(total)} MB');
          }
        });
        _status = 'Modello scaricato e verificato (${_mb(await lab.store.size)} MB).';
      });

  Future<void> _import() => _run('Copio il file…', () async {
        final r = await FilePicker.pickFiles();
        final path = r.isEmpty ? null : r.single.path;
        if (path == null) {
          _status = null;
          return;
        }
        await lab.store.importFrom(path);
        _status = 'Modello importato (${_mb(await lab.store.size)} MB).';
      });

  Future<void> _load() => _run('Carico il modello in memoria…', () async {
        await lab.loadModel();
        _status = 'Modello ${lab.loadInfo}.';
      });

  @override
  Widget build(BuildContext context) {
    if (!_ready) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    final bySura = <int, List<Ayah>>{};
    for (final a in lab.ayat) {
      bySura.putIfAbsent(a.sura, () => []).add(a);
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rateel · prova tajweed'),
        actions: [
          IconButton(
              tooltip: 'Avviso IA e licenza',
              icon: const Icon(Icons.info_outline),
              onPressed: () => showNotice(context, firstTime: false)),
        ],
      ),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Modello (Quran Muaalem v3_2, int8, ~610 MB)', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(_modelOk ? 'Presente sul telefono.' : 'Non ancora sul telefono.'),
              if (_status != null) ...[const SizedBox(height: 8), Text(_status!)],
              if (_busy) const Padding(padding: EdgeInsets.only(top: 8), child: LinearProgressIndicator()),
              const SizedBox(height: 8),
              TextField(
                controller: _url,
                decoration: const InputDecoration(labelText: 'Indirizzo del manifest (download a parti)'),
                style: const TextStyle(fontSize: 12),
              ),
              const SizedBox(height: 8),
              Wrap(spacing: 8, runSpacing: 8, children: [
                FilledButton.tonal(onPressed: _busy ? null : _download, child: const Text('Scarica (Wi-Fi)')),
                OutlinedButton(onPressed: _busy ? null : _import, child: const Text('Importa file .onnx')),
                if (_modelOk)
                  OutlinedButton(
                      onPressed: _busy
                          ? null
                          : () => _run('Cancello…', () async {
                                await lab.session?.close();
                                lab.session = null;
                                await lab.store.delete();
                                _status = 'Modello cancellato.';
                              }),
                      child: const Text('Cancella')),
              ]),
              const Divider(height: 24),
              Row(children: [
                const Text('Thread CPU: '),
                for (final t in [1, 2, 4])
                  Padding(
                    padding: const EdgeInsets.only(left: 6),
                    child: ChoiceChip(
                        label: Text('$t'),
                        selected: lab.threads == t,
                        onSelected: (_) => setState(() => lab.threads = t)),
                  ),
              ]),
              const SizedBox(height: 8),
              FilledButton(
                  onPressed: _busy || !_modelOk ? null : _load,
                  child: Text(lab.session == null ? 'Carica il modello in memoria' : 'Ricarica il modello')),
              if (lab.loadInfo != null) Padding(padding: const EdgeInsets.only(top: 8), child: Text(lab.loadInfo!)),
            ]),
          ),
        ),
        const SizedBox(height: 12),
        for (final e in bySura.entries)
          ExpansionTile(
            title: Text('سورة ${e.value.first.suraName} (${e.key})', textDirection: TextDirection.rtl),
            children: [
              for (final a in e.value)
                ListTile(
                  title: Text(a.uthmani, textDirection: TextDirection.rtl, style: const TextStyle(fontSize: 20)),
                  subtitle: Text('${a.sura}:${a.aya}'),
                  onTap: () => Navigator.push(
                      context, MaterialPageRoute(builder: (_) => AyahPage(lab: lab, ayah: a))).then((_) => setState(() {})),
                ),
            ],
          ),
      ]),
    );
  }
}

Future<void> showNotice(BuildContext context, {required bool firstTime}) => showDialog(
      context: context,
      barrierDismissible: !firstTime,
      builder: (ctx) => AlertDialog(
        title: const Text('Avviso IA · تنبيه'),
        content: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            const Text(aiNoticeAr, textDirection: TextDirection.rtl, style: TextStyle(fontSize: 18, height: 1.6)),
            const SizedBox(height: 12),
            const Text(aiNoticeIt),
            const SizedBox(height: 12),
            Text(
              'App di prova di Rateel. Modello e codice Quran Muaalem © obadx e contributori, licenza Quran Muaalem '
              'License (QML) 1.0.',
              style: Theme.of(ctx).textTheme.bodySmall,
            ),
          ]),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.push(ctx, MaterialPageRoute(builder: (_) => const LicencePage())),
              child: const Text('Licenza')),
          FilledButton(onPressed: () => Navigator.pop(ctx), child: Text(firstTime ? 'Ho capito' : 'Chiudi')),
        ],
      ),
    );

class LicencePage extends StatelessWidget {
  const LicencePage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('QML 1.0 · NOTICE')),
        body: FutureBuilder<List<String>>(
          future: Future.wait([
            rootBundle.loadString('assets/licence/QML-NOTICE.txt'),
            rootBundle.loadString('assets/licence/QML-LICENSE.txt'),
          ]),
          builder: (_, s) => s.hasData
              ? SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: SelectableText('${s.data![0]}\n\n${s.data![1]}', style: const TextStyle(fontSize: 12)))
              : const Center(child: CircularProgressIndicator()),
        ),
      );
}

class _FeatJob {
  final Uint8List wav;
  final Float32List window, mel;
  _FeatJob(this.wav, this.window, this.mel);
}

class _FeatResult {
  final Features f;
  final double seconds;
  final int rate;
  _FeatResult(this.f, this.seconds, this.rate);
}

_FeatResult _features(_FeatJob j) {
  final w = parseWav(j.wav);
  final x = resampleTo16k(w.samples, w.rate);
  return _FeatResult(extractFeatures(x, j.window, j.mel), x.length / sampleRate, w.rate);
}

class Analysis {
  final String predicted;
  final Correction correction;
  final double audioSeconds;
  final int featMs, modelMs, rssMb, maxRssMb, recordRate;
  Analysis(this.predicted, this.correction, this.audioSeconds, this.featMs, this.modelMs, this.rssMb, this.maxRssMb,
      this.recordRate);
}

class AyahPage extends StatefulWidget {
  final Lab lab;
  final Ayah ayah;
  const AyahPage({super.key, required this.lab, required this.ayah});
  @override
  State<AyahPage> createState() => _AyahPageState();
}

class _AyahPageState extends State<AyahPage> {
  final _rec = AudioRecorder();
  final _player = AudioPlayer();
  bool _recording = false, _busy = false, _fixed = false;
  String? _lastPredicted;
  String? _msg;
  Analysis? _result;
  DateTime? _recStart;

  @override
  void dispose() {
    _rec.dispose();
    _player.dispose();
    super.dispose();
  }

  String get _everyayah =>
      'https://everyayah.com/data/Husary_128kbps/${widget.ayah.sura.toString().padLeft(3, '0')}${widget.ayah.aya.toString().padLeft(3, '0')}.mp3';

  Future<void> _toggleRecord() async {
    if (_recording) return _stop();
    if (!await _rec.hasPermission()) {
      setState(() => _msg = 'Serve il permesso del microfono.');
      return;
    }
    final dir = await getTemporaryDirectory();
    await _rec.start(
        const RecordConfig(encoder: AudioEncoder.wav, sampleRate: 16000, numChannels: 1, autoGain: false,
            echoCancel: false, noiseSuppress: false),
        path: '${dir.path}/take.wav');
    _recStart = DateTime.now();
    setState(() {
      _recording = true;
      _result = null;
      _msg = 'Registro… recita l\'ayah (massimo 15 s), poi premi di nuovo.';
    });
    Future.delayed(const Duration(seconds: 15), () {
      if (_recording && mounted && DateTime.now().difference(_recStart!).inSeconds >= 15) _stop();
    });
  }

  Future<void> _stop() async {
    final path = await _rec.stop();
    setState(() {
      _recording = false;
      _msg = null;
    });
    if (path != null) await _analyse(File(path));
  }

  Future<void> _analyse(File wavFile) async {
    final session = widget.lab.session;
    if (session == null) {
      setState(() => _msg = 'Prima carica il modello in memoria (pagina iniziale).');
      return;
    }
    setState(() => _busy = true);
    try {
      final bytes = await wavFile.readAsBytes();
      final sw = Stopwatch()..start();
      final fr = await compute(_features, _FeatJob(bytes, widget.lab.window, widget.lab.mel));
      final featMs = sw.elapsedMilliseconds;
      sw
        ..reset()
        ..start();
      final input = await OrtValue.fromList(fr.f.values, [1, fr.f.frames, 160]);
      final mask = await OrtValue.fromList(fr.f.mask, [1, fr.f.frames]);
      final out = await session.run({'input_features': input, 'attention_mask': mask});
      final ph = out['phonemes']!;
      final logits = (await ph.asFlattenedList()).map((e) => (e as num).toDouble()).toList();
      final modelMs = sw.elapsedMilliseconds;
      final frames = ph.shape[1], classes = ph.shape[2];
      for (final v in [input, mask, ...out.values]) {
        await v.dispose();
      }
      final predicted = greedyDecode(logits, frames, classes, widget.lab.vocab);
      _lastPredicted = predicted;
      final corr = correct(widget.ayah, predicted, fixed: _fixed);
      final a = Analysis(predicted, corr, fr.seconds, featMs, modelMs, int.parse(_mb(ProcessInfo.currentRss)),
          int.parse(_mb(ProcessInfo.maxRss)), fr.rate);
      setState(() => _result = a);
      await _save(bytes, a);
    } catch (e) {
      setState(() => _msg = 'Errore: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// Keeps every take and its result for the evaluation (Android/data/it.rateel.tajweed_lab/files/takes).
  Future<void> _save(Uint8List wav, Analysis a) async {
    final base = await getExternalStorageDirectory() ?? await getApplicationDocumentsDirectory();
    final dir = Directory('${base.path}/takes');
    await dir.create(recursive: true);
    final stamp = DateTime.now().toIso8601String().replaceAll(':', '-').split('.').first;
    final name = '${widget.ayah.sura}_${widget.ayah.aya}_$stamp';
    await File('${dir.path}/$name.wav').writeAsBytes(wav);
    await File('${dir.path}/$name.json').writeAsString(const JsonEncoder.withIndent(' ').convert({
      'sura': widget.ayah.sura,
      'aya': widget.ayah.aya,
      'predicted': a.predicted,
      'reference': a.correction.variant.ph,
      'reading': a.correction.variant.labels,
      'errors': [for (final e in a.correction.errors) e.toJson()],
      'audio_s': a.audioSeconds,
      'record_rate': a.recordRate,
      'features_ms': a.featMs,
      'model_ms': a.modelMs,
      'threads': widget.lab.threads,
      'rss_mb': a.rssMb,
      'max_rss_mb': a.maxRssMb,
      'device': Platform.operatingSystemVersion,
    }));
  }

  @override
  Widget build(BuildContext context) {
    final a = _result;
    return Scaffold(
      appBar: AppBar(title: Text('${widget.ayah.suraName} ${widget.ayah.sura}:${widget.ayah.aya}')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        _AyahText(text: widget.ayah.uthmani, errors: a?.correction.errors ?? const []),
        const SizedBox(height: 16),
        Wrap(spacing: 8, runSpacing: 8, alignment: WrapAlignment.center, children: [
          OutlinedButton.icon(
              onPressed: () => _player.play(UrlSource(_everyayah)),
              icon: const Icon(Icons.volume_up),
              label: const Text('Ascolta al-Husary')),
          FilledButton.icon(
              onPressed: _busy ? null : _toggleRecord,
              style: _recording ? FilledButton.styleFrom(backgroundColor: Colors.red.shade700) : null,
              icon: Icon(_recording ? Icons.stop : Icons.mic),
              label: Text(_recording ? 'Stop e analizza' : 'Registra')),
        ]),
        SwitchListTile(
          title: const Text('Lettura fissa (عارض 4 · منفصل 4 · متصل 4)'),
          subtitle: const Text('Spento: ogni lunghezza lecita dei mudud è accettata (decisione del 28/11).'),
          value: _fixed,
          onChanged: (v) => setState(() {
            _fixed = v;
            final r = _result, p = _lastPredicted;
            if (r != null && p != null) {
              _result = Analysis(p, correct(widget.ayah, p, fixed: v), r.audioSeconds, r.featMs, r.modelMs, r.rssMb,
                  r.maxRssMb, r.recordRate);
            }
          }),
        ),
        if (_busy) const Padding(padding: EdgeInsets.all(16), child: LinearProgressIndicator()),
        if (_msg != null) Padding(padding: const EdgeInsets.all(8), child: Text(_msg!)),
        if (a != null) ..._resultView(a),
        const SizedBox(height: 24),
        Text(aiNoticeAr, textDirection: TextDirection.rtl, style: Theme.of(context).textTheme.bodySmall),
      ]),
    );
  }

  List<Widget> _resultView(Analysis a) {
    final errs = a.correction.errors;
    final rtf = a.modelMs / 1000 / a.audioSeconds;
    return [
      const SizedBox(height: 12),
      Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(errs.isEmpty ? 'Nessun errore trovato · لا يوجد خطأ' : '${errs.length} errori · أخطاء',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 6),
            Text(
                'Audio ${a.audioSeconds.toStringAsFixed(1)} s · feature ${a.featMs} ms · modello ${a.modelMs} ms '
                '(×${rtf.toStringAsFixed(2)} tempo reale) · RAM ${a.rssMb} MB (picco ${a.maxRssMb} MB)'
                '${a.recordRate != 16000 ? ' · registrato a ${a.recordRate} Hz, ricampionato' : ''}',
                style: Theme.of(context).textTheme.bodySmall),
            Text('Lettura più vicina: ${a.correction.variant.labelText}',
                textDirection: TextDirection.rtl, style: Theme.of(context).textTheme.bodySmall),
          ]),
        ),
      ),
      for (final e in errs) _ErrorTile(error: e, uthmani: widget.ayah.uthmani),
      ExpansionTile(title: const Text('Fonemi (dettaglio)'), children: [
        _phRow('Atteso', a.correction.variant.ph),
        _phRow('Sentito', a.predicted),
      ]),
    ];
  }

  Widget _phRow(String label, String ph) => ListTile(
      dense: true,
      title: Text(label),
      subtitle: SelectableText(ph, textDirection: TextDirection.rtl, style: const TextStyle(fontSize: 18)));
}

/// The ayah, with the words that have an error in red.
class _AyahText extends StatelessWidget {
  final String text;
  final List<ReciterError> errors;
  const _AyahText({required this.text, required this.errors});

  @override
  Widget build(BuildContext context) {
    final bad = List<bool>.filled(text.length + 1, false);
    for (final e in errors) {
      final (s, t) = wordSpan(text, e.uthmaniPos[0], e.uthmaniPos[1]);
      for (var i = s; i < t; i++) {
        bad[i] = true;
      }
    }
    final spans = <TextSpan>[];
    var i = 0;
    while (i < text.length) {
      var j = i;
      while (j < text.length && bad[j] == bad[i]) {
        j++;
      }
      spans.add(TextSpan(
          text: text.substring(i, j),
          style: bad[i] ? const TextStyle(color: Color(0xFFFF6B6B), decoration: TextDecoration.underline) : null));
      i = j;
    }
    return Text.rich(TextSpan(children: spans, style: const TextStyle(fontSize: 30, height: 1.9)),
        textDirection: TextDirection.rtl, textAlign: TextAlign.center);
  }
}

/// Whole word(s) around the Uthmani characters [start, end).
(int, int) wordSpan(String text, int start, int end) {
  if (end <= start) end = start + 1;
  var s = start.clamp(0, text.length);
  var t = end.clamp(0, text.length);
  while (s > 0 && text[s - 1] != ' ') {
    s--;
  }
  while (t < text.length && text[t] != ' ') {
    t++;
  }
  return (s, t);
}

const _typeAr = {'tajweed': 'خطأ تجويد', 'normal': 'خطأ في الحرف', 'tashkeel': 'خطأ في الحركة'};
const _typeIt = {'tajweed': 'tajweed', 'normal': 'lettera', 'tashkeel': 'haraka'};
const _speechAr = {'insert': 'زيادة', 'delete': 'نقص', 'replace': 'إبدال'};

class _ErrorTile extends StatelessWidget {
  final ReciterError error;
  final String uthmani;
  const _ErrorTile({required this.error, required this.uthmani});

  @override
  Widget build(BuildContext context) {
    final e = error;
    final (s, t) = wordSpan(uthmani, e.uthmaniPos[0], e.uthmaniPos[1]);
    final word = uthmani.substring(s, t);
    final rules = e.refRules.map((r) => r.ar).join('، ');
    final lens = e.expectedLen != null ? ' · المتوقع ${e.expectedLen} حركات، المنطوق ${e.predictedLen}' : '';
    return Card(
      child: ListTile(
        title: Text('${_typeAr[e.errorType]} / ${_speechAr[e.speechErrorType]} في «$word»',
            textDirection: TextDirection.rtl),
        subtitle: Text(
            'المتوقع «${e.expectedPh}» والمنطوق «${e.predictedPh}»$lens${rules.isNotEmpty ? ' ← $rules' : ''}\n'
            '(${_typeIt[e.errorType]})',
            textDirection: TextDirection.rtl),
      ),
    );
  }
}
