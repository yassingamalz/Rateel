import 'package:material_ui/material_ui.dart';

import '../theme/rateel_theme.dart';

/// Contextual help for the reading lesson's real controls.
class ReadingHelp extends StatefulWidget {
  const ReadingHelp({super.key, required this.onClose});
  final VoidCallback onClose;

  @override
  State<ReadingHelp> createState() => _ReadingHelpState();
}

class _ReadingHelpState extends State<ReadingHelp> {
  int page = 0;
  static const tips = [
    (
      'تابع تقدمك',
      'يعرض عدد الأجزاء المنجزة من الدرس.',
      'المظهر وحجم الخط',
      'غيّر المظهر واضبط حجم النص للقراءة.',
    ),
    (
      'قواعد التجويد',
      'افتح شرح القواعد والألوان في النص.',
      'التنقل بين الأجزاء',
      'استخدم السهمين للانتقال بين أجزاء الدرس.',
    ),
    (
      'إيقاف الدرس',
      'أوقف الدرس مؤقتاً أو عد للقائمة.',
      'متابعة القراءة',
      'عند الانتهاء يمكنك متابعة الدرس.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final (title1, body1, title2, body2) = tips[page];
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) widget.onClose();
      },
      child: LayoutBuilder(
        builder: (context, box) {
          final u = box.maxHeight / 100;
          return Stack(
            fit: StackFit.expand,
            children: [
              const ModalBarrier(dismissible: false, color: Color(0xB900160F)),
              Positioned(
                left: u * 4,
                top: u * 3,
                child: IconButton(
                  tooltip: 'إغلاق المساعدة',
                  onPressed: widget.onClose,
                  icon: Icon(
                    Icons.cancel_outlined,
                    color: const Color(0xffffd568),
                    size: u * 8,
                  ),
                ),
              ),
              Positioned(
                top: u * 4,
                left: box.maxWidth / 2 - u * 45,
                width: u * 90,
                height: u * 12,
                child: _bubble(
                  u,
                  Text(
                    'كيف تستخدم الدرس؟',
                    textAlign: TextAlign.center,
                    style: readex(
                      u * 5.2,
                      weight: 700,
                      color: RateelColors.cream,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: u * 12,
                top: u * 17,
                width: u * 42,
                height: u * 11,
                child: _highlight(u),
              ),
              Positioned(
                left: box.maxWidth / 2 - u * 16,
                top: u * 32,
                width: u * 32,
                height: u * 11,
                child: _highlight(u),
              ),
              Positioned(
                left: u * 29,
                top: u * 31,
                width: u * 40,
                height: u * 20,
                child: _tip(u, title1, body1),
              ),
              Positioned(
                left: box.maxWidth / 2 - u * 23,
                top: u * 51,
                width: u * 46,
                height: u * 19,
                child: _tip(u, title2, body2),
              ),
              Positioned(
                bottom: u * 12,
                left: box.maxWidth / 2 - u * 17,
                width: u * 34,
                height: u * 9,
                child: ElevatedButton(
                  onPressed: () {
                    if (page == tips.length - 1) {
                      widget.onClose();
                    } else {
                      setState(() => page++);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: RateelColors.gold,
                    foregroundColor: const Color(0xff043a2b),
                  ),
                  child: Text(
                    page == tips.length - 1 ? 'تم' : 'التالي',
                    style: readex(
                      u * 4,
                      weight: 700,
                      color: const Color(0xff043a2b),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: u * 5,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (var i = 0; i < tips.length; i++)
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: u * 1.1),
                        width: u * 2.6,
                        height: u * 2.6,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: i == page
                              ? RateelColors.gold
                              : const Color(0xff426b51),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _highlight(double u) => IgnorePointer(
    child: DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(u * 8),
        border: Border.all(color: RateelColors.gold, width: u * .32),
        boxShadow: [
          BoxShadow(
            color: RateelColors.gold.withValues(alpha: .38),
            blurRadius: u * 2,
          ),
        ],
      ),
    ),
  );

  Widget _bubble(double u, Widget child) => Container(
    padding: EdgeInsets.all(u * 1.3),
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: const Color(0xff063d2e),
      borderRadius: BorderRadius.circular(u * 3.5),
      border: Border.all(color: RateelColors.gold, width: u * .35),
      boxShadow: [
        BoxShadow(
          color: RateelColors.gold.withValues(alpha: .25),
          blurRadius: u * 2,
        ),
      ],
    ),
    child: child,
  );

  Widget _tip(double u, String title, String text) => _bubble(
    u,
    FittedBox(
      fit: BoxFit.scaleDown,
      child: SizedBox(
        width: u * 36,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: readex(u * 3.7, weight: 700),
            ),
            SizedBox(height: u),
            Text(text, textAlign: TextAlign.center, style: readex(u * 2.9)),
          ],
        ),
      ),
    ),
  );
}
