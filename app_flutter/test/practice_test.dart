import 'package:flutter_test/flutter_test.dart';
import 'package:rateel/challenges/challenge_data.dart';
import 'package:rateel/practice/practice_store.dart';

void main() {
  String ago(int n) =>
      PracticeStore.key(PracticeStore.today.subtract(Duration(days: n)));

  setUp(() {
    PracticeStore.days.value = {};
    PracticeStore.remindedDay = null;
    PracticeStore.firstDay = ago(30);
    PracticeStore.forceRemind = false;
  });

  test('streak counts up to today, or up to yesterday while today is open', () {
    PracticeStore.days.value = {ago(1), ago(2), ago(3), ago(5)};
    expect(PracticeStore.streak, 3);
    PracticeStore.days.value = {...PracticeStore.days.value, ago(0)};
    expect(PracticeStore.streak, 4);
  });

  test('week runs Saturday → Friday and holds today', () {
    final w = PracticeStore.week;
    expect(w.length, 7);
    expect(w.first.weekday, DateTime.saturday);
    expect(w.last.weekday, DateTime.friday);
    expect(w.contains(PracticeStore.today), isTrue);
  });

  test('reminder: a full day without practice, once a day, not day one', () {
    PracticeStore.days.value = {ago(1)};
    expect(PracticeStore.shouldRemind, isFalse); // practised yesterday
    PracticeStore.days.value = {ago(2)};
    expect(PracticeStore.daysAway, 1);
    expect(PracticeStore.shouldRemind, isTrue);
    PracticeStore.markReminded();
    expect(PracticeStore.shouldRemind, isFalse); // once a day
    PracticeStore.remindedDay = null;
    PracticeStore.days.value = {};
    PracticeStore.firstDay = ago(0);
    expect(PracticeStore.shouldRemind, isFalse); // first day of use
  });

  test('a practice today closes the reminder and sets the app streak', () {
    PracticeStore.days.value = {ago(1)};
    PracticeStore.markDoneToday();
    expect(PracticeStore.doneToday, isTrue);
    expect(PracticeStore.shouldRemind, isFalse);
    expect(dailyStreak.value, 2);
  });

  test('Arabic counts', () {
    expect(arabicDays(1), 'يوم');
    expect(arabicDays(2), 'يومين');
    expect(arabicDays(4, consecutive: true), '4 أيام متتالية');
    expect(arabicQuestions(3), '3 أسئلة');
    expect(arabicAyat(2), 'آيتان');
  });
}
