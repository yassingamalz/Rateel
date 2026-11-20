import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class NavItem {
  const NavItem({
    required this.label,
    required this.railIcon,
    required this.menuIcon,
    required this.count,
  });

  final String label;

  /// Filled glyph used in the closed rail (style C).
  final FaIconData railIcon;

  /// Glyph used in the open menu (outline where the reference shows one).
  final FaIconData menuIcon;
  final int count;
}

/// Six sections, same order in the closed rail and the open menu (owner, 2026-11-20).
/// Counts are the demo values from the references until real data is wired.
const navItems = <NavItem>[
  NavItem(label: 'الدروس', railIcon: FontAwesomeIcons.graduationCap, menuIcon: FontAwesomeIcons.graduationCap, count: 30),
  NavItem(label: 'القرآن', railIcon: FontAwesomeIcons.book, menuIcon: FontAwesomeIcons.bookOpen, count: 114),
  NavItem(label: 'التدريب', railIcon: FontAwesomeIcons.microphone, menuIcon: FontAwesomeIcons.microphone, count: 2),
  NavItem(label: 'المتصدرين', railIcon: FontAwesomeIcons.trophy, menuIcon: FontAwesomeIcons.trophy, count: 15),
  NavItem(label: 'الإنجازات', railIcon: FontAwesomeIcons.medal, menuIcon: FontAwesomeIcons.medal, count: 5),
  NavItem(label: 'الشهادات', railIcon: FontAwesomeIcons.award, menuIcon: FontAwesomeIcons.fileLines, count: 3),
];
