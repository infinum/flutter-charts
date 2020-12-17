part of flutter_charts;

/// Chart widget will initiate [ChartPainter] with passed state
/// chart size and [GestureDetector] are added here as well
///
/// TODO(lukaknezic): Add ScrollView here as well? We already have access to [ChartState.behaviour.isScrollable]
class _ChartWidget extends StatelessWidget {
  const _ChartWidget({
    this.height = 240.0,
    this.state,
    Key key,
  }) : super(key: key);

  final double height;
  final ChartState state;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final _itemWidth = max(state?.itemOptions?.minBarWidth ?? 0.0, state?.itemOptions?.maxBarWidth ?? 0.0);

          // TODO(lukaknezic): Figure out how to calculate size between scrollable and non scrollable chart!
          final _size = state.behaviour.isScrollable
              ? Size((_itemWidth + state.itemOptions.padding.horizontal) * state.items.length, height)
              : Size(constraints.maxWidth, height);
          final _chart = CustomPaint(
            size: _size,
            painter: ChartPainter(state),
          );

          // If chart is clickable, then wrap it with [GestureDetector]
          // for detecting clicks, and sending item ID's to [onChartItemClicked]
          if (state.behaviour.onItemClicked != null) {
            final size = state?.defaultPadding?.deflateSize(_size) ?? _size;

            final _constraintSize = constraints.biggest;
            final _constraint = state?.defaultPadding?.deflateSize(_constraintSize) ?? _constraintSize;
            final _itemWidth = ((size.width.isFinite ? size.width : _constraint.width) / state.items.length);

            return GestureDetector(
              onTapDown: (tapDetails) =>
                  state.behaviour.onChartItemClicked(_getClickLocation(_itemWidth, tapDetails.localPosition)),
              onPanUpdate: (panUpdate) =>
                  state.behaviour.onChartItemClicked(_getClickLocation(_itemWidth, panUpdate.localPosition)),
              child: _chart,
            );
          }

          return _chart;
        },
      ),
    );
  }

  int _getClickLocation(double _itemWidth, Offset offset) {
    return (offset.dx / (_itemWidth ?? 0.0)).floor();
  }
}
