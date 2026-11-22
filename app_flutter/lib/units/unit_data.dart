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

CourseUnitsProgress unitsProgressOf(int course) => _progressByCourse
    .putIfAbsent(course, () => CourseUnitsProgress(unitsOf(course).length));

/// Set by the lesson flow when the last lesson of a unit is finished (the
/// lesson screens then close back to the units screen, which plays the unit
/// completion). Index into [unitsOf] of the open course.
final unitCompleted = ValueNotifier<int?>(null);
