part of charts_painter;

typedef ChartDataRendererFactory<T> = ChartDataRenderer<T> Function(
    ChartState<T?> state);

/// Renderer for whole chart data
///
/// It should go through all data in chart state and assign [ChartItemRenderer] to each item in data.
abstract class ChartDataRenderer<T> extends MultiChildRenderObjectWidget {
  ChartDataRenderer({Key? key, List<Widget> children = const []})
      : super(key: key, children: children);
}

abstract class ChartItemRenderer<T> extends RenderBox {
  ChartItemRenderer(this._chartData) : super();

  ChartData<T?> _chartData;
  ChartData<T?> get chartData => _chartData;
  set chartData(ChartData<T?> data) {
    if (_chartData != data) {
      _chartData = data;
      markNeedsPaint();
      markNeedsSemanticsUpdate();
    }
  }
}
