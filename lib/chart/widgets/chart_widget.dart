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

  double _horizontalPadding() {
    return state.data.items.foldIndexed<double>(0.0,
        (index, double prevValue, _) {
      return max(prevValue, state.itemOptions.padding.horizontal);
    });
  }

  double _wantedItemWidthNormal() {
    return state.data.items.foldIndexed<double>(0.0,
        (index, double prevValue, _) {
      return max(
        prevValue,
        max(
          state.itemOptions.minBarWidth ?? 0.0,
          state.itemOptions.maxBarWidth ?? 0.0,
        ),
      );
    });
  }

  double _wantedItemWidthForSetVisibleItems(double width) {
    final visibleItems = state.behaviour._visibleItems;
    if (visibleItems == null) {
      return _wantedItemWidthNormal();
    }

    final wantedItemWidth = width / visibleItems - _horizontalPadding();
    return max(_wantedItemWidthNormal(), wantedItemWidth);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final _width =
            constraints.maxWidth.isFinite ? constraints.maxWidth : width!;
        final _height =
            constraints.maxHeight.isFinite ? constraints.maxHeight : height!;

        // What size does the item want to be?
        final _wantedItemWidth = state.behaviour.isScrollable
            ? _wantedItemWidthForSetVisibleItems(_width)
            : _wantedItemWidthNormal();

        final _listSize = state.data.listSize;

        final _size = Size(
            _width +
                (((_wantedItemWidth + _horizontalPadding()) * _listSize) -
                        _width) *
                    state.behaviour._isScrollable,
            _height);

        return Container(
          constraints: BoxConstraints.tight(_size),
          child: ChartRenderer(state),
        );
      },
    );
  }
}
