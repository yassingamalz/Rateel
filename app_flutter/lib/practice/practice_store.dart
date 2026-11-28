import 'dart:convert';

import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../challenges/challenge_data.dart';

/// Daily practice (screen 31) saved on the device: the days with a completed
/// practice, the day the reminder popup was last shown and the first day of
/// use. One JSON value `practice.v1` in shared_preferences (as `progress.v1`
/// and `profile.v1`), read during startup and written after every change.
///
/// **One streak for the whole app** (owner, 2026-11-28, plan Q10): the
/// practice streak, published in [dailyStreak] for 03, 12, 24 and 29.
class PracticeStore {
  PracticeStore._();

  static const _key = 'practice.v1';
  static const _keepDays = 60;
  static SharedPreferences? _prefs;

  /// Days (`yyyy-mm-dd`) with a completed practice.
  static final days = ValueNotifier<Set<String>>({});

  /// Day the reminder popup was last shown (once a day, plan Q7).
  static String? remindedDay;

  /// First day of use: no reminder on that day.
  static String? firstDay;

  /// Review aids: `?practiceDays=0,1,2` (days ago with a practice),
  /// `?practiceToday=1`, `?remind=1` (force the popup), `?today=yyyy-mm-dd`.
  static bool review = false;
  static bool forceRemind = false;
  static DateTime? _today;

  static DateTime get today {
    final n = _today ?? DateTime.now();
    return DateTime(n.year, n.month, n.day);
  }

  static String key(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  static bool doneOn(DateTime d) => days.value.contains(key(d));
  static bool get doneToday => doneOn(today);

  /// Consecutive days with a practice up to today, or up to yesterday while
  /// today is not done yet.
  static int get streak {
    var d = today;
    if (!doneOn(d)) d = d.subtract(const Duration(days: 1));
    var n = 0;
    while (doneOn(d)) {
      n++;
      d = d.subtract(const Duration(days: 1));
    }
    return n;
  }

  /// The week shown on 31, Saturday → Friday (plan: as the reference).
  static List<DateTime> get week {
    final t = today;
    final fromSaturday = (t.weekday + 1) % 7; // Sat 0 … Fri 6
    final start = t.subtract(Duration(days: fromSaturday));
    return [for (var i = 0; i < 7; i++) start.add(Duration(days: i))];
  }

  /// Arabic initials of the week days, Saturday first.
  static const dayInitials = ['س', 'ح', 'ن', 'ث', 'ر', 'خ', 'ج'];

  /// Full days without a practice before today (0 = practised yesterday).
  static int get daysAway {
    final t = today;
    final first = firstDay == null ? t : DateTime.parse(firstDay!);
    var d = t.subtract(const Duration(days: 1));
    var n = 0;
    while (!doneOn(d) && !d.isBefore(first)) {
      n++;
      d = d.subtract(const Duration(days: 1));
      if (n > 365) break;
    }
    return n;
  }

  /// Reminder popup when a lesson opens (owner, plan Q7): no practice
  /// yesterday nor today, not on the first day of use, once a day.
  static bool get shouldRemind {
    if (forceRemind) return remindedDay != key(today);
    return !doneToday && daysAway >= 1 && remindedDay != key(today);
  }

  static void markReminded() {
    remindedDay = key(today);
    _save();
  }

  /// End of a practice session.
  static void markDoneToday() {
    days.value = {...days.value, key(today)};
    // The open practice challenge of 12 is completed by the practice (plan
    // Q11).
    final open = challengesDone.value;
    if (open < dailyChallenges.length &&
        dailyChallenges[open].kind == ChallengeKind.practice) {
      completeOpenChallenge();
    }
    _publish();
    _save();
  }

  static Future<void> load() async {
    final q = Uri.base.queryParameters;
    final t = DateTime.tryParse(q['today'] ?? '');
    if (t != null) _today = t;
    forceRemind = q['remind'] == '1';
    final ago = q['practiceDays'];
    review = ago != null || q['practiceToday'] != null || forceRemind;
    if (review) {
      final set = <String>{
        for (final s in (ago ?? '').split(','))
          if (int.tryParse(s) != null)
            key(today.subtract(Duration(days: int.parse(s)))),
      };
      if (q['practiceToday'] == '1') set.add(key(today));
      days.value = set;
      firstDay = key(today.subtract(const Duration(days: 30)));
      _publish();
      return;
    }
    try {
      final p = _prefs = await SharedPreferences.getInstance().timeout(
        const Duration(seconds: 2),
      );
      final raw = p.getString(_key);
      if (raw != null) restore(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {}
    if (firstDay == null) {
      firstDay = key(today);
      _save();
    }
    _publish();
  }

  static Map<String, Object?> snapshot() => {
    'days': (days.value.toList()..sort()),
    'reminded': remindedDay,
    'first': firstDay,
  };

  static void restore(Map<String, dynamic> j) {
    final d = j['days'];
    days.value = {
      if (d is List)
        for (final s in d)
          if (s is String && DateTime.tryParse(s) != null) s,
    };
    final r = j['reminded'];
    remindedDay = r is String ? r : null;
    final f = j['first'];
    firstDay = f is String && DateTime.tryParse(f) != null ? f : null;
  }

  static void _publish() {
    if (Uri.base.queryParameters['streak'] != null) return;
    dailyStreak.value = streak;
  }

  static void _save() {
    // Keep the last [_keepDays] days only.
    final cut = key(today.subtract(const Duration(days: _keepDays)));
    if (days.value.any((d) => d.compareTo(cut) < 0)) {
      days.value = {
        for (final d in days.value)
          if (d.compareTo(cut) >= 0) d,
      };
    }
    if (review) return;
    try {
      _prefs?.setString(_key, jsonEncode(snapshot()));
    } catch (_) {}
  }

  /// Settings «إعادة ضبط التقدم».
  static void clear() {
    days.value = {};
    remindedDay = null;
    _publish();
    if (review) return;
    try {
      _prefs?.setString(_key, jsonEncode(snapshot()));
    } catch (_) {}
  }
}

/// Arabic count of «n days»: يوم واحد / يومان / 3–10 أيام / 11+ يوماً.
String arabicDays(int n, {bool consecutive = false}) {
  if (consecutive) {
    if (n == 1) return 'يوم واحد';
    if (n == 2) return 'يومان متتاليان';
    if (n <= 10) return '$n أيام متتالية';
    return '$n يوماً متتالياً';
  }
  if (n == 1) return 'يوم';
  if (n == 2) return 'يومين';
  if (n <= 10) return '$n أيام';
  return '$n يوماً';
}

/// Arabic count of questions: سؤال واحد / سؤالان / 3–10 أسئلة / 11+ سؤالاً.
String arabicQuestions(int n) {
  if (n == 1) return 'سؤال واحد';
  if (n == 2) return 'سؤالان';
  if (n <= 10) return '$n أسئلة';
  return '$n سؤالاً';
}

/// Arabic count of ayat: آية واحدة / آيتان / 3–10 آيات / 11+ آية.
String arabicAyat(int n) {
  if (n == 1) return 'آية واحدة';
  if (n == 2) return 'آيتان';
  if (n <= 10) return '$n آيات';
  return '$n آية';
}
