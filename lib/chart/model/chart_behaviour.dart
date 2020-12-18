part of flutter_charts;

class ChartBehaviour {
  const ChartBehaviour({
    bool isScrollable = false,
    this.onItemClicked,
  }) : _isScrollable = isScrollable ? 1.0 : 0.0;

  const ChartBehaviour._lerp(this._isScrollable, this.onItemClicked);

  final double _isScrollable;
  final ValueChanged<int> onItemClicked;

  bool get isScrollable => _isScrollable > 0.5;

  void onChartItemClicked(int index) {
    onItemClicked?.call(index);
  }

  static ChartBehaviour lerp(ChartBehaviour a, ChartBehaviour b, double t) {
    return ChartBehaviour._lerp(
      lerpDouble(a._isScrollable, b._isScrollable, t),
      t > 0.5 ? b.onItemClicked : a.onItemClicked,
    );
  }
}
