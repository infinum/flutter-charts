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
///

typedef ItemOptionsBuilder = ItemOptions Function(int);

class ChartState<T> {
  /// Chart state constructor
  ChartState(
    this.data, {
    ItemOptions itemOptions = const BarItemOptions(),
    ItemOptionsBuilder? itemOptionsBuilder,
    this.behaviour = const ChartBehaviour(),
    this.backgroundDecorations = const <DecorationPainter>[],
    this.foregroundDecorations = const <DecorationPainter>[],
    ChartDataRendererFactory<T?>? dataRenderer,
  })  : assert(data.isNotEmpty, 'No items!'),
        defaultPadding = EdgeInsets.zero,
        itemOptionsBuilder = itemOptionsBuilder ?? ((int i) => itemOptions),
        defaultMargin = EdgeInsets.zero,
        dataRenderer = dataRenderer ??
            defaultItemRenderer<T>(
                data.items.mapIndexed((e, _) => (itemOptionsBuilder ?? ((int i) => itemOptions))(e)).toList()) {
    /// Set default padding and margin, decorations padding and margins will be added to this value
    _setUpDecorations();
  }

  /// Create line chart with foreground sparkline decoration and background grid decoration
  factory ChartState.line(
    ChartData<T> data, {
    ItemOptionsBuilder? itemOptionsBuilder,
    ChartBehaviour behaviour = const ChartBehaviour(),
    List<DecorationPainter> backgroundDecorations = const <DecorationPainter>[],
    List<DecorationPainter> foregroundDecorations = const <DecorationPainter>[],
  }) {
    return ChartState(
      data,
      itemOptionsBuilder: itemOptionsBuilder ?? (index) => BubbleItemOptions(maxBarWidth: 2.0),
      behaviour: behaviour,
      backgroundDecorations: backgroundDecorations.isEmpty ? [GridDecoration()] : backgroundDecorations,
      foregroundDecorations: foregroundDecorations.isEmpty ? [SparkLineDecoration()] : foregroundDecorations,
    );
  }

  /// Create bar chart with background grid decoration
  factory ChartState.bar(
    ChartData<T> data, {
    ItemOptionsBuilder? itemOptionsBuilder,
    ChartBehaviour behaviour = const ChartBehaviour(),
    List<DecorationPainter> backgroundDecorations = const <DecorationPainter>[],
    List<DecorationPainter> foregroundDecorations = const <DecorationPainter>[],
  }) {
    return ChartState(
      data,
      itemOptionsBuilder:
          itemOptionsBuilder ?? (index) => BarItemOptions(padding: EdgeInsets.symmetric(horizontal: 4.0)),
      behaviour: behaviour,
      backgroundDecorations: backgroundDecorations.isEmpty ? [GridDecoration()] : backgroundDecorations,
      foregroundDecorations: foregroundDecorations,
    );
  }

  ChartState._lerp(
    this.data, {
    required this.itemOptionsBuilder,
    this.behaviour = const ChartBehaviour(),
    this.backgroundDecorations = const [],
    this.foregroundDecorations = const [],
    required this.dataRenderer,
    required this.defaultMargin,
    required this.defaultPadding,
  }) {
    _initDecorations();
  }

  // Data layer
  /// [ChartData] data that chart will show
  final ChartData<T> data;

  /// How is data rendered on the screen, by default it uses [ChartLinearDataRenderer]
  final ChartDataRendererFactory<T?> dataRenderer;

  // Geometry layer
  /// [ItemOptions] define how each item is painted
  final ItemOptionsBuilder itemOptionsBuilder;

  /// [ChartBehaviour] define how chart behaves and how it should react
  final ChartBehaviour behaviour;

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
  List<DecorationPainter> get _allDecorations => [...foregroundDecorations, ...backgroundDecorations];

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
  void _initDecorations() => _allDecorations.forEach((decoration) => decoration.initDecoration(this));

  /// Get total padding needed by all decorations
  void _getDecorationsMargin() => _allDecorations.forEach((element) => defaultMargin += element.marginNeeded());

  /// Get total margin needed by all decorations
  void _getDecorationsPadding() => _allDecorations.forEach((element) => defaultPadding += element.paddingNeeded());

  /// For later in case charts will have to animate between states.
  static ChartState<T?> lerp<T>(ChartState<T?> a, ChartState<T?> b, double t) {
    return ChartState<T?>._lerp(
      ChartData.lerp(a.data, b.data, t),
      behaviour: ChartBehaviour.lerp(a.behaviour, b.behaviour, t),
      itemOptionsBuilder: ItemOptionsBuilderLerp.lerp(a, b, t)!,
      // Find background matches, if found, then animate to them, else just show them.
      backgroundDecorations: b.backgroundDecorations.map<DecorationPainter>((e) {
        final _match = a.backgroundDecorations.firstWhereOrNull((element) => element.isSameType(e));
        if (_match != null) {
          return _match.animateTo(e, t);
        }

        return e;
      }).toList(),
      // Find foreground matches, if found, then animate to them, else just show them.
      foregroundDecorations: b.foregroundDecorations.map((e) {
        final _match = a.foregroundDecorations.firstWhereOrNull((element) => element.isSameType(e));
        if (_match != null) {
          return _match.animateTo(e, t);
        }

        return e;
      }).toList(),

      defaultMargin: EdgeInsets.lerp(a.defaultMargin, b.defaultMargin, t) ?? EdgeInsets.zero,
      defaultPadding: EdgeInsets.lerp(a.defaultPadding, b.defaultPadding, t) ?? EdgeInsets.zero,
      dataRenderer: t > 0.5 ? b.dataRenderer : a.dataRenderer,
    );
  }

  static ChartDataRendererFactory<T?> defaultItemRenderer<T>(List<ItemOptions> itemOptions) {
    return (chartState) => ChartLinearDataRenderer<T?>(
        chartState,
        chartState.data.items
            .mapIndexed(
              (key, items) => items
                  .map((e) =>
                      LeafChartItemRenderer(e, chartState.data, chartState.itemOptionsBuilder(key), arrayKey: key))
                  .toList(),
            )
            .expand((element) => element)
            .toList());
  }

  static ChartDataRendererFactory<T?> widgetItemRenderer<T>(
      List<ItemOptions> itemOptions, Widget Function(ChartItem<T?> item, int itemKey, int listKey) childBuilder) {
    return (chartState) => ChartLinearDataRenderer<T?>(
        chartState,
        chartState.data.items
            .mapIndexed(
              (key, items) => items
                  .map((e) => ChildChartItemRenderer<T?>(
                        e,
                        chartState.data,
                        itemOptions[key],
                        arrayKey: key,
                        child: childBuilder(e, items.indexOf(e), key),
                      ))
                  .toList(),
            )
            .expand((element) => element)
            .toList());
  }
}

/// Lerp [ColorForKey] function to get color for key in animation
class ItemOptionsBuilderLerp {
  /// Make new function that will return lerp color based on [a.colorForKey] and [b.colorForKey]
  static ItemOptionsBuilder? lerp(ChartState a, ChartState b, double t) {
    return (int key) {
      final _aOptions = a.itemOptionsBuilder(key);
      final _bOptions = b.itemOptionsBuilder(key);

      return _aOptions.animateTo(_bOptions, t);
    };
  }
}
