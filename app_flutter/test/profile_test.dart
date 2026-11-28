import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:rateel/core/app_settings.dart';
import 'package:rateel/settings/settings_screen.dart';

void main() {
  testWidgets(
    'profile opens from settings, shows the user, closes (screen 29)',
    (tester) async {
      tester.view.physicalSize = const Size(1686, 853);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      addTearDown(() {
        AppSettings.light.value = false;
        SettingsScreen.showProfile.value = false;
      });
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Directionality(
              textDirection: TextDirection.rtl,
              child: SettingsScreen(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('الملف الشخصي'));
      await tester.pumpAndSettle();
      expect(SettingsScreen.showProfile.value, isTrue);
      for (final t in [
        'أحمد عبدالرحمن',
        'الرياض',
        'النقاط',
        '511',
        'الدروس',
        '14',
        'الترتيب',
        '15',
        'أيام متتالية',
        'المستوى',
        'مستوى مبتدئ',
      ]) {
        expect(find.text(t), findsOneWidget, reason: t);
      }
      // Light theme: same content.
      AppSettings.light.value = true;
      await tester.pumpAndSettle();
      expect(find.text('أحمد عبدالرحمن'), findsOneWidget);
      // Drag to the right closes the profile (as screen 12).
      await tester.drag(find.text('الدروس'), const Offset(900, 0));
      await tester.pumpAndSettle();
      expect(SettingsScreen.showProfile.value, isFalse);
      expect(find.text('الإعدادات'), findsOneWidget);
    },
  );
}
