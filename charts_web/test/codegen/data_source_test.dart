import 'package:charts_painter/chart.dart';
import 'package:charts_web/codegen/data_source.dart';
import 'package:charts_web/codegen/source_writer.dart';
import 'package:charts_web/ui/playground/presenter/chart_state_presenter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

String render(void Function(ChartStatePresenter) configure) {
  final container = ProviderContainer();
  addTearDown(container.dispose);

  final presenter = container.read(chartStatePresenter);
  configure(presenter);

  final writer = SourceWriter();
  writeChartData(writer, presenter);

  return writer.build();
}

void main() {
  test('single list emits one ChartItem list', () {
    final source = render((presenter) => presenter.updateData([
          [4, 6, 3].map((e) => ChartItem<void>(e.toDouble())).toList(),
        ]));

    // The presenter starts on StackDataStrategy, which is not the library
    // default (DefaultDataStrategy(stackMultipleValues: true)), so it is
    // emitted even for a single series.
    expect(source, '''
data: ChartData(
  [
    [4.0, 6.0, 3.0].map((e) => ChartItem<void>(e)).toList(),
  ],
  dataStrategy: const StackDataStrategy(),
  valueAxisMaxOver: 2.0,
),''');
  });

  test('stack strategy is emitted when selected', () {
    final source = render((presenter) {
      presenter.addDataList([ChartItem<void>(1)]);
      presenter.updateDataStrategy(const StackDataStrategy());
    });

    expect(source, contains('dataStrategy: const StackDataStrategy(),'));
  });

  test('grouped strategy emits stackMultipleValues when turned off', () {
    final source = render((presenter) {
      presenter.addDataList([ChartItem<void>(1)]);
      presenter.updateDataStrategy(
          const DefaultDataStrategy(stackMultipleValues: true));
      presenter.updateStackMultipleValues(false);
    });

    expect(
      source,
      contains(
          'dataStrategy: const DefaultDataStrategy(stackMultipleValues: false),'),
    );
  });

  test('never emits the deprecated BarValue constructor', () {
    expect(render((_) {}), isNot(contains('BarValue')));
  });
}
