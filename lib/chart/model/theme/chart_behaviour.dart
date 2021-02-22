part of flutter_charts;

enum MultiBarItemView { stacked, grouped }

/// Behaviour of the chart
/// [isScrollable] - If chart is scrollable then width of canvas is ignored and
/// chart will take any size it needs. Chart has to be wrapped with [SingleChildScrollView]
/// or similar scrollable widget.
/// [multiValueStack] - Defaults to true, Dictates how items in stack will be shown, if set to true items will stack on
/// each other, on false they will be side by side.
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

  /// Return index of item clicked. Since graph can be multi value, user
  /// will have to handle clicked index to show data they want to show
  final ValueChanged<int> onItemClicked;

  bool get isScrollable => _isScrollable > 0.5;
  bool get multiValueStack => _multiValueStacked > 0.5;

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
