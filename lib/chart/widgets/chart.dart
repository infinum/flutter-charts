part of flutter_charts;

/// Extend [ImplicitlyAnimatedWidget], that way every change on
/// [ChartState] that is included in lerp function will get animated.
class Chart<T> extends StatelessWidget {
  const Chart({
    this.height = 240.0,
    this.width,
    this.state,
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
