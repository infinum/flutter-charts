part of flutter_charts;

/// Default `ChartItem`
class ChartItem<T> {
  /// Protected constructor for animations
  @protected
  ChartItem(this.value, this.min, this.max);

  final double min;
  final double max;
  final T value;

  bool get isEmpty => (max ?? 0) == 0 && (min ?? 0) == 0;

  /// Animate to [endValue] with factor `t`
  ChartItem<T> animateTo<T>(ChartItem<T> endValue, double t) {
    return ChartItem<T>(
      endValue.value,
      lerpDouble(min, endValue.min, t),
      lerpDouble(max, endValue.max, t),
    );
  }

  /// Animate from [startValue] to this with factor `t`
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

  /// Add two [ChartItem]'s together
  /// `T` value is taken from [other]
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

  /// Multiply [ChartItem] with another [ChartItem] of number
  ChartItem<T> operator *(Object other) {
    if (other is ChartItem<T>) {
      return ChartItem<T>(
        other.value,
        (other?.min ?? 0.0) * (min ?? 0.0),
        (other?.max ?? 0.0) * (max ?? 0.0),
      );
    } else if (other is num) {
      return ChartItem<T>(
        value,
        (other ?? 0.0).toDouble() * (min ?? 0.0),
        (other ?? 0.0).toDouble() * (max ?? 0.0),
      );
    }

    return this;
  }

  @override
  String toString() {
    return 'ChartItem(min: $min, max: $max, value: $value)';
  }
}
