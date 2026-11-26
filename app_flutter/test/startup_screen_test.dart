import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:rateel/splash/startup_screen.dart';

void main() {
  testWidgets(
    'startup holds below 100% and reveals its destination only once',
    (tester) async {
      final ready = Completer<void>();
      var starts = 0;
      tester.view.physicalSize = const Size(915, 412);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        MaterialApp(
          home: StartupScreen(
            initialize: (_) {
              starts++;
              return ready.future;
            },
            child: const Text('courses'),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 900));
      expect(find.text('60%'), findsOneWidget);
      expect(find.text('courses'), findsNothing);
      await tester.pump(const Duration(seconds: 3));
      expect(find.text('90%'), findsOneWidget);
      ready.complete();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));
      await tester.pumpAndSettle();
      expect(find.text('courses'), findsOneWidget);
      expect(find.text('جارٍ تحميل المحتوى…'), findsNothing);
      expect(starts, 1);
    },
  );

  testWidgets('a failed load offers an Arabic retry and recovers', (
    tester,
  ) async {
    var starts = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: StartupScreen(
          initialize: (_) async {
            if (++starts == 1) throw StateError('load failed');
          },
          child: const Text('courses'),
        ),
      ),
    );
    await tester.pump();
    expect(tester.takeException(), isA<StateError>());
    expect(find.text('courses'), findsNothing);
    await tester.tap(find.text('إعادة المحاولة'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1350));
    await tester.pump(const Duration(milliseconds: 150));
    await tester.pumpAndSettle();
    expect(starts, 2);
    expect(find.text('courses'), findsOneWidget);
  });
}
