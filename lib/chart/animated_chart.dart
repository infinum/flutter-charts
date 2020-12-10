part of flutter_charts;

/// Extend [ImplicitlyAnimatedWidget], that way every change on
/// [ChartState] that is included in lerp function will get animated.
///
/// Things that are currently not animating are:
/// [ChartItemOptions.showValue] - bool, could animate by changing opacity of [ChartItemOptions.valueColor] and [ChartItemOptions.valueColorOver]
/// [ChartItemOptions.colorForValue] - Function, not sure if effort is worth (not really used that often)
/// [ChartItemOptions.itemPainter] - Function, painter, probably impossible to animate without some kind of shuttle.
///
class AnimatedChart extends ImplicitlyAnimatedWidget {
  const AnimatedChart({
    this.height = 240.0,
    this.state,
    Curve curve = Curves.linear,
    @required Duration duration,
    VoidCallback onEnd,
    Key key,
  }) : super(duration: duration, curve: curve, onEnd: onEnd, key: key);

  final double height;
  final ChartState state;

  @override
  _ChartState createState() => _ChartState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<ChartState>('state', state));
    properties.add(DiagnosticsProperty<double>('height', height));
  }
}

class _ChartState extends AnimatedWidgetBaseState<AnimatedChart> {
  ChartStateTween _chartStateTween;
  Tween<double> _heightTween;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.fromHeight(_heightTween?.evaluate(animation)),
      painter: ChartPainter(
        _chartStateTween?.evaluate(animation),
      ),
    );
  }

  @override
  void forEachTween(visitor) {
    _chartStateTween =
        visitor(_chartStateTween, widget.state, (dynamic value) => ChartStateTween(begin: value as ChartState))
            as ChartStateTween;
    _heightTween =
        visitor(_heightTween, widget.height, (dynamic value) => Tween<double>(begin: value as double)) as Tween<double>;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder description) {
    super.debugFillProperties(description);
    description.add(DiagnosticsProperty<ChartStateTween>('state', _chartStateTween, defaultValue: null));
    description.add(DiagnosticsProperty<Tween<double>>('height', _heightTween, defaultValue: null));
  }
}

class ChartStateTween extends Tween<ChartState> {
  ChartStateTween({ChartState begin, ChartState end}) : super(begin: begin, end: end);

  @override
  ChartState lerp(double t) => ChartState.lerp(begin, end, t);
}
