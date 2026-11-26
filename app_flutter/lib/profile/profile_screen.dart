import 'package:material_ui/material_ui.dart';

import '../challenges/challenge_data.dart';
import '../core/screen_decor.dart';
import '../leaderboard/leaderboard_data.dart';
import '../theme/rateel_theme.dart';

/// Profile preview using the existing leaderboard and streak demo data.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final player = players.firstWhere((p) => p.isMe);
    final rank = players.indexOf(player) + 1;
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final u = constraints.maxHeight / 100;
          return Stack(
            fit: StackFit.expand,
            children: [
              const RepaintBoundary(
                child: Image(
                  image: AssetImage('assets/ui/coming_soon/background.webp'),
                  fit: BoxFit.fill,
                  color: RateelColors.soonBgTone,
                  colorBlendMode: BlendMode.modulate,
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: u * 4,
                    vertical: u * 2,
                  ),
                  child: Column(
                    children: [
                      SizedBox(
                        height: u * 13,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Text(
                              'الملف الشخصي',
                              style: cairo(
                                u * 6.1,
                                weight: 700,
                                color: RateelColors.soonTitle,
                              ),
                            ),
                            Positioned(
                              right: 0,
                              child: IconButton(
                                tooltip: 'رجوع',
                                onPressed: () =>
                                    Navigator.of(context).maybePop(),
                                icon: Icon(
                                  Icons.arrow_forward_rounded,
                                  size: u * 6,
                                  color: RateelColors.cream,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: u * 76,
                        height: u * 3,
                        child: GoldDivider(u: u),
                      ),
                      Expanded(
                        child: LayoutBuilder(
                          builder: (context, area) {
                            // Scroll on narrow windows or larger accessibility text.
                            return SingleChildScrollView(
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  minHeight: area.maxHeight,
                                ),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    vertical: u * 3,
                                  ),
                                  child: Wrap(
                                    alignment: WrapAlignment.center,
                                    crossAxisAlignment:
                                        WrapCrossAlignment.center,
                                    spacing: u * 3,
                                    runSpacing: u * 3,
                                    children: [
                                      SizedBox(
                                        width: area.maxWidth < u * 150
                                            ? area.maxWidth
                                            : area.maxWidth * .36,
                                        child: _Identity(player: player, u: u),
                                      ),
                                      SizedBox(
                                        width: area.maxWidth < u * 150
                                            ? area.maxWidth
                                            : area.maxWidth * .58,
                                        child: _Progress(
                                          player: player,
                                          rank: rank,
                                          u: u,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      Text(
                        'بيانات تجريبية',
                        style: cairo(u * 2.45, color: const Color(0xffa7bb9b)),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

BoxDecoration _panel(double u) => BoxDecoration(
  borderRadius: BorderRadius.circular(u * 4),
  border: Border.all(color: RateelColors.setRimTop, width: u * .3),
  gradient: const LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [RateelColors.setCardTop, RateelColors.setCardBottom],
  ),
  boxShadow: [
    BoxShadow(
      color: const Color(0x55000000),
      blurRadius: u * 2,
      offset: Offset(0, u * .6),
    ),
  ],
);

class _Identity extends StatelessWidget {
  const _Identity({required this.player, required this.u});
  final Player player;
  final double u;

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.symmetric(horizontal: u * 3, vertical: u * 4),
    decoration: _panel(u),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: u * 25,
          height: u * 25,
          padding: EdgeInsets.all(u * .8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: RateelColors.gold, width: u * .45),
            boxShadow: [
              BoxShadow(
                color: RateelColors.gold.withValues(alpha: .22),
                blurRadius: u * 3,
              ),
            ],
          ),
          child: ClipOval(
            child: Image.asset(player.avatarAsset, fit: BoxFit.cover),
          ),
        ),
        SizedBox(height: u * 2),
        Text(
          player.name,
          textAlign: TextAlign.center,
          style: cairo(u * 5.1, weight: 700, color: RateelColors.soonTitle),
        ),
        SizedBox(height: u * .6),
        Text(
          player.region,
          style: cairo(u * 3, color: const Color(0xffbdccad)),
        ),
      ],
    ),
  );
}

class _Progress extends StatelessWidget {
  const _Progress({required this.player, required this.rank, required this.u});
  final Player player;
  final int rank;
  final double u;

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.all(u * 3.2),
    decoration: _panel(u),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'رحلتي في التعلّم',
          textAlign: TextAlign.right,
          style: cairo(u * 4.3, weight: 700, color: RateelColors.soonTitle),
        ),
        SizedBox(height: u * 1.5),
        SizedBox(
          height: u * 2.5,
          child: GoldDivider(u: u * .8),
        ),
        SizedBox(height: u * 1.5),
        Row(
          children: [
            Expanded(
              child: _Stat(
                icon: Icons.stars_rounded,
                value: '${player.score}',
                label: 'النقاط',
                u: u,
              ),
            ),
            SizedBox(width: u * 1.4),
            Expanded(
              child: _Stat(
                icon: Icons.menu_book_rounded,
                value: '${player.lessons}',
                label: 'الدروس',
                u: u,
              ),
            ),
          ],
        ),
        SizedBox(height: u * 1.4),
        Row(
          children: [
            Expanded(
              child: _Stat(
                icon: Icons.emoji_events_rounded,
                value: '$rank',
                label: 'الترتيب',
                u: u,
              ),
            ),
            SizedBox(width: u * 1.4),
            Expanded(
              child: ValueListenableBuilder<int>(
                valueListenable: dailyStreak,
                builder: (_, streak, _) => _Stat(
                  icon: Icons.local_fire_department_rounded,
                  value: '$streak',
                  label: 'أيام متتالية',
                  u: u,
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

class _Stat extends StatelessWidget {
  const _Stat({
    required this.icon,
    required this.value,
    required this.label,
    required this.u,
  });
  final IconData icon;
  final String value, label;
  final double u;

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.symmetric(vertical: u * 2, horizontal: u * 2),
    decoration: BoxDecoration(
      color: const Color(0x77002017),
      borderRadius: BorderRadius.circular(u * 2.2),
      border: Border.all(color: const Color(0x667f925e)),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: RateelColors.gold, size: u * 5.5),
        SizedBox(width: u * 2),
        Flexible(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                textDirection: TextDirection.ltr,
                style: cairo(
                  u * 4.3,
                  weight: 700,
                  color: RateelColors.soonTitle,
                ),
              ),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: cairo(u * 2.9, color: const Color(0xffd1dfbd)),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
