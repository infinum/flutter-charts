part of charts_painter;

/// Behaviour of the chart
/// [isScrollable] - If chart is scrollable then width of canvas is ignored and
/// chart will take any size it needs. Chart has to be wrapped with [SingleChildScrollView]
/// or similar scrollable widget.
/// [multiValueStack] - Defaults to true, Dictates how items in stack will be shown, if set to true items will stack on
/// each other, on false they will be side by side.
/// [onItemClicked] - Returns index of clicked item.
class ChartBehaviour {
  /// Default constructor for ChartBehaviour
  /// If chart is scrollable then it will ignore width limit and it should be wrapped in [SingleChildScrollView]
  const ChartBehaviour({
    bool isScrollable = false,
    this.onItemClicked,
    this.onItemHoverEnter,
    this.onItemHoverExit,
  }) : _isScrollable = isScrollable ? 1.0 : 0.0;

  ChartBehaviour._lerp(
    this._isScrollable,
    this.onItemClicked,
    this.onItemHoverEnter,
    this.onItemHoverExit,
  );

  final double _isScrollable;

  /// Return index of item clicked. Since graph can be multi value, user
  /// will have to handle clicked index to show data they want to show
  final ValueChanged<ItemBuilderData>? onItemClicked;

  /// Return true if chart is currently scrollable
  bool get isScrollable => _isScrollable > 0.5;

  /// Return index of item clicked. Since graph can be multi value, user
  /// will have to handle clicked index to show data they want to show
  final ValueChanged<ItemBuilderData>? onItemHoverEnter;

  /// Return index of item clicked. Since graph can be multi value, user
  /// will have to handle clicked index to show data they want to show
  final ValueChanged<ItemBuilderData>? onItemHoverExit;

  /// Animate Behaviour from one state to other
  static ChartBehaviour lerp(ChartBehaviour a, ChartBehaviour b, double t) {
    // This values should never return null, this is for null-safety
    // But if it somehow does occur, then revert to default values
    final _scrollableLerp =
        lerpDouble(a._isScrollable, b._isScrollable, t) ?? 0.0;

    return ChartBehaviour._lerp(
      _scrollableLerp,
      t > 0.5 ? b.onItemClicked : a.onItemClicked,
      t > 0.5 ? b.onItemHoverEnter : a.onItemHoverEnter,
      t > 0.5 ? b.onItemHoverExit : a.onItemHoverExit,
    );
  }
}
