part of flutter_charts;

/// Draw [_ChartWidget] with set [state], [width] and [height] for the chart
class Chart<T> extends StatelessWidget {
  const Chart({
    @required this.state,
    this.height = 240.0,
    this.width,
    Key key,
  }) : super(key: key);

  final double height;
  final double width;
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
