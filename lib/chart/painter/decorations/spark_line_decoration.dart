part of flutter_charts;

class SparkLineDecoration extends DecorationPainter {
  SparkLineDecoration({
    this.fill = false,
    this.lineWidth = 1.0,
    this.lineColor = Colors.blue,
    this.startPosition = 0.5,
});

  final bool fill;
  final double lineWidth;
  final Color lineColor;

  final double startPosition;

  List<ChartItem> _items;

  @override
  void initDecoration(ChartState state) {
    _items = state.items;
  }

  @override
  void draw(Canvas canvas, Size size, ChartState state) {
    final _paint = Paint()
      ..color = lineColor
      ..style = fill ? PaintingStyle.fill : PaintingStyle.stroke
      ..strokeWidth = lineWidth;

    final _size = state?.defaultPadding?.deflateSize(size) ?? size;
    final _maxValue = state.maxValue - state.minValue;
    final scale = _size.height / _maxValue;
    final _padding = state?.itemOptions?.padding ?? EdgeInsets.zero;
    final _itemWidth = _size.width / state.items.length;

    canvas.save();
    canvas.translate(_padding.left + state.defaultMargin.left, _size.height + state.defaultMargin.top);
    final Path _path = Path();

    for (int _index = 0; _index < state.items.length; _index++) {
      final _item = _items[_index];

      if (fill && _index == 0) {
        _path.lineTo(_size.width * (_index / _items.length) + _itemWidth * startPosition, 0.0);
      }

      if (!fill && _index == 0) {
        _path.moveTo(_size.width * (_index / _items.length) + _itemWidth * startPosition, -_item.max * scale);
      } else {
        _path.lineTo(_size.width * (_index / _items.length) + _itemWidth * startPosition, -_item.max * scale);
      }

      if (fill && _index == _items.length - 1) {
        _path.lineTo(_size.width * (_index / _items.length) + _itemWidth * startPosition, 0.0);
      }
    }

    canvas.drawPath(_path, _paint);

    canvas.restore();
  }

  @override
  DecorationPainter animateTo(DecorationPainter endValue, double t) {
    if (endValue is SparkLineDecoration) {
      return SparkLineDecoration(
        fill: t > 0.5 ? endValue.fill : fill,
        lineWidth: lerpDouble(lineWidth, endValue.lineWidth, t),
        startPosition: lerpDouble(startPosition, endValue.startPosition, t),
        lineColor: Color.lerp(lineColor, endValue.lineColor, t),
      ).._items = ChartItemsLerp().lerpValues(_items, endValue._items, t);
    }

    return this;
  }
}
