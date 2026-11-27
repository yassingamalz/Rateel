/// Points and levels (screen 13, achievements). **MOCK**: there is no backend
/// and no saving yet; logged in docs/flutter/SCREENS.md («Screens running on
/// mock data»). One shared number for the app (owner, 2026-11-27): the
/// achievements page, and later the leaderboard, the lessons (+10) and the
/// badge rewards read [userPoints].
///
/// Level maths from the Angular app (`achievement-header.component.ts`):
/// `level = 1 + floor(sqrt(points / 100))`, cap 99. The Angular «next level»
/// number was wrong (it showed 1089 at 511 points while level 4 starts at
/// 900); the owner approved the fix (2026-11-27): level L starts at
/// (L − 1)² · 100 and level L + 1 at L² · 100.
library;

import 'dart:math' as math;

import 'package:flutter/foundation.dart';

/// The user's points. Mock start: 511 (level 3), as the reference and the
/// leaderboard user.
final userPoints = ValueNotifier<int>(511);

const maxLevel = 99;

/// Level reached with [points].
int levelOf(int points) {
  if (points <= 0) return 1;
  return math.min(1 + math.sqrt(points / 100).floor(), maxLevel);
}

/// Points at which [level] starts.
int levelStart(int level) => (level - 1) * (level - 1) * 100;

/// Points at which the level after [level] starts (null at the cap).
int? levelEnd(int level) => level >= maxLevel ? null : level * level * 100;

/// Points still missing for the next level (0 at the cap).
int pointsToNext(int points) {
  final end = levelEnd(levelOf(points));
  return end == null ? 0 : end - points;
}

/// Share (0–1) of the way through the current level; 1 at the cap.
double levelShare(int points) {
  final l = levelOf(points);
  final end = levelEnd(l);
  if (end == null) return 1;
  final start = levelStart(l);
  return ((points - start) / (end - start)).clamp(0.0, 1.0);
}

enum PointsKind { earned, bonus, spent }

class PointsActivity {
  const PointsActivity(this.title, this.points, this.kind, this.daysAgo);

  final String title;

  /// Negative for [PointsKind.spent].
  final int points;
  final PointsKind kind;
  final int daysAgo;
}

/// Mock ledger, newest first (the titles are the Angular ones).
const pointsActivities = <PointsActivity>[
  PointsActivity('إكمال درس النون الساكنة', 40, PointsKind.earned, 0),
  PointsActivity('مكافأة يومية', 25, PointsKind.bonus, 1),
  PointsActivity('إكمال اختبار بنجاح', 50, PointsKind.earned, 2),
  PointsActivity('إنجاز متتالي', 30, PointsKind.bonus, 3),
  PointsActivity('فتح درس إضافي', -20, PointsKind.spent, 4),
  PointsActivity('إكمال تحدي الإدغام', 45, PointsKind.earned, 6),
  PointsActivity('مكافأة يومية', 25, PointsKind.bonus, 8),
  PointsActivity('إكمال المقرر الأساسي', 60, PointsKind.earned, 11),
];

int pointsSum(PointsKind kind) => pointsActivities
    .where((a) => a.kind == kind)
    .fold(0, (s, a) => s + a.points.abs());

/// Review aid `?points=950`: set the points at start.
void debugSetPoints(int p) => userPoints.value = p;
