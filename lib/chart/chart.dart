part of flutter_charts;

/// Extend [ImplicitlyAnimatedWidget], that way every change on
/// [ChartState] that is included in lerp function will get animated.
///
/// Things that are currently not animating are:
/// [ChartItemOptions.showValue] - bool, could animate by changing opacity of [ChartItemOptions.valueColor] and [ChartItemOptions.valueColorOver]
/// [ChartItemOptions.colorForValue] - Function, not sure if effort is worth (not really used that often)
/// [ChartItemOptions.itemPainter] - Function, painter, probably impossible to animate without some kind of shuttle.
///
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
