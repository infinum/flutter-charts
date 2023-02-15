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
    this.scrollSettings = const ScrollSettings.none(),
    this.onItemClicked,
    this.onItemHoverEnter,
    this.onItemHoverExit,
  });

  ChartBehaviour._lerp(
    this.scrollSettings,
    this.onItemClicked,
    this.onItemHoverEnter,
    this.onItemHoverExit,
  );

  final ScrollSettings scrollSettings;

  /// Return index of item clicked. Since graph can be multi value, user
  /// will have to handle clicked index to show data they want to show
  final ValueChanged<ItemBuilderData>? onItemClicked;

  /// Return true if chart is currently scrollable
  bool get isScrollable => scrollSettings._isScrollable > 0.5;

  /// Return index of item clicked. Since graph can be multi value, user
  /// will have to handle clicked index to show data they want to show
  final ValueChanged<ItemBuilderData>? onItemHoverEnter;

  /// Return index of item clicked. Since graph can be multi value, user
  /// will have to handle clicked index to show data they want to show
  final ValueChanged<ItemBuilderData>? onItemHoverExit;

  /// Animate Behaviour from one state to other
  static ChartBehaviour lerp(ChartBehaviour a, ChartBehaviour b, double t) {
    return ChartBehaviour._lerp(
      ScrollSettings.lerp(a.scrollSettings, b.scrollSettings, t),
      t > 0.5 ? b.onItemClicked : a.onItemClicked,
      t > 0.5 ? b.onItemHoverEnter : a.onItemHoverEnter,
      t > 0.5 ? b.onItemHoverExit : a.onItemHoverExit,
    );
  }
}
