part 'lesson_data_gen.dart';

/// Lesson types in the data (`src/assets/data/lessons/*/*.json`);
/// `assessment` is read as [test].
enum LessonType { video, read, practice, listen, test }

class Lesson {
  const Lesson({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.minutes,
  });

  final String id;
  final String title;
  final String description;
  final LessonType type;

  /// Duration in minutes (0 when the data has none).
  final int minutes;
}

/// Lessons of the unit with id [unitId]. Empty for units that have no lessons
/// in the data yet: screen 06 shows «قريبًا».
List<Lesson> lessonsOf(String unitId) => _lessonsByUnit[unitId] ?? const [];

/// Lessons completed in each unit, kept for the session (the real storage
/// comes with the backend). One progress for the whole app (owner,
/// 2026-11-22): the unit ring is done / lessons, the course bar follows the
/// units (`courseProgressFromUnits`).
final _doneByUnit = <String, int>{};

int lessonsDone(String unitId) => _doneByUnit[unitId] ?? 0;

void setLessonsDone(String unitId, int done) => _doneByUnit[unitId] = done;

/// Share of the unit done by its lessons (0 when it has none).
double unitShareFromLessons(String unitId) {
  final n = lessonsOf(unitId).length;
  return n == 0 ? 0 : lessonsDone(unitId).clamp(0, n) / n;
}

/// Review aid: `?completeLesson=<k>` plays the completion of lesson k when
/// the lessons screen opens.
int? startCompleteLesson;

/// Scale of the lesson cards and title: ×1.4 (owner, 2026-11-22); review:
/// `?origScale=1.35`.
double origScale = 1.4;

/// Padlock of a locked lesson: `icon` (on the lesson-type icon, as screen 05)
/// or `card` (card centre, on a dark glass disc). Review: `?lessonLock=card`.
String lessonLockPos = 'card';

/// Padlock colour under review: `green` (screen 05) or `gold` (owner's trial,
/// 2026-11-23). Review: `?lessonLockColor=gold`.
String lessonLockColor = 'green';
