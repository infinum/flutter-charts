import 'package:charts_painter/chart.dart';
import 'package:charts_web/ui/gallery/gallery_entries.dart';
import 'package:charts_web/ui/playground/presenter/chart_decorations_presenter.dart';
import 'package:charts_web/ui/playground/presenter/chart_state_presenter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// The number and kind of decorations each preview draws. Opening an entry in
/// the playground should land you on the same chart, not an approximation of
/// it — previously the previews used GridDecoration, which the playground
/// could not represent at all, so those decorations silently went missing.
const Map<String, List<Type>> expectedDecorations = {
  'simple-bar': [GridDecoration],
  'stacked-bar': [],
  'grouped-bar': [],
  'sparkline': [SparkLineDecoration],
  'bubble': [GridDecoration],
  'negative-values': [HorizontalAxisDecoration],
  'gradient-bars': [],
  'rounded-bars': [],
  'axis-labels': [HorizontalAxisDecoration, VerticalAxisDecoration],
  'target-line': [WidgetDecoration],
  'value-labels': [],
  'scrollable': [],
  'widget-items': [],
};

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

void main() {
  test('applying an entry reproduces the decorations its preview draws', () {
    for (final entry in galleryEntries) {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      entry.applyToPlayground(_RefStub(container));

      final state = container.read(chartStatePresenter).state;
      final applied = [
        ...state.backgroundDecorations,
        ...state.foregroundDecorations,
      ].map((decoration) => decoration.runtimeType).toList();

      expect(
        applied,
        unorderedEquals(expectedDecorations[entry.id]!),
        reason: entry.id,
      );
    }
  });

  test('the grid decoration is available to the playground', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    container.read(chartDecorationsPresenter).addDecoration(GridDecoration());

    expect(
      container.read(chartStatePresenter).state.foregroundDecorations,
      hasLength(1),
    );
  });
}
