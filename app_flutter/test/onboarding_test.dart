import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:rateel/core/user_profile.dart';
import 'package:rateel/leaderboard/leaderboard_data.dart';
import 'package:rateel/onboarding/onboarding_screen.dart';

import 'widget_test.dart' show openApp, settle;

void main() {
  testWidgets('onboarding: name, avatar, level, goal, then the app (screen 30)',
      (tester) async {
    tester.view.physicalSize = const Size(1844, 853);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await openApp(tester, onboarded: false);
    expect(find.byType(OnboardingScreen), findsOneWidget);
    expect(find.text('أهلاً بك في رتّل'), findsOneWidget);

    // Empty name: «التالي» does not move on.
    await tester.tap(find.text('التالي'));
    await settle(tester);
    expect(find.text('ما اسمك؟'), findsOneWidget);

    await tester.enterText(find.byType(TextField), '  سارة  ');
    await tester.pump();
    // Third avatar of the row (right → left).
    final third = UserProfile.avatarChoices[2];
    await tester.tap(find.byWidgetPredicate((w) =>
        w is Image &&
        w.image is AssetImage &&
        (w.image as AssetImage).assetName ==
            'assets/ui/leaderboard/avatar_$third.webp'));
    await tester.pump();
    await tester.tap(find.text('التالي'));
    await settle(tester);
    expect(find.text('ما مستواك في التجويد؟'), findsOneWidget);

    await tester.tap(find.text('متوسط'));
    await tester.pump();
    await tester.tap(find.text('التالي'));
    await settle(tester);
    expect(find.text('ما هدفك اليومي؟'), findsOneWidget);

    await tester.tap(find.text('15 دقيقة'));
    await tester.pump();
    await tester.tap(find.text('ابدأ التعلّم'));
    await settle(tester);

    expect(find.byType(OnboardingScreen), findsNothing);
    expect(UserProfile.onboarded.value, isTrue);
    expect(UserProfile.name.value, 'سارة');
    expect(UserProfile.avatar.value, third);
    expect(UserProfile.levelName, 'متوسط');
    expect(UserProfile.goalMinutes.value, 15);
    // The leaderboard's user row shows the chosen name and avatar (Q11).
    final me = players.firstWhere((p) => p.isMe);
    expect(me.name, 'سارة');
    expect(me.avatar, third);
  });

  test('profile survives a save and a restore (JSON)', () {
    UserProfile.complete(newName: 'علي', newAvatar: 4, newLevel: 2, newGoal: 20);
    final snap = UserProfile.snapshot();
    UserProfile.onboarded.value = false;
    UserProfile.name.value = '';
    UserProfile.restore(Map<String, dynamic>.from(snap));
    expect(UserProfile.onboarded.value, isTrue);
    expect(UserProfile.name.value, 'علي');
    expect(UserProfile.avatar.value, 4);
    expect(UserProfile.level.value, 2);
    expect(UserProfile.goalMinutes.value, 20);
    // Bad values fall back to the defaults.
    UserProfile.restore({'name': '', 'avatar': 99, 'level': 7, 'goal': 3, 'onboarded': true});
    expect(UserProfile.onboarded.value, isFalse);
    expect(UserProfile.avatar.value, UserProfile.avatarChoices.first);
    expect(UserProfile.level.value, 2);
    expect(UserProfile.goalMinutes.value, 10);
  });
}
