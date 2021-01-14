part of flutter_charts;

/// Chart widget will initiate [ChartPainter] with passed state
/// chart size and [GestureDetector] are added here as well
///
/// TODO(lukaknezic): Add ScrollView here as well? We already have access to [ChartState.behaviour.isScrollable]
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
    return SizedBox(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final _itemWidth = max(state?.itemOptions?.minBarWidth ?? 0.0, state?.itemOptions?.maxBarWidth ?? 0.0);

          final _width = constraints.maxWidth.isFinite ? constraints.maxWidth : width;
          assert(_width != null, 'Width is null! If you are in ScrollView you need to provide the width!');

          final int _listSize =
              state.items.values.fold(0, (previousValue, element) => max(previousValue, element.length));

          final _size = Size(
              _width +
                  (((_itemWidth + state.itemOptions.padding.horizontal) * _listSize) - _width) *
                      state.behaviour._isScrollable,
              height);
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
            final _itemWidth = (size.width.isFinite ? size.width : _constraint.width) / _listSize;

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
