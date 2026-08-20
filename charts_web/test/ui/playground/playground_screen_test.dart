import 'package:charts_painter/chart.dart';
import 'package:charts_web/theme/app_theme.dart';
import 'package:charts_web/ui/playground/chart_stage.dart';
import 'package:charts_web/ui/playground/playground_screen.dart';
import 'package:charts_web/ui/playground/resizable_pane.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

Future<void> _pump(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(ProviderScope(
    child: MaterialApp(
      theme: appTheme(Brightness.light),
      home: const Scaffold(body: PlaygroundScreen()),
    ),
  ));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('expanded shows options, chart and code panel side by side',
      (tester) async {
    await _pump(tester, const Size(1800, 1200));

    expect(find.byType(ChartStage), findsOneWidget);
    expect(find.byKey(PlaygroundScreen.optionsPaneKey), findsOneWidget);
    expect(find.byKey(PlaygroundScreen.codePaneKey), findsOneWidget);
  });

  testWidgets('medium hides the inline code pane', (tester) async {
    await _pump(tester, const Size(1000, 900));

    expect(find.byKey(PlaygroundScreen.optionsPaneKey), findsOneWidget);
    expect(find.byKey(PlaygroundScreen.codePaneKey), findsNothing);
  });

  testWidgets('compact puts the chart above the options', (tester) async {
    await _pump(tester, const Size(420, 900));

    final chart = tester.getTopLeft(find.byType(AnimatedChart<void>));
    final options =
        tester.getTopLeft(find.byKey(PlaygroundScreen.optionsPaneKey));

    expect(chart.dy, lessThan(options.dy));
  });

  testWidgets('the options pane opens fully extended on a wide window',
      (tester) async {
    await _pump(tester, const Size(1900, 1200));

    final width =
        tester.getSize(find.byKey(PlaygroundScreen.optionsPaneKey)).width;

    expect(width, kMaxOptionsWidth);
  });

  testWidgets('a narrow window shrinks the pane rather than the chart',
      (tester) async {
    // 900px cannot fit a 720px pane plus a usable chart.
    await _pump(tester, const Size(900, 900));

    final width =
        tester.getSize(find.byKey(PlaygroundScreen.optionsPaneKey)).width;

    expect(width, lessThan(kMaxOptionsWidth));
    expect(width, greaterThanOrEqualTo(kMinOptionsWidth));
    expect(tester.getSize(find.byType(ChartStage)).width,
        greaterThanOrEqualTo(kMinChartWidth - 1));
  });
}
