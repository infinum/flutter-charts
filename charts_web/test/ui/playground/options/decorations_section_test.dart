import 'package:charts_painter/chart.dart';
import 'package:charts_web/theme/app_theme.dart';
import 'package:charts_web/ui/playground/options/decorations_section.dart';
import 'package:charts_web/ui/playground/presenter/chart_decorations_presenter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets('adding a sparkline shows its editor and can move layers',
      (tester) async {
    tester.view.physicalSize = const Size(1200, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final container = ProviderContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        theme: appTheme(Brightness.light),
        home: const Scaffold(
          body: SingleChildScrollView(child: DecorationsSection()),
        ),
      ),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.text('SparkLine'));
    await tester.pumpAndSettle();

    final presenter = container.read(chartDecorationsPresenter);
    expect(
      presenter.foregroundDecorations.values.whereType<SparkLineDecoration>(),
      hasLength(1),
    );
    expect(find.text('SparkLine decoration'), findsOneWidget);

    await tester.tap(find.text('Background'));
    await tester.pumpAndSettle();

    expect(presenter.backgroundDecorations, hasLength(1));
    expect(presenter.foregroundDecorations, isEmpty);
  });
}
