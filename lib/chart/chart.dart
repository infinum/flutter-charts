part of flutter_charts;

/// Extend [ImplicitlyAnimatedWidget], that way every change on
/// [ChartState] that is included in lerp function will get animated.
class Chart extends StatelessWidget {
  const Chart({
    this.height = 240.0,
    this.state,
    Key key,
  }) : super(key: key);

  final double height;
  final ChartState state;

  @override
  Widget build(BuildContext context) {
    return _ChartWidget(
      height: height,
      state: state,
    );
  }
}
