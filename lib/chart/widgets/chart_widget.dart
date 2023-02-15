part of charts_painter;

/// Chart widget will initiate [_ChartPainter] with passed state
/// chart size and [GestureDetector] are added here as well
///
// TODO(lukaknezic): Add ScrollView here as well? We already have access to [ChartState.behaviour.isScrollable]
class _ChartWidget<T> extends StatelessWidget {
  const _ChartWidget({
    this.height = 240.0,
    this.width,
    required this.state,
    Key? key,
  }) : super(key: key);

  final double? height;
  final double? width;
  final ChartState<T?> state;

  double get _horizontalItemPadding => state.itemOptions.padding.horizontal;

  double _clampItemWidth(double width) {
    final minBarWidth = state.itemOptions.minBarWidth;
    final maxBarWidth = state.itemOptions.maxBarWidth;

    if (minBarWidth != null) {
      return max(minBarWidth, width);
    }

    if (maxBarWidth != null) {
      return min(maxBarWidth, width);
    }

    return width;
  }

  double _calcItemWidthNonScrollable() {
    return max(
      state.itemOptions.minBarWidth ?? 0.0,
      state.itemOptions.maxBarWidth ?? 0.0,
    );
  }

  double _calcItemWidthForScrollable(double frameWidth) {
    final visibleItems = state.behaviour.scrollSettings.visibleItems;
    if (visibleItems == null) {
      return _calcItemWidthNonScrollable();
    }

    final availableWidth = frameWidth - state.defaultPadding.horizontal;
    final width = availableWidth / visibleItems - _horizontalItemPadding;

    return _clampItemWidth(max(0, width));
  }

  double _calcItemWidth(double frameWidth) {
    // Used for smooth transition between scrollable and non-scrollable chart
    final sizeTween = Tween(
      begin: _calcItemWidthNonScrollable(),
      end: _calcItemWidthForScrollable(frameWidth),
    );

    return sizeTween.transform(state.behaviour.scrollSettings._isScrollable);
  }

  Size _calcChartSize(double itemWidth, double frameWidth, double frameHeight) {
    final listSize = state.data.listSize;
    final totalItemWidth = itemWidth + _horizontalItemPadding;
    final listWidth = totalItemWidth * listSize;

    final chartWidth = frameWidth +
        (listWidth - frameWidth) * state.behaviour.scrollSettings._isScrollable;
    final finalWidth = chartWidth + state.defaultPadding.horizontal;

    return Size(finalWidth, frameHeight);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final frameWidth =
            constraints.maxWidth.isFinite ? constraints.maxWidth : width!;
        final frameHeight =
            constraints.maxHeight.isFinite ? constraints.maxHeight : height!;

        final itemWidth = _calcItemWidth(frameWidth);
        final size = _calcChartSize(itemWidth, frameWidth, frameHeight);

        return Container(
          constraints: BoxConstraints.tight(size),
          child: ChartRenderer(state),
        );
      },
    );
  }
}
