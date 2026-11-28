import 'package:rateel/core/user_profile.dart';
import 'package:rateel/lessons/test_lesson_page.dart';
import 'package:rateel/lessons/test_data.dart';
import 'package:rateel/lessons/lesson_shell.dart';
import 'package:rateel/lessons/lesson_end.dart';
import 'package:rateel/lessons/video_lesson_page.dart';
import 'package:rateel/lessons/reading_lesson_page.dart';
import 'package:rateel/lessons/reading_data.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rateel/nav/side_nav.dart';
import 'package:rateel/nav/nav_items.dart';
import 'package:rateel/challenges/challenge_data.dart';
import 'package:rateel/challenges/daily_challenges_screen.dart';
import 'package:material_ui/material_ui.dart';
import 'package:rateel/courses/course_data.dart';
import 'package:rateel/main.dart';
import 'package:rateel/lessons/lesson_data.dart';
import 'package:rateel/units/unit_data.dart';
import 'package:rateel/core/app_settings.dart';
import 'package:rateel/settings/settings_screen.dart';

// The courses screen has a looping glow: settle with fixed pumps.
Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 4; i++) {
    await tester.pump(const Duration(milliseconds: 500));
  }
}

/// [onboarded] false: the first start (screen 30) opens after the splash.
Future<void> openApp(WidgetTester tester, {bool onboarded = true}) async {
  UserProfile.onboarded.value = onboarded;
  await tester.pumpWidget(RateelApp(initialize: (_) async {}));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 1350));
  await tester.pump(const Duration(milliseconds: 150));
  await settle(tester);
}

void main() {
  // Progress is shared by the whole app (and saved): every test starts
  // from a new learner.
  setUp(AppSettings.resetProgress);

  testWidgets('side nav opens and closes', (tester) async {
    tester.view.physicalSize = const Size(1844, 853);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await openApp(tester);
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
    await openApp(tester);
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
    await openApp(tester);
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
    await openApp(tester);
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
    await openApp(tester);
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
    // Unit 1 has video lessons (screen 07): no platform view in the test,
    // the "not available" state with «تخطي».
    videoMode = 'none';
    addTearDown(() => videoMode = null);
    tester.view.physicalSize = const Size(1844, 853);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await openApp(tester);
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
    // Lesson 1 → video lesson (07, not available) → «تخطي»: the completion
    // plays and the next lesson opens by itself; three times.
    await tester.tap(find.text('مقدمة في علم التجويد'));
    for (var k = 0; k < 3; k++) {
      for (var i = 0; i < 3; i++) {
        await settle(tester);
      }
      expect(find.text('الفيديو غير متاح'), findsOneWidget);
      await tester.tap(find.text('تخطي'));
      // No end card (24) after an explanation (owner, 2026-11-28).
      for (var i = 0; i < 11; i++) {
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

  testWidgets('lesson top bar: pause menu, restart, back (screen 02)', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1844, 853);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    var step = 3, backs = 0;
    final paused = <bool>[];
    await tester.pumpWidget(
      MaterialApp(
        home: StatefulBuilder(
          builder: (context, set) => LessonShell(
            step: step,
            total: 16,
            onBack: () => backs++,
            onRestart: () => set(() => step = 1),
            onPausedChanged: paused.add,
            child: const SizedBox.expand(),
          ),
        ),
      ),
    );
    expect(find.bySemanticsLabel('الخطوة 3 من 16'), findsOneWidget);
    await tester.tap(find.bySemanticsLabel('إيقاف مؤقت'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(paused, [true]);
    await tester.tap(find.bySemanticsLabel('من البداية'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(step, 1);
    expect(paused, [true, false]);
    await tester.tap(find.bySemanticsLabel('إيقاف مؤقت'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tap(find.bySemanticsLabel('رجوع'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(backs, 1);
  });

  testWidgets(
    'video lesson: section end waits on the 02 play, back button (screen 07)',
    (tester) async {
      tester.view.physicalSize = const Size(1844, 853);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      videoMode = 'demo';
      videoStartAt = 0.33; // 105.6 s: section 1 ends at 106.7 s
      addTearDown(() {
        videoMode = null;
        videoStartAt = 0;
      });
      const lesson = Lesson(
        id: 't',
        title: 'درس',
        description: '',
        type: LessonType.video,
        minutes: 5,
        videoUrl: 'https://www.youtube.com/watch?v=BqFxf-WspTc',
      );
      await tester.pumpWidget(
        const MaterialApp(
          home: VideoLessonPage(lesson: lesson, index: 1, count: 1),
        ),
      );
      await tester.pump(const Duration(seconds: 1));
      expect(find.bySemanticsLabel('الخطوة 1 من 3'), findsOneWidget);
      // The video reaches the end of section 1: the 02 button waits.
      for (var i = 0; i < 12; i++) {
        await tester.pump(const Duration(milliseconds: 250));
      }
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.bySemanticsLabel('متابعة'), findsOneWidget);
      await tester.tap(find.bySemanticsLabel('متابعة'));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.bySemanticsLabel('الخطوة 2 من 3'), findsOneWidget);
      // (The return of the pause glyph and the ‹ button are checked in the web
      // build, video-demo.js: the simulated video's timer stops the test's
      // frames after the section change.)
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets(
    'reading lesson: sentences, theme, rules panel, completion (screen 08)',
    (tester) async {
      tester.view.physicalSize = const Size(1844, 853);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      addTearDown(() => readingLight.value = false);
      const lesson = Lesson(
        id: 'recitation-basics-lesson-1',
        title: 'آداب تلاوة القرآن الكريم',
        description: '',
        type: LessonType.read,
        minutes: 10,
      );
      bool? result;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Center(
              child: TextButton(
                onPressed: () async =>
                    result = await Navigator.of(context)
                        .push(readingLessonRoute(lesson, 1, 3)),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      for (var i = 0; i < 6; i++) {
        await tester.pump(const Duration(milliseconds: 300));
      }
      // 8 sentences: the capsule shows 1/8, the first sentence is on the card.
      expect(find.bySemanticsLabel('الخطوة 1 من 8'), findsOneWidget);
      expect(
        find.text('ينبغي للقارئ أن يستحضر عظمة كلام الله تعالى'),
        findsOneWidget,
      );
      // ‹ (next in RTL) → sentence 2.
      await tester.tap(find.bySemanticsLabel('التالي'));
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.bySemanticsLabel('الخطوة 2 من 8'), findsOneWidget);
      expect(find.text('2 / 8'), findsOneWidget);
      // Moon → light reading.
      await tester.tap(find.bySemanticsLabel('الوضع الفاتح'));
      await tester.pump(const Duration(milliseconds: 500));
      expect(readingLight.value, isTrue);
      // Rules panel opens with the rules, closes with ✕.
      await tester.tap(find.text('قواعد التجويد'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('إدغام'), findsOneWidget);
      // A rule opens its detail over the veiled screen; ✕ closes it.
      await tester.tap(find.text('إدغام'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('استمع إلى مثال'), findsOneWidget);
      await tester.tap(find.bySemanticsLabel('إغلاق').last);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('استمع إلى مثال'), findsNothing);
      await tester.tap(find.bySemanticsLabel('إغلاق'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('إدغام'), findsNothing);
      // «تخطي» completes the lesson: no end card (24) after an explanation
      // (owner, 2026-11-28), the page leaves with true.
      await tester.tap(find.text('تخطي'));
      for (var i = 0; i < 14; i++) {
        await tester.pump(const Duration(milliseconds: 300));
      }
      expect(find.text('أحسنت، أكملت الدرس'), findsNothing);
      expect(result, isTrue);
    },
  );

  testWidgets('settings: the rail icon closes the profile (screen 29)', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1844, 853);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Directionality(
            textDirection: TextDirection.rtl,
            child: SettingsScreen(),
          ),
        ),
      ),
    );
    SettingsScreen.showProfile.value = true;
    await tester.pump(const Duration(milliseconds: 400));
    SideNavScaffold.reselected.value = null;
    SideNavScaffold.reselected.value = settingsSection;
    await tester.pump(const Duration(milliseconds: 400));
    expect(SettingsScreen.showProfile.value, isFalse);
    expect(find.text('الإعدادات'), findsOneWidget);
    SideNavScaffold.reselected.value = null;
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 50));
  });

  testWidgets('settings: theme, switches, text size, reset (screen 23)', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1844, 853);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    addTearDown(() {
      AppSettings.light.value = false;
      AppSettings.sounds.value = true;
      AppSettings.textScale.value = 1.0;
    });
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Directionality(
            textDirection: TextDirection.rtl,
            child: SettingsScreen(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('الإعدادات'), findsOneWidget);
    await tester.tap(find.text('فاتح'));
    await tester.pumpAndSettle();
    expect(AppSettings.light.value, isTrue);
    await tester.tap(find.byIcon(Icons.add_rounded));
    await tester.pumpAndSettle();
    expect(AppSettings.textScale.value, closeTo(1.05, 0.001));
    expect(find.text('105%'), findsOneWidget);
    // Scroll to the last rows, reset with confirmation.
    await tester.drag(find.text('القارئ'), const Offset(0, -400));
    await tester.pumpAndSettle();
    setLessonsDone('x', 2);
    await tester.tap(find.text('إعادة الضبط'));
    await tester.pumpAndSettle();
    expect(find.text('إلغاء'), findsOneWidget);
    await tester.tap(find.text('إعادة الضبط').last);
    await tester.pumpAndSettle();
    expect(lessonsDone('x'), 0);
    expect(find.text('تمت إعادة ضبط التقدم'), findsOneWidget);
  });

  testWidgets(
    'daily challenges: streak chip opens 12, long press completes (screen 12)',
    (tester) async {
      tester.view.physicalSize = const Size(1844, 853);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      challengesDone.value = 0;
      dailyStreak.value = 0;
      await openApp(tester);
      await tester.tap(find.byType(StreakChip));
      await settle(tester);
      expect(find.text('رحلة التحديات اليومية'), findsOneWidget);
      expect(find.text('100'), findsOneWidget);
      // Locked tile: nothing completes.
      final tiles = find.byKey(const ValueKey('tile3'));
      await tester.longPress(tiles);
      await settle(tester);
      expect(challengesDone.value, 0);
      await tester.longPress(find.byKey(const ValueKey('tile0')));
      for (var i = 0; i < 6; i++) {
        await tester.pump(const Duration(milliseconds: 400));
      }
      expect(challengesDone.value, 1);
      // One streak for the whole app = the practice streak (owner,
      // 2026-11-28, screen 31 Q10): a challenge does not change it.
      expect(dailyStreak.value, 0);
      await settle(tester);
      // Back without a button: drag the finger to the right (owner, 2026-11-26).
      await tester.drag(
        find.text('رحلة التحديات اليومية'),
        const Offset(700, 0),
      );
      await settle(tester);
      expect(find.text('رحلة التحديات اليومية'), findsNothing);
      expect(find.byType(StreakChip), findsOneWidget);
      // The courses icon of the rail goes back from 12 to the courses.
      await tester.tap(find.byType(StreakChip));
      await settle(tester);
      expect(find.text('رحلة التحديات اليومية'), findsOneWidget);
      SideNavScaffold.reselected.value = null;
      SideNavScaffold.reselected.value = 0;
      await settle(tester);
      expect(find.text('رحلة التحديات اليومية'), findsNothing);
      expect(find.byType(StreakChip), findsOneWidget);
    },
  );

  test('test lesson scoring follows the Angular rules (screen 10)', () {
    final c = TestContent.parse({
      'title': 't',
      'passingScore': 70,
      'questions': [
        for (var i = 0; i < 3; i++)
          {
            'id': 'q$i',
            'text': 'q$i',
            'type': 'singleChoice',
            'options': [
              {'id': 'a', 'text': 'a'},
              {'id': 'b', 'text': 'b'},
            ],
            'correctAnswer': 'a',
          },
        {
          'id': 'm',
          'text': 'm',
          'type': 'multipleChoice',
          'options': [
            {'id': 'a', 'text': 'a'},
            {'id': 'b', 'text': 'b'},
            {'id': 'c', 'text': 'c'},
          ],
          'correctAnswer': ['a', 'b'],
        },
        {
          'id': 't',
          'text': 't',
          'type': 'textInput',
          'correctAnswer': ['من يعمل'],
        },
      ],
    })!;
    final run = TestRun(c);
    final qs = c.questions;
    expect(run.isUnlocked(1), isFalse);
    // Streak: 10, then 10 + 4, then 10 + 6 (Angular getQuestionPoints).
    for (final q in qs.take(3)) {
      run.toggle(q, 'a');
      expect(run.submit(q), isTrue);
    }
    expect(run.points, 10 + 14 + 16);
    expect(run.isUnlocked(3), isTrue);
    // Multiple choice needs exactly the right set.
    // Multiple choice: exactly the right set, or partly right (half points).
    run.toggle(qs[3], 'a');
    expect(run.submit(qs[3]), isFalse);
    expect(run.isPartial(qs[3]), isTrue);
    expect(run.points, 10 + 14 + 16 + 5);
    expect(run.streak, 0);
    // Text answers are trimmed and compared case-insensitively.
    run.setText(qs[4], '  من يعمل ');
    expect(run.submit(qs[4]), isTrue);
    expect(run.score, 90); // (4 + 0.5) / 5
    expect(run.partialCount, 1);
    expect(run.wrongCount, 0);
    expect(run.passed, isTrue);
    expect(run.recommendations().length, 2);
  });

  testWidgets('test lesson: select, confirm, feedback, next (screen 10)', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1844, 853);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    const lesson = Lesson(
      id: 'assessment-lesson-1',
      title: 'اختبار المعرفة النظرية',
      description: '',
      type: LessonType.test,
      minutes: 20,
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Center(
            child: TextButton(
              onPressed: () =>
                  Navigator.of(context).push(testLessonRoute(lesson, 1, 2)),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 300));
    }
    expect(find.text('ما هو تعريف علم التجويد؟'), findsOneWidget);
    expect(find.bySemanticsLabel('الخطوة 0 من 10'), findsOneWidget);
    // Question 2 is locked until question 1 is answered.
    await tester.tap(find.bySemanticsLabel(RegExp('^السؤال 2')));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('ما هو تعريف علم التجويد؟'), findsOneWidget);
    await tester.tap(
      find.text('علم يعنى بتحسين تلاوة القرآن الكريم وإخراج كل حرف من مخرجه'),
    );
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('تأكيد الإجابة'));
    for (var i = 0; i < 4; i++) {
      await tester.pump(const Duration(milliseconds: 200));
    }
    expect(find.text('إجابة صحيحة'), findsOneWidget);
    expect(find.bySemanticsLabel('الخطوة 1 من 10'), findsOneWidget);
    await tester.tap(find.text('السؤال التالي'));
    for (var i = 0; i < 4; i++) {
      await tester.pump(const Duration(milliseconds: 200));
    }
    expect(
      find.text('ما هو حكم التجويد عند قراءة القرآن الكريم؟'),
      findsOneWidget,
    );
  });

  testWidgets('end of lesson (24): stars, tiles, continue and restart', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1844, 853);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    expect(LessonEndResult.starsFor(5, 5), 3);
    expect(LessonEndResult.starsFor(4, 5), 2);
    expect(LessonEndResult.starsFor(3, 5), 1);
    expect(LessonEndResult.starsForScore(95), 3);
    expect(LessonEndResult.starsForScore(75), 2);
    final shell = GlobalKey<LessonShellState>();
    await tester.pumpWidget(
      MaterialApp(
        home: LessonShell(
          key: shell,
          step: 3,
          total: 8,
          onBack: () {},
          onRestart: () {},
          child: const SizedBox.expand(),
        ),
      ),
    );
    // A lesson without questions: no «إجابات صحيحة» tile.
    var choice = shell.currentState!.finish(const LessonEndResult.done());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1800));
    expect(find.text('أحسنت، أكملت الدرس'), findsOneWidget);
    expect(find.text('إجابات صحيحة'), findsNothing);
    expect(find.text('+10'), findsOneWidget);
    // The capsule shows the lesson complete.
    expect(find.bySemanticsLabel('الخطوة 8 من 8'), findsOneWidget);
    await tester.tap(find.text('إعادة الدرس'));
    await tester.pump(const Duration(milliseconds: 200));
    expect(await choice, LessonEndChoice.again);
    expect(find.text('أحسنت، أكملت الدرس'), findsNothing);
    // With questions: the answers tile; «متابعة» completes with next.
    choice = shell.currentState!.finish(
      LessonEndResult.answers(right: 4, total: 5, points: 40),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1800));
    expect(find.text('إجابات صحيحة'), findsOneWidget);
    expect(find.text('+40'), findsOneWidget);
    await tester.tap(find.text('متابعة'));
    await tester.pump(const Duration(milliseconds: 200));
    expect(await choice, LessonEndChoice.next);
  });
}
