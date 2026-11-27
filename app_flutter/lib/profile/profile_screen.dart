import 'package:flutter_svg/flutter_svg.dart';
import 'package:material_ui/material_ui.dart';

import '../challenges/challenge_data.dart';
import '../core/screen_decor.dart';
import '../leaderboard/leaderboard_data.dart';
import '../theme/rateel_theme.dart';

/// Profile (29). Values come from the existing leaderboard and streak demo.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key, this.onBack});
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final player = players.firstWhere((item) => item.isMe);
    final rank = players.indexOf(player) + 1;
    return LayoutBuilder(
      builder: (context, box) {
        final u = box.maxHeight / 100;
        final width = box.maxWidth;
        return Stack(
          fit: StackFit.expand,
          children: [
            const RepaintBoundary(child: ScreenBackground()),
            Positioned(
              left: 0,
              top: 0,
              width: u * 34,
              height: u * 32,
              child: Image.asset(
                'assets/ui/decor/corner_glow_left.webp',
                fit: BoxFit.contain,
              ),
            ),
            Positioned(
              right: 0,
              top: 0,
              width: u * 34,
              height: u * 32,
              child: Image.asset(
                'assets/ui/decor/corner_glow_right.webp',
                fit: BoxFit.contain,
              ),
            ),
            Positioned(
              left: u * 9,
              top: u * 3,
              width: u * 29,
              height: u * 24,
              child: Opacity(
                opacity: .46,
                child: Image.asset(
                  'assets/ui/decor/mosque.webp',
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Positioned(
              right: u * 22,
              top: u * 4,
              width: u * 12,
              height: u * 12,
              child: SvgPicture.asset('assets/ui/decor/crescent_star.svg'),
            ),
            Positioned(
              left: width / 2 - u * 43,
              top: u * 1,
              width: u * 86,
              height: u * 19,
              child: SvgPicture.asset(
                'assets/ui/decor/header_arch.svg',
                fit: BoxFit.fill,
              ),
            ),
            Positioned(
              left: width / 2 - u * 6,
              top: u * 4,
              width: u * 12,
              height: u * 8,
              child: SvgPicture.asset(
                'assets/ui/decor/header_book.svg',
                fit: BoxFit.contain,
              ),
            ),
            Positioned(
              top: u * 11,
              left: 0,
              right: 0,
              child: Text(
                'الملف الشخصي',
                textAlign: TextAlign.center,
                style: readex(
                  u * 6.4,
                  weight: 700,
                  color: RateelColors.soonTitle,
                ),
              ),
            ),
            Positioned(
              left: width / 2 - u * 20,
              top: u * 21,
              width: u * 40,
              height: u * 3,
              child: GoldDivider(u: u),
            ),
            Positioned(
              left: u * 3,
              top: u * 2,
              child: IconButton(
                tooltip: 'رجوع',
                onPressed: onBack ?? () => Navigator.of(context).maybePop(),
                icon: Icon(
                  Icons.arrow_forward_rounded,
                  color: RateelColors.cream,
                  size: u * 6,
                ),
              ),
            ),
            Positioned(
              left: u * 5,
              right: u * 5,
              top: u * 26,
              bottom: u * 3,
              child: LayoutBuilder(
                builder: (context, available) => SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: available.maxHeight),
                    child: Column(
                      children: [
                        _identity(player, u),
                        SizedBox(height: u * 2),
                        _overview(player, rank, u),
                        SizedBox(height: u),
                        Text(
                          'بيانات تجريبية',
                          style: readex(
                            u * 2.2,
                            color: const Color(0xff9fb89d),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _identity(Player player, double u) => Container(
    height: u * 28,
    padding: EdgeInsets.symmetric(horizontal: u * 4, vertical: u * 1.5),
    decoration: _panel(u, gold: true),
    child: Row(
      children: [
        Container(
          width: u * 22,
          height: u * 22,
          padding: EdgeInsets.all(u * .55),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: RateelColors.gold, width: u * .45),
          ),
          child: ClipOval(
            child: Image.asset(player.avatarAsset, fit: BoxFit.cover),
          ),
        ),
        SizedBox(width: u * 4),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                player.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: readex(
                  u * 5.3,
                  weight: 700,
                  color: RateelColors.soonTitle,
                ),
              ),
              SizedBox(height: u * 2),
              Row(
                children: [
                  Icon(
                    Icons.location_on_rounded,
                    color: RateelColors.gold,
                    size: u * 4,
                  ),
                  SizedBox(width: u),
                  Text(
                    player.region,
                    style: readex(u * 3.3, color: const Color(0xffc7d1b5)),
                  ),
                ],
              ),
            ],
          ),
        ),
        Container(
          width: u * .2,
          height: u * 18,
          color: RateelColors.gold.withValues(alpha: .35),
        ),
        SizedBox(width: u * 5),
        SizedBox(
          width: u * 33,
          child: Image.asset(
            'assets/ui/course_art/emblem/course_01.webp',
            fit: BoxFit.contain,
          ),
        ),
      ],
    ),
  );

  Widget _overview(Player p, int rank, double u) => Container(
    padding: EdgeInsets.all(u * 2),
    decoration: _panel(u),
    child: Column(
      children: [
        ValueListenableBuilder<int>(
          valueListenable: dailyStreak,
          builder: (context, streak, _) => Row(
            children: [
              Expanded(
                child: _stat(Icons.star_rounded, 'النقاط', '${p.score}', u),
              ),
              SizedBox(width: u * 1.5),
              Expanded(
                child: _stat(
                  Icons.menu_book_rounded,
                  'الدروس',
                  '${p.lessons}',
                  u,
                ),
              ),
              SizedBox(width: u * 1.5),
              Expanded(
                child: _stat(
                  Icons.workspace_premium_rounded,
                  'الترتيب',
                  '$rank',
                  u,
                ),
              ),
              SizedBox(width: u * 1.5),
              Expanded(
                child: _stat(
                  Icons.local_fire_department_rounded,
                  'أيام متتالية',
                  '$streak',
                  u,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: u * 2),
        Container(
          height: u * 10,
          padding: EdgeInsets.symmetric(horizontal: u * 4),
          decoration: _panel(u),
          child: Row(
            children: [
              Icon(
                Icons.layers_outlined,
                size: u * 5,
                color: RateelColors.gold,
              ),
              SizedBox(width: u * 2),
              Text('المستوى', style: readex(u * 3.7, weight: 600)),
              const Spacer(),
              Text(
                'غير محدد',
                style: readex(u * 3.5, color: RateelColors.gold),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _stat(IconData icon, String label, String value, double u) =>
      Container(
        height: u * 21,
        padding: EdgeInsets.symmetric(horizontal: u, vertical: u * .6),
        decoration: _panel(u),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Icon(icon, color: RateelColors.gold, size: u * 5.4),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                maxLines: 1,
                style: readex(u * 3, weight: 550),
              ),
            ),
            SizedBox(
              height: u * 1.4,
              width: u * 12,
              child: GoldDivider(u: u * .5),
            ),
            Text(
              value,
              textDirection: TextDirection.ltr,
              style: readex(u * 4.7, weight: 700),
            ),
          ],
        ),
      );
}

BoxDecoration _panel(double u, {bool gold = false}) => BoxDecoration(
  borderRadius: BorderRadius.circular(u * 4),
  border: Border.all(
    color: gold ? RateelColors.gold : const Color(0xff3d7964),
    width: u * .28,
  ),
  gradient: const LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xff114b36), Color(0xff003024)],
  ),
  boxShadow: const [
    BoxShadow(color: Color(0x40000000), blurRadius: 8, offset: Offset(0, 3)),
  ],
);
