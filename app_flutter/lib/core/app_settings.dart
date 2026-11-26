import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../lessons/lesson_data.dart';
import '../lessons/reading_data.dart';
import '../theme/rateel_theme.dart';
import '../units/unit_data.dart';

/// App settings, screen 23 (docs/flutter/screens/23-settings.md).
///
/// One notifier per setting; every change is stored at once on the device
/// (shared_preferences) and read back on start ([load], before runApp).
/// Failures of the storage are ignored: the app keeps working with defaults.
class AppSettings {
  AppSettings._();

  /// Light theme. Today only the lessons that have a light design (08) follow
  /// it; it is the same value as the reading lesson's moon toggle.
  static ValueNotifier<bool> get light => readingLight;

  /// Text size of the whole app, 0.9–1.1 (1.2 broke the fixed card layouts,
  /// 2026-11-26; course cards and screen 14 do not scale) (owner, 2026-11-21: the app ignores
  /// the phone's text zoom and scales its own text from here).
  static final textScale = ValueNotifier<double>(1.0);
  static const textScaleMin = 0.9;
  static const textScaleMax = 1.1;
  static const textScaleStep = 0.05;

  static final sounds = ValueNotifier<bool>(true);
  static final haptics = ValueNotifier<bool>(true);

  /// Reciter for the listening lessons (22) and the rules' audio examples (08).
  /// Stored only: no audio uses it yet.
  static final reciter = ValueNotifier<int>(0);
  static const reciters = [
    'محمود خليل الحصري',
    'محمد صديق المنشاوي',
    'عبد الباسط عبد الصمد',
    'مشاري راشد العفاسي',
  ];

  /// Daily reminder (time in minutes after midnight). Stored only: the
  /// notification itself comes with the daily challenges (12).
  static final reminder = ValueNotifier<bool>(true);
  static final reminderMinutes = ValueNotifier<int>(20 * 60);

  static SharedPreferences? _prefs;

  static Future<void> load() async {
    try {
      final p = _prefs = await SharedPreferences.getInstance().timeout(
        const Duration(seconds: 2),
      );
      light.value = p.getBool('light') ?? false;
      textScale.value = (p.getDouble('textScale') ?? 1.0).clamp(
        textScaleMin,
        textScaleMax,
      );
      sounds.value = p.getBool('sounds') ?? true;
      haptics.value = p.getBool('haptics') ?? true;
      reciter.value = (p.getInt('reciter') ?? 0).clamp(0, reciters.length - 1);
      reminder.value = p.getBool('reminder') ?? true;
      reminderMinutes.value = p.getInt('reminderMinutes') ?? 20 * 60;
    } catch (_) {}
    _syncTheme();
    light.addListener(() {
      _syncTheme();
      _prefs?.setBool('light', light.value);
    });
    textScale.addListener(
      () => _prefs?.setDouble('textScale', textScale.value),
    );
    sounds.addListener(() => _prefs?.setBool('sounds', sounds.value));
    haptics.addListener(() => _prefs?.setBool('haptics', haptics.value));
    reciter.addListener(() => _prefs?.setInt('reciter', reciter.value));
    reminder.addListener(() => _prefs?.setBool('reminder', reminder.value));
    reminderMinutes.addListener(
      () => _prefs?.setInt('reminderMinutes', reminderMinutes.value),
    );
  }

  static void _syncTheme() =>
      themeMode.value = light.value ? ThemeMode.light : ThemeMode.dark;

  /// «إعادة ضبط التقدم»: units, lessons and course progress back to 0
  /// (progress lives in memory for now; the screens rebuild from it).
  static void resetProgress() {
    resetUnitsProgress();
    resetLessonsDone();
  }
}

/// «8:00 م» from minutes after midnight (Arabic 12-hour clock, Latin digits as
/// in the reference).
String formatReminder(int minutes) {
  final h24 = minutes ~/ 60;
  final m = minutes % 60;
  final h = h24 % 12 == 0 ? 12 : h24 % 12;
  return '$h:${m.toString().padLeft(2, '0')} ${h24 < 12 ? 'ص' : 'م'}';
}
