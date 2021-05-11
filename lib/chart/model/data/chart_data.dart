part of charts_painter;

/// Data strategy to use for [ChartData]
enum DataStrategy {
  /// Data will be the same as it was passed
  none,

  /// Data will be 'stacked' one on top of the other
  stack,
}

/// [axisMin] - Min value that has to be displayed on the chart, if data contains value that is
/// lower than [axisMin] in that case [axisMin] is ignored and actual min value is shown.
///
/// [axisMax] - Same as [axisMin] but for max value.
class ChartData<T> {
  /// Takes list to make chart, this is used for multiple list charts
  ///
  /// [valueAxisMaxOver] - How much should chart draw above max value in the chart
  ChartData(
    this._items, {
    this.strategy = DataStrategy.none,
    this.axisMax,
    double? valueAxisMaxOver,
    this.axisMin,
  })  : _strategyChange = strategy != DataStrategy.none ? 1.0 : 0.0,
        minValue = _getMinValue(
            _formatDataStrategy(_items, strategy)
                .fold(<ChartItem<T?>>[], (List<ChartItem<T?>> list, element) => list..addAll(element)).toList(),
            axisMin),
        maxValue = _getMaxValue(
                _formatDataStrategy(_items, strategy)
                    .fold(<ChartItem<T?>>[], (List<ChartItem<T?>> list, element) => list..addAll(element)).toList(),
                axisMax) +
            (valueAxisMaxOver ?? 0.0);

  /// Make chart data from list of [ChartItem]'s
  factory ChartData.fromList(
    List<ChartItem<T>> items, {
    double? axisMax,
    double? axisMin,
    double? valueAxisMaxOver,
  }) {
    return ChartData(
      [items],
      strategy: DataStrategy.none,
      axisMin: axisMin,
      axisMax: axisMax,
      valueAxisMaxOver: valueAxisMaxOver,
    );
  }

  /// Generate a list of random [BarValue] items for the chart
  factory ChartData.randomBarValues({
    int items = 10,
    double maxValue = 20,
    double minValue = 0,
    double? valueAxisMaxOver,
  }) {
    return ChartData<T?>(
      [
        List.generate(items, (index) => BarValue<T>((Random().nextDouble() * (maxValue - minValue)) + minValue))
            .toList()
      ],
      valueAxisMaxOver: valueAxisMaxOver,
    ) as ChartData<T>;
  }

  ChartData._lerp(
    this._items,
    this._strategyChange, {
    this.strategy = DataStrategy.none,
    this.axisMax,
    this.axisMin,
    this.minValue = 0,
    this.maxValue = 0,
  });

  /// Chart items, items in the list cannot be null, but ChartItem can be defined
  /// with null values to represent gaps in the data
  final List<List<ChartItem<T?>>> _items;
  final double? _strategyChange;

  /// Data strategy to use on items
  /// Defaults to [DataStrategy.none]
  final DataStrategy strategy;

  // Scale
  /// Min value that chart should show.
  /// In case chart shouldn't start from 0 use this to specify new min starting point
  /// If data has value that goes below [minValue] then [minValue] is ignored
  late final double minValue;

  /// Max value to show on the chart, in case data has point higher then
  /// specified [maxValue] then [maxValue] is ignored
  late final double maxValue;

  /// Max value that chart should show, in case that [axisMax] is bellow
  /// the value of value passed with data in the chart this will be ignored.
  final double? axisMax;

  /// Min value of the chart, anything below that will not be shown and chart
  /// x axis will start from [axisMin] (default: 0)
  final double? axisMin;

  /// Return list as formatted data defined by [DataStrategy]
  List<List<ChartItem<T?>>> get items {
    return _formatDataStrategy(_items, strategy, _strategyChange);
  }

  /// Format items according to currently selected [DataStrategy]
  static List<List<ChartItem<T?>>> _formatDataStrategy<T>(
    List<List<ChartItem<T?>>> items,
    DataStrategy strategy, [
    double? _stackValue,
  ]) {
    switch (strategy) {
      case DataStrategy.none:
      case DataStrategy.stack:
        _stackValue ??= strategy != DataStrategy.none ? 1.0 : 0.0;

        final _incrementList = <ChartItem<T?>>[];
        return items.reversed
            .map((entry) {
              return entry.asMap().entries.map((e) {
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

  /// Returns true if there is no items in the [ChartData]
  bool get isEmpty => _items.isEmpty;

  /// Returns true if there is at least one item in the [ChartData]
  bool get isNotEmpty => !isEmpty;

  /// Get max list size
  int get listSize => _items.fold(0, (previousValue, element) => max(previousValue, element.length));

  /// Get number of data lists in the chart
  int get stackSize => _items.length;

  /// Get max value of the chart
  /// Max value is max data item from [items] or [ChartOptions.axisMax]
  static double _getMaxValue<T>(List<ChartItem<T>> items, double? valueAxisMax) {
    return max(valueAxisMax ?? 0.0, items.map((e) => e.max ?? 0.0).reduce(max));
  }

  /// Get min value of the chart
  /// Min value is min data item from [items] or [ChartOptions.axisMin]
  static double _getMinValue<T>(List<ChartItem<T?>> items, double? valueAxisMin) {
    final _minItems = items
        .where((e) => (e.min != null && e.min != 0.0) || (e.min == null && e.max != 0.0))
        .map((e) => e.min ?? e.max ?? double.infinity);
    if (_minItems.isEmpty) {
      return valueAxisMin ?? 0.0;
    }

    return min(valueAxisMin ?? 0.0, _minItems.reduce(min));
  }

  /// Linearly interpolate between two [ChartData], `a` and `b`, by an extrapolation
  /// factor `t`.
  ///
  /// This will animate changes in the [ChartData]
  static ChartData<T?> lerp<T>(ChartData<T?> a, ChartData<T?> b, double t) {
    return ChartData._lerp(
      ChartItemsLerp.lerpValues(a._items, b._items, t),
      lerpDouble(a._strategyChange, b._strategyChange, t),
      strategy: t > 0.5 ? b.strategy : a.strategy,
      axisMax: lerpDouble(a.axisMax, b.axisMax, t),
      axisMin: lerpDouble(a.axisMin, b.axisMin, t),

      /// Those are usually calculated, but we need to have a control over them in the animation
      maxValue: lerpDouble(a.maxValue, b.maxValue, t) ?? b.maxValue,
      minValue: lerpDouble(a.minValue, b.minValue, t) ?? b.minValue,
    );
  }
}

/// Lerp items in the charts
class ChartItemsLerp {
  /// Lerp chart items
  static List<List<ChartItem<T?>>> lerpValues<T>(List<List<ChartItem<T?>>> a, List<List<ChartItem<T?>>> b, double t) {
    /// Get list length in animation, we will add the items in steps.
    final _listLength = lerpDouble(a.length, b.length, t)!;

    /// Empty value for generated list.
    final _emptyList = <ChartItem<T>>[];

    /// Generate new list fot animation step, add items depending on current [_listLength]
    return List<List<ChartItem<T?>>>.generate(_listLength.ceil(), (int index) {
      return _lerpItemList<T>(a.length > index ? a[index] : _emptyList, b.length > index ? b[index] : _emptyList, t);
    });
  }

  static List<ChartItem<T?>> _lerpItemList<T>(List<ChartItem<T?>?> a, List<ChartItem<T?>?> b, double t) {
    final _listLength = lerpDouble(a.length, b.length, t)!;

    /// Empty value for generated list.
    final _emptyValue = ChartItem<T?>(null, 0.0, 0.0);

    return List<ChartItem<T?>>.generate(_listLength.ceil(), (int index) {
      // If old list and new list have value at [index], then just animate from,
      // old list value to the new value
      final _firstItem = index < a.length ? a[index] : null;
      final _secondItem = index < b.length ? b[index] : null;

      if (index < a.length && index < b.length) {
        if (_secondItem != null && _firstItem != null) {
          return _secondItem.animateFrom(_firstItem, t);
        } else if (_secondItem != null) {
          return _secondItem.animateFrom(_emptyValue, t);
        } else if (_firstItem != null) {
          return _firstItem.animateTo(_emptyValue, t);
        }

        return _emptyValue;
      }

      // If new list is larger, then check if item in the list is not empty
      // In case item is not empty then animate to it from our [_emptyValue]
      if (index < b.length) {
        if (_secondItem == null || _secondItem.isEmpty) {
          return _secondItem ?? _emptyValue;
        }

        // If item is appearing then it's time to animate is
        // from time it first showed to end of the animation.
        final _value = _listLength.floor() == index ? ((_listLength - _listLength.floor()) * t) : t;
        return _secondItem.animateFrom(_emptyValue, _value);
      }

      // In case that our old list is bigger, and item is not empty
      // then we need to animate to empty value from current item value
      if (_firstItem == null || _firstItem.isEmpty) {
        return _firstItem ?? _emptyValue;
      }

      final _value = _listLength.floor() == index
          ? min(1, (1 - (_listLength - _listLength.floor())) + t / _listLength)
          : _listLength.floor() >= index
              ? 0
              : t;
      return _firstItem.animateTo(_emptyValue, _value.toDouble());
    });
  }
}
