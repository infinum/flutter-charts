part of charts_painter;

/// Behaviour of the chart
/// [isScrollable] - If chart is scrollable then width of canvas is ignored and
/// chart will take any size it needs. Chart has to be wrapped with [SingleChildScrollView]
/// or similar scrollable widget.
/// [onItemClicked] - Returns index of clicked item.
class ChartBehaviour {
  /// Default constructor for ChartBehaviour
  /// If chart is scrollable then it will ignore width limit and it should be wrapped in [SingleChildScrollView]
  const ChartBehaviour({
    bool isScrollable = false,
    this.visibleItems,
    this.onItemClicked,
  })  : assert(visibleItems == null || isScrollable,
            'visibleItems are only used when chart is scrollable'),
        assert(visibleItems == null || visibleItems > 0,
            'visibleItems must be greater than 0'),
        _isScrollable = isScrollable ? 1.0 : 0.0;

  ChartBehaviour._lerp(
      this._isScrollable, this.visibleItems, this.onItemClicked);

  final double _isScrollable;

  final double? visibleItems;

  /// Return index of item clicked. Since graph can be multi value, user
  /// will have to handle clicked index to show data they want to show
  final ValueChanged<ItemBuilderData>? onItemClicked;

  /// Return true if chart is currently scrollable
  bool get isScrollable => _isScrollable > 0.5;

  /// Animate Behaviour from one state to other
  static ChartBehaviour lerp(ChartBehaviour a, ChartBehaviour b, double t) {
    // This values should never return null, this is for null-safety
    // But if it somehow does occur, then revert to default values
    final scrollableLerp =
        lerpDouble(a._isScrollable, b._isScrollable, t) ?? 0.0;
    final visibleLerp = lerpDouble(a.visibleItems, b.visibleItems, t);

    return ChartBehaviour._lerp(
      scrollableLerp,
      visibleLerp,
      t > 0.5 ? b.onItemClicked : a.onItemClicked,
    );
  }
}
