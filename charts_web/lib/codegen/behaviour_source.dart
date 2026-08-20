import 'package:charts_web/codegen/dart_literal.dart';
import 'package:charts_web/codegen/source_writer.dart';
import 'package:charts_web/ui/playground/presenter/chart_state_presenter.dart';

/// Emits the `behaviour:` argument, which the playground only touches for
/// scroll settings.
void writeBehaviour(SourceWriter writer, ChartStatePresenter presenter) {
  final visibleItems = presenter.visibleItems;
  if (visibleItems == null) return;

  writer.open('behaviour: ChartBehaviour(');
  writer.line(
      'scrollSettings: ScrollSettings(visibleItems: ${doubleLiteral(visibleItems)}),');
  writer.close('),');
  writer.line(
      '// A scrollable chart sizes itself; wrap it in a horizontal scroll view.');
}
