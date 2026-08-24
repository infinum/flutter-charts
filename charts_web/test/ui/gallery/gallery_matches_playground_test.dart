import 'package:charts_painter/chart.dart';
import 'package:charts_web/theme/app_theme.dart';
import 'package:charts_web/ui/gallery/gallery_entries.dart';
import 'package:charts_web/ui/playground/playground_reset.dart';
import 'package:charts_web/ui/playground/presenter/chart_label_color_provider.dart';
import 'package:charts_web/ui/playground/presenter/chart_state_presenter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

/// "Open in playground" promises the chart you clicked. This walks every entry,
/// renders its preview, applies it to a fresh playground, and compares the two
/// ChartStates field by field.
///
/// It was written after the previews and the playground had drifted apart in
/// 32 places: wrong data strategy on all 13, padding and colours dropped, and
/// the sparkline losing its gradient.
///
/// The second case reuses one container across entries. The first version of
/// this test made a fresh one each time, and so never noticed that opening a
/// second example layered it on top of the first.
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

String _describeItem(ItemOptions options) {
  final buffer = StringBuffer('${options.runtimeType} '
      'padding=${options.padding} multiValue=${options.multiValuePadding} '
      'max=${options.maxBarWidth} min=${options.minBarWidth} '
      'start=${options.startPosition}');

  // Two samples, because an item builder may answer differently per item: the
  // goal-tracking entry recolours everything over its target, and one probe
  // below the target would call that a match whatever the playground did.
  for (final value in [5.0, 15.0]) {
    final built =
        options.itemBuilder(ItemBuilderData(ChartItem<void>(value), 0, 0));
    buffer.write(' @$value');

    if (built is BarItem) {
      buffer.write(' BarItem(color=${built.color} '
          'gradient=${built.gradient} border=${built.border} '
          'radius=${built.radius})');
    } else if (built is BubbleItem) {
      buffer.write(' BubbleItem(color=${built.color} '
          'gradient=${built.gradient} border=${built.border})');
    } else {
      buffer.write(' widget');
    }
  }

  return buffer.toString();
}

String _describeDecoration(DecorationPainter decoration) {
  if (decoration is SparkLineDecoration) {
    return 'SparkLine(fill=${decoration.fill} '
        'smooth=${decoration.smoothPoints} width=${decoration.lineWidth} '
        'color=${decoration.lineColor} gradient=${decoration.gradient} '
        'listIndex=${decoration.listIndex} dash=${decoration.dashArray})';
  }
  if (decoration is GridDecoration) return 'Grid';
  if (decoration is HorizontalAxisDecoration) {
    return 'HorizontalAxis(values=${decoration.showValues} '
        'step=${decoration.axisStep} lines=${decoration.showLines} '
        'color=${decoration.lineColor})';
  }
  if (decoration is VerticalAxisDecoration) {
    return 'VerticalAxis(values=${decoration.showValues} '
        'step=${decoration.axisStep} lines=${decoration.showLines} '
        'color=${decoration.lineColor})';
  }
  if (decoration is WidgetDecoration) {
    return 'WidgetDecoration(margin=${decoration.margin})';
  }

  return decoration.runtimeType.toString();
}

List<String> _describe(ChartState<void> state) => [
      'data=${state.data.items.map((l) => l.map((i) => i.max).toList()).toList()}',
      'strategy=${state.data.dataStrategy.runtimeType}',
      'min=${state.data.minValue} max=${state.data.maxValue}',
      'scrollable=${state.behaviour.isScrollable} '
          'visible=${state.behaviour.scrollSettings.visibleItems}',
      'items=${_describeItem(state.itemOptions)}',
      'background=${state.backgroundDecorations.map(_describeDecoration).toList()}',
      'foreground=${state.foregroundDecorations.map(_describeDecoration).toList()}',
    ];

void main() {
  const brightness = Brightness.light;
  final scheme = appTheme(brightness).colorScheme;

  testWidgets('opening an entry reproduces its preview exactly',
      (tester) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    for (final entry in galleryEntries) {
      await tester.pumpWidget(MaterialApp(
        theme: appTheme(brightness),
        home: Scaffold(
          body: SizedBox(
            width: 500,
            height: 300,
            child: Builder(builder: entry.buildChart),
          ),
        ),
      ));
      await tester.pumpAndSettle();

      final preview =
          tester.widget<Chart<void>>(find.byType(Chart<void>)).state;

      final container = ProviderContainer();
      addTearDown(container.dispose);
      _syncTheme(container, scheme);

      entry.applyToPlayground(_RefStub(container));
      final applied = container.read(chartStatePresenter).state;

      expect(_describe(applied), _describe(preview), reason: entry.id);
    }
  });

  testWidgets('opening one entry after another replaces it, not layers on it',
      (tester) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    // Collect every preview first; rendering needs the fake-async pump.
    final previews = <String, List<String>>{};
    for (final entry in galleryEntries) {
      await tester.pumpWidget(MaterialApp(
        theme: appTheme(brightness),
        home: Scaffold(
          body: SizedBox(
            width: 500,
            height: 300,
            child: Builder(builder: entry.buildChart),
          ),
        ),
      ));
      await tester.pumpAndSettle();

      previews[entry.id] =
          _describe(tester.widget<Chart<void>>(find.byType(Chart<void>)).state);
    }
    await tester.pumpWidget(const SizedBox.shrink());

    // One container for the whole walk, like the running app. Real async here:
    // resetPlayground invalidates providers, and riverpod schedules the
    // refresh on a timer that the fake-async zone will not retire.
    await tester.runAsync(() async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      _syncTheme(container, scheme);
      final ref = _RefStub(container);

      // Start on a heavy entry so there is plenty left to leak: three series,
      // a stacked strategy and a decoration.
      galleryEntries
          .firstWhere((entry) => entry.id == 'stacked-bar')
          .applyToPlayground(ref);

      for (final entry in galleryEntries) {
        // What GalleryDetail does when the button is pressed.
        resetPlayground(ref);
        entry.applyToPlayground(ref);

        expect(
          _describe(container.read(chartStatePresenter).state),
          previews[entry.id],
          reason: '${entry.id} opened after another entry',
        );
      }
    });
  });
}

void _syncTheme(ProviderContainer container, ColorScheme scheme) {
  // ChartThemeSync does this in the running app; the decorations read it for
  // their default line colour.
  container.read(chartGridColorProvider.notifier).state = scheme.outlineVariant;
  container.read(chartLabelColorProvider.notifier).state = scheme.onSurface;
}
