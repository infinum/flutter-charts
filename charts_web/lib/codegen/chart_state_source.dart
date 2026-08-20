import 'package:charts_web/codegen/data_source.dart';
import 'package:charts_web/codegen/decorations_source.dart';
import 'package:charts_web/codegen/item_options_source.dart';
import 'package:charts_web/codegen/source_writer.dart';
import 'package:charts_web/ui/playground/presenter/chart_decorations_presenter.dart';
import 'package:charts_web/ui/playground/presenter/chart_state_presenter.dart';

/// Builds the Dart source for the current playground configuration.
///
/// Reads the presenters rather than the built `ChartState`, because a
/// `ChartState` has already erased the user's intent into closures.
///
/// Values equal to a library default are omitted; everything the user changed
/// is emitted. The result therefore reproduces the chart exactly without
/// spelling out defaults.
String buildChartStateSource(
  ChartStatePresenter state,
  ChartDecorationsPresenter decorations,
) {
  final writer = SourceWriter();

  writer.open('ChartState<void>(');
  writeChartData(writer, state);
  writeItemOptions(writer, state);
  writeDecorations(writer, decorations);
  writer.close(')');

  return writer.build();
}
