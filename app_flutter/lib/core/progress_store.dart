import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../courses/course_data.dart';
import '../lessons/lesson_data.dart';
import '../units/unit_data.dart';

/// The learner's progress saved on the device (owner, 2026-11-27): the course
/// in progress and the course bars, the units of every course, the lessons
/// done in every unit. One JSON value in shared_preferences, written after
/// every change ([save]) and read once during startup ([load]), before the
/// courses screen is built. Failures of the storage are ignored: the app keeps
/// working in memory, as before.
///
/// Not saved yet (mock data, `SCREENS.md`): daily challenges and streak,
/// points, badges, leaderboard.
class ProgressStore {
  ProgressStore._();

  static const _key = 'progress.v1';
  static SharedPreferences? _prefs;

  /// A review link sets the progress itself (`?units=`, `?lessons=`, …): the
  /// saved progress is then neither read nor overwritten.
  static bool _review = false;

  static const _reviewKeys = {
    'complete',
    'units',
    'unit',
    'completeUnit',
    'lessons',
    'lessonDone',
    'completeLesson',
    'openLesson',
  };

  static Future<void> load() async {
    _review = Uri.base.queryParameters.keys.any(_reviewKeys.contains);
    if (_review) return;
    try {
      final p = _prefs = await SharedPreferences.getInstance().timeout(
        const Duration(seconds: 2),
      );
      final raw = p.getString(_key);
      if (raw == null) return;
      restore(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {}
  }

  /// The progress as saved (also used by the tests).
  static Map<String, Object> snapshot() => {
    'course': coursesProgress.current,
    'bars': coursesProgress.bars,
    'units': unitsProgressToJson(),
    'lessons': lessonsDoneToJson(),
  };

  /// Applies a [snapshot], fitted to the courses, units and lessons in the
  /// data today; values that do not fit are dropped.
  static void restore(Map<String, dynamic> json) {
    final cp = CoursesProgress();
    final course = json['course'];
    if (course is num) {
      cp.current = course.toInt().clamp(0, courses.length - 1);
    }
    final bars = json['bars'];
    if (bars is List) {
      for (var i = 0; i < cp.bars.length && i < bars.length; i++) {
        final v = bars[i];
        if (v is num) cp.bars[i] = v.toDouble().clamp(0.0, 1.0);
      }
    }
    coursesProgress = cp;
    final units = json['units'];
    unitsProgressFromJson(units is Map<String, dynamic> ? units : const {});
    final lessons = json['lessons'];
    lessonsDoneFromJson(lessons is Map<String, dynamic> ? lessons : const {});
    _finishInterrupted();
  }

  /// The app was closed during a completion sequence (the lessons are saved
  /// first, then the unit, then the course): a unit whose lessons are all
  /// done counts as completed; a course whose units are all done plays its
  /// completion on the courses screen at start.
  static void _finishInterrupted() {
    for (var c = 0; c < courses.length; c++) {
      final list = unitsOf(c);
      if (list.isEmpty) continue;
      final st = unitsProgressOf(c);
      while (st.current < list.length) {
        final id = list[st.current].id;
        final n = lessonsOf(id).length;
        if (n == 0 || lessonsDone(id) < n) break;
        st.progress[st.current] = 1;
        st.current++;
      }
    }
    final i = coursesProgress.current;
    if (unitsOf(i).isEmpty || courseProgressFromUnits(i) < 1) return;
    if (coursesProgress.bars[i] < 1) {
      courseCompleted.value = i;
    } else if (i < courses.length - 1) {
      // Closed while the light ran to the next course.
      coursesProgress.current = i + 1;
    }
  }

  static void save() {
    if (_review) return;
    _prefs?.setString(_key, jsonEncode(snapshot()));
  }

  /// Settings «إعادة ضبط التقدم».
  static void clear() {
    if (_review) return;
    _prefs?.remove(_key);
  }
}
