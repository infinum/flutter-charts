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

  EdgeInsets get _horizontalItemPadding =>
      state.itemOptions.padding.copyWith(top: 0.0, bottom: 0.0);

  double? get _minBarWidth => state.itemOptions.minBarWidth;

  double? get _maxBarWidth => state.itemOptions.maxBarWidth;

  double _wantedItemWidthNonScrollable() {
    return max(_minBarWidth ?? 0.0, _maxBarWidth ?? 0.0);
  }

  double _wantedItemWidthForScrollable(double frameWidth) {
    final visibleItems = state.behaviour.visibleItems;
    if (visibleItems == null) {
      return _wantedItemWidthNonScrollable();
    }

    final width =
        (frameWidth - state.defaultPadding.horizontal) / visibleItems -
            _horizontalItemPadding.horizontal;

    return max(0, width);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final frameWidth =
            constraints.maxWidth.isFinite ? constraints.maxWidth : width!;
        final frameHeight =
            constraints.maxHeight.isFinite ? constraints.maxHeight : height!;

        // Used for smooth transition between scrollable and non-scrollable chart
        final sizeTween = Tween(
          begin: _wantedItemWidthNonScrollable(),
          end: _wantedItemWidthForScrollable(frameWidth),
        );

        final horizontalItemPadding = state.itemOptions.padding.horizontal;

        final wantedItemWidth =
            sizeTween.transform(state.behaviour._isScrollable);

        final listSize = state.data.listSize;
        final totalItemWidth = wantedItemWidth + horizontalItemPadding;
        final listWidth = totalItemWidth * listSize;

        final chartWidth = frameWidth +
            (listWidth - frameWidth) * state.behaviour._isScrollable;
        final finalWidth = chartWidth + state.defaultPadding.horizontal;

        final size = Size(finalWidth, frameHeight);

        return Container(
          constraints: BoxConstraints.tight(size),
          child: ChartRenderer(state),
        );
      },
    );
  }
}
