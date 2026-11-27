import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:rateel/profile/profile_screen.dart';
import 'package:rateel/challenges/challenge_data.dart';

void main() {
  testWidgets('profile renders leaderboard data and observes streak', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(915, 412);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    addTearDown(() => dailyStreak.value = 0);
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: ProfileScreen())),
    );
    await tester.pumpAndSettle();
    expect(find.text('أحمد عبدالرحمن'), findsOneWidget);
    expect(find.text('511'), findsOneWidget);
    expect(find.text('غير محدد'), findsOneWidget);
    dailyStreak.value = 4;
    await tester.pump();
    expect(find.text('4'), findsOneWidget);
  });
}
