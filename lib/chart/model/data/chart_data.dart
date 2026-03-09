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
    this._sections, {
    this.dataStrategy = const DefaultDataStrategy(stackMultipleValues: true),
    this.axisMax,
    this.valueAxisMaxOver,
    this.axisMin,
  })  : _animatedListSize = null,
        minValue = _getMinValue<T>(
            dataStrategy.formatDataStrategy(_sections).expand((element) => element.items).toList(), axisMin),
        maxValue = _getMaxValue(
                dataStrategy.formatDataStrategy(_sections).expand((element) => element.items).toList(), axisMax) +
            (valueAxisMaxOver ?? 0.0);

  /// Make chart data from list of [ChartItem]'s
  factory ChartData.fromList(
    List<ChartItem<T>> items, {
    double? axisMax,
    double? axisMin,
    double? valueAxisMaxOver,
  }) {
    return ChartData(
      [ChartDataSection<T>(items: items)],
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
    return ChartData<T>(
      [
        ChartDataSection<T>(
          items: List.generate(
            items,
            (index) => ChartItem<T>((Random().nextDouble() * (maxValue - minValue)) + minValue),
          ),
        ),
      ],
      valueAxisMaxOver: valueAxisMaxOver,
    );
  }

  ChartData._lerp(
    this._sections, {
    this.dataStrategy = const DefaultDataStrategy(stackMultipleValues: true),
    this.axisMax,
    this.axisMin,
    this.valueAxisMaxOver,
    required this.minValue,
    required this.maxValue,
    double? animatedListSize,
  }) : _animatedListSize = animatedListSize;

  /// Chart items, items in the list cannot be null, but ChartItem can be defined
  /// with null values to represent gaps in the data
  final List<ChartDataSection<T>> _sections;

  /// Animated logical list size used for smooth width animation when items are
  /// added or removed between chart states.
  final double? _animatedListSize;

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
  bool get isEmpty => _sections.isEmpty;

  /// Returns true if there is at least one item in the [ChartData]
  bool get isNotEmpty => !isEmpty;

  /// Get max list size
  int get listSize => _sections.fold(0, (previousValue, element) => max(previousValue, element.length));

  /// Animated list size used for width calculations during transitions.
  double get animatedListSize => _animatedListSize ?? listSize.toDouble();

  /// Get number of data lists in the chart
  int get stackSize => _sections.length;

  List<ChartDataSection<T>>? _cachedSections;

  /// Return list as formatted data defined by [DataStrategy]
  List<ChartDataSection<T>> get sections {
    _cachedSections ??= dataStrategy.formatDataStrategy(_sections);
    return _cachedSections ?? dataStrategy.formatDataStrategy(_sections);
  }

  /// Get max value of the chart
  /// Max value is max data item from [items] or [ChartOptions.axisMax]
  static double _getMaxValue<T>(List<ChartItem<T>> items, double? valueAxisMax) {
    return max(valueAxisMax ?? 0.0, items.map((e) => e.max ?? 0.0).fold(0.0, max));
  }

  /// Get min value of the chart
  /// Min value is min data item from [items] or [ChartOptions.axisMin]
  static double _getMinValue<T>(List<ChartItem<T>> items, double? valueAxisMin) {
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
  static ChartData<T> lerp<T>(ChartData<T> a, ChartData<T> b, double t) {
    return ChartData._lerp(
      ChartSectionsLerp.lerpValues(a._sections, b._sections, t),
      axisMax: lerpDouble(a.axisMax, b.axisMax, t),
      axisMin: lerpDouble(a.axisMin, b.axisMin, t),
      dataStrategy: t > 0.5 ? b.dataStrategy : a.dataStrategy,
      valueAxisMaxOver: lerpDouble(a.valueAxisMaxOver, b.valueAxisMaxOver, t),

      /// Those are usually calculated, but we need to have a control over them in the animation
      maxValue: lerpDouble(a.maxValue, b.maxValue, t) ?? b.maxValue,
      minValue: lerpDouble(a.minValue, b.minValue, t) ?? b.minValue,
      animatedListSize: lerpDouble(a.listSize.toDouble(), b.listSize.toDouble(), t),
    );
  }
}

/// Lerp items in the charts
class ChartSectionsLerp {
  /// Lerp chart items
  static List<ChartDataSection<T>> lerpValues<T>(List<ChartDataSection<T>> a, List<ChartDataSection<T>> b, double t) {
    /// Get list length in animation, we will add the items in steps.

    /// Generate new list fot animation step, add items depending on current [_listLength]
    return List<ChartDataSection<T>>.generate(b.length, (int index) {
      return ChartDataSection.lerp<T>(
        a.length > index ? a[index] : ChartDataSection<T>(items: [], offset: a.lastOrNull?.length ?? 0),
        b.length > index ? b[index] : ChartDataSection<T>(items: [], offset: b.lastOrNull?.length ?? 0),
        t,
      );
    });
  }
}
