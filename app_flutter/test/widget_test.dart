import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:rateel/courses/course_data.dart';
import 'package:rateel/main.dart';
import 'package:rateel/lessons/lesson_data.dart';
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
    // Complete unit 1: unit 2 opens and its lessons (screen 06) open by
    // themselves.
    unitCompleted.value = 0;
    for (var i = 0; i < 10; i++) {
      await settle(tester);
    }
    expect(find.text('آداب تلاوة القرآن الكريم'), findsOneWidget);
    Navigator.of(tester.element(find.text('آداب تلاوة القرآن الكريم'))).pop();
    for (var i = 0; i < 3; i++) {
      await settle(tester);
    }
    expect(find.textContaining('أولًا'), findsNothing);
    // «تغيير المقرر» goes back to the courses screen.
    await tester.tap(find.text('تغيير المقرر'));
    for (var i = 0; i < 4; i++) {
      await settle(tester);
    }
    expect(find.text('وحدات المقرر'), findsNothing);
    // Shared progress: 1 of 5 units done → the course bar shows 20%.
    expect(find.text('20%'), findsOneWidget);
  });

  testWidgets('lessons: finishing every lesson completes the unit', (
    tester,
  ) async {
    // Progress is kept for the session: start course 1 from zero again.
    final st = unitsProgressOf(0);
    st.current = 0;
    st.progress.fillRange(0, st.progress.length, 0);
    setLessonsDone('intro-tajweed', 0);
    tester.view.physicalSize = const Size(1844, 853);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const RateelApp());
    await settle(tester);
    await tester.tap(find.text('أساسيات التجويد'));
    await settle(tester);
    await tester.tap(find.text('مقدمة في التجويد'));
    for (var i = 0; i < 3; i++) {
      await settle(tester);
    }
    expect(find.text('مقدمة في علم التجويد'), findsOneWidget);
    // Lesson 2 is locked.
    await tester.tap(find.text('أهمية إتقان التجويد'));
    await settle(tester);
    expect(find.textContaining('أولًا'), findsOneWidget);
    await tester.pump(const Duration(seconds: 3));
    // Lesson 1 → placeholder page → «أكملت الدرس»: the completion plays and
    // the next lesson opens by itself; three times.
    await tester.tap(find.text('مقدمة في علم التجويد'));
    for (var k = 0; k < 3; k++) {
      for (var i = 0; i < 3; i++) {
        await settle(tester);
      }
      expect(find.text('أكملت الدرس'), findsOneWidget);
      await tester.tap(find.text('أكملت الدرس'));
      for (var i = 0; i < 8; i++) {
        await settle(tester);
      }
    }
    // Last lesson → back to the units, unit 1 completed, unit 2's lessons
    // open by themselves.
    for (var i = 0; i < 10; i++) {
      await settle(tester);
    }
    expect(find.text('آداب تلاوة القرآن الكريم'), findsOneWidget);
    expect(lessonsDone('intro-tajweed'), 3);
    expect(unitsProgressOf(0).current, 1);
  });
}
