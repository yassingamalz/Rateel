import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:rateel/profile/profile_screen.dart';
import 'package:rateel/challenges/challenge_data.dart';

void main() {
  testWidgets('profile shows leaderboard data, updates streak and returns', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(915, 412);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    addTearDown(() => dailyStreak.value = 0);
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const ProfileScreen()),
            ),
            child: const Text('open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.text('أحمد عبدالرحمن'), findsOneWidget);
    expect(find.text('511'), findsOneWidget);
    expect(find.text('بيانات تجريبية'), findsOneWidget);
    dailyStreak.value = 4;
    await tester.pump();
    expect(find.text('4'), findsOneWidget);
    await tester.tap(find.byTooltip('رجوع'));
    await tester.pumpAndSettle();
    expect(find.text('open'), findsOneWidget);
  });
}
