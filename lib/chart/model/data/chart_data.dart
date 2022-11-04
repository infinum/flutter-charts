part of charts_painter;

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
    this.dataStrategy = const DefaultDataStrategy(stackMultipleValues: true),
    this.axisMax,
    this.valueAxisMaxOver,
    this.axisMin,
  })  : minValue = _getMinValue<T>(
          dataStrategy.formatDataStrategy(_items).fold(
            <ChartItem<T?>>[],
            (List<ChartItem<T?>> list, element) => list..addAll(element),
          ).toList(),
          axisMin,
        ),
        maxValue = _getMaxValue(
              dataStrategy.formatDataStrategy(_items).fold(
                <ChartItem<T?>>[],
                (List<ChartItem<T?>> list, element) => list..addAll(element),
              ).toList(),
              axisMax,
            ) +
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
      axisMin: axisMin,
      axisMax: axisMax,
      valueAxisMaxOver: valueAxisMaxOver,
    );
  }

  /// Generate a list of random [ChartItem] items for the chart
  factory ChartData.randomBarValues({
    int items = 10,
    double maxValue = 20,
    double minValue = 0,
    double? valueAxisMaxOver,
  }) {
    return ChartData<T?>(
      [
        List.generate(
          items,
          (index) => ChartItem<T>(
            (Random().nextDouble() * (maxValue - minValue)) + minValue,
          ),
        ).toList()
      ],
      valueAxisMaxOver: valueAxisMaxOver,
    ) as ChartData<T>;
  }

  ChartData._lerp(
    this._items, {
    this.dataStrategy = const DefaultDataStrategy(stackMultipleValues: true),
    this.axisMax,
    this.axisMin,
    this.valueAxisMaxOver,
    required this.minValue,
    required this.maxValue,
  });

  /// Chart items, items in the list cannot be null, but ChartItem can be defined
  /// with null values to represent gaps in the data
  final List<List<ChartItem<T?>>> _items;

  // Statistics layer
  /// Data strategy to use on items
  /// Default: [DefaultDataStrategy]
  final DataStrategy dataStrategy;

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

  /// Max value that chart should show, in case that [axisMax] is bellow
  /// the value of value passed with data in the chart this will be ignored.
  final double? valueAxisMaxOver;

  /// Min value of the chart, anything below that will not be shown and chart
  /// x axis will start from [axisMin] (default: 0)
  final double? axisMin;

  /// Returns true if there is no items in the [ChartData]
  bool get isEmpty => _items.isEmpty;

  /// Returns true if there is at least one item in the [ChartData]
  bool get isNotEmpty => !isEmpty;

  /// Get max list size
  int get listSize => _items.fold(
        0,
        (previousValue, element) => max(previousValue, element.length),
      );

  /// Get number of data lists in the chart
  int get stackSize => _items.length;

  List<List<ChartItem<T?>>>? _cachedItems;

  /// Return list as formatted data defined by [DataStrategy]
  List<List<ChartItem<T?>>> get items {
    _cachedItems ??= dataStrategy.formatDataStrategy(_items);
    return _cachedItems ?? dataStrategy.formatDataStrategy(_items);
  }

  /// Get max value of the chart
  /// Max value is max data item from [items] or [ChartOptions.axisMax]
  static double _getMaxValue<T>(
    List<ChartItem<T>> items,
    double? valueAxisMax,
  ) {
    return max(valueAxisMax ?? 0.0, items.map((e) => e.max ?? 0.0).reduce(max));
  }

  /// Get min value of the chart
  /// Min value is min data item from [items] or [ChartOptions.axisMin]
  static double _getMinValue<T>(
    List<ChartItem<T?>> items,
    double? valueAxisMin,
  ) {
    final _minItems = items
        .where(
          (e) =>
              (e.min != null && e.min != 0.0) ||
              (e.min == null && e.max != 0.0),
        )
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
      axisMax: lerpDouble(a.axisMax, b.axisMax, t),
      axisMin: lerpDouble(a.axisMin, b.axisMin, t),
      dataStrategy: t > 0.5 ? b.dataStrategy : a.dataStrategy,
      valueAxisMaxOver: lerpDouble(a.valueAxisMaxOver, b.valueAxisMaxOver, t),

      /// Those are usually calculated, but we need to have a control over them in the animation
      maxValue: lerpDouble(a.maxValue, b.maxValue, t) ?? b.maxValue,
      minValue: lerpDouble(a.minValue, b.minValue, t) ?? b.minValue,
    );
  }
}

/// Lerp items in the charts
class ChartItemsLerp {
  /// Lerp chart items
  static List<List<ChartItem<T?>>> lerpValues<T>(
    List<List<ChartItem<T?>>> a,
    List<List<ChartItem<T?>>> b,
    double t,
  ) {
    /// Get list length in animation, we will add the items in steps.
    final _listLength = lerpDouble(a.length, b.length, t) ?? b.length;

    /// Empty value for generated list.
    final _emptyList = <ChartItem<T>>[];

    /// Generate new list fot animation step, add items depending on current [_listLength]
    return List<List<ChartItem<T?>>>.generate(_listLength.ceil(), (int index) {
      return _lerpItemList<T>(
        a.length > index ? a[index] : _emptyList,
        b.length > index ? b[index] : _emptyList,
        t,
      );
    });
  }

  static List<ChartItem<T?>> _lerpItemList<T>(
    List<ChartItem<T?>?> a,
    List<ChartItem<T?>?> b,
    double t,
  ) {
    final _listLength = lerpDouble(a.length, b.length, t) ?? b.length;

    /// Empty value for generated list.
    final _emptyValue = ChartItem<T?>(0, min: 0);

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
        final _value = _listLength.floor() == index
            ? ((_listLength - _listLength.floor()) * t)
            : t;
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
