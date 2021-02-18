part of flutter_charts;

enum DataStrategy {
  none,
  stack,
}

/// [valueAxisMin] - Min value that has to be displayed on the chart, if data contains value that is
/// lower than [valueAxisMin] in that case [valueAxisMin] is ignored and actual min value is shown.
///
/// [valueAxisMax] - Same as [valueAxisMin] but for max value.
class ChartData<T> {
  ChartData(
    this._items, {
    this.strategy = DataStrategy.none,
    this.valueAxisMax,
    double valueAxisMaxOver,
    this.valueAxisMin,
  })  : _strategyChange = strategy != DataStrategy.none ? 1.0 : 0.0,
        minValue = _getMinValue(
            formatDataStrategy(_items, strategy != DataStrategy.none ? 1.0 : 0.0)
                .fold(<ChartItem<T>>[], (List<ChartItem<T>> list, element) => list..addAll(element)).toList(),
            valueAxisMin),
        maxValue = _getMaxValue(
                formatDataStrategy(_items, strategy != DataStrategy.none ? 1.0 : 0.0)
                    .fold(<ChartItem<T>>[], (List<ChartItem<T>> list, element) => list..addAll(element)).toList(),
                valueAxisMax) +
            (valueAxisMaxOver ?? 0.0);

  factory ChartData.fromList(
    List<ChartItem<T>> items, {
    DataStrategy strategy = DataStrategy.none,
    double valueAxisMax,
    double valueAxisMin,
  }) {
    return ChartData([items], strategy: strategy, valueAxisMin: valueAxisMin, valueAxisMax: valueAxisMax);
  }

  ChartData._lerp(
    this._items,
    this._strategyChange, {
    this.strategy = DataStrategy.none,
    this.valueAxisMax,
    this.valueAxisMin,
    this.minValue,
    this.maxValue,
  });

  final List<List<ChartItem<T>>> _items;
  final DataStrategy strategy;
  final double _strategyChange;

  /// Scale
  final double minValue;
  final double maxValue;

  /// Max value that chart should show, in case that [valueAxisMax] is bellow
  /// the value of value passed with data in the chart this will be ignored.
  final double valueAxisMax;

  /// Min value of the chart, anything below that will not be shown and chart
  /// x axis will start from [valueAxisMin] (default: 0)
  final double valueAxisMin;

  List<List<ChartItem<T>>> get items {
    return formatDataStrategy(_items, _strategyChange);
  }

  static List<List<ChartItem<T>>> formatDataStrategy<T>(List<List<ChartItem<T>>> items, double strategy) {
    final _incrementList = <ChartItem<T>>[];
    return items.reversed
        .map((entry) {
          return entry.asMap().entries.map((e) {
            if (_incrementList.length > e.key) {
              final _newValue = e.value + _incrementList[e.key];
              _incrementList[e.key] = (_incrementList[e.key] + e.value) * strategy;
              return _newValue;
            } else {
              _incrementList.add(e.value * strategy);
            }

            return e.value;
          }).toList();
        })
        .toList()
        .reversed
        .toList();
  }

  bool get isEmpty => _items.isEmpty;
  bool get isNotEmpty => !isEmpty;

  int get listSize => _items.fold(0, (previousValue, element) => max(previousValue, element.length));
  int get stackSize => _items.length;

  /// Get max value of the chart
  /// Max value is max data item from [items] or [ChartOptions.valueAxisMax]
  static double _getMaxValue<T>(List<ChartItem<T>> items, double valueAxisMax) {
    return max(valueAxisMax ?? 0.0, items.map((e) => e.max ?? 0.0).reduce(max));
  }

  /// Get min value of the chart
  /// Min value is min data item from [items] or [ChartOptions.valueAxisMin]
  static double _getMinValue<T>(List<ChartItem<T>> items, double valueAxisMin) {
    final _minItems = items
        .where((e) => (e.min != null && e.min != 0.0) || (e.min == null && e.max != 0.0))
        .map((e) => e.min ?? e.max ?? double.infinity);
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
      valueAxisMax: lerpDouble(a.valueAxisMax, b.valueAxisMax, t),
      valueAxisMin: lerpDouble(a.valueAxisMin, b.valueAxisMin, t),

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
        return b[index].animateFrom<T>(a[index], t);
      }

      // If new list is larger, then check if item in the list is not empty
      // In case item is not empty then animate to it from our [_emptyValue]
      if (index < b.length) {
        if (b[index].isEmpty) {
          return b[index];
        }

        // If item is appearing then it's time to animate is
        // from time it first showed to end of the animation.
        final double _value = _listLength.floor() == index ? ((_listLength - _listLength.floor()) * t) : t;
        return b[index].animateFrom<T>(_emptyValue, _value);
      }

      // In case that our old list is bigger, and item is not empty
      // then we need to animate to empty value from current item value
      if (a[index].isEmpty) {
        return a[index];
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
