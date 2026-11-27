import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:rateel/core/app_settings.dart';
import 'package:rateel/core/progress_store.dart';
import 'package:rateel/courses/course_data.dart';
import 'package:rateel/lessons/lesson_data.dart';
import 'package:rateel/units/unit_data.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    AppSettings.resetProgress();
    courseCompleted.value = null;
  });

  test('progress survives a save and a restore (JSON)', () {
    final unit0 = unitsOf(0)[0].id;
    coursesProgress.current = 1;
    coursesProgress.bars[0] = 1;
    coursesProgress.bars[1] = 0.25;
    unitsProgressOf(1).current = 1;
    unitsProgressOf(1).progress[1] = 0.5;
    setLessonsDone(unit0, 2);

    final raw = jsonEncode(ProgressStore.snapshot());
    AppSettings.resetProgress();
    expect(coursesProgress.current, 0);
    expect(lessonsDone(unit0), 0);

    ProgressStore.restore(jsonDecode(raw) as Map<String, dynamic>);
    expect(coursesProgress.current, 1);
    expect(coursesProgress.bars[0], 1);
    expect(coursesProgress.bars[1], 0.25);
    expect(unitsProgressOf(1).current, 1);
    expect(unitsProgressOf(1).progress[1], 0.5);
    expect(lessonsDone(unit0), 2);
  });

  test('saved values that no longer fit the data are dropped or clamped', () {
    final unit0 = unitsOf(0)[0].id;
    ProgressStore.restore({
      'course': 99,
      'bars': [2, -1, 'x'],
      'units': {
        '0': {
          'current': 99,
          'progress': [0.5],
        },
        'nope': {'current': 1},
      },
      'lessons': {unit0: 99, 'no-such-unit': 3},
    });
    expect(coursesProgress.current, courses.length - 1);
    expect(coursesProgress.bars[0], 1);
    expect(coursesProgress.bars[1], 0);
    expect(unitsProgressOf(0).current, unitsOf(0).length);
    expect(lessonsDone(unit0), lessonsOf(unit0).length);
    expect(lessonsDone('no-such-unit'), 0);
  });

  test('a unit whose lessons are all done counts as completed', () {
    final unit0 = unitsOf(0)[0].id;
    final n = lessonsOf(unit0).length;
    expect(n, greaterThan(0));
    ProgressStore.restore({
      'lessons': {unit0: n},
    });
    expect(unitsProgressOf(0).current, 1);
    expect(unitsProgressOf(0).progress[0], 1);
  });

  test('reset clears the saved progress too', () async {
    SharedPreferences.setMockInitialValues({
      'progress.v1': jsonEncode({'course': 1}),
    });
    await ProgressStore.load();
    expect(coursesProgress.current, 1);
    AppSettings.resetProgress();
    expect(coursesProgress.current, 0);
    final p = await SharedPreferences.getInstance();
    expect(p.getString('progress.v1'), isNull);
  });
}
