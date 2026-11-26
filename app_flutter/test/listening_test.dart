import 'package:flutter_test/flutter_test.dart';
import 'package:rateel/lessons/lesson_data.dart';
import 'package:rateel/lessons/listening_data.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('screen 22: mock listening lesson in «النون المشددة»', () {
    final l = lessonsOf('noon-mushaddad-theory');
    expect(l.map((e) => e.type), everyElement(LessonType.listen));
    expect(l.first.id, 'listen-ghunna');
  });

  test('screen 22: lesson data loads, words and peaks match', () async {
    final c = await ListenContent.load('listen-kawthar-ghunna');
    expect(c, isNotNull);
    expect(c!.questions, hasLength(5));
    for (final q in c.questions) {
      expect(q.options, contains(q.correct));
      expect(q.word, lessThan(q.ayah.words.length));
      expect(q.ayah.peaks, hasLength(51));
    }
    final a = c.questions.first.ayah;
    expect(a.wordAt(a.words[1].startMs + 1), 1);
    expect(a.wordAt(a.durationMs + 1), -1);
  });

  test('screen 22: rule lesson, coloured words inside the ayat', () async {
    final c = await ListenContent.load('listen-ghunna');
    expect(c!.rule!.colour, 'green');
    expect(c.steps, hasLength(7));
    expect(c.questions, hasLength(3));
    for (final s in c.steps) {
      for (final w in s.words) {
        expect(w, lessThan(s.ayah.words.length));
      }
    }
  });
}
