import 'dart:convert';

import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The learner's profile from the first start (screen 30, onboarding; owner
/// 2026-11-27: no account, the data on the phone is primary). One JSON value
/// `profile.v1` in shared_preferences, read during startup ([load]) and
/// written after every change ([save]). Failures of the storage are ignored:
/// the app keeps the values in memory.
///
/// Used by: the profile 29 (name, avatar, starting level), the user's row of
/// the leaderboard 11 (name, avatar), the settings 23 (daily goal).
class UserProfile {
  UserProfile._();

  static const _key = 'profile.v1';
  static SharedPreferences? _prefs;

  /// Avatars offered on step A, right → left (owner, 2026-11-28, plan Q4):
  /// numbers of `assets/ui/leaderboard/avatar_<n>.webp`.
  static const avatarChoices = [6, 4, 2, 5, 3, 7];

  /// Levels of step B (index 0–2) and the daily goals of step C (minutes).
  static const levels = ['مبتدئ', 'متوسط', 'متقدم'];
  static const goals = [5, 10, 15, 20];

  /// Longest name accepted on step A (plan Q8).
  static const maxName = 20;

  /// False until the first start is completed: the app then opens the
  /// onboarding after the splash.
  static final onboarded = ValueNotifier<bool>(false);
  static final name = ValueNotifier<String>('');
  static final avatar = ValueNotifier<int>(avatarChoices.first);
  static final level = ValueNotifier<int>(0);
  static final goalMinutes = ValueNotifier<int>(10);

  static String get levelName => levels[level.value.clamp(0, 2)];

  /// Arabic label of a goal, as the cards of step C: «5 دقائق», «15 دقيقة».
  static String goalLabel(int minutes) =>
      '$minutes ${minutes <= 10 ? 'دقائق' : 'دقيقة'}';

  /// Review aid `?onboarding=1`: the onboarding opens even when completed
  /// and the saved profile is neither read nor overwritten.
  static bool review = false;

  static Future<void> load() async {
    review = Uri.base.queryParameters['onboarding'] == '1';
    if (review) return;
    try {
      final p = _prefs = await SharedPreferences.getInstance().timeout(
        const Duration(seconds: 2),
      );
      final raw = p.getString(_key);
      if (raw != null) restore(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {}
    // Settings 23 change the goal alone: save at once.
    goalMinutes.addListener(save);
  }

  static Map<String, Object> snapshot() => {
    'onboarded': onboarded.value,
    'name': name.value,
    'avatar': avatar.value,
    'level': level.value,
    'goal': goalMinutes.value,
  };

  static void restore(Map<String, dynamic> j) {
    name.value = (j['name'] as String? ?? '').trim();
    final a = j['avatar'];
    avatar.value = a is int && a >= 1 && a <= 10 ? a : avatarChoices.first;
    final l = j['level'];
    level.value = l is int ? l.clamp(0, levels.length - 1) : 0;
    final g = j['goal'];
    goalMinutes.value = g is int && goals.contains(g) ? g : 10;
    onboarded.value = j['onboarded'] == true && name.value.isNotEmpty;
  }

  static void save() {
    if (review) return;
    try {
      _prefs?.setString(_key, jsonEncode(snapshot()));
    } catch (_) {}
  }

  /// End of the first start (step C «ابدأ التعلّم») or of an edit (29).
  static void complete({
    required String newName,
    required int newAvatar,
    required int newLevel,
    required int newGoal,
  }) {
    name.value = newName.trim();
    avatar.value = newAvatar;
    level.value = newLevel;
    goalMinutes.value = newGoal;
    onboarded.value = true;
    save();
  }
}
