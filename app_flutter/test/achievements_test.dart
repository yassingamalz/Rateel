import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:rateel/achievements/achievement_data.dart';
import 'package:rateel/achievements/achievements_flow.dart';
import 'package:rateel/badges/badge_data.dart';
import 'package:rateel/gamification/points.dart';
import 'package:rateel/nav/side_nav.dart';

Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 8; i++) {
    await tester.pump(const Duration(milliseconds: 400));
  }
}

Future<void> open(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1686, 853);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.runAsync(() async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(body: AchievementsFlow()),
        ),
      ),
    );
    await Future<void>.delayed(const Duration(milliseconds: 500));
  });
  await settle(tester);
}

void main() {
  setUp(() {
    userPoints.value = 511;
    for (final b in badges) {
      badgeProgress[b.id] = b.start;
    }
  });

  test('achievements: two earned, shared progress with the badges', () {
    expect(achievements.length, 5);
    expect(earnedAchievements(), 2);
    // A5 and A4 read the progress of badges M12 and M11 (same event).
    expect(achievementShare(achievements[4]), 0);
    expect(achievementProgress(achievements[3]), 1);
    badgeProgress[11] = 5;
    expect(achievementEarned(achievements[3]), isTrue);
    // The collection holds the 5 achievements and the 9 other badges.
    expect(collectionItems().length, 14);
  });

  testWidgets('screen 13: header, tabs and the achievement cards', (
    tester,
  ) async {
    await open(tester);
    expect(find.text('511'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
    expect(find.text('389 للتالي'), findsOneWidget);
    for (final t in ['الإنجازات', 'الأوسمة', 'المجموعة']) {
      expect(find.text(t), findsOneWidget);
    }
    expect(
      find.text('النقاط'),
      findsNWidgets(2),
    ); // label under the medal + tab
    expect(find.text('بداية الرحلة'), findsOneWidget);
    expect(find.text('متقن القراءة'), findsOneWidget);
    expect(find.text('مكتمل'), findsNWidgets(2));
    // Next page of the carousel: the in-progress achievements.
    await tester.drag(find.byType(PageView), const Offset(700, 0));
    await settle(tester);
    expect(find.text('حافظ النص'), findsOneWidget);
    expect(find.text('70%'), findsOneWidget);
  });

  testWidgets('screen 13: points and collection tabs', (tester) async {
    await open(tester);
    await tester.tap(find.text('النقاط').last);
    await settle(tester);
    expect(find.text('+195'), findsOneWidget);
    expect(find.text('آخر النشاطات'), findsOneWidget);
    await tester.tap(find.text('المجموعة'));
    await settle(tester);
    expect(find.textContaining('المجموعة'), findsWidgets);
    expect(find.text('نادر'), findsWidgets);
  });

  testWidgets(
    'screen 13: the level emblem opens the level page; the rail goes back',
    (tester) async {
      await open(tester);
      await tester.tap(find.text('المستوى'));
      await settle(tester);
      expect(find.text('المستوى الثالث'), findsWidgets);
      expect(find.text('الدروس'), findsOneWidget);
      // Level 3 = course 3: a locked course, its units are locked.
      expect(find.text('مقفل'), findsWidgets);
      SideNavScaffold.reselected.value = 4;
      await settle(tester);
      expect(find.text('الإنجازات'), findsOneWidget);
    },
  );

  testWidgets('screen 13: crossing a level moves the level number', (
    tester,
  ) async {
    await open(tester);
    userPoints.value = 950; // level 4
    await settle(tester);
    expect(find.text('4'), findsOneWidget);
    expect(find.text('نقطة'), findsNothing);
  });
}
