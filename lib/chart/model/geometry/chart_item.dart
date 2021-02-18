part of flutter_charts;

class ChartItem<T> {
  @protected
  ChartItem(this.value, this.min, this.max);

  final double min;
  final double max;
  final T value;

  bool get isEmpty => (max ?? 0) == 0 && (min ?? 0) == 0;

  ChartItem<T> animateTo<T>(ChartItem<T> endValue, double t) {
    return ChartItem(
      endValue.value,
      lerpDouble(min, endValue.min, t),
      lerpDouble(max, endValue.max, t),
    );
  }

  ChartItem<T> animateFrom<T>(ChartItem<T> startValue, double t) {
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
  ChartItem<T> operator +(Object other) {
    if (other is ChartItem<T>) {
      return ChartItem<T>(
        other.value,
        (other?.min ?? 0.0) + (min ?? 0.0),
        (other?.max ?? 0.0) + (max ?? 0.0),
      );
    }

    return this;
  }

  @override
  String toString() {
    return 'ChartItem(min: $min, max: $max, value: $value)';
  }
}
