/// Badges data (screen 27, الأوسمة). **MOCK** (owner, 2026-11-27: «Claude
/// decides» the list): there is no backend yet; logged in
/// docs/flutter/SCREENS.md, «Screens running on mock data». Plan and the
/// requirements of every badge: docs/flutter/screens/27-badges.md.
library;

import 'package:flutter/foundation.dart';

enum BadgeFilter { all, earned, locked }

class BadgeDef {
  const BadgeDef({
    required this.id,
    required this.name,
    required this.description,
    required this.reward,
    required this.total,
    required this.start,
  });

  /// 1…12: medal `assets/ui/badges/m<nn>.webp`.
  final int id;
  final String name;
  final String description;

  /// Coins, as shown («5K»).
  final String reward;

  /// Target of the requirement, and the mock value it starts from.
  final int total;
  final int start;

  String get code => 'm${id.toString().padLeft(2, '0')}';
}

const badges = <BadgeDef>[
  BadgeDef(
    id: 1,
    name: 'بداية الرحلة',
    description: 'أكمل أول 5 دروس',
    reward: '50',
    total: 5,
    start: 5,
  ),
  BadgeDef(
    id: 2,
    name: 'خاتم الوحدة',
    description: 'أكمل وحدة كاملة من أي مقرر',
    reward: '100',
    total: 1,
    start: 1,
  ),
  BadgeDef(
    id: 3,
    name: 'إتقان التلاوة',
    description: 'أكمل 10 دروس استماع',
    reward: '200',
    total: 10,
    start: 10,
  ),
  BadgeDef(
    id: 4,
    name: 'خبير المخارج',
    description: 'أكمل مقرر مخارج الحروف',
    reward: '500',
    total: 1,
    start: 1,
  ),
  BadgeDef(
    id: 5,
    name: 'قارئ متقدم',
    description: 'أتمم 50 درسًا في أساسيات التجويد',
    reward: '5K',
    total: 50,
    start: 34,
  ),
  BadgeDef(
    id: 6,
    name: 'المواظب',
    description: 'تعلّم 7 أيام متتالية',
    reward: '300',
    total: 7,
    start: 4,
  ),
  BadgeDef(
    id: 7,
    name: 'متقن الغنة',
    description: 'أجب إجابة صحيحة عن 20 سؤالًا في الغنة',
    reward: '300',
    total: 20,
    start: 6,
  ),
  BadgeDef(
    id: 8,
    name: 'محترف الأحكام',
    description: 'أكمل مقرر أحكام النون والميم',
    reward: '1K',
    total: 1,
    start: 0,
  ),
  BadgeDef(
    id: 9,
    name: 'صوت جميل',
    description: 'سجّل 10 تلاوات',
    reward: '500',
    total: 10,
    start: 0,
  ),
  BadgeDef(
    id: 10,
    name: 'متميز في المراجعة',
    description: 'أعد 10 دروس مكتملة',
    reward: '300',
    total: 10,
    start: 2,
  ),
  BadgeDef(
    id: 11,
    name: 'المتفوق',
    description: 'احصل على علامة كاملة في 5 اختبارات',
    reward: '1K',
    total: 5,
    start: 1,
  ),
  BadgeDef(
    id: 12,
    name: 'سيد التجويد',
    description: 'أكمل جميع المقررات',
    reward: '10K',
    total: 12,
    start: 0,
  ),
];

/// Progress of every badge by id. In memory only (mock) until progress is
/// saved for real; «reset progress» (settings) will clear it with the rest.
final Map<int, int> badgeProgress = {for (final b in badges) b.id: b.start};

bool isEarned(BadgeDef b) => (badgeProgress[b.id] ?? 0) >= b.total;

double shareOf(BadgeDef b) =>
    ((badgeProgress[b.id] ?? 0) / b.total).clamp(0.0, 1.0);

/// The badge the app has just given (id), played once by the screen: the
/// celebration of the first time. The lessons / tests will set it when the
/// requirement is reached; review aid `?earn=5`.
final ValueNotifier<int?> badgeEarned = ValueNotifier<int?>(null);

/// Medal engraving: `std` (brown, as the reference) or `green` (dark green);
/// both come from the owner, the choice is open (review aid `?medals=green`).
String badgeMedalSet = 'std';

String medalAsset(BadgeDef b, {bool locked = false}) {
  if (locked) return 'assets/ui/badges/l1.webp';
  final dir = badgeMedalSet == 'green' ? 'green/' : '';
  return 'assets/ui/badges/$dir${b.code}.webp';
}

/// Order of the grid: earned first, then by progress (highest first), then
/// the list order (stable).
///
/// [holdLocked]: a badge being celebrated counts as still locked until the
/// effect ends, so its tile glides to the earned group only then.
List<BadgeDef> orderedBadges(BadgeFilter filter, {int? holdLocked}) {
  bool earned(BadgeDef b) => b.id != holdLocked && isEarned(b);
  final list = [
    for (final b in badges)
      if (filter == BadgeFilter.all || (filter == BadgeFilter.earned) == earned(b))
        b,
  ];
  int rank(BadgeDef b) => earned(b) ? 0 : 1;
  final indexOf = {for (var i = 0; i < badges.length; i++) badges[i].id: i};
  list.sort((a, b) {
    final r = rank(a) - rank(b);
    if (r != 0) return r;
    final s = shareOf(b).compareTo(shareOf(a));
    if (s != 0) return s;
    return indexOf[a.id]! - indexOf[b.id]!;
  });
  return list;
}

/// First badge in progress (the one selected when the screen opens), else the
/// first of the list.
BadgeDef firstInProgress() {
  final all = orderedBadges(BadgeFilter.all);
  return all.firstWhere((b) => !isEarned(b), orElse: () => all.first);
}
