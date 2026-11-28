import 'package:material_ui/material_ui.dart';

/// Screen 12, daily challenges: **mock data** (logged in docs/flutter/SCREENS.md,
/// «Screens running on mock data»), the list of the Angular original
/// (`daily-challenges.service.ts`): seven challenges done in order, the last
/// one (the trophy) worth 100 and acting as the final bonus (owner Q4).
///
/// To wire later (owner, 2026-11-25, Q3): a challenge is completed when the
/// user comes back from the matching activity (lesson, practice, recitation);
/// the path resets at midnight; the streak gains one day for each day with at
/// least one completed challenge and goes back to 0 after a missed day (Q6).
enum ChallengeKind { lesson, practice, recitation, trophy }

class Challenge {
  const Challenge(this.kind, this.points);

  final ChallengeKind kind;
  final int points;

  /// Cream glyph of the tile (owner's icon collection, green-line variants;
  /// microphone and trophy from the shared library).
  String get icon => switch (kind) {
    ChallengeKind.lesson => 'assets/ui/icons/document_01.webp',
    ChallengeKind.practice => 'assets/ui/coming_soon/glyph_microphone.webp',
    ChallengeKind.recitation => 'assets/ui/icons/quran_rehal_01.webp',
    ChallengeKind.trophy => 'assets/ui/icons/trophy_cream_01.webp',
  };
}

const dailyChallenges = <Challenge>[
  Challenge(ChallengeKind.lesson, 50),
  Challenge(ChallengeKind.practice, 50),
  Challenge(ChallengeKind.recitation, 50),
  Challenge(ChallengeKind.lesson, 50),
  Challenge(ChallengeKind.practice, 50),
  Challenge(ChallengeKind.recitation, 50),
  Challenge(ChallengeKind.trophy, 100),
];

/// Challenges completed today, in order (0 = only the first one is open).
final challengesDone = ValueNotifier<int>(0);

/// The app's streak: days in a row with a completed daily practice (owner,
/// 2026-11-28: one streak for the whole app). Set by `PracticeStore`.
final dailyStreak = ValueNotifier<int>(0);

/// Marks the open challenge as completed (review: long press on the open tile).
void completeOpenChallenge() {
  if (challengesDone.value >= dailyChallenges.length) return;
  challengesDone.value++;
}
