import 'package:flutter/foundation.dart';

part 'unit_data_gen.dart';

/// Unit types used in the data (`src/assets/data/units/*.json`).
enum UnitType { video, reading, practice, test }

class Unit {
  const Unit({required this.id, required this.title, required this.type});

  final String id;
  final String title;
  final UnitType type;
}

/// Units of course [course] (index into `courses`). Empty for courses that
/// have no units file yet (08–11): the screen shows «قريبًا».
List<Unit> unitsOf(int course) => _unitsByCourse[course] ?? const [];

/// Progress of the units of one course, kept for the session (the real
/// storage comes with the lesson flow). The unit at [current] is in progress,
/// the ones before it are completed, the ones after it locked.
/// Progress always starts at 0 (owner, 2026-11-20).
class CourseUnitsProgress {
  CourseUnitsProgress(int count) : progress = List.filled(count, 0.0);

  int current = 0;
  final List<double> progress;
}

final _progressByCourse = <int, CourseUnitsProgress>{};

/// Settings «إعادة ضبط التقدم»: every course back to its first unit at 0.
void resetUnitsProgress() => _progressByCourse.clear();

/// Saved form of the units progress (`ProgressStore`): course index →
/// {current, progress}.
Map<String, Object> unitsProgressToJson() => {
  for (final e in _progressByCourse.entries)
    '${e.key}': {'current': e.value.current, 'progress': e.value.progress},
};

/// Restores [unitsProgressToJson], fitted to the units in the data today.
void unitsProgressFromJson(Map<String, dynamic> json) {
  _progressByCourse.clear();
  json.forEach((key, value) {
    final course = int.tryParse(key);
    if (course == null || value is! Map) return;
    final n = unitsOf(course).length;
    if (n == 0) return;
    final st = CourseUnitsProgress(n);
    final current = value['current'];
    if (current is num) st.current = current.toInt().clamp(0, n);
    final progress = value['progress'];
    if (progress is List) {
      for (var i = 0; i < n && i < progress.length; i++) {
        final v = progress[i];
        if (v is num) st.progress[i] = v.toDouble().clamp(0.0, 1.0);
      }
    }
    _progressByCourse[course] = st;
  });
}

CourseUnitsProgress unitsProgressOf(int course) => _progressByCourse
    .putIfAbsent(course, () => CourseUnitsProgress(unitsOf(course).length));

/// Set by the lesson flow when the last lesson of a unit is finished (the
/// lesson screens then close back to the units screen, which plays the unit
/// completion). Index into [unitsOf] of the open course.
final unitCompleted = ValueNotifier<int?>(null);

/// Progress of course [course] from its units (owner, 2026-11-22: one shared
/// progress): completed units plus the share of the unit in progress.
/// Courses without units keep 0.
double courseProgressFromUnits(int course) {
  final n = unitsOf(course).length;
  if (n == 0) return 0;
  final st = unitsProgressOf(course);
  final done = st.current.clamp(0, n);
  final partial = st.current < n ? st.progress[st.current] : 0.0;
  return (done + partial) / n;
}

/// Padlock size in u on locked units (reference 6.6u; owner: larger).
double lockSize = 9.0;
