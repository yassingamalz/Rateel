class NavItem {
  const NavItem({required this.label, required this.icon, required this.count});

  final String label;

  /// SVG from the shared UI library (`assets/ui/nav/`), drawn with
  /// `currentColor`, same glyph in the rail and in the menu.
  final String icon;
  final int count;
}

/// Six sections, same order in the closed rail and the open menu (owner, 2026-11-20).
/// Counts are the demo values from the references until real data is wired.
const navItems = <NavItem>[
  NavItem(label: 'الدروس', icon: 'assets/ui/nav/lessons.svg', count: 30),
  NavItem(label: 'القرآن', icon: 'assets/ui/nav/quran.svg', count: 114),
  NavItem(label: 'التدريب', icon: 'assets/ui/nav/training.svg', count: 2),
  NavItem(label: 'المتصدرين', icon: 'assets/ui/nav/leaderboard.svg', count: 15),
  NavItem(label: 'الإنجازات', icon: 'assets/ui/nav/achievements.svg', count: 5),
  NavItem(label: 'الشهادات', icon: 'assets/ui/nav/certificates_two_tone.svg', count: 3),
];
