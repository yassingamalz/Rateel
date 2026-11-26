import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:rateel/lessons/guided/guided_content.dart';
import 'package:rateel/lessons/guided/guided_page.dart';

void main() {
  testWidgets('guided review gates the quiz and exits after the summary', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(915, 412);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        builder: (_, child) =>
            Directionality(textDirection: TextDirection.rtl, child: child!),
        routes: {'/guided': (_) => const GuidedPage()},
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => Navigator.of(context).pushNamed('/guided'),
            child: const Text('open'),
          ),
        ),
      ),
    );
    Future<void> tap(String label) async {
      await tester.tap(find.text(label));
      await tester.pumpAndSettle();
    }

    await tap('open');
    await tester.tap(find.byTooltip('كتم الصوت'));
    await tester.pumpAndSettle();
    await tap('ابدأ الدرس');
    expect(find.text(meaning), findsOneWidget);
    await tap('متابعة');
    expect(find.textContaining(definition), findsOneWidget);
    await tap('متابعة');
    await tap(answers[1].text);
    expect(find.text('ليس تماماً، حاول مرّة أخرى.'), findsOneWidget);
    await tester.tap(find.text('متابعة'), warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(find.text(question), findsOneWidget);
    await tap(answers.first.text);
    expect(find.text(explanation), findsOneWidget);
    await tap('متابعة');
    expect(find.text(comparison.first.title), findsOneWidget);
    await tester.tap(find.byTooltip('السابق'));
    await tester.pumpAndSettle();
    expect(find.text(explanation), findsOneWidget);
    await tap('متابعة');
    await tap('متابعة');
    expect(find.text(verseWords[2].text), findsOneWidget);
    await tap('متابعة');
    expect(find.text(summaryTitle), findsOneWidget);
    await tap('إنهاء الدرس');
    expect(find.text('open'), findsOneWidget);
  });
}
