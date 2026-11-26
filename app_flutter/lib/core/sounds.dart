import 'package:audioplayers/audioplayers.dart';

import 'app_settings.dart';

/// App sounds. The fill sound comes from the Angular app
/// (`public/sounds/fill-sound.mp3`, border-fill effect); the owner kept it for
/// the unit completion (2026-11-22). Failures (no audio device, web autoplay
/// rules) are ignored: sound is never required.
class Sounds {
  Sounds._();

  static final _player = AudioPlayer()..setReleaseMode(ReleaseMode.stop);

  /// Ring / progress fill on a completion.
  static Future<void> fill() async {
    if (!AppSettings.sounds.value) return; // settings «المؤثرات الصوتية»
    try {
      await _player.stop();
      await _player.play(AssetSource('sounds/fill-sound.mp3'), volume: 0.7);
    } catch (_) {}
  }

  // Test lesson (screen 10): CC0 sounds of plinkfx chosen by the owner
  // (2026-11-26, `docs/design-assets/test-lesson/sounds/README.md`).
  static final _test = AudioPlayer()..setReleaseMode(ReleaseMode.stop);

  static Future<void> _playTest(String file, double volume) async {
    if (!AppSettings.sounds.value) return; // settings «المؤثرات الصوتية»
    try {
      await _test.stop();
      await _test.play(AssetSource('sounds/$file'), volume: volume);
    } catch (_) {}
  }

  /// Correct answer: a glassy bell (plinkfx gem).
  static Future<void> correct() => _playTest('test_correct.mp3', 0.6);

  /// Wrong answer: two low buzzes (plinkfx error).
  static Future<void> wrong() => _playTest('test_wrong.mp3', 0.55);

  /// Correct answers in a row (streak banner, plinkfx sparkle).
  static Future<void> streak() => _playTest('test_streak.mp3', 0.55);

  /// Test passed (plinkfx level-up).
  static Future<void> passed() => _playTest('test_passed.mp3', 0.65);
}
