// Rateel tajweed desk: an interactive PC app to try the Quran Muaalem model (test tool, not Rateel).
// Your recitation and al-Husary's side by side, every letter placed in time, hover / click / A-B listening.
import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tajweed_core/explain.dart';
import 'package:tajweed_core/timeline.dart';

import 'issues.dart';
import 'screens.dart';
import 'state.dart';
import 'track.dart';

const aiNoticeAr =
    'هذا المعلّم القرآني نموذج ذكاء اصطناعي قد يخطئ؛ فهو للإعانة فقط ولا يُعتمد عليه، وليس بديلاً عن معلّمٍ مُتقِنٍ مُجاز؛ لأنّ القرآن لا يُؤخذ إلا بالمشافهة.';
const aiNoticeIt =
    "Questo Insegnante del Corano è un modello di intelligenza artificiale che può commettere errori. È destinato solo "
    "all'assistenza e non deve essere considerato affidabile. Non sostituisce un insegnante competente e debitamente "
    "autorizzato, poiché il Corano si riceve solo attraverso la trasmissione orale (mushafahah).";

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const DeskApp());
}

class DeskApp extends StatelessWidget {
  const DeskApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Rateel · laboratorio tajweed',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1F6B4F), brightness: Brightness.dark, surface: kCard),
          scaffoldBackgroundColor: kBg,
          fontFamily: 'ReadexPro',
          useMaterial3: true,
        ),
        home: const DeskHome(),
      );
}

class DeskHome extends StatefulWidget {
  const DeskHome({super.key});
  @override
  State<DeskHome> createState() => _DeskHomeState();
}

class _DeskHomeState extends State<DeskHome> {
  final lab = LabState();
  bool _ready = false;
  String _filter = '';
  final _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    await lab.init();
    setState(() => _ready = true);
    await lab.openAyah(lab.ayat.first);
    await _demo();
    if (mounted && Platform.environment['LAB_DEMO'] == null) _notice(first: true);
  }

  /// Review aid for screenshots: env LAB_DEMO=sura:aya, LAB_DEMO_WAV=file, LAB_DEMO_SELECT=reference group.
  Future<void> _demo() async {
    final d = Platform.environment['LAB_DEMO'];
    if (d == null) return;
    final p = d.split(':').map(int.parse).toList();
    await lab.openAyah(lab.ayat.firstWhere((a) => a.sura == p[0] && a.aya == p[1]));
    while (lab.engine.loaded == false && lab.modelPath != null && lab.loadingModel) {
      await Future<void>.delayed(const Duration(milliseconds: 200));
    }
    final wav = Platform.environment['LAB_DEMO_WAV'];
    if (wav != null) await lab.openWav(wav, label: 'La tua registrazione');
    if (Platform.environment['LAB_DEMO_FIXED'] != null) lab.setFixedReading(true);
    final sel = Platform.environment['LAB_DEMO_SELECT'];
    final m = lab.mine?.analysis;
    if (sel == 'err' && m != null) {
      final r = List.generate(m.refGroups.length, (i) => i).where((i) => m.errorsOfRef[i].isNotEmpty).firstOrNull;
      lab.select(r);
    } else if (sel != null) {
      lab.select(int.parse(sel));
    }
  }

  void _notice({bool first = false}) => showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Avviso IA · تنبيه'),
          content: SizedBox(
            width: 560,
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              const Text(aiNoticeAr, textDirection: TextDirection.rtl, style: TextStyle(fontSize: 20, height: 1.6)),
              const SizedBox(height: 12),
              const Text(aiNoticeIt),
              const SizedBox(height: 12),
              Text('Strumento di prova di Rateel. Modello Quran Muaalem © obadx e contributori, licenza QML 1.0.',
                  style: Theme.of(ctx).textTheme.bodySmall),
            ]),
          ),
          actions: [
            TextButton(onPressed: () => _licence(ctx), child: const Text('Licenza')),
            FilledButton(onPressed: () => Navigator.pop(ctx), child: Text(first ? 'Ho capito' : 'Chiudi')),
          ],
        ),
      );

  Future<void> _licence(BuildContext ctx) async {
    final n = await rootBundle.loadString('packages/tajweed_core/assets/licence/QML-NOTICE.txt');
    final l = await rootBundle.loadString('packages/tajweed_core/assets/licence/QML-LICENSE.txt');
    if (!ctx.mounted) return;
    await showDialog(
        context: ctx,
        builder: (c) => AlertDialog(
              content: SizedBox(
                  width: 700,
                  height: 600,
                  child: SingleChildScrollView(child: SelectableText('$n\n\n$l', style: const TextStyle(fontSize: 12)))),
              actions: [TextButton(onPressed: () => Navigator.pop(c), child: const Text('Chiudi'))],
            ));
  }

  Future<void> _pickModel() async {
    final r = await FilePicker.pickFiles(dialogTitle: 'Scegli muaalem-v3_2-int8.onnx');
    if (r.isNotEmpty && r.single.path != null) await lab.setModel(r.single.path!);
  }

  Future<void> _pickWav() async {
    final r = await FilePicker.pickFiles(dialogTitle: 'Apri una registrazione WAV', type: FileType.custom, allowedExtensions: ['wav']);
    if (r.isNotEmpty && r.single.path != null) await lab.openWav(r.single.path!);
  }

  KeyEventResult _key(FocusNode _, KeyEvent e) {
    if (e is! KeyDownEvent) return KeyEventResult.ignored;
    final k = e.logicalKey;
    final shift = HardwareKeyboard.instance.isShiftPressed;
    final sel = lab.selectedRef;
    if (k == LogicalKeyboardKey.space) {
      lab.togglePlay(lab.mine != null && !shift ? Who.me : Who.husary);
    } else if (k == LogicalKeyboardKey.keyH) {
      lab.togglePlay(Who.husary);
    } else if (k == LogicalKeyboardKey.keyR) {
      lab.toggleRecord();
    } else if (k == LogicalKeyboardKey.arrowLeft) {
      lab.moveSelection(lab.rtlTime ? 1 : -1);
    } else if (k == LogicalKeyboardKey.arrowRight) {
      lab.moveSelection(lab.rtlTime ? -1 : 1);
    } else if (k == LogicalKeyboardKey.enter && sel != null) {
      lab.playRef(shift ? Who.husary : Who.me, sel);
    } else if (k == LogicalKeyboardKey.keyB && sel != null) {
      lab.playAB(sel, word: shift);
    } else if (k == LogicalKeyboardKey.keyW && sel != null) {
      lab.playRef(shift ? Who.husary : Who.me, sel, word: true);
    } else if (k == LogicalKeyboardKey.keyF) {
      lab.setFixedReading(!lab.fixedReading);
    } else if (k == LogicalKeyboardKey.equal || k == LogicalKeyboardKey.numpadAdd) {
      lab.zoom(1.25);
    } else if (k == LogicalKeyboardKey.minus || k == LogicalKeyboardKey.numpadSubtract) {
      lab.zoom(0.8);
    } else if (k == LogicalKeyboardKey.digit1) {
      lab.setSpeed(0.5);
    } else if (k == LogicalKeyboardKey.digit2) {
      lab.setSpeed(0.75);
    } else if (k == LogicalKeyboardKey.digit3) {
      lab.setSpeed(1.0);
    } else if (k == LogicalKeyboardKey.escape) {
      lab.stop();
      lab.select(null);
    } else {
      return KeyEventResult.ignored;
    }
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) return const Scaffold(backgroundColor: kBg, body: Center(child: CircularProgressIndicator()));
    return Focus(
      focusNode: _focus,
      autofocus: true,
      onKeyEvent: _key,
      child: ListenableBuilder(
        listenable: lab,
        builder: (context, _) => Scaffold(
          backgroundColor: kBg,
          body: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            SizedBox(width: 320, child: _sidebar(context)),
            Expanded(child: _main(context)),
          ]),
        ),
      ),
    );
  }

  // ------------------------------------------------------------ sidebar: model + ayat
  Widget _sidebar(BuildContext context) {
    final list = lab.ayat
        .where((a) => _filter.isEmpty || a.uthmani.contains(_filter) || a.suraName.contains(_filter) || '${a.sura}:${a.aya}'.contains(_filter))
        .toList();
    final loaded = lab.engine.loaded;
    final nErr = lab.mine?.analysis == null ? null : issuesOf(lab.mine!.analysis!).length;
    final rows = <Widget>[];
    int? sura;
    for (final a in list) {
      if (a.sura != sura) {
        sura = a.sura;
        rows.add(Padding(
          padding: const EdgeInsets.fromLTRB(8, 14, 8, 4),
          child: Text('سورة ${a.suraName}', textDirection: TextDirection.rtl, style: const TextStyle(fontSize: 12, color: kMuted)),
        ));
      }
      final sel = identical(a, lab.ayah);
      rows.add(Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Material(
          color: sel ? const Color(0xFF1F3A2F) : Colors.transparent,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10), side: sel ? const BorderSide(color: kGreen) : BorderSide.none),
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: () {
              lab.openAyah(a);
              _focus.requestFocus();
            },
            child: Container(
              constraints: const BoxConstraints(minHeight: 48),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Row(children: [
                Text(sel && nErr != null ? '${a.sura}:${a.aya} · ${nErr == 0 ? 'ok' : '$nErr err.'}' : '${a.sura}:${a.aya}',
                    style: TextStyle(fontSize: 13, color: sel ? kMint : kMuted)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(a.uthmani,
                      textDirection: TextDirection.rtl,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontFamily: kQuran, fontSize: 18, color: kText)),
                ),
              ]),
            ),
          ),
        ),
      ));
    }
    return Container(
      decoration: const BoxDecoration(color: kSide, border: Border(right: BorderSide(color: kLine))),
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [
          const Expanded(child: Text('Laboratorio tajweed', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500))),
          IconButton(tooltip: 'Avviso IA e licenza', icon: const Icon(Icons.info_outline, color: kMuted), onPressed: _notice),
        ]),
        const SizedBox(height: 8),
        Row(children: [
          Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(shape: BoxShape.circle, color: loaded ? kGreen : (lab.loadingModel ? kAmber : kRed))),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
                loaded
                    ? (lab.modelInfo ?? 'Modello pronto')
                    : (lab.loadingModel ? 'Carico il modello…' : (lab.modelInfo ?? 'Modello non caricato')),
                style: const TextStyle(fontSize: 13, color: kMuted)),
          ),
        ]),
        if (lab.loadingModel) const Padding(padding: EdgeInsets.only(top: 8), child: LinearProgressIndicator(color: kGreen)),
        const SizedBox(height: 10),
        Row(children: [
          OutlinedButton(
            onPressed: lab.loadingModel ? null : _pickModel,
            style: OutlinedButton.styleFrom(foregroundColor: kText, side: const BorderSide(color: kLine2), minimumSize: const Size(0, 40)),
            child: Text(loaded ? 'Cambia modello' : 'Scegli .onnx'),
          ),
          const SizedBox(width: 10),
          DropdownButton<int>(
            value: lab.threads,
            underline: const SizedBox(),
            items: [for (final n in {1, 2, 4, 6, 8, lab.threads}.toList()..sort()) DropdownMenuItem(value: n, child: Text('$n thread'))],
            onChanged: lab.loadingModel ? null : (v) => lab.setThreads(v!),
          ),
        ]),
        const SizedBox(height: 14),
        TextField(
          decoration: InputDecoration(
            isDense: true,
            prefixIcon: const Icon(Icons.search, color: kMuted),
            hintText: 'Sura, ayah o parola',
            filled: true,
            fillColor: kBg,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: kLine)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: kLine)),
          ),
          onChanged: (v) => setState(() => _filter = v.trim()),
        ),
        const SizedBox(height: 4),
        Expanded(child: ListView(children: rows)),
      ]),
    );
  }

  // ------------------------------------------------------------ main area
  Widget _main(BuildContext context) {
    final ayah = lab.ayah;
    if (ayah == null) return const SizedBox();
    final showResult = lab.mine?.analysis != null && !lab.recording;
    return Padding(
      padding: const EdgeInsets.fromLTRB(40, 28, 40, 0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        StepsBar(lab: lab),
        if (lab.status != null)
          Padding(padding: const EdgeInsets.only(top: 10), child: Text(lab.status!, style: const TextStyle(color: Color(0xFFFFC46B)))),
        const SizedBox(height: 20),
        Expanded(
          child: SingleChildScrollView(
            child: showResult ? RisultatoView(lab: lab, details: _details(context)) : RecitaView(lab: lab, onOpenWav: _pickWav),
          ),
        ),
      ]),
    );
  }

  /// The technical view of before: both tracks, letter details, errors, mudud.
  Widget _details(BuildContext context) => Container(
        decoration: BoxDecoration(color: kSide, borderRadius: BorderRadius.circular(16), border: Border.all(color: kLine)),
        child: ExpansionTile(
          shape: const Border(),
          collapsedShape: const Border(),
          title: const Text('Dettagli tecnici: forme d\'onda e lettere nel tempo', style: TextStyle(fontSize: 15, color: kMuted)),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          children: [
            _toolbar(context),
            TrackView(lab: lab, who: Who.me),
            TrackView(lab: lab, who: Who.husary),
            SizedBox(height: 340, child: _BottomPanel(lab: lab)),
          ],
        ),
      );

  Widget _toolbar(BuildContext context) {
    return Wrap(spacing: 8, runSpacing: 8, crossAxisAlignment: WrapCrossAlignment.center, children: [
      OutlinedButton.icon(
        onPressed: lab.mine == null ? null : () => lab.togglePlay(Who.me),
        icon: Icon(lab.playing == Who.me ? Icons.stop : Icons.play_arrow),
        label: const Text('Tu (Spazio)'),
      ),
      OutlinedButton.icon(
        onPressed: () => lab.togglePlay(Who.husary),
        icon: Icon(lab.playing == Who.husary ? Icons.stop : Icons.play_arrow),
        label: const Text('al-Husary (H)'),
      ),
      SegmentedButton<double>(
        segments: const [
          ButtonSegment(value: 0.5, label: Text('0.5×')),
          ButtonSegment(value: 0.75, label: Text('0.75×')),
          ButtonSegment(value: 1.0, label: Text('1×')),
        ],
        selected: {lab.speed},
        onSelectionChanged: (s) => lab.setSpeed(s.first),
        showSelectedIcon: false,
      ),
      IconButton(tooltip: 'Zoom − (−)', onPressed: () => lab.zoom(0.8), icon: const Icon(Icons.zoom_out)),
      IconButton(tooltip: 'Zoom + (+)', onPressed: () => lab.zoom(1.25), icon: const Icon(Icons.zoom_in)),
      FilterChip(
        label: const Text('Lettura fissa 4/4/4 (F)'),
        selected: lab.fixedReading,
        onSelected: lab.setFixedReading,
        tooltip: 'Spento: ogni lunghezza lecita dei mudud è accettata (decisione del 28/11)',
      ),
      FilterChip(label: const Text('Tempo da destra'), selected: lab.rtlTime, onSelected: lab.setRtl),
      OutlinedButton.icon(onPressed: _pickWav, icon: const Icon(Icons.folder_open), label: const Text('Apri WAV')),
      if (lab.busy) const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
      const Tooltip(
        message: 'Spazio: ascolta te · H: al-Husary · R: registra · ←/→: lettera precedente/successiva\n'
            'Invio: ascolta la lettera (Maiusc: al-Husary) · W: la parola · B: confronto A/B (Maiusc: parola)\n'
            'F: lettura fissa · +/−: zoom · 1/2/3: velocità · Esc: stop',
        child: Icon(Icons.keyboard, size: 22),
      ),
    ]);
  }
}

/// Details of the selected letter, list of errors, mudud comparison.
class _BottomPanel extends StatelessWidget {
  final LabState lab;
  const _BottomPanel({required this.lab});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Card(
        margin: const EdgeInsets.only(top: 6),
        child: Column(children: [
          TabBar(tabs: [
            Tab(text: 'Lettera selezionata'),
            Tab(text: 'Errori (${lab.mine?.analysis?.correction.errors.length ?? '–'})'),
            const Tab(text: 'Mudud: tu vs al-Husary'),
          ]),
          Expanded(
            child: TabBarView(children: [
              _Detail(lab: lab),
              _Errors(lab: lab),
              _Mudud(lab: lab),
            ]),
          ),
        ]),
      ),
    );
  }
}

const _typeAr = {'tajweed': 'خطأ تجويد', 'normal': 'خطأ في الحرف', 'tashkeel': 'خطأ في الحركة'};
const _speechAr = {'insert': 'زيادة', 'delete': 'نقص', 'replace': 'إبدال'};

/// Keeps an Arabic piece in its own direction inside an Italian line.
String iso(String s) => '\u2068$s\u2069';

String describe(ReciterError e) {
  final rules = e.refRules.map((r) => r.ar).join('، ');
  final lens = e.expectedLen != null ? ' · المتوقع ${e.expectedLen} حركات، المنطوق ${e.predictedLen}' : '';
  return '${_typeAr[e.errorType]} / ${_speechAr[e.speechErrorType]}: المتوقع «${e.expectedPh}» والمنطوق «${e.predictedPh}»'
      '$lens${rules.isNotEmpty ? ' ← $rules' : ''}';
}

class _Detail extends StatelessWidget {
  final LabState lab;
  const _Detail({required this.lab});

  String _dur((double, double)? s) => s == null ? '—' : '${((s.$2 - s.$1) * 1000).round()} ms';

  @override
  Widget build(BuildContext context) {
    final r = lab.selectedRef;
    final a = lab.mine?.analysis ?? lab.husary?.analysis;
    if (r == null || a == null || r >= a.refGroups.length) {
      return const Center(
          child: Text('Passa il mouse o clicca su una lettera (nelle tracce o nel testo). ←/→ per spostarti, B per il confronto A/B.'));
    }
    final mineA = lab.mine?.analysis;
    final husA = lab.husary?.analysis;
    final rules = a.correction.variant.groupRules[r];
    final mySpan = lab.spanOf(lab.mine, r), husSpan = lab.spanOf(lab.husary, r);
    final myGroup = mineA == null || mineA.refToPred[r] < 0 ? null : mineA.groups[mineA.refToPred[r]];
    final husGroup = husA == null || husA.refToPred[r] < 0 ? null : husA.groups[husA.refToPred[r]];
    final errs = mineA?.errorsOfRef[r] ?? const <ReciterError>[];
    final t = Theme.of(context).textTheme;
    final (u0, u1) = a.uthmaniOfRef(r);
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Column(children: [
          Text(lab.ayah!.uthmani.substring(u0, u1), style: const TextStyle(fontSize: 44), textDirection: TextDirection.rtl),
          Text('atteso ${iso(groupLabel(a.refGroups[r]))}', style: t.bodySmall),
        ]),
        const SizedBox(width: 24),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            if (rules.isNotEmpty)
              Text('Regola: ${rules.map((x) => '${iso(x.ar)} (${x.en}${x.correctness == 'count' ? ', ${x.goldenLen} tempi' : ''})').join(' · ')}'),
            const SizedBox(height: 6),
            Text('Tu: ${myGroup == null ? (mineA == null ? 'nessuna registrazione' : 'non si sente') : '${iso(groupLabel(myGroup.text))} · ${_dur(mySpan)} · confidenza ${(myGroup.confidence * 100).round()}%'}'),
            Text('al-Husary: ${husGroup == null ? '—' : '${iso(groupLabel(husGroup.text))} · ${_dur(husSpan)}'}'),
            const SizedBox(height: 6),
            if (errs.isEmpty && mineA != null)
              const Text('Nessun errore su questa lettera.', style: TextStyle(color: Color(0xFF7FD1B9))),
            for (final e in errs)
              Text(describe(e), textDirection: TextDirection.rtl, style: const TextStyle(color: Color(0xFFFFB26B))),
            const SizedBox(height: 8),
            Wrap(spacing: 8, children: [
              FilledButton.tonalIcon(onPressed: () => lab.playRef(Who.me, r), icon: const Icon(Icons.play_arrow), label: const Text('Tu (Invio)')),
              FilledButton.tonalIcon(
                  onPressed: () => lab.playRef(Who.husary, r), icon: const Icon(Icons.play_arrow), label: const Text('al-Husary (Maiusc+Invio)')),
              FilledButton.icon(onPressed: () => lab.playAB(r), icon: const Icon(Icons.compare_arrows), label: const Text('A/B (B)')),
              OutlinedButton.icon(
                  onPressed: () => lab.playAB(r, word: true), icon: const Icon(Icons.text_fields), label: const Text('A/B parola (Maiusc+B)')),
            ]),
          ]),
        ),
      ]),
    );
  }
}

class _Errors extends StatelessWidget {
  final LabState lab;
  const _Errors({required this.lab});
  @override
  Widget build(BuildContext context) {
    final a = lab.mine?.analysis;
    if (a == null) return const Center(child: Text('Registra o apri una registrazione per vedere gli errori.'));
    final errs = a.correction.errors;
    if (errs.isEmpty) {
      return Center(child: Text('Nessun errore trovato · لا يوجد خطأ\nLettura più vicina: ${a.correction.variant.labelText}',
          textAlign: TextAlign.center));
    }
    return ListView(children: [
      for (final e in errs)
        ListTile(
          dense: true,
          leading: Icon(Icons.circle,
              size: 12,
              color: e.errorType == 'tajweed'
                  ? statusColor[GroupStatus.tajweed]
                  : (e.errorType == 'normal' ? statusColor[GroupStatus.letter] : statusColor[GroupStatus.haraka])),
          title: Text(describe(e), textDirection: TextDirection.rtl),
          subtitle: Text('«${_word(lab.ayah!.uthmani, e.uthmaniPos)}» · clic: seleziona e confronta A/B', textDirection: TextDirection.rtl),
          onTap: () {
            final r = _refOf(a, e);
            if (r == null) return;
            lab.select(r);
            lab.playAB(r);
          },
        ),
    ]);
  }

  int? _refOf(TakeAnalysis a, ReciterError e) {
    for (var r = 0; r < a.refGroups.length; r++) {
      if (a.refStartPh[r] >= e.phPos[0] && a.refStartPh[r] < (e.phPos[1] > e.phPos[0] ? e.phPos[1] : e.phPos[0] + 1)) return r;
    }
    return null;
  }

  String _word(String text, List<int> pos) {
    var s = pos[0].clamp(0, text.length), e = pos[1].clamp(s, text.length);
    while (s > 0 && text[s - 1] != ' ') {
      s--;
    }
    while (e < text.length && text[e] != ' ') {
      e++;
    }
    return text.substring(s, e);
  }
}

class _Mudud extends StatelessWidget {
  final LabState lab;
  const _Mudud({required this.lab});
  @override
  Widget build(BuildContext context) {
    final a = lab.mine?.analysis ?? lab.husary?.analysis;
    if (a == null) return const Center(child: Text('Serve il modello caricato.'));
    final rows = <int>[
      for (var r = 0; r < a.refGroups.length; r++)
        if (a.correction.variant.groupRules[r].any((x) => x.correctness == 'count')) r
    ];
    if (rows.isEmpty) return const Center(child: Text('Nessun mad in questa ayah.'));
    double dur(Take? t, int r) {
      final s = lab.spanOf(t, r);
      return s == null ? 0 : s.$2 - s.$1;
    }

    var maxD = 0.3;
    for (final r in rows) {
      for (final t in [lab.mine, lab.husary]) {
        if (dur(t, r) > maxD) maxD = dur(t, r);
      }
    }
    return ListView(padding: const EdgeInsets.all(12), children: [
      for (final r in rows)
        InkWell(
          onTap: () {
            lab.select(r);
            lab.playAB(r);
          },
          onHover: (h) => lab.hover(h ? r : null),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(children: [
              SizedBox(
                width: 220,
                child: Text(
                    '${lab.ayah!.uthmani.substring(a.uthmaniOfRef(r).$1, a.uthmaniOfRef(r).$2)}  ·  '
                    '${a.correction.variant.groupRules[r].first.ar} (${a.correction.variant.groupRules[r].first.goldenLen})',
                    textDirection: TextDirection.rtl),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(children: [
                  _bar(context, 'Tu', dur(lab.mine, r), maxD, const Color(0xFF7FD1B9), r == lab.selectedRef),
                  const SizedBox(height: 3),
                  _bar(context, 'Husary', dur(lab.husary, r), maxD, const Color(0xFFD9C27F), r == lab.selectedRef),
                ]),
              ),
            ]),
          ),
        ),
    ]);
  }

  Widget _bar(BuildContext c, String who, double d, double max, Color color, bool sel) => Row(children: [
        SizedBox(width: 56, child: Text(who, style: Theme.of(c).textTheme.bodySmall)),
        Expanded(
          child: LayoutBuilder(
            builder: (_, k) => Align(
              alignment: Alignment.centerLeft,
              child: Container(
                width: k.maxWidth * (d / max),
                height: 12,
                decoration: BoxDecoration(
                    color: color.withValues(alpha: sel ? 1 : 0.7),
                    borderRadius: BorderRadius.circular(3),
                    border: sel ? Border.all(color: Colors.white) : null),
              ),
            ),
          ),
        ),
        SizedBox(width: 64, child: Text(d == 0 ? '—' : '${(d * 1000).round()} ms', textAlign: TextAlign.end)),
      ]);
}
