import 'package:charts_web/theme/app_theme.dart';
import 'package:charts_web/ui/playground/code_panel.dart';
import 'package:charts_web/ui/playground/presenter/chart_state_presenter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets('shows generated source and follows presenter changes',
      (tester) async {
    tester.view.physicalSize = const Size(600, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final container = ProviderContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        theme: appTheme(Brightness.light),
        home: const Scaffold(body: CodePanel()),
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.textContaining('BarItemOptions'), findsOneWidget);

    container
        .read(chartStatePresenter)
        .updateItemPainter(SelectedPainter.bubble);
    await tester.pumpAndSettle();

    expect(find.textContaining('BubbleItemOptions'), findsOneWidget);
  });
}
