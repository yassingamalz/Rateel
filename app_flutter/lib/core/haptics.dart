import 'package:flutter/services.dart';

import 'app_settings.dart';

/// App-wide haptic vocabulary (owner, 2026-11-20: vibrations that make the app
/// feel professional). Every screen uses these names, never raw
/// HapticFeedback calls, so the feel stays the same everywhere.
/// On the web they are no-ops.
class Haptics {
  Haptics._();

  /// Settings «الاهتزاز» (screen 23).
  static bool get _on => AppSettings.haptics.value;

  /// Smallest tick: a progress step, a light passing a mark, a selection.
  static Future<void> tick() async {
    if (_on) await HapticFeedback.selectionClick();
  }

  /// A tap on something that reacts (card, button).
  static Future<void> tap() async {
    if (_on) await HapticFeedback.lightImpact();
  }

  /// A milestone reached: half of a course, a course at 100%.
  static Future<void> milestone() async {
    if (_on) await HapticFeedback.mediumImpact();
  }

  /// Something opens: the next course unlocks.
  static Future<void> unlock() async {
    if (_on) await HapticFeedback.heavyImpact();
  }

  /// Success: two short light taps.
  static Future<void> success() async {
    if (!_on) return;
    await HapticFeedback.lightImpact();
    await Future<void>.delayed(const Duration(milliseconds: 90));
    await HapticFeedback.lightImpact();
  }

  /// A lesson finished (owner, 2026-11-23: its own feel, a little different
  /// from the unit and course milestones): three quick rising taps.
  static Future<void> lessonDone() async {
    if (!_on) return;
    await HapticFeedback.selectionClick();
    await Future<void>.delayed(const Duration(milliseconds: 70));
    await HapticFeedback.lightImpact();
    await Future<void>.delayed(const Duration(milliseconds: 70));
    await HapticFeedback.mediumImpact();
  }

  /// Not allowed (locked course): a firm tap and a soft echo.
  static Future<void> denied() async {
    if (!_on) return;
    await HapticFeedback.mediumImpact();
    await Future<void>.delayed(const Duration(milliseconds: 80));
    await HapticFeedback.lightImpact();
  }
}
