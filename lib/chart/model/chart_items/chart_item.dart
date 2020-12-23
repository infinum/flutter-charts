part of flutter_charts;

abstract class ChartItem<T> {
  ChartItem(this.value, this.min, this.max);

  final double min;
  final double max;
  final T value;

  bool get isEmpty => (max ?? 0) == 0 && (min ?? 0) == 0;

  ChartItem animateTo(ChartItem endValue, double t);

  ChartItem animateFrom(ChartItem startValue, double t) {
    return animateTo(startValue, 1 - t);
  }

  @override
  int get hashCode => hashValues(min, max) ^ value.hashCode;

  @override
  bool operator ==(Object other) {
    if (other is ChartItem) {
      return other.hashCode == hashCode;
    }

    return false;
  }

  @override
  String toString() {
    return 'ChartItem(min: $min, max: $max, value: $value)';
  }
}
