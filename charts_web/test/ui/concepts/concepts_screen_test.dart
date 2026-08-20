import 'package:charts_painter/chart.dart';
import 'package:charts_web/theme/app_theme.dart';
import 'package:charts_web/ui/concepts/concepts_screen.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets('renders all four concepts with a live chart each',
      (tester) async {
    tester.view.physicalSize = const Size(1200, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(MaterialApp(
      theme: appTheme(Brightness.light),
      home: const Scaffold(body: ConceptsScreen()),
    ));
    await tester.pumpAndSettle();

    expect(find.text('ChartState'), findsOneWidget);
    expect(find.text('ChartData and DataStrategy'), findsOneWidget);
    expect(find.text('ItemOptions'), findsOneWidget);
    expect(find.text('Decorations'), findsOneWidget);
    expect(find.byType(Chart<void>), findsNWidgets(4));
    expect(tester.takeException(), isNull);
  });
}
