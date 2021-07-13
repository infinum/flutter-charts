part of charts_painter;

/// Main state of the charts. Painter will use this as state and it will format
/// chart depending on options.
///
/// [itemOptions] Contains all modifiers for separate bar item
///
/// [behaviour] How chart reacts and sizes itself
///
/// [foregroundDecorations] and [backgroundDecorations] decorations that aren't
/// connected directly to the chart but can show important info (Axis, target line...)
///
/// More different decorations can be added by extending [DecorationPainter]
class ChartState<T> {
  /// Chart state constructor
  ChartState(
    this.data, {
    this.itemOptions = const ItemOptions(geometryPainter: barPainter),
    this.behaviour = const ChartBehaviour(),
    this.strategy = const DefaultDataStrategy(),
    this.backgroundDecorations = const <DecorationPainter>[],
    this.foregroundDecorations = const <DecorationPainter>[],
  })  : assert(data.isNotEmpty, 'No items!'),
        defaultPadding = EdgeInsets.zero,
        defaultMargin = EdgeInsets.zero,
        minValue = _getMinValue<T>(
            strategy.formatDataStrategy(data._items).fold(
                <ChartItem<T?>>[],
                (List<ChartItem<T?>> list, element) =>
                    list..addAll(element)).toList(),
            data.axisMin),
        maxValue = _getMaxValue(
                strategy.formatDataStrategy(data._items).fold(
                    <ChartItem<T?>>[],
                    (List<ChartItem<T?>> list, element) =>
                        list..addAll(element)).toList(),
                data.axisMax) +
            (data.valueAxisMaxOver ?? 0.0) {
    /// Set default padding and margin, decorations padding and margins will be added to this value
    _setUpDecorations();
  }

  /// Create line chart with foreground sparkline decoration and background grid decoration
  factory ChartState.line(
    ChartData<T> data, {
    ItemOptions itemOptions =
        const ItemOptions(geometryPainter: bubblePainter, maxBarWidth: 2.0),
    ChartBehaviour behaviour = const ChartBehaviour(),
    List<DecorationPainter> backgroundDecorations = const <DecorationPainter>[],
    List<DecorationPainter> foregroundDecorations = const <DecorationPainter>[],
  }) {
    return ChartState(
      data,
      itemOptions: itemOptions,
      behaviour: behaviour,
      backgroundDecorations: backgroundDecorations.isEmpty
          ? [GridDecoration()]
          : backgroundDecorations,
      foregroundDecorations: foregroundDecorations.isEmpty
          ? [SparkLineDecoration()]
          : foregroundDecorations,
    );
  }

  /// Create bar chart with background grid decoration
  factory ChartState.bar(
    ChartData<T> data, {
    ItemOptions itemOptions = const ItemOptions(
        geometryPainter: barPainter,
        padding: EdgeInsets.symmetric(horizontal: 4.0)),
    ChartBehaviour behaviour = const ChartBehaviour(),
    List<DecorationPainter> backgroundDecorations = const <DecorationPainter>[],
    List<DecorationPainter> foregroundDecorations = const <DecorationPainter>[],
  }) {
    return ChartState(
      data,
      itemOptions: itemOptions,
      behaviour: behaviour,
      backgroundDecorations: backgroundDecorations.isEmpty
          ? [GridDecoration()]
          : backgroundDecorations,
      foregroundDecorations: foregroundDecorations,
    );
  }

  ChartState._lerp(
    this.data, {
    this.itemOptions = const ItemOptions(geometryPainter: barPainter),
    this.behaviour = const ChartBehaviour(),
    this.backgroundDecorations = const [],
    this.foregroundDecorations = const [],
    this.strategy = const DefaultDataStrategy(),
    required this.defaultMargin,
    required this.defaultPadding,
    required this.maxValue,
    required this.minValue,
  }) {
    _initDecorations();
  }

  // Data layer
  /// [ChartData] data that chart will show
  final ChartData<T> data;

  // Geometry layer
  /// [ItemOptions] define how each item is painted
  final ItemOptions itemOptions;

  /// [ChartBehaviour] define how chart behaves and how it should react
  final ChartBehaviour behaviour;

  // Statistics layer
  /// Data strategy to use on items
  /// Default: [DefaultDataStrategy]
  final DataStrategy strategy;

  /// TODO: Move to aesthetics
  // Scale
  /// Min value that chart should show.
  /// In case chart shouldn't start from 0 use this to specify new min starting point
  /// If data has value that goes below [minValue] then [minValue] is ignored
  late final double minValue;

  /// Max value to show on the chart, in case data has point higher then
  /// specified [maxValue] then [maxValue] is ignored
  late final double maxValue;

  /// ------

  // Theme layer
  /// Decorations for chart background, the go below the items
  final List<DecorationPainter> backgroundDecorations;

  /// Decorations for chart foreground, they are drawn last, and the go above items
  final List<DecorationPainter> foregroundDecorations;

  /// Margin of chart drawing area where items are drawn. This is so decorations
  /// can be placed outside of the chart drawing area without actually scaling the chart.
  EdgeInsets defaultMargin;

  /// Padding is used for decorations that want other decorations to be drawn on them.
  /// Unlike [defaultMargin] decorations can draw inside the padding area.
  EdgeInsets defaultPadding;

  /// Get all decorations. This will return list of [backgroundDecorations] and [foregroundDecorations] as one list.
  List<DecorationPainter> get _allDecorations =>
      [...foregroundDecorations, ...backgroundDecorations];

  /// Set up decorations and calculate chart's [defaultPadding] and [defaultMargin]
  /// Decorations are a bit special, calling init on them with current state
  /// this is required because some decorations need to know some stuff about chart
  /// before being able to tell how much padding or/and margin do they need in
  /// order to lay them out properly
  ///
  /// First init decoration, this will make sure that all decorations are able to calculate their
  /// margin and padding needed
  ///
  /// Add all calculated paddings and margins for current decorations in this state
  /// they will update [defaultMargin] and [defaultPadding] values
  void _setUpDecorations() {
    _initDecorations();
    _getDecorationsPadding();
    _getDecorationsMargin();
  }

  /// Init all decorations, pass current chart state so each decoration can access data it requires
  /// to set up it's padding and margin values
  void _initDecorations() =>
      _allDecorations.forEach((decoration) => decoration.initDecoration(this));

  /// Get total padding needed by all decorations
  void _getDecorationsMargin() => _allDecorations
      .forEach((element) => defaultMargin += element.marginNeeded());

  /// Get total margin needed by all decorations
  void _getDecorationsPadding() => _allDecorations
      .forEach((element) => defaultPadding += element.paddingNeeded());

  List<List<ChartItem<T?>>>? _cachedItems;

  /// Return list as formatted data defined by [DataStrategy]
  List<List<ChartItem<T?>>> get items {
    _cachedItems ??= strategy.formatDataStrategy(data._items);
    return _cachedItems ?? strategy.formatDataStrategy(data._items);
  }

  /// For later in case charts will have to animate between states.
  static ChartState<T?> lerp<T>(ChartState<T?> a, ChartState<T?> b, double t) {
    return ChartState<T?>._lerp(
      ChartData.lerp(a.data, b.data, t),
      behaviour: ChartBehaviour.lerp(a.behaviour, b.behaviour, t),
      itemOptions: a.itemOptions.animateTo(b.itemOptions, t),
      // Find background matches, if found, then animate to them, else just show them.
      backgroundDecorations:
          b.backgroundDecorations.map<DecorationPainter>((e) {
        final _match = a.backgroundDecorations
            .firstWhereOrNull((element) => element.isSameType(e));
        if (_match != null) {
          return _match.animateTo(e, t);
        }

        return e;
      }).toList(),
      // Find foreground matches, if found, then animate to them, else just show them.
      foregroundDecorations: b.foregroundDecorations.map((e) {
        final _match = a.foregroundDecorations
            .firstWhereOrNull((element) => element.isSameType(e));
        if (_match != null) {
          return _match.animateTo(e, t);
        }

        return e;
      }).toList(),

      strategy: t > 0.5 ? b.strategy : a.strategy,
      defaultMargin: EdgeInsets.lerp(a.defaultMargin, b.defaultMargin, t) ??
          EdgeInsets.zero,
      defaultPadding: EdgeInsets.lerp(a.defaultPadding, b.defaultPadding, t) ??
          EdgeInsets.zero,

      /// Those are usually calculated, but we need to have a control over them in the animation
      maxValue: lerpDouble(a.maxValue, b.maxValue, t) ?? b.maxValue,
      minValue: lerpDouble(a.minValue, b.minValue, t) ?? b.minValue,
    );
  }

  /// Get max value of the chart
  /// Max value is max data item from [items] or [ChartOptions.axisMax]
  static double _getMaxValue<T>(
      List<ChartItem<T>> items, double? valueAxisMax) {
    return max(valueAxisMax ?? 0.0, items.map((e) => e.max ?? 0.0).reduce(max));
  }

  /// Get min value of the chart
  /// Min value is min data item from [items] or [ChartOptions.axisMin]
  static double _getMinValue<T>(
      List<ChartItem<T?>> items, double? valueAxisMin) {
    final _minItems = items
        .where((e) =>
            (e.min != null && e.min != 0.0) || (e.min == null && e.max != 0.0))
        .map((e) => e.min ?? e.max ?? double.infinity);
    if (_minItems.isEmpty) {
      return valueAxisMin ?? 0.0;
    }

    return min(valueAxisMin ?? 0.0, _minItems.reduce(min));
  }
}
