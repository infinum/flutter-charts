part of flutter_charts;

enum DataStrategy {
  none,
  stack,
}

/// [verticalAxisMin] - Min value that has to be displayed on the chart, if data contains value that is
/// lower than [verticalAxisMin] in that case [verticalAxisMin] is ignored and actual min value is shown.
///
/// [verticalAxisMax] - Same as [verticalAxisMin] but for max value.
class ChartData<T> {
  ChartData(
    this._items, {
    this.strategy = DataStrategy.none,
    this.verticalAxisMax,
    double valueAxisMaxOver,
    this.verticalAxisMin,
  })  : _strategyChange = strategy != DataStrategy.none ? 1.0 : 0.0,
        minValue = _getMinValue(
            formatDataStrategy(_items, strategy)
                .fold(<ChartItem<T>>[], (List<ChartItem<T>> list, element) => list..addAll(element)).toList(),
            verticalAxisMin),
        maxValue = _getMaxValue(
                formatDataStrategy(_items, strategy)
                    .fold(<ChartItem<T>>[], (List<ChartItem<T>> list, element) => list..addAll(element)).toList(),
                verticalAxisMax) +
            (valueAxisMaxOver ?? 0.0);

  factory ChartData.fromList(
    List<ChartItem<T>> items, {
    DataStrategy strategy = DataStrategy.none,
    double axisMax,
    double axisMin,
  }) {
    return ChartData([items], strategy: strategy, verticalAxisMin: axisMin, verticalAxisMax: axisMax);
  }

  ChartData._lerp(
    this._items,
    this._strategyChange, {
    this.strategy = DataStrategy.none,
    this.verticalAxisMax,
    this.verticalAxisMin,
    this.minValue,
    this.maxValue,
  });

  final List<List<ChartItem<T>>> _items;
  final DataStrategy strategy;
  final double _strategyChange;

  /// Scale
  final double minValue;
  final double maxValue;

  /// Max value that chart should show, in case that [verticalAxisMax] is bellow
  /// the value of value passed with data in the chart this will be ignored.
  final double verticalAxisMax;

  /// Min value of the chart, anything below that will not be shown and chart
  /// x axis will start from [verticalAxisMin] (default: 0)
  final double verticalAxisMin;

  List<List<ChartItem<T>>> get items {
    return formatDataStrategy(_items, strategy, _strategyChange);
  }

  static List<List<ChartItem<T>>> formatDataStrategy<T>(
    List<List<ChartItem<T>>> items,
    DataStrategy strategy, [
    double _stackValue,
  ]) {
    switch (strategy) {
      case DataStrategy.none:
      case DataStrategy.stack:
        _stackValue ??= strategy != DataStrategy.none ? 1.0 : 0.0;

        final _incrementList = <ChartItem<T>>[];
        return items.reversed
            .map((entry) {
              return entry.asMap().entries.map((e) {
                if (e.value == null) {
                  return e.value;
                }

                if (_incrementList.length > e.key) {
                  final _newValue = e.value + _incrementList[e.key];
                  _incrementList[e.key] = (_incrementList[e.key] + e.value) * _stackValue;
                  return _newValue;
                } else {
                  _incrementList.add(e.value * _stackValue);
                }

                return e.value;
              }).toList();
            })
            .toList()
            .reversed
            .toList();

      // Strategy not handled, return items
      default:
        return items;
    }
  }

  bool get isEmpty => _items.isEmpty;
  bool get isNotEmpty => !isEmpty;

  int get listSize => _items.fold(0, (previousValue, element) => max(previousValue, element.length));
  int get stackSize => _items.length;

  /// Get max value of the chart
  /// Max value is max data item from [items] or [ChartOptions.verticalAxisMax]
  static double _getMaxValue<T>(List<ChartItem<T>> items, double valueAxisMax) {
    return max(valueAxisMax ?? 0.0, items.map((e) => e?.max ?? 0.0).reduce(max));
  }

  /// Get min value of the chart
  /// Min value is min data item from [items] or [ChartOptions.verticalAxisMin]
  static double _getMinValue<T>(List<ChartItem<T>> items, double valueAxisMin) {
    final _minItems = items
        .where((e) => (e?.min != null && e.min != 0.0) || (e?.min == null && e?.max != 0.0))
        .map((e) => e?.min ?? e?.max ?? double.infinity);
    if (_minItems.isEmpty) {
      return valueAxisMin ?? 0.0;
    }

    return min(valueAxisMin ?? 0.0, _minItems.reduce(min));
  }

  static ChartData<T> lerp<T>(ChartData<T> a, ChartData<T> b, double t) {
    return ChartData._lerp(
      ChartItemsLerp().lerpValues(a._items, b._items, t),
      lerpDouble(a._strategyChange, b._strategyChange, t),
      strategy: t > 0.5 ? b.strategy : a.strategy,
      verticalAxisMax: lerpDouble(a.verticalAxisMax, b.verticalAxisMax, t),
      verticalAxisMin: lerpDouble(a.verticalAxisMin, b.verticalAxisMin, t),

      /// Those are usually calculated, but we need to have a control over them in the animation
      maxValue: lerpDouble(a.maxValue, b.maxValue, t),
      minValue: lerpDouble(a.minValue, b.minValue, t),
    );
  }
}

/// Lerp items in the charts
class ChartItemsLerp {
  List<List<ChartItem<T>>> lerpValues<T>(List<List<ChartItem<T>>> a, List<List<ChartItem<T>>> b, double t) {
    /// Get list length in animation, we will add the items in steps.
    final double _listLength = lerpDouble(a.length, b.length, t);

    /// Empty value for generated list.
    final List<BarValue<T>> _emptyList = [];

    /// Generate new list fot animation step, add items depending on current [_listLength]
    return List<List<ChartItem<T>>>.generate(_listLength.ceil(), (int index) {
      return _lerpItemList<T>(a.length > index ? a[index] : _emptyList, b.length > index ? b[index] : _emptyList, t);
    });
  }

  List<ChartItem<T>> _lerpItemList<T>(List<ChartItem<T>> a, List<ChartItem<T>> b, double t) {
    final double _listLength = lerpDouble(a.length, b.length, t);

    /// Empty value for generated list.
    final ChartItem<T> _emptyValue = ChartItem<T>(null, 0.0, 0.0);

    return List<ChartItem<T>>.generate(_listLength.ceil(), (int index) {
      // If old list and new list have value at [index], then just animate from,
      // old list value to the new value
      if (index < a.length && index < b.length) {
        if (b[index] != null && a[index] != null) {
          return b[index].animateFrom<T>(a[index], t);
        } else if (b[index] != null) {
          return b[index].animateFrom<T>(_emptyValue, t);
        } else if (a[index] != null) {
          return a[index].animateTo<T>(_emptyValue, t);
        }

        return _emptyValue;
      }

      // If new list is larger, then check if item in the list is not empty
      // In case item is not empty then animate to it from our [_emptyValue]
      if (index < b.length) {
        if (b[index] == null || b[index].isEmpty) {
          return b[index] ?? _emptyValue;
        }

        // If item is appearing then it's time to animate is
        // from time it first showed to end of the animation.
        final double _value = _listLength.floor() == index ? ((_listLength - _listLength.floor()) * t) : t;
        return b[index].animateFrom<T>(_emptyValue, _value);
      }

      // In case that our old list is bigger, and item is not empty
      // then we need to animate to empty value from current item value
      if (a[index] == null || a[index].isEmpty) {
        return a[index] ?? _emptyValue;
      }

      final double _value = _listLength.floor() == index
          ? min(1, (1 - (_listLength - _listLength.floor())) + t / _listLength)
          : _listLength.floor() >= index
              ? 0
              : t;
      return a[index].animateTo<T>(_emptyValue, _value);
    });
  }
}
