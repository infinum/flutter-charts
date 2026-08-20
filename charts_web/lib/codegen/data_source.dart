import 'package:charts_painter/chart.dart';
import 'package:charts_web/codegen/dart_literal.dart';
import 'package:charts_web/codegen/source_writer.dart';
import 'package:charts_web/ui/playground/presenter/chart_state_presenter.dart';

/// Emits the `data:` argument of `ChartState`.
void writeChartData(SourceWriter writer, ChartStatePresenter presenter) {
  writer.open('data: ChartData(');
  writer.open('[');

  for (final list in presenter.data) {
    final values = list.map((item) => doubleLiteral(item.max ?? 0)).join(', ');
    writer.line('[$values].map((e) => ChartItem<void>(e)).toList(),');
  }

  writer.close('],');

  final strategy = presenter.state.data.dataStrategy;
  if (strategy is StackDataStrategy) {
    writer.line('dataStrategy: const StackDataStrategy(),');
  } else if (!presenter.stackMultipleValues) {
    // The library default is DefaultDataStrategy(stackMultipleValues: true),
    // so it only needs emitting when the user turned stacking off.
    writer.line(
        'dataStrategy: const DefaultDataStrategy(stackMultipleValues: false),');
  }

  final axisMin = presenter.axisMin;
  if (axisMin != null) writer.line('axisMin: ${doubleLiteral(axisMin)},');
  final axisMax = presenter.axisMax;
  if (axisMax != null) writer.line('axisMax: ${doubleLiteral(axisMax)},');

  // The presenter always sets this, so it is always part of the output.
  writer.line(
      'valueAxisMaxOver: ${doubleLiteral(presenter.valueAxisMaxOver)},');
  writer.close('),');
}
