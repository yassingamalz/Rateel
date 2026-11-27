import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:rateel/badges/badge_data.dart';
import 'package:rateel/badges/badges_screen.dart';

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
          child: Scaffold(body: BadgesScreen()),
        ),
      ),
    );
    await Future<void>.delayed(const Duration(milliseconds: 500));
  });
  await settle(tester);
}

void main() {
  setUp(() {
    for (final b in badges) {
      badgeProgress[b.id] = b.start;
    }
    badgeEarned.value = null;
  });

  test('mock data: earned first, then by progress; M05 is the first in progress', () {
    final all = orderedBadges(BadgeFilter.all);
    expect(all.length, 12);
    expect(all.take(4).every(isEarned), isTrue);
    expect(all.skip(4).any(isEarned), isFalse);
    expect(firstInProgress().id, 5); // 34 / 50
    expect(all[4].id, 5);
    expect(all[5].id, 6); // 4 / 7
    expect(orderedBadges(BadgeFilter.earned).length, 4);
    expect(orderedBadges(BadgeFilter.locked).length, 8);
    // A badge on hold counts as locked until its celebration ends.
    badgeProgress[5] = 50;
    expect(orderedBadges(BadgeFilter.all, holdLocked: 5)[4].id, 5);
    expect(orderedBadges(BadgeFilter.all)[4].id, 5);
    expect(orderedBadges(BadgeFilter.earned).length, 5);
    expect(orderedBadges(BadgeFilter.earned, holdLocked: 5).length, 4);
  });

  testWidgets('badges: detail panel, tile selection and filters (screen 27)', (
    tester,
  ) async {
    await open(tester);
    // M05 is selected at start: name in the grid and in the panel.
    expect(find.text('قارئ متقدم'), findsNWidgets(2));
    expect(find.textContaining('34'), findsOneWidget);
    expect(find.text('5K'), findsOneWidget);
    await tester.tap(find.text('خاتم الوحدة'));
    await settle(tester);
    expect(find.text('خاتم الوحدة'), findsNWidgets(2));
    expect(find.text('100'), findsOneWidget);
    await tester.tap(find.text('مكتسبة'));
    await settle(tester);
    await tester.tap(find.text('غير مكتسبة'));
    await settle(tester);
    // The selected badge left the filter: the first locked one is selected.
    expect(find.text('قارئ متقدم'), findsNWidgets(2));
    await tester.tap(find.text('الكل'));
    await settle(tester);
  });

  testWidgets('badges: earning a badge plays once and ends earned', (
    tester,
  ) async {
    await open(tester);
    expect(isEarned(badges[4]), isFalse);
    badgeEarned.value = 5;
    await settle(tester);
    await tester.pump(const Duration(seconds: 3));
    expect(isEarned(badges[4]), isTrue);
    expect(badgeEarned.value, isNull);
    expect(find.textContaining('50'), findsWidgets);
  });
}
