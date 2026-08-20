import 'package:charts_web/theme/app_theme.dart';
import 'package:charts_web/ui/shell/app_shell.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

Future<void> _pumpShell(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(ProviderScope(
    child: MaterialApp(
      theme: appTheme(Brightness.light),
      home: const AppShell(),
    ),
  ));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('wide layout shows a navigation rail with three destinations',
      (tester) async {
    await _pumpShell(tester, const Size(1600, 1000));

    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
    expect(find.text('Playground'), findsOneWidget);
    expect(find.text('Gallery'), findsOneWidget);
    expect(find.text('Concepts'), findsOneWidget);
  });

  testWidgets('compact layout shows a bottom navigation bar', (tester) async {
    await _pumpShell(tester, const Size(500, 900));

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byType(NavigationRail), findsNothing);
  });

  testWidgets('switching destinations keeps every panel alive', (tester) async {
    await _pumpShell(tester, const Size(1600, 1000));

    expect(find.byType(IndexedStack), findsOneWidget);
    final stack = tester.widget<IndexedStack>(find.byType(IndexedStack));
    expect(stack.children.length, 3);
    expect(stack.index, 0);

    await tester.tap(find.text('Gallery'));
    await tester.pumpAndSettle();

    expect(tester.widget<IndexedStack>(find.byType(IndexedStack)).index, 1);
  });
}
