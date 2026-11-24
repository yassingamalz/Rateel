import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:rateel/leaderboard/leaderboard_data.dart';
import 'package:rateel/leaderboard/leaderboard_screen.dart';

Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 8; i++) {
    await tester.pump(const Duration(milliseconds: 400));
  }
}

void main() {
  test('mock data: filters keep the global rank (as Angular)', () {
    expect(rankedFor(LeaderboardFilter.all).length, 15);
    final me = rankedFor(LeaderboardFilter.all).last;
    expect(me.$2.isMe, isTrue);
    expect(me.$1, 15);
    final friends = rankedFor(LeaderboardFilter.friends);
    expect(friends.every((e) => e.$2.isFriend || e.$2.isMe), isTrue);
    expect(friends.last.$1, 15);
    final region = rankedFor(LeaderboardFilter.region);
    expect(region.every((e) => e.$2.region == 'الرياض'), isTrue);
  });

  testWidgets('leaderboard: tabs filter, pinned bar scrolls to the user (screen 11)', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1686, 853);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.runAsync(() async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(body: LeaderboardScreen()),
          ),
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 500));
    });
    await settle(tester);
    // Pinned bar + the user's row in the list.
    expect(find.text('أحمد عبدالرحمن'), findsNWidgets(2));
    expect(find.text('10K'), findsOneWidget);
    await tester.tap(find.text('أحمد عبدالرحمن').last);
    await settle(tester);
    await tester.tap(find.text('الأصدقاء'));
    await settle(tester);
    expect(find.text('الأصدقاء'), findsOneWidget);
    await tester.tap(find.text('الكل'));
    await settle(tester);
  });
}
