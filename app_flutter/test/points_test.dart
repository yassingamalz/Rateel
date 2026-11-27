import 'package:flutter_test/flutter_test.dart';
import 'package:rateel/gamification/points.dart';

void main() {
  test('level follows the Angular formula', () {
    expect(levelOf(0), 1);
    expect(levelOf(99), 1);
    expect(levelOf(100), 2);
    expect(levelOf(400), 3);
    expect(levelOf(511), 3);
    expect(levelOf(900), 4);
    expect(levelOf(10000000), maxLevel);
  });

  test('next level starts where the level formula says (fix of the 1089 bug)', () {
    expect(levelStart(3), 400);
    expect(levelEnd(3), 900);
    expect(pointsToNext(511), 389);
    expect(pointsToNext(899), 1);
    expect(levelOf(900), 4);
  });

  test('share through the level, cap at 99', () {
    expect(levelShare(400), 0);
    expect(levelShare(650), closeTo(0.5, 1e-9));
    expect(levelShare(10000000), 1);
    expect(levelEnd(maxLevel), isNull);
    expect(pointsToNext(10000000), 0);
  });

  test('mock ledger totals', () {
    expect(pointsSum(PointsKind.earned), 195);
    expect(pointsSum(PointsKind.bonus), 80);
    expect(pointsSum(PointsKind.spent), 20);
  });
}
