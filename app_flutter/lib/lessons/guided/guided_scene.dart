import 'package:flutter/foundation.dart' show ValueListenable;
import 'package:material_ui/material_ui.dart';

import '../../theme/rateel_theme.dart';
import '../lesson_widgets.dart';
import 'guided_content.dart';

const _gold = Color(0xfff1bd4c);
const _ink = Color(0xff123d30);
const _paper = Color(0xfff3e8ca);

BoxDecoration guidedPanel({Color? fill, double radius = 20}) => BoxDecoration(
  borderRadius: BorderRadius.circular(radius),
  gradient: fill == null
      ? const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xff1b5141), Color(0xff092e25)],
        )
      : null,
  color: fill,
  border: Border.all(color: const Color(0xffac8e46), width: 1.3),
  boxShadow: const [
    BoxShadow(color: Color(0x40070d07), blurRadius: 8, offset: Offset(0, 3)),
  ],
);

class GuidedScene extends StatelessWidget {
  const GuidedScene({
    super.key,
    required this.step,
    required this.answer,
    required this.position,
    required this.verse,
    required this.onStart,
    required this.onIntroAudio,
    required this.onReplay,
    required this.onAnswer,
  });
  final int step;
  final String? answer;
  final ValueListenable<int> position;
  final bool verse;
  final VoidCallback onStart, onIntroAudio, onReplay;
  final ValueChanged<String> onAnswer;

  Widget words(
    String value,
    double size, {
    Color color = RateelColors.cream,
    double weight = 600,
  }) => Text(
    value,
    textAlign: TextAlign.center,
    style: cairo(size, weight: weight, color: color),
  );

  Widget badge(String label) => Container(
    alignment: Alignment.center,
    width: 260,
    height: 48,
    decoration: const BoxDecoration(
      image: DecorationImage(
        image: AssetImage('assets/guided/label-pill.webp'),
        fit: BoxFit.fill,
      ),
    ),
    child: words(label, 22, color: _gold),
  );

  Widget line(List<Widget> children) => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      for (final child in children)
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: child,
          ),
        ),
    ],
  );

  Widget formatCard(Widget child, {Color? fill, double height = 112}) =>
      Container(
        height: height,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: guidedPanel(fill: fill),
        child: child,
      );

  // Keep each composition centred at its design size. Long Arabic lines and
  // the app's larger text setting may need a small proportional reduction.
  Widget column(List<Widget> children) => LayoutBuilder(
    builder: (context, box) => FittedBox(
      fit: BoxFit.scaleDown,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: box.maxWidth,
          maxWidth: box.maxWidth,
          minHeight: box.maxHeight,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: children,
        ),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) => switch (step) {
    0 => column([
      const Image(
        image: AssetImage('assets/guided/emblem-quran.webp'),
        width: 78,
        height: 78,
      ),
      badge(guidedBadge),
      words(guidedTitle, 42, weight: 750),
      SizedBox(
        width: 212,
        height: 48,
        child: LessonPill(
          u: 4,
          height: 11.3,
          gold: true,
          label: 'ابدأ الدرس',
          glyph: PillGlyph.play,
          onTap: onStart,
        ),
      ),
      TextButton.icon(
        onPressed: onIntroAudio,
        icon: const Icon(Icons.headphones, color: _gold),
        label: words('استمع إلى المقدمة', 17, weight: 500),
      ),
    ]),
    1 => column([
      badge(conceptLabel),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 227,
            child: formatCard(words(keyword, 35), height: 72),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Icon(Icons.west, color: _gold, size: 42),
          ),
          SizedBox(
            width: 227,
            child: formatCard(
              words(meaning, 35, color: _ink),
              fill: _gold,
              height: 72,
            ),
          ),
        ],
      ),
      words(conceptNote, 23),
    ]),
    2 => column([
      badge(definitionLabel),
      words('« $definition »', 25, weight: 700),
      line([
        for (final (index, item) in pillars.indexed)
          formatCard(
            column([
              Icon(
                [
                  Icons.place_outlined,
                  Icons.diamond_outlined,
                  Icons.auto_awesome,
                ][index],
                color: _gold,
                size: 28,
              ),
              words(item.title, 24, color: _gold),
              words(item.text, 15, weight: 500),
            ]),
          ),
      ]),
    ]),
    3 => column([
      badge('سؤال'),
      words(question, 29, weight: 700),
      line([
        for (final option in answers)
          Semantics(
            button: true,
            selected: answer == option.id,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => onAnswer(option.id),
              child: formatCard(
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (answer == option.id)
                      Icon(
                        answer == correctId ? Icons.check_circle : Icons.cancel,
                        color: RateelColors.cream,
                      ),
                    Flexible(child: words(option.text, 23)),
                  ],
                ),
                fill: answer != option.id
                    ? null
                    : answer == correctId
                    ? const Color(0xff147452)
                    : const Color(0xff763e38),
                height: 73,
              ),
            ),
          ),
      ]),
      Semantics(
        liveRegion: true,
        child: words(
          answer == null
              ? 'اختر الإجابة الصحيحة'
              : answer == correctId
              ? explanation
              : 'ليس تماماً، حاول مرّة أخرى.',
          19,
          color: _gold,
        ),
      ),
    ]),
    4 => column([
      badge(compareLabel),
      line([
        for (final (i, card) in comparison.indexed)
          formatCard(
            column([
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    i == 0
                        ? Icons.warning_amber_rounded
                        : Icons.visibility_off_outlined,
                    color: _ink,
                    size: 28,
                  ),
                  const SizedBox(width: 8),
                  words(card.title, 27, color: _ink, weight: 750),
                ],
              ),
              words(card.subtitle, 18, color: _ink),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 1,
                ),
                decoration: BoxDecoration(
                  color: i == 0
                      ? const Color(0xfff6c2ac)
                      : const Color(0xffffd777),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: words(card.verdict, 20, color: _ink),
              ),
              words(card.text, 17, color: _ink, weight: 450),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/guided/lahn-${i == 0 ? 'jali' : 'khafi'}.webp',
                    width: 43,
                    height: 41,
                    excludeFromSemantics: true,
                  ),
                  const SizedBox(width: 9),
                  words(
                    i == 0 ? 'أَنْعَمْتَ ← أَنْعَمْتُ' : 'مثال: تركُ الغُنّة',
                    17,
                    color: _ink,
                  ),
                ],
              ),
            ]),
            fill: _paper,
            height: 189,
          ),
      ]),
    ]),
    5 => column([
      badge(listenLabel),
      formatCard(
        column([
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              words('$surah · ٧', 16, color: _gold),
              words('محمود خليل الحصري', 15),
            ],
          ),
          ValueListenableBuilder<int>(
            valueListenable: position,
            builder: (context, ms, _) => Wrap(
              alignment: WrapAlignment.center,
              spacing: 10,
              children: [
                for (final (index, word) in verseWords.indexed)
                  words(
                    word.text,
                    37,
                    color:
                        (ms < 0
                            ? index == 2
                            : ms >= word.start && ms < word.end)
                        ? _gold
                        : RateelColors.cream,
                  ),
                words('…', 30),
              ],
            ),
          ),
        ]),
        height: 122,
      ),
      SizedBox(
        width: 210,
        height: 45,
        child: LessonPill(
          u: 4,
          height: 10,
          fontSize: 4.2,
          label: verse ? 'تشغيل من البداية' : 'إعادة الاستماع',
          glyph: PillGlyph.replay,
          onTap: onReplay,
        ),
      ),
    ]),
    _ => column([
      badge('مراجعة الدرس الأول'),
      const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.star, color: _gold),
          Icon(Icons.star, color: _gold, size: 32),
          Icon(Icons.star, color: _gold),
        ],
      ),
      words(summaryTitle, 29, weight: 750),
      for (var i = 0; i < summaryPoints.length; i += 2)
        line([
          for (final point in summaryPoints.skip(i).take(2))
            formatCard(
              Row(
                children: [
                  const Icon(
                    Icons.check_circle_outline,
                    color: _gold,
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: words(point, 17, weight: 550)),
                ],
              ),
              height: 54,
            ),
        ]),
    ]),
  };
}
