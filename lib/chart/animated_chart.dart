part of flutter_charts;

/// Extend [ImplicitlyAnimatedWidget], that way every change on
/// [ChartState] that is included in lerp function will get animated.
class AnimatedChart extends ImplicitlyAnimatedWidget {
  const AnimatedChart({
    this.height = 240.0,
    this.width,
    this.state,
    Curve curve = Curves.linear,
    @required Duration duration,
    VoidCallback onEnd,
    Key key,
  }) : super(duration: duration, curve: curve, onEnd: onEnd, key: key);

  final double height;
  final double width;
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
    return _ChartWidget(
      width: widget.width,
      height: _heightTween?.evaluate(animation),
      state: _chartStateTween?.evaluate(animation),
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
