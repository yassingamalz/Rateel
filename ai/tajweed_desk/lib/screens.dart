// The two main screens of the desk app (owner's approved mockup, 2026-11-28):
// 1 · Recita: the ayah and one big microphone button; 2 · Risultato: summary, the ayah with the words to review,
// one card per error in plain words with A/B listening; the technical tracks are folded in «Dettagli tecnici».
import 'package:material_ui/material_ui.dart';

import 'issues.dart';
import 'state.dart';

const kBg = Color(0xFF0F1A16);
const kSide = Color(0xFF12201B);
const kCard = Color(0xFF16241F);
const kLine = Color(0xFF22362E);
const kLine2 = Color(0xFF3A554A);
const kText = Color(0xFFE8F0EC);
const kMuted = Color(0xFF9FB8AE);
const kGreen = Color(0xFF3FBF8A);
const kMint = Color(0xFF7FD1B9);
const kAmber = Color(0xFFFFB547);
const kRed = Color(0xFFFF8C8C);
const kGold = Color(0xFFD9C27F);
const kQuran = 'AmiriQuran';

Color issueColor(IssueKind k) => k == IssueKind.tajweed ? kAmber : kRed;

// ------------------------------------------------------------------ steps
class StepsBar extends StatelessWidget {
  final LabState lab;
  const StepsBar({super.key, required this.lab});
  @override
  Widget build(BuildContext context) {
    final done = [lab.engine.loaded, lab.ayah != null, lab.mine?.analysis != null, false];
    final active = !lab.engine.loaded ? 0 : (lab.mine?.analysis != null ? 3 : 2);
    const names = ['Modello', 'Ayah', 'Recita', 'Risultato'];
    final items = <Widget>[];
    for (var i = 0; i < 4; i++) {
      if (i > 0) items.add(const Text('—', style: TextStyle(color: kLine2)));
      final isActive = i == active, isDone = done[i] && !isActive;
      items.add(Row(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 26,
          height: 26,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? kGreen : (isDone ? const Color(0xFF1F3A2F) : null),
            border: isActive || isDone ? null : Border.all(color: kLine2),
          ),
          child: isDone
              ? const Icon(Icons.check, size: 15, color: kMint)
              : Text('${i + 1}',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isActive ? kBg : kMuted)),
        ),
        const SizedBox(width: 8),
        Text(names[i],
            style: TextStyle(
                fontSize: 14,
                color: isActive ? Colors.white : (isDone ? kMint : kMuted),
                fontWeight: isActive ? FontWeight.w500 : FontWeight.w400)),
      ]));
    }
    return Wrap(spacing: 12, runSpacing: 8, crossAxisAlignment: WrapCrossAlignment.center, children: items);
  }
}

// ------------------------------------------------------------------ 1 · recita
class RecitaView extends StatelessWidget {
  final LabState lab;
  final VoidCallback onOpenWav;
  const RecitaView({super.key, required this.lab, required this.onOpenWav});

  @override
  Widget build(BuildContext context) {
    final a = lab.ayah!;
    final rec = lab.recording;
    final analysing = lab.analysingMine;
    final secs = rec && lab.recStart != null ? DateTime.now().difference(lab.recStart!).inMilliseconds / 1000 : 0.0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
      decoration: BoxDecoration(color: kCard, borderRadius: BorderRadius.circular(20), border: Border.all(color: kLine)),
      child: Column(children: [
        Text('سورة ${a.suraName} · ${a.sura}:${a.aya}', style: const TextStyle(fontSize: 14, color: kMuted)),
        const SizedBox(height: 24),
        Text(a.uthmani,
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.center,
            style: const TextStyle(fontFamily: kQuran, fontSize: 60, height: 1.9, color: Color(0xFFF4F8F6))),
        const SizedBox(height: 36),
        if (analysing) ...[
          const SizedBox(width: 72, height: 72, child: CircularProgressIndicator(strokeWidth: 5, color: kGreen)),
          const SizedBox(height: 20),
          const Text('Analizzo la tua recitazione…', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
        ] else ...[
          Semantics(
            button: true,
            label: rec ? 'Ferma e analizza' : 'Registra',
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: lab.engine.loaded ? lab.toggleRecord : null,
              child: Container(
                width: 112,
                height: 112,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: !lab.engine.loaded ? kLine2 : (rec ? const Color(0xFFD9534F) : kGreen),
                  boxShadow: [BoxShadow(color: rec ? const Color(0xFF5A2323) : const Color(0xFF1F3A2F), spreadRadius: 10)],
                ),
                child: Icon(rec ? Icons.stop_rounded : Icons.mic, size: 48, color: rec ? Colors.white : kBg),
              ),
            ),
          ),
          const SizedBox(height: 26),
          Text(
              !lab.engine.loaded
                  ? 'Prima carica il modello (a sinistra)'
                  : (rec ? 'Registro… ${secs.toStringAsFixed(1)} s · premi di nuovo per finire' : 'Premi e recita l\'ayah'),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          const Text('Tasto R · si ferma da solo dopo 15 secondi', style: TextStyle(fontSize: 14, color: kMuted)),
        ],
        if (lab.mine?.error != null)
          Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text('Errore: ${lab.mine!.error}', style: const TextStyle(color: kRed))),
        const SizedBox(height: 32),
        Wrap(spacing: 12, runSpacing: 12, alignment: WrapAlignment.center, children: [
          _pill(Icons.play_arrow, lab.playing == Who.husary ? 'Ferma al-Husary' : 'Ascolta prima al-Husary',
              () => lab.togglePlay(Who.husary)),
          _pill(Icons.folder_open, 'Oppure apri un file WAV', onOpenWav),
        ]),
      ]),
    );
  }
}

Widget _pill(IconData icon, String label, VoidCallback? onTap, {bool primary = false}) => primary
    ? FilledButton.icon(
        onPressed: onTap,
        style: FilledButton.styleFrom(
            backgroundColor: kGreen, foregroundColor: kBg, minimumSize: const Size(0, 46), textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
        icon: Icon(icon, size: 19),
        label: Text(label))
    : OutlinedButton.icon(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
            foregroundColor: kText, side: const BorderSide(color: kLine2), minimumSize: const Size(0, 46), textStyle: const TextStyle(fontSize: 15)),
        icon: Icon(icon, size: 18),
        label: Text(label));

// ------------------------------------------------------------------ 2 · risultato
class RisultatoView extends StatelessWidget {
  final LabState lab;
  final Widget details;
  const RisultatoView({super.key, required this.lab, required this.details});

  @override
  Widget build(BuildContext context) {
    final a = lab.mine!.analysis!;
    final issues = issuesOf(a);
    final text = lab.ayah!.uthmani;
    // words of the ayah and the issues in each one
    final words = <(int, int)>[];
    var s = 0;
    for (var i = 0; i <= text.length; i++) {
      if (i == text.length || text[i] == ' ') {
        if (i > s) words.add((s, i));
        s = i + 1;
      }
    }
    final wordIssues = [
      for (final (ws, we) in words)
        [
          for (var k = 0; k < issues.length; k++)
            if (a.uthmaniOfRef(issues[k].ref).$1 < we && a.uthmaniOfRef(issues[k].ref).$2 > ws) k
        ]
    ];
    final nWordsBad = wordIssues.where((w) => w.isNotEmpty).length;
    final spans = <InlineSpan>[];
    for (var w = 0; w < words.length; w++) {
      final (ws, we) = words[w];
      final its = wordIssues[w];
      final color = its.isEmpty ? kMint : issueColor(issues[its.first].kind);
      spans.add(TextSpan(
        text: text.substring(ws, we),
        style: TextStyle(
            color: color,
            decoration: its.isEmpty ? null : TextDecoration.underline,
            decorationColor: color,
            decorationThickness: 2.5),
      ));
      for (final k in its) {
        spans.add(WidgetSpan(
          alignment: PlaceholderAlignment.top,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 2),
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
            decoration: BoxDecoration(color: issueColor(issues[k].kind), borderRadius: BorderRadius.circular(12)),
            child: Text('${k + 1}', style: const TextStyle(fontFamily: 'ReadexPro', fontSize: 15, color: kBg, fontWeight: FontWeight.w600)),
          ),
        ));
      }
      spans.add(const TextSpan(text: ' '));
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        decoration: BoxDecoration(color: kCard, borderRadius: BorderRadius.circular(20), border: Border.all(color: kLine)),
        child: Column(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
                color: issues.isEmpty ? const Color(0xFF1F3A2F) : const Color(0xFF3A2A12), borderRadius: BorderRadius.circular(999)),
            child: Text(
                issues.isEmpty
                    ? 'Nessun errore trovato · لا يوجد خطأ'
                    : '${issues.length} ${issues.length == 1 ? 'punto' : 'punti'} da rivedere su ${words.length} parole'
                        '${nWordsBad != issues.length ? ' ($nWordsBad parole)' : ''}',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: issues.isEmpty ? kMint : const Color(0xFFFFC46B))),
          ),
          const SizedBox(height: 10),
          Text.rich(TextSpan(children: spans, style: const TextStyle(fontFamily: kQuran, fontSize: 52, height: 2.0)),
              textDirection: TextDirection.rtl, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          Wrap(spacing: 18, runSpacing: 6, alignment: WrapAlignment.center, children: [
            _legend(kMint, 'corretto'),
            _legend(kAmber, 'regola di tajweed (durata)'),
            _legend(kRed, 'lettera o haraka'),
          ]),
          const SizedBox(height: 18),
          Wrap(spacing: 12, runSpacing: 12, alignment: WrapAlignment.center, children: [
            _pill(Icons.mic, 'Registra di nuovo (R)', lab.toggleRecord, primary: true),
            _pill(lab.playing == Who.me ? Icons.stop : Icons.play_arrow, 'Riascolta te', () => lab.togglePlay(Who.me)),
            _pill(lab.playing == Who.husary ? Icons.stop : Icons.play_arrow, 'Ascolta al-Husary', () => lab.togglePlay(Who.husary)),
          ]),
          const SizedBox(height: 10),
          Text('Lettura più vicina: \u2068${a.correction.variant.labelText}\u2069${lab.fixedReading ? ' (lettura fissa)' : ''}',
              style: const TextStyle(fontSize: 13, color: kMuted)),
        ]),
      ),
      if (issues.isNotEmpty) ...[
        const SizedBox(height: 24),
        const Text('Cosa rivedere', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
        const SizedBox(height: 12),
        for (var k = 0; k < issues.length; k++) ...[
          IssueCard(lab: lab, issue: issues[k], number: k + 1),
          const SizedBox(height: 14),
        ],
      ],
      const SizedBox(height: 12),
      details,
      const SizedBox(height: 16),
    ]);
  }

  Widget _legend(Color c, String t) => Row(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(3))),
        const SizedBox(width: 6),
        Text(t, style: const TextStyle(fontSize: 13, color: kMuted)),
      ]);
}

class IssueCard extends StatelessWidget {
  final LabState lab;
  final Issue issue;
  final int number;
  const IssueCard({super.key, required this.lab, required this.issue, required this.number});

  @override
  Widget build(BuildContext context) {
    final a = lab.mine!.analysis!;
    final c = issueColor(issue.kind);
    final text = lab.ayah!.uthmani;
    var (ws, we) = a.uthmaniOfRef(issue.ref);
    while (ws > 0 && text[ws - 1] != ' ') {
      ws--;
    }
    while (we < text.length && text[we] != ' ') {
      we++;
    }
    final selected = lab.selectedRef == issue.ref;
    return MouseRegion(
      onEnter: (_) => lab.hover(issue.ref),
      onExit: (_) => lab.hover(null),
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: kCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: selected ? c : Color.lerp(c, kCard, 0.65)!, width: selected ? 2 : 1),
        ),
        child: Wrap(spacing: 24, runSpacing: 16, crossAxisAlignment: WrapCrossAlignment.center, children: [
          SizedBox(
            width: 170,
            child: Column(children: [
              CircleAvatar(
                  radius: 16,
                  backgroundColor: c,
                  child: Text('$number', style: const TextStyle(color: kBg, fontWeight: FontWeight.w600))),
              Text(text.substring(ws, we),
                  textDirection: TextDirection.rtl, style: const TextStyle(fontFamily: kQuran, fontSize: 38, height: 1.7)),
            ]),
          ),
          ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 320, maxWidth: 560),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Wrap(spacing: 10, crossAxisAlignment: WrapCrossAlignment.end, children: [
                Text(issue.title, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w500)),
                if (issue.arabic.isNotEmpty)
                  Text(issue.arabic, textDirection: TextDirection.rtl, style: TextStyle(fontSize: 16, color: Color.lerp(c, Colors.white, 0.2))),
              ]),
              const SizedBox(height: 8),
              Text(issue.detail, style: const TextStyle(fontSize: 16, color: Color(0xFFC9D8D1))),
              const SizedBox(height: 12),
              _comparison(),
            ]),
          ),
          SizedBox(
            width: 270,
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              FilledButton.icon(
                onPressed: () {
                  lab.select(issue.ref);
                  lab.playAB(issue.ref, word: true);
                },
                style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF2E5A47), foregroundColor: Colors.white, minimumSize: const Size(0, 46)),
                icon: const Icon(Icons.compare_arrows, size: 19),
                label: const Text('Confronta: tu → al-Husary'),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: () {
                  lab.select(issue.ref);
                  lab.playRef(Who.me, issue.ref, word: true);
                },
                style: OutlinedButton.styleFrom(foregroundColor: kText, side: const BorderSide(color: kLine2), minimumSize: const Size(0, 44)),
                child: const Text('Solo tu'),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: () {
                  lab.select(issue.ref);
                  lab.playRef(Who.husary, issue.ref, word: true);
                },
                style: OutlinedButton.styleFrom(foregroundColor: kText, side: const BorderSide(color: kLine2), minimumSize: const Size(0, 44)),
                child: const Text('Solo al-Husary'),
              ),
            ]),
          ),
        ]),
      ),
    );
  }

  /// Your timing against al-Husary's: harakat as dots for a madd, otherwise bars of the duration.
  Widget _comparison() {
    final my = lab.spanOf(lab.mine, issue.ref), hus = lab.spanOf(lab.husary, issue.ref);
    String secs((double, double)? s) => s == null ? '—' : '${(s.$2 - s.$1).toStringAsFixed(2).replaceAll('.', ',')} s';
    final husA = lab.husary?.analysis;
    if (issue.expectedCount != null) {
      int? husCount;
      if (husA != null && husA.refToPred[issue.ref] >= 0) {
        husCount = countFor(lab.mine!.analysis!, issue.ref, husA.groups[husA.refToPred[issue.ref]].text);
      }
      final slots = [issue.expectedCount!, issue.myCount ?? 0, husCount ?? 0].reduce((x, y) => x > y ? x : y);
      Widget dots(int filled, Color color) => Row(mainAxisSize: MainAxisSize.min, children: [
            for (var i = 0; i < slots; i++)
              Container(
                width: 22,
                height: 22,
                margin: const EdgeInsets.only(right: 6),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: i < filled ? color : null,
                  border: i < filled ? null : Border.all(color: const Color(0xFF6B5A3A), width: 2),
                ),
              ),
          ]);
      return _grid([
        ('Tu', dots(issue.myCount ?? 0, kAmber), secs(my)),
        ('al-Husary', dots(husCount ?? 0, kGold), secs(hus)),
      ]);
    }
    final dMy = my == null ? 0.0 : my.$2 - my.$1, dHus = hus == null ? 0.0 : hus.$2 - hus.$1;
    final max = (dMy > dHus ? dMy : dHus) * 1.3 + 0.001;
    Widget bar(double d, Color color) => LayoutBuilder(
          builder: (_, k) => Container(
            height: 14,
            decoration: BoxDecoration(color: kLine, borderRadius: BorderRadius.circular(7)),
            alignment: Alignment.centerLeft,
            child: Container(width: k.maxWidth * d / max, height: 14, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(7))),
          ),
        );
    return _grid([
      ('Tu', bar(dMy, issueColor(issue.kind)), my == null ? 'non si sente' : secs(my)),
      ('al-Husary', bar(dHus, kGold), secs(hus)),
    ]);
  }

  Widget _grid(List<(String, Widget, String)> rows) => Column(children: [
        for (final (who, w, v) in rows)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(children: [
              SizedBox(width: 90, child: Text(who, style: const TextStyle(fontSize: 14, color: kMuted))),
              Expanded(child: Align(alignment: Alignment.centerLeft, child: w)),
              SizedBox(width: 96, child: Text(v, textAlign: TextAlign.end, style: const TextStyle(fontSize: 14, color: Color(0xFFC9D8D1)))),
            ]),
          ),
      ]);
}

