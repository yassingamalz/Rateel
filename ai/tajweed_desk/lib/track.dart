// One take on screen: waveform, the phoneme groups in time below it, the playhead.
// Hover a group: it lights up here, in the other take and in the ayah. Click: select and play it.
// Double-click: play the whole word. Click on the waveform: play from there.
import 'dart:math' as math;

import 'package:flutter/scheduler.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tajweed_core/timeline.dart';

import 'state.dart';

const statusColor = {
  GroupStatus.ok: Color(0xFF2E8B67),
  GroupStatus.tajweed: Color(0xFFE0A030),
  GroupStatus.letter: Color(0xFFE05A5A),
  GroupStatus.haraka: Color(0xFFB07CE0),
  GroupStatus.extra: Color(0xFF8A8A8A),
};

class TrackView extends StatefulWidget {
  final LabState lab;
  final Who who;
  const TrackView({super.key, required this.lab, required this.who});
  @override
  State<TrackView> createState() => _TrackViewState();
}

class _TrackViewState extends State<TrackView> with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  final _playhead = ValueNotifier<double?>(null);
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _ticker = createTicker((_) {
      final p = widget.lab.playheadOf(widget.who);
      _playhead.value = p;
      if (p != null) _follow(p);
    });
    widget.lab.addListener(_onLab);
  }

  void _onLab() {
    final playing = widget.lab.playing == widget.who;
    if (playing && !_ticker.isActive) _ticker.start();
    if (!playing && _ticker.isActive) {
      _ticker.stop();
      _playhead.value = null;
    }
  }

  /// Keep the playhead visible while playing.
  void _follow(double t) {
    if (!_scroll.hasClients) return;
    final take = widget.lab.take(widget.who);
    if (take == null) return;
    final w = take.seconds * widget.lab.pxPerSecond;
    final x = widget.lab.rtlTime ? w - t * widget.lab.pxPerSecond : t * widget.lab.pxPerSecond;
    final view = _scroll.position.viewportDimension;
    final off = _scroll.offset;
    if (x < off + 40 || x > off + view - 40) {
      _scroll.jumpTo((x - view / 2).clamp(0, _scroll.position.maxScrollExtent));
    }
  }

  @override
  void dispose() {
    widget.lab.removeListener(_onLab);
    _ticker.dispose();
    _scroll.dispose();
    super.dispose();
  }

  double _timeAt(double x, double width) {
    final lab = widget.lab;
    return (lab.rtlTime ? width - x : x) / lab.pxPerSecond;
  }

  int? _groupAt(TakeAnalysis a, double t) {
    for (var i = 0; i < a.groups.length; i++) {
      if (t >= a.groups[i].start && t < a.groups[i].end) return i;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final lab = widget.lab;
    final take = lab.take(widget.who);
    final theme = Theme.of(context);
    final title = widget.who == Who.me ? 'La tua recitazione' : 'al-Husary (riferimento)';
    if (take == null) {
      return _frame(theme, title, null,
          const Center(child: Text('Nessuna registrazione: premi «Registra» (R) o «Apri WAV».')));
    }
    final a = take.analysis;
    final width = (take.seconds * lab.pxPerSecond).clamp(200.0, 100000.0);
    final info = a == null
        ? (take.error != null ? 'Errore: ${take.error}' : (lab.engine.loaded ? 'Analisi…' : 'Carica il modello per analizzare'))
        : '${take.seconds.toStringAsFixed(1)} s · feature ${take.featMs} ms · modello ${take.modelMs} ms · '
            '${a.correction.errors.length} errori';
    return _frame(
      theme,
      title,
      info,
      Scrollbar(
        controller: _scroll,
        thumbVisibility: true,
        child: SingleChildScrollView(
          controller: _scroll,
          scrollDirection: Axis.horizontal,
          reverse: lab.rtlTime,
          child: MouseRegion(
            onHover: (e) {
              if (a == null) return;
              final g = _groupAt(a, _timeAt(e.localPosition.dx, width));
              lab.hover(g == null ? null : (a.predToRef[g] < 0 ? null : a.predToRef[g]));
            },
            onExit: (_) => lab.hover(null),
            child: GestureDetector(
              onTapUp: (d) {
                final t = _timeAt(d.localPosition.dx, width);
                if (a != null && d.localPosition.dy > _waveH) {
                  final g = _groupAt(a, t);
                  if (g != null) {
                    final r = a.predToRef[g];
                    if (r >= 0) {
                      lab.select(r);
                      lab.playRef(widget.who, r);
                    } else {
                      lab.play(widget.who, a.groups[g].start, a.groups[g].end);
                    }
                  }
                } else {
                  lab.play(widget.who, t, take.seconds);
                }
              },
              onDoubleTapDown: (d) {
                if (a == null) return;
                final g = _groupAt(a, _timeAt(d.localPosition.dx, width));
                if (g != null && a.predToRef[g] >= 0) lab.playRef(widget.who, a.predToRef[g], word: true);
              },
              child: RepaintBoundary(
                child: CustomPaint(
                  size: Size(width, _waveH + _stripH + 18),
                  painter: _TrackPainter(take, lab, _playhead, theme),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _frame(ThemeData theme, String title, String? info, Widget child) => Card(
        margin: const EdgeInsets.symmetric(vertical: 6),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Icon(widget.who == Who.me ? Icons.person : Icons.record_voice_over, size: 18),
              const SizedBox(width: 6),
              Text(title, style: theme.textTheme.titleSmall),
              const SizedBox(width: 12),
              if (info != null) Expanded(child: Text(info, style: theme.textTheme.bodySmall, overflow: TextOverflow.ellipsis)),
            ]),
            const SizedBox(height: 6),
            SizedBox(height: _waveH + _stripH + 30, child: child),
          ]),
        ),
      );
}

const double _waveH = 90, _stripH = 44;

class _TrackPainter extends CustomPainter {
  final Take take;
  final LabState lab;
  final ValueNotifier<double?> playhead;
  final ThemeData theme;
  _TrackPainter(this.take, this.lab, this.playhead, this.theme) : super(repaint: Listenable.merge([lab, playhead]));

  double _x(double t, double w) => lab.rtlTime ? w - t * lab.pxPerSecond : t * lab.pxPerSecond;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final a = take.analysis;
    final selected = lab.selectedRef, hovered = lab.hoveredRef;

    // highlight of the hovered / selected group across the whole height
    void band(int? r, Color c) {
      if (r == null || a == null || r >= a.refToPred.length) return;
      final p = a.refToPred[r];
      if (p < 0) return;
      final g = a.groups[p];
      final x0 = _x(g.start, w), x1 = _x(g.end, w);
      canvas.drawRect(Rect.fromLTRB(x0 < x1 ? x0 : x1, 0, x0 < x1 ? x1 : x0, _waveH + _stripH), Paint()..color = c);
    }

    band(hovered, Colors.white.withValues(alpha: 0.07));
    band(selected, theme.colorScheme.primary.withValues(alpha: 0.18));

    // waveform
    final mid = _waveH / 2;
    final wave = Paint()
      ..color = (take.who == Who.me ? const Color(0xFF7FD1B9) : const Color(0xFFD9C27F))
      ..strokeWidth = 1;
    final perPx = 100 / lab.pxPerSecond; // peaks are every 10 ms
    for (var px = 0.0; px < w; px += 1) {
      final t = lab.rtlTime ? (w - px) / lab.pxPerSecond : px / lab.pxPerSecond;
      final i0 = (t * 100).floor();
      if (i0 < 0 || i0 >= take.peaks.length) continue;
      final i1 = math.min(i0 + math.max(1, perPx.ceil()), take.peaks.length);
      var m = 0.0;
      for (var i = i0; i < i1; i++) {
        if (take.peaks[i] > m) m = take.peaks[i];
      }
      final h = (m * 1.6).clamp(0.0, 1.0) * (mid - 2);
      canvas.drawLine(Offset(px, mid - h), Offset(px, mid + h), wave);
    }

    // time ticks every second
    final tick = Paint()..color = Colors.white24;
    for (var s = 0; s <= take.seconds; s++) {
      final x = _x(s.toDouble(), w);
      canvas.drawLine(Offset(x, _waveH + _stripH), Offset(x, _waveH + _stripH + 5), tick);
      _text(canvas, '${s}s', Offset(x + 2, _waveH + _stripH + 2), 10, Colors.white38, left: true);
    }

    // phoneme groups
    if (a != null) {
      for (var i = 0; i < a.groups.length; i++) {
        final g = a.groups[i];
        final x0 = _x(g.start, w), x1 = _x(g.end, w);
        final r = Rect.fromLTRB(x0 < x1 ? x0 : x1, _waveH + 4, x0 < x1 ? x1 : x0, _waveH + _stripH - 2).deflate(0.5);
        final ref = a.predToRef[i];
        final isSel = ref >= 0 && ref == selected, isHov = ref >= 0 && ref == hovered;
        final c = statusColor[a.status[i]]!;
        canvas.drawRRect(RRect.fromRectAndRadius(r, const Radius.circular(4)),
            Paint()..color = c.withValues(alpha: isSel || isHov ? 0.95 : 0.55));
        if (isSel) {
          canvas.drawRRect(RRect.fromRectAndRadius(r, const Radius.circular(4)),
              Paint()
                ..color = Colors.white
                ..style = PaintingStyle.stroke
                ..strokeWidth = 2);
        }
        // low confidence: dotted top line
        if (g.confidence < 0.6) {
          canvas.drawLine(Offset(r.left, r.top), Offset(r.right, r.top),
              Paint()
                ..color = Colors.white70
                ..strokeWidth = 2);
        }
        if (r.width > 10) _text(canvas, groupLabel(g.text), r.center, 15, Colors.white, maxWidth: r.width + 30);
      }
    }

    // playhead
    final p = playhead.value;
    if (p != null) {
      final x = _x(p, w);
      canvas.drawLine(Offset(x, 0), Offset(x, _waveH + _stripH), Paint()
        ..color = Colors.white
        ..strokeWidth = 2);
    }
  }

  void _text(Canvas c, String s, Offset at, double size, Color color, {bool left = false, double maxWidth = 200}) {
    final tp = TextPainter(
      text: TextSpan(text: s, style: TextStyle(fontSize: size, color: color)),
      textDirection: TextDirection.rtl,
    )..layout(maxWidth: maxWidth);
    tp.paint(c, left ? at : at - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant _TrackPainter old) => old.take != take;
}

/// Readable label of a phoneme group: madd letters as the letter and the number of harakat («ي ×4»).
String groupLabel(String g) {
  const madd = {'ۦ': 'ي', 'ۥ': 'و', 'ا': 'ا'};
  final base = g[0];
  final n = g.split('').where((c) => c == base).length;
  if (madd.containsKey(base) && n > 1) return '${madd[base]}×$n';
  if (n > 2) return '$base×$n';
  return g.replaceAll('ں', 'ن').replaceAll('۾', 'م');
}
