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
    final _chart = CustomPaint(
      size: state.behaviour.isScrollable
          ? Size((state.itemOptions.minBarWidth + state.itemOptions.padding.horizontal) * state.items.length, height)
          : Size.fromHeight(height),
      painter: ChartPainter(state),
    );

    if (state.behaviour.onItemClicked != null) {
      return GestureDetector(
        onTapDown: (tapDetails) {
          final _position = tapDetails.localPosition;
          final _item = state.items[_position.dx ~/ (state.itemOptions.minBarWidth + state.itemOptions.padding.horizontal)];
          state.behaviour.onItemClicked(_item);
        },
        child: _chart,
      );
    }

    return _chart;
  }
}
