/// Leaderboard data. **MOCK** (owner, 2026-11-24): there is no backend yet;
/// logged in docs/flutter/SCREENS.md, «Screens running on mock data».
/// Names and avatars come from the Angular mock (gamification.service.ts:
/// name i ↔ avatar i % 10 + 1); the first rows and the user follow the
/// reference (11-classifica.webp): the user «أحمد عبدالرحمن» is rank 15,
/// as the nav badge.
library;

enum LeaderboardFilter { all, friends, region }

class Player {
  const Player({
    required this.name,
    required this.avatar,
    required this.score,
    required this.lessons,
    this.isMe = false,
    this.isFriend = false,
    required this.region,
  });

  final String name;

  /// 1…10: `assets/ui/leaderboard/avatar_<n>.webp`.
  final int avatar;
  final int score;
  final int lessons;
  final bool isMe;
  final bool isFriend;
  final String region;

  String get avatarAsset => 'assets/ui/leaderboard/avatar_$avatar.webp';
}

/// Rank = position in [players] (sorted by score, highest first).
const players = <Player>[
  Player(
    name: 'عبدالله محمد',
    avatar: 3,
    score: 1406,
    lessons: 33,
    isFriend: true,
    region: 'الرياض',
  ),
  Player(name: 'حسن علي', avatar: 9, score: 1302, lessons: 7, region: 'جدة'),
  Player(
    name: 'ليلى أحمد',
    avatar: 8,
    score: 1299,
    lessons: 21,
    isFriend: true,
    region: 'الرياض',
  ),
  Player(name: 'محمد أحمد', avatar: 1, score: 1187, lessons: 26, region: 'مكة'),
  Player(
    name: 'فاطمة علي',
    avatar: 2,
    score: 1102,
    lessons: 19,
    isFriend: true,
    region: 'الرياض',
  ),
  Player(
    name: 'نورة سلطان',
    avatar: 4,
    score: 1046,
    lessons: 24,
    region: 'الدمام',
  ),
  Player(
    name: 'سارة خالد',
    avatar: 6,
    score: 973,
    lessons: 17,
    region: 'الرياض',
  ),
  Player(
    name: 'يوسف محمد',
    avatar: 7,
    score: 911,
    lessons: 15,
    isFriend: true,
    region: 'المدينة',
  ),
  Player(name: 'ريم سعد', avatar: 10, score: 864, lessons: 12, region: 'جدة'),
  Player(
    name: 'عمر محمد',
    avatar: 1,
    score: 802,
    lessons: 16,
    region: 'الرياض',
  ),
  Player(
    name: 'جواهر فهد',
    avatar: 2,
    score: 745,
    lessons: 11,
    isFriend: true,
    region: 'مكة',
  ),
  Player(
    name: 'خالد ناصر',
    avatar: 3,
    score: 688,
    lessons: 10,
    region: 'الرياض',
  ),
  Player(
    name: 'سلمى عبدالله',
    avatar: 4,
    score: 640,
    lessons: 9,
    region: 'الدمام',
  ),
  Player(
    name: 'طلال فيصل',
    avatar: 6,
    score: 577,
    lessons: 8,
    isFriend: true,
    region: 'جدة',
  ),
  Player(
    name: 'أحمد عبدالرحمن',
    avatar: 5,
    score: 511,
    lessons: 14,
    isMe: true,
    region: 'الرياض',
  ),
];

/// Entries of a filter with their **global** rank (as Angular: the filtered
/// list keeps `player.rank`; medals and rewards go to its first three rows).
List<(int rank, Player player)> rankedFor(LeaderboardFilter f) {
  final me = players.firstWhere((p) => p.isMe);
  final list = switch (f) {
    LeaderboardFilter.all => players,
    LeaderboardFilter.friends =>
      players.where((p) => p.isFriend || p.isMe).toList(),
    LeaderboardFilter.region =>
      players.where((p) => p.region == me.region).toList(),
  };
  return [for (final p in list) (players.indexOf(p) + 1, p)];
}

/// Rewards of the first three (Angular: 10K / 5K / 2K).
const rewards = ['10K', '5K', '2K'];
const medals = ['gold', 'silver', 'bronze'];
