import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:rateel/main.dart';

void main() {
  testWidgets('side nav opens and closes', (tester) async {
    tester.view.physicalSize = const Size(1844, 853);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const RateelApp());
    expect(find.text('الشهادات'), findsNothing); // labels only in the open menu
    await tester.tap(find.bySemanticsLabel(RegExp('القائمة')));
    await tester.pumpAndSettle();
    expect(find.text('الشهادات'), findsOneWidget);
    await tester.tap(find.bySemanticsLabel(RegExp('القائمة')));
    await tester.pumpAndSettle();
    expect(find.text('الشهادات'), findsNothing);
  });
}
