part of flutter_charts;

/// Chart widget will initiate [_ChartPainter] with passed state
/// chart size and [GestureDetector] are added here as well
///
// TODO(lukaknezic): Add ScrollView here as well? We already have access to [ChartState.behaviour.isScrollable]
class _ChartWidget extends StatelessWidget {
  const _ChartWidget({
    this.height = 240.0,
    this.width,
    this.state,
    Key key,
  }) : super(key: key);

  final double height;
  final double width;
  final ChartState state;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // What size does the item want to be?
        final _wantedItemWidth = max(state?.itemOptions?.minBarWidth ?? 0.0, state?.itemOptions?.maxBarWidth ?? 0.0);

        final _width = constraints.maxWidth.isFinite ? constraints.maxWidth : width;
        final _height = constraints.maxHeight.isFinite ? constraints.maxHeight : height;
        assert(_width != null, 'Parent has infinite width! Charts need finite width!');

        final int _listSize = state.data.listSize;

        final _size = Size(
            _width +
                (((_wantedItemWidth + state.itemOptions.padding.horizontal) * _listSize) - _width) *
                    state.behaviour._isScrollable,
            _height);
        final _chart = CustomPaint(
          size: _size,
          isComplex: true,
          painter: _ChartPainter(state),
        );

        // If chart is clickable, then wrap it with [GestureDetector]
        // for detecting clicks, and sending item index to [onChartItemClicked]
        if (state.behaviour.onItemClicked != null) {
          final size = state?.defaultPadding?.deflateSize(_size) ?? _size;

          final _constraintSize = constraints.biggest;
          final _constraint = state?.defaultPadding?.deflateSize(_constraintSize) ?? _constraintSize;
          final _itemWidth = (size.width.isFinite ? size.width : _constraint.width) / _listSize;

          return GestureDetector(
            onTapDown: (tapDetails) =>
                state.behaviour._onChartItemClicked(_getClickLocation(_itemWidth, tapDetails.localPosition)),
            onPanUpdate: (panUpdate) =>
                state.behaviour._onChartItemClicked(_getClickLocation(_itemWidth, panUpdate.localPosition)),
            child: _chart,
          );
        }

        return _chart;
      },
    );
  }

  int _getClickLocation(double _itemWidth, Offset offset) {
    return (offset.dx / (_itemWidth ?? 0.0)).floor();
  }
}
