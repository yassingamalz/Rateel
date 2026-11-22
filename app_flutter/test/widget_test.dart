import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:rateel/courses/course_data.dart';
import 'package:rateel/main.dart';
import 'package:rateel/units/unit_data.dart';

// The courses screen has a looping glow: settle with fixed pumps.
Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 4; i++) {
    await tester.pump(const Duration(milliseconds: 500));
  }
}

void main() {
  testWidgets('side nav opens and closes', (tester) async {
    tester.view.physicalSize = const Size(1844, 853);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const RateelApp());
    await settle(tester);
    expect(find.text('الشهادات'), findsNothing); // labels only in the open menu
    await tester.tap(find.bySemanticsLabel(RegExp('القائمة')));
    await settle(tester);
    expect(find.text('الشهادات'), findsOneWidget);
    await tester.tap(find.bySemanticsLabel(RegExp('القائمة')));
    await settle(tester);
    expect(find.text('الشهادات'), findsNothing);
  });

  testWidgets('swipe right-to-left on the rail opens, left-to-right closes', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1844, 853);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const RateelApp());
    await settle(tester);
    // Start on the rail, below the items.
    await tester.dragFrom(const Offset(1780, 820), const Offset(-500, 0));
    await settle(tester);
    expect(find.text('الشهادات'), findsOneWidget);
    await tester.dragFrom(const Offset(1500, 820), const Offset(500, 0));
    await settle(tester);
    expect(find.text('الشهادات'), findsNothing);
    // A drag on the content (not the rail) does not open the menu.
    await tester.dragFrom(const Offset(800, 400), const Offset(-500, 0));
    await settle(tester);
    expect(find.text('الشهادات'), findsNothing);
  });

  testWidgets('courses screen shows the path and reacts to taps', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1844, 853);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const RateelApp());
    await settle(tester);
    expect(find.text('المسارات التعليمية'), findsWidgets);
    expect(find.text('أساسيات التجويد'), findsOneWidget);
    await tester.tap(find.text('النون والميم المشددتان'));
    await settle(tester);
    expect(find.textContaining('أولًا'), findsOneWidget);
    await tester.pump(const Duration(seconds: 3));
  });

  testWidgets('completing a course unlocks the next one', (tester) async {
    tester.view.physicalSize = const Size(1844, 853);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const RateelApp());
    await settle(tester);
    courseCompleted.value = 0;
    for (var i = 0; i < 10; i++) {
      await settle(tester);
    }
    // Course 2 is now in progress: tapping it no longer asks to finish course 1.
    await tester.tap(find.text('النون والميم المشددتان'));
    await settle(tester);
    expect(find.textContaining('أولًا'), findsNothing);
    // It opens the units screen (05).
    expect(find.text('وحدات المقرر'), findsWidgets);
    await tester.pump(const Duration(seconds: 3));
  });

  testWidgets('units screen: locked unit, completion opens the next unit', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1844, 853);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const RateelApp());
    await settle(tester);
    await tester.tap(find.text('أساسيات التجويد'));
    await settle(tester);
    expect(find.text('وحدات المقرر'), findsWidgets);
    expect(find.text('مقدمة في التجويد'), findsOneWidget);
    // Unit 2 is locked.
    await tester.tap(find.text('أساسيات التلاوة'));
    await settle(tester);
    expect(find.textContaining('أولًا'), findsOneWidget);
    await tester.pump(const Duration(seconds: 3));
    // Complete unit 1: unit 2 opens (no more «finish first»).
    unitCompleted.value = 0;
    for (var i = 0; i < 10; i++) {
      await settle(tester);
    }
    await tester.tap(find.text('أساسيات التلاوة'));
    await settle(tester);
    expect(find.textContaining('أولًا'), findsNothing);
    await tester.pump(const Duration(seconds: 3));
    // «تغيير المقرر» goes back to the courses screen.
    await tester.tap(find.text('تغيير المقرر'));
    await settle(tester);
    expect(find.text('وحدات المقرر'), findsNothing);
  });
}
