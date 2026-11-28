import 'package:material_ui/material_ui.dart';

class NavItem {
  const NavItem({required this.label, this.icon, this.iconData, this.count});

  final String label;

  /// SVG from the shared UI library (`assets/ui/nav/`), drawn with
  /// `currentColor`, same glyph in the rail and in the menu.
  final String? icon;

  /// Font glyph for items without an SVG (the settings gear).
  final IconData? iconData;

  /// Count bubble; null = no bubble (settings).
  final int? count;
}

/// Six sections, same order in the closed rail and the open menu (owner, 2026-11-20),
/// plus the settings gear at the bottom (screen 23, owner 2026-11-25: the rail
/// scrolls when it does not fit).
/// Counts are the demo values from the references until real data is wired.
const navItems = <NavItem>[
  NavItem(label: 'الدروس', icon: 'assets/ui/nav/lessons.svg', count: 30),
  NavItem(label: 'القرآن', icon: 'assets/ui/nav/quran.svg', count: 114),
  NavItem(label: 'التدريب', icon: 'assets/ui/nav/training.svg', count: 2),
  NavItem(label: 'المتصدرين', icon: 'assets/ui/nav/leaderboard.svg', count: 15),
  NavItem(label: 'الإنجازات', icon: 'assets/ui/nav/achievements.svg', count: 5),
  NavItem(
    label: 'الشهادات',
    icon: 'assets/ui/nav/certificates_two_tone.svg',
    count: 3,
  ),
  NavItem(label: 'الإعدادات', iconData: Icons.settings_rounded),
];

/// Index of «التدريب» (screen 31).
const practiceSection = 2;

/// Index of the settings item.
const settingsSection = 6;
