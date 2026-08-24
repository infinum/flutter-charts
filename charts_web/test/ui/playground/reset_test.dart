import 'package:charts_painter/chart.dart';
import 'package:charts_web/theme/app_theme.dart';
import 'package:charts_web/ui/gallery/gallery_entries.dart';
import 'package:charts_web/ui/playground/applied_example.dart';
import 'package:charts_web/ui/playground/chart_stage.dart';
import 'package:charts_web/ui/playground/playground_reset.dart';
import 'package:charts_web/ui/playground/presenter/chart_state_presenter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

Future<void> _pump(WidgetTester tester, ProviderContainer container) async {
  tester.view.physicalSize = const Size(1200, 900);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(UncontrolledProviderScope(
    container: container,
    child: MaterialApp(
      theme: appTheme(Brightness.light),
      home: const Scaffold(body: ChartStage()),
    ),
  ));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('with no example loaded, reset restores the defaults',
      (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await _pump(tester, container);
    container
        .read(chartStatePresenter)
        .updateItemPainter(SelectedPainter.bubble);
    await tester.pumpAndSettle();

    expect(find.text('Reset'), findsOneWidget);
    await tester.tap(find.text('Reset'));
    await tester.pumpAndSettle();

    expect(container.read(chartStatePresenter).selectedPainter,
        SelectedPainter.bar);
  });

  testWidgets('after opening a gallery entry, reset returns to that entry',
      (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final entry =
        galleryEntries.firstWhere((entry) => entry.id == 'simple-bar');

    await _pump(tester, container);

    // Stand in for arriving from the gallery.
    entry.applyToPlayground(_stubRef(container));
    container.read(appliedGalleryEntryProvider.notifier).state = entry.id;
    await tester.pumpAndSettle();

    // Wander off the example.
    container.read(chartStatePresenter)
      ..updateItemPainter(SelectedPainter.bubble)
      ..updateData([
        [ChartItem<void>(1)]
      ]);
    await tester.pumpAndSettle();

    expect(find.text('Reset to example'), findsOneWidget);
    await tester.tap(find.text('Reset to example'));
    await tester.pumpAndSettle();

    final presenter = container.read(chartStatePresenter);
    expect(presenter.selectedPainter, SelectedPainter.bar);
    expect(presenter.data.first, hasLength(8));
    // The example's grid comes back too, not just its data.
    expect(
      presenter.state.backgroundDecorations.whereType<GridDecoration>(),
      hasLength(1),
    );
  });

  testWidgets('a second reset leaves the example for the defaults',
      (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final entry =
        galleryEntries.firstWhere((entry) => entry.id == 'simple-bar');

    await _pump(tester, container);
    entry.applyToPlayground(_stubRef(container));
    container.read(appliedGalleryEntryProvider.notifier).state = entry.id;
    await tester.pumpAndSettle();

    await tester.tap(find.text('Reset to example'));
    await tester.pumpAndSettle();

    // The button now offers the other half of the pair.
    expect(find.text('Reset to default'), findsOneWidget);
    await tester.tap(find.text('Reset to default'));
    await tester.pumpAndSettle();

    final presenter = container.read(chartStatePresenter);
    expect(presenter.data.first, hasLength(8));
    // The example's decorations are gone, not just its data reset.
    expect(presenter.state.backgroundDecorations, isEmpty);
    expect(container.read(appliedGalleryEntryProvider), isNull);
    // Back to a one-step reset, since there is no example to return to.
    expect(find.text('Reset'), findsOneWidget);
  });

  testWidgets('opening another example starts the reset pair over',
      (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final entry =
        galleryEntries.firstWhere((entry) => entry.id == 'simple-bar');

    await _pump(tester, container);
    entry.applyToPlayground(_stubRef(container));
    container.read(appliedGalleryEntryProvider.notifier).state = entry.id;
    await tester.pumpAndSettle();

    await tester.tap(find.text('Reset to example'));
    await tester.pumpAndSettle();
    expect(find.text('Reset to default'), findsOneWidget);

    // Stand in for arriving from the gallery again.
    resetPlayground(_stubRef(container));
    entry.applyToPlayground(_stubRef(container));
    container.read(appliedGalleryEntryProvider.notifier).state = entry.id;
    await tester.pumpAndSettle();

    expect(find.text('Reset to example'), findsOneWidget);
  });
}

WidgetRef _stubRef(ProviderContainer container) => _RefStub(container);

class _RefStub implements WidgetRef {
  _RefStub(this.container);

  final ProviderContainer container;

  @override
  T read<T>(ProviderListenable<T> provider) => container.read(provider);

  @override
  void invalidate(ProviderOrFamily provider, {bool asReload = false}) =>
      container.invalidate(provider);

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnsupportedError('only read()/invalidate() are used here');
}
