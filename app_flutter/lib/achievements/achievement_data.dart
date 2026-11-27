/// Achievements data (screen 13, الإنجازات). **MOCK** (no backend, in memory
/// only): the five tiered achievements of the Angular app
/// (`gamification.service.ts`, `generateMockData`). Three of them are the same
/// event as a badge of screen 27 (owner, 2026-11-27: same event, same reward,
/// paid once): their progress is read from `badgeProgress`.
/// Plan: docs/flutter/screens/13-achievements.md.
library;

import 'package:flutter/painting.dart';

import '../badges/badge_data.dart';

enum Tier { bronze, silver, gold, platinum, diamond }

/// Rarity shown by the collection tab (Angular: bronze → common … diamond →
/// legendary).
enum Rarity { common, uncommon, rare, epic, legendary }

const rarityLabels = {
  Rarity.common: 'عادي',
  Rarity.uncommon: 'غير شائع',
  Rarity.rare: 'نادر',
  Rarity.epic: 'ملحمي',
  Rarity.legendary: 'أسطوري',
};

/// Tint of the card frame by tier (owner, 2026-11-27: subtle metal tint).
const tierColors = {
  Tier.bronze: Color(0xFFD59A63),
  Tier.silver: Color(0xFFD2D9DD),
  Tier.gold: Color(0xFFEBC24A),
  Tier.platinum: Color(0xFF9FD6DE),
  Tier.diamond: Color(0xFF9EC9FF),
};

class Achievement {
  const Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.tier,
    required this.reward,
    required this.total,
    required this.start,
    this.badgeId,
  });

  final int id;
  final String name;
  final String description;
  final Tier tier;

  /// Points given when earned.
  final int reward;
  final int total;
  final int start;

  /// Badge of screen 27 that is the same event (progress and medal image).
  final int? badgeId;

  Rarity get rarity => Rarity.values[tier.index];
}

const achievements = <Achievement>[
  Achievement(
    id: 1,
    name: 'بداية الرحلة',
    description: 'أكمل 5 دروس من المقرر',
    tier: Tier.bronze,
    reward: 50,
    total: 5,
    start: 5,
    badgeId: 1,
  ),
  Achievement(
    id: 2,
    name: 'متقن القراءة',
    description: 'أكمل 10 دروس من المقرر',
    tier: Tier.silver,
    reward: 100,
    total: 10,
    start: 10,
  ),
  Achievement(
    id: 3,
    name: 'حافظ النص',
    description: 'أكمل جميع دروس المقرر الأساسي',
    tier: Tier.gold,
    reward: 200,
    total: 20,
    start: 14,
  ),
  Achievement(
    id: 4,
    name: 'المتفوق',
    description: 'احصل على علامة كاملة في 5 اختبارات',
    tier: Tier.platinum,
    reward: 300,
    total: 5,
    start: 1,
    badgeId: 11,
  ),
  Achievement(
    id: 5,
    name: 'سيد التجويد',
    description: 'أكمل جميع مقررات التجويد',
    tier: Tier.diamond,
    reward: 500,
    total: 12,
    start: 0,
    badgeId: 12,
  ),
];

final Map<int, int> _ownProgress = {
  for (final a in achievements)
    if (a.badgeId == null) a.id: a.start,
};

BadgeDef _badge(int id) => badges.firstWhere((b) => b.id == id);

int achievementProgress(Achievement a) =>
    a.badgeId != null ? badgeProgress[a.badgeId] ?? 0 : _ownProgress[a.id] ?? 0;

int achievementTotal(Achievement a) =>
    a.badgeId != null ? _badge(a.badgeId!).total : a.total;

double achievementShare(Achievement a) =>
    (achievementProgress(a) / achievementTotal(a)).clamp(0.0, 1.0);

bool achievementEarned(Achievement a) =>
    achievementProgress(a) >= achievementTotal(a);

/// Emblem of the card: the card emblems C1–C5 are still to be generated
/// (docs/flutter/prompts/13-achievements); until then the medal of the badge
/// of the same idea.
String achievementEmblem(Achievement a) => switch (a.id) {
  1 => medalAsset(_badge(1)),
  2 => medalAsset(_badge(5)),
  3 => medalAsset(_badge(4)),
  4 => medalAsset(_badge(11)),
  _ => medalAsset(_badge(12)),
};

/// The medal before it is earned (brown engraving, shown dimmed with a
/// padlock), same mapping as [achievementEmblem].
String achievementEmblemStart(Achievement a) => switch (a.id) {
  1 => medalStart(_badge(1)),
  2 => medalStart(_badge(5)),
  3 => medalStart(_badge(4)),
  4 => medalStart(_badge(11)),
  _ => medalStart(_badge(12)),
};

/// One item of the collection tab (المجموعة): an achievement or a badge.
class CollectionItem {
  const CollectionItem({
    required this.name,
    required this.description,
    required this.image,
    required this.startImage,
    required this.share,
    required this.earned,
    required this.progressText,
    required this.reward,
    required this.rarity,
  });

  final String name;
  final String description;
  final String image;
  final String startImage;
  final double share;
  final bool earned;
  final String progressText;
  final String reward;
  final Rarity rarity;
}

/// Rarity of the 12 badges of screen 27 (by the size of their reward).
Rarity _badgeRarity(BadgeDef b) => switch (b.id) {
  1 || 2 => Rarity.common,
  3 || 6 || 7 || 10 => Rarity.uncommon,
  4 || 9 || 11 => Rarity.rare,
  5 || 8 => Rarity.epic,
  _ => Rarity.legendary,
};

List<CollectionItem> collectionItems() => [
  for (final a in achievements)
    CollectionItem(
      name: a.name,
      description: a.description,
      image: achievementEmblem(a),
      startImage: achievementEmblemStart(a),
      share: achievementShare(a),
      earned: achievementEarned(a),
      progressText: '${achievementProgress(a)} / ${achievementTotal(a)}',
      reward: '${a.reward}',
      rarity: a.rarity,
    ),
  for (final b in badges)
    if (!achievements.any((a) => a.badgeId == b.id))
      CollectionItem(
        name: b.name,
        description: b.description,
        image: medalAsset(b),
        startImage: medalStart(b),
        share: shareOf(b),
        earned: isEarned(b),
        progressText: '${badgeProgress[b.id] ?? 0} / ${b.total}',
        reward: b.reward,
        rarity: _badgeRarity(b),
      ),
];

int earnedAchievements() => achievements.where(achievementEarned).length;
