part of flutter_charts;

/// Extended [ImplicitlyAnimatedWidget], that will animate the chart on every change of the [ChartState].
class AnimatedChart<T> extends ImplicitlyAnimatedWidget {
  /// Default constructor for animated chart [state] and [duration] are required
  const AnimatedChart({
    @required this.state,
    @required Duration duration,
    this.height = 240.0,
    this.width,
    Curve curve = Curves.linear,
    VoidCallback onEnd,
    Key key,
  }) : super(duration: duration, curve: curve, onEnd: onEnd, key: key);

  final double height;
  final double width;
  final ChartState<T> state;

  @override
  _ChartState<T> createState() => _ChartState<T>();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<ChartState>('state', state));
    properties.add(DiagnosticsProperty<double>('height', height));
    properties.add(DiagnosticsProperty<double>('width', width));
  }
}

class _ChartState<T> extends AnimatedWidgetBaseState<AnimatedChart<T>> {
  ChartStateTween<T> _chartStateTween;
  Tween<double> _heightTween;
  Tween<double> _widthTween;

  @override
  Widget build(BuildContext context) {
    return _ChartWidget(
      width: _widthTween?.evaluate(animation),
      height: _heightTween?.evaluate(animation),
      state: _chartStateTween?.evaluate(animation),
    );
  }

  @override
  void forEachTween(visitor) {
    _chartStateTween =
        visitor(_chartStateTween, widget.state, (dynamic value) => ChartStateTween<T>(begin: value as ChartState<T>))
            as ChartStateTween<T>;
    _heightTween =
        visitor(_heightTween, widget.height, (dynamic value) => Tween<double>(begin: value as double)) as Tween<double>;
    _widthTween =
        visitor(_widthTween, widget.width, (dynamic value) => Tween<double>(begin: value as double)) as Tween<double>;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder description) {
    super.debugFillProperties(description);
    description.add(DiagnosticsProperty<ChartStateTween>('state', _chartStateTween, defaultValue: null));
    description.add(DiagnosticsProperty<Tween<double>>('height', _heightTween, defaultValue: null));
    description.add(DiagnosticsProperty<Tween<double>>('width', _widthTween, defaultValue: null));
  }
}

class ChartStateTween<T> extends Tween<ChartState<T>> {
  ChartStateTween({ChartState<T> begin, ChartState<T> end}) : super(begin: begin, end: end);

  @override
  ChartState<T> lerp(double t) => ChartState.lerp(begin, end, t);
}
