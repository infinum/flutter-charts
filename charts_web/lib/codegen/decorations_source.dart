import 'package:charts_painter/chart.dart';
import 'package:charts_web/codegen/source_writer.dart';
import 'package:charts_web/ui/playground/decorations/presenters/decorations_grid_presenter.dart';
import 'package:charts_web/ui/playground/decorations/presenters/decorations_horizontal_axis_presenter.dart';
import 'package:charts_web/ui/playground/decorations/presenters/decorations_sparkline_presenter.dart';
import 'package:charts_web/ui/playground/decorations/presenters/decorations_vertical_axis_presenter.dart';
import 'package:charts_web/ui/playground/decorations/presenters/decorations_widget_presenter.dart';
import 'package:charts_web/ui/playground/presenter/chart_decorations_presenter.dart';

/// Emits the `backgroundDecorations:` and `foregroundDecorations:` arguments.
/// Background comes first, matching paint order.
void writeDecorations(
    SourceWriter writer, ChartDecorationsPresenter presenter) {
  _writeLayer(writer, presenter, 'backgroundDecorations',
      presenter.backgroundDecorations);
  _writeLayer(writer, presenter, 'foregroundDecorations',
      presenter.foregroundDecorations);
}

void _writeLayer(
  SourceWriter writer,
  ChartDecorationsPresenter presenter,
  String parameterName,
  Map<int, DecorationPainter> decorations,
) {
  if (decorations.isEmpty) return;

  writer.open('$parameterName: [');

  decorations.forEach((index, decoration) {
    _builderFor(presenter, index, decoration)?.writeDecorationSource(writer);
  });

  writer.close('],');
}

/// Maps a live decoration back to the presenter that owns its settings, the
/// same dispatch `ChartDecorationsPresenter.addDecoration` uses.
DecorationBuilder? _builderFor(
  ChartDecorationsPresenter presenter,
  int index,
  DecorationPainter decoration,
) =>
    switch (decoration) {
      GridDecoration() => presenter.ref.read(decorationGridPresenter(index)),
      SparkLineDecoration() =>
        presenter.ref.read(decorationSparkLinePresenter(index)),
      VerticalAxisDecoration() =>
        presenter.ref.read(decorationVerticalAxisPresenter(index)),
      HorizontalAxisDecoration() =>
        presenter.ref.read(decorationHorizontalAxisPresenter(index)),
      WidgetDecoration() =>
        presenter.ref.read(decorationWidgetPresenter(index)),
      _ => null,
    };
