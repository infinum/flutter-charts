part of flutter_charts;

class _ChartWidget extends StatelessWidget {
  _ChartWidget({
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
          final _size = state.behaviour.isScrollable
              ? Size(
                  (state.itemOptions.minBarWidth + state.itemOptions.padding.horizontal) * state.items.length, height)
              : Size(constraints.maxWidth, height);
          final _chart = CustomPaint(
            size: _size,
            painter: ChartPainter(state),
          );

          if (state.behaviour.onItemClicked != null) {
            final size = state?.defaultPadding?.deflateSize(_size) ?? _size;

            // final _itemWidth = max(state?.itemOptions?.minBarWidth ?? 0.0,
            //     min(state?.itemOptions?.maxBarWidth ?? double.infinity, (_size.width) / state.items.length));

            final _constraintSize = constraints.biggest;
            final _constraint = state?.defaultPadding?.deflateSize(_constraintSize) ?? _constraintSize;
            final _itemWidth = ((size.width.isFinite ? size.width : _constraint.width) / state.items.length);

            return GestureDetector(
              onTapDown: (tapDetails) {
                final _position = tapDetails.localPosition;
                final _index = (_position.dx / ((_itemWidth ?? 0.0))).floor();

                state.behaviour.onChartItemClicked(_index);
              },
              child: _chart,
            );
          }

          return _chart;
        },
      ),
    );
  }
}
