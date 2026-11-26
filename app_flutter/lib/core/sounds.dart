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
}
