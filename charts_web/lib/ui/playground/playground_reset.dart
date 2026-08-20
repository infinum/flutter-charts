import 'package:charts_web/ui/playground/decorations/presenters/decorations_grid_presenter.dart';
import 'package:charts_web/ui/playground/decorations/presenters/decorations_horizontal_axis_presenter.dart';
import 'package:charts_web/ui/playground/decorations/presenters/decorations_sparkline_presenter.dart';
import 'package:charts_web/ui/playground/decorations/presenters/decorations_vertical_axis_presenter.dart';
import 'package:charts_web/ui/playground/decorations/presenters/decorations_widget_presenter.dart';
import 'package:charts_web/ui/playground/presenter/chart_decorations_presenter.dart';
import 'package:charts_web/ui/playground/presenter/chart_state_presenter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Returns the playground to its defaults by recreating the presenters, which
/// saves every presenter needing a reset method of its own.
///
/// Order matters. `ChartDecorationsPresenter` registers a listener on each
/// per-decoration family presenter, so disposing it alone leaves those
/// presenters holding a callback into a dead object and the next edit throws
/// "used after being disposed".
///
/// Applying a gallery example calls this first. Without it a second example
/// lands on top of the first: decorations accumulate, and settings the new
/// example does not mention — a painter, an axis bound, a gradient — survive
/// from the old one.
void resetPlayground(WidgetRef ref) {
  ref.invalidate(decorationGridPresenter);
  ref.invalidate(decorationSparkLinePresenter);
  ref.invalidate(decorationHorizontalAxisPresenter);
  ref.invalidate(decorationVerticalAxisPresenter);
  ref.invalidate(decorationWidgetPresenter);

  ref.invalidate(chartDecorationsPresenter);
  ref.invalidate(chartStatePresenter);
}
