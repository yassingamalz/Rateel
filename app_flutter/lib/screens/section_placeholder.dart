import 'package:material_ui/material_ui.dart';

import '../nav/nav_items.dart';
import '../theme/rateel_theme.dart';

/// Temporary content next to the navigation, until each screen is built.
/// Only the background (gradient + existing lattice corners) and the section
/// name: not a designed screen.
class SectionPlaceholder extends StatelessWidget {
  const SectionPlaceholder({super.key, required this.index});

  final int index;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) {
        final u = box.maxHeight / 100;
        return DecoratedBox(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(0, -0.4),
              radius: 1.2,
              colors: [RateelColors.bgTop, RateelColors.bgBottom],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                left: 0,
                top: 0,
                width: u * 26,
                child: Opacity(
                  opacity: 0.35,
                  child: Image.asset('assets/images/lattice-corner-left.webp'),
                ),
              ),
              Center(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    navItems[index].label,
                    key: ValueKey(index),
                    textDirection: TextDirection.rtl,
                    style: readex(u * 9, weight: 700),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
