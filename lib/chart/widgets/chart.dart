part of charts_painter;

/// Draw [_ChartWidget] with set [state], [width] and [height] for the chart
class Chart<T> extends StatelessWidget {
  /// Make chart widget
  const Chart({
    required this.state,
    this.height = 240.0,
    this.width,
    Key? key,
  }) : super(key: key);

  /// Chart height
  final double height;

  /// Chart width
  final double? width;

  /// Chart state
  final ChartState<T> state;

  @override
  Widget build(BuildContext context) {
    return _ChartWidget(
      height: height,
      width: width,
      state: state,
    );
  }
}
