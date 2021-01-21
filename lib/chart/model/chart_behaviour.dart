part of flutter_charts;

enum MultiBarItemView { stacked, grouped }

/// Behaviour of the chart
/// [isScrollable] - If chart is scrollable then width of canvas is ignored and
/// chart will take any size it needs. Chart has to be wrapped with [SingleChildScrollView]
/// or similar scrollable widget.
/// [onItemClicked] - Returns index of clicked item.
class ChartBehaviour {
  const ChartBehaviour({
    bool isScrollable = false,
    this.onItemClicked,
    bool multiItemStack = true,
  })  : _isScrollable = isScrollable ? 1.0 : 0.0,
        _multiValueStacked = multiItemStack ? 1.0 : 0.0;

  const ChartBehaviour._lerp(this._isScrollable, this.onItemClicked, this._multiValueStacked);

  final double _isScrollable;
  final double _multiValueStacked;

  final ValueChanged<int> onItemClicked;

  bool get isScrollable => _isScrollable > 0.5;

  void onChartItemClicked(int index) {
    onItemClicked?.call(index);
  }

  static ChartBehaviour lerp(ChartBehaviour a, ChartBehaviour b, double t) {
    return ChartBehaviour._lerp(
      lerpDouble(a._isScrollable, b._isScrollable, t),
      t > 0.5 ? b.onItemClicked : a.onItemClicked,
      lerpDouble(a._multiValueStacked, b._multiValueStacked, t),
    );
  }
}
