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

class ChartState<T> {
  /// Chart state constructor
  ChartState({
    required this.data,
    required this.itemOptions,
    this.behaviour = const ChartBehaviour(),
    this.backgroundDecorations = const <DecorationPainter>[],
    this.foregroundDecorations = const <DecorationPainter>[],
  })
      : assert(data.isNotEmpty, 'No items!'),
        defaultPadding = EdgeInsets.zero,
        defaultMargin = EdgeInsets.zero,
        dataRenderer = (itemOptions is WidgetItemOptions
            ? _widgetItemRenderer(itemOptions)
            : _defaultItemRenderer<T>(itemOptions)) {
    /// Set default padding and margin, decorations padding and margins will be added to this value
    _setUpDecorations();
  }

  /// Create line chart with foreground sparkline decoration and background grid decoration
  factory ChartState.line(ChartData<T> data, {
    required BubbleItemOptions itemOptions,
    ChartBehaviour behaviour = const ChartBehaviour(),
    List<DecorationPainter> backgroundDecorations = const <DecorationPainter>[],
    List<DecorationPainter> foregroundDecorations = const <DecorationPainter>[],
  }) {
    return ChartState(
      data: data,
      itemOptions: itemOptions,
      behaviour: behaviour,
      backgroundDecorations: backgroundDecorations.isEmpty ? [GridDecoration()] : backgroundDecorations,
      foregroundDecorations: foregroundDecorations.isEmpty ? [SparkLineDecoration()] : foregroundDecorations,
    );
  }

  /// Create bar chart with background grid decoration
  factory ChartState.bar(ChartData<T> data, {
    required BarItemOptions itemOptions,
    ChartBehaviour behaviour = const ChartBehaviour(),
    List<DecorationPainter> backgroundDecorations = const <DecorationPainter>[],
    List<DecorationPainter> foregroundDecorations = const <DecorationPainter>[],
  }) {
    return ChartState(
      data: data,
      itemOptions: itemOptions,
      behaviour: behaviour,
      backgroundDecorations: backgroundDecorations.isEmpty ? [GridDecoration()] : backgroundDecorations,
      foregroundDecorations: foregroundDecorations,
    );
  }

  ChartState._lerp(this.data, {
    this.behaviour = const ChartBehaviour(),
    this.backgroundDecorations = const [],
    this.foregroundDecorations = const [],
    required this.dataRenderer,
    required this.defaultMargin,
    required this.defaultPadding,
    required this.itemOptions,
  }) {
    _initDecorations();
  }

  // Data layer
  /// [ChartData] data that chart will show
  final ChartData<T> data;

  /// How is data rendered on the screen, by default it uses [ChartLinearDataRenderer]
  final ChartDataRendererFactory<T?> dataRenderer;

  // Geometry layer
  // Todo: add comment
  final ItemOptions itemOptions;

  /// [ChartBehaviour] define how chart behaves and how it should react
  final ChartBehaviour behaviour;

  // Theme layer
  /// Decorations for chart background, the go below the items
  final List<DecorationPainter> backgroundDecorations;

  /// Decorations for chart foreground, they are drawn last, and the go above items
  final List<DecorationPainter> foregroundDecorations;

  /// Margin of chart drawing area where items are drawn.
  ///
  /// Whole chart and all items will move with margin
  EdgeInsets defaultMargin;

  /// Padding is used for decorations that want other decorations to be drawn on them.
  /// Unlike [defaultMargin] some decorations don't need to respect padding.
  /// Sometimes decorations paint over this padding.
  ///
  /// Whole chart and all items will move with margin
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
      itemOptions: a.itemOptions.animateTo(b.itemOptions, t),
    );
  }

  /// Default item renderer will use [LeafChartItemRenderer] to show items. Items are sized and customized with
  /// [ItemOptions].
  ///
  /// If you need more customization of the individual chart items see [_widgetItemRenderer]
  static ChartDataRendererFactory<T?> _defaultItemRenderer<T>(ItemOptions itemOptions) {
    return (chartState) {
      return ChartLinearDataRenderer<T?>(
          chartState,
          chartState.data.items
              .mapIndexed(
                (lineKey, items) =>
                items
                    .mapIndexed((itemKey, item) =>
                    LeafChartItemRenderer(
                      item,
                      chartState.data,
                      itemOptions,
                      itemKey: itemKey,
                      listKey: lineKey,
                      drawDataItem:
                      itemOptions.itemBuilder(ItemBuilderData<T?>(item, itemKey, lineKey)) as DrawDataItem,
                    ))
                    .toList(),
          )
              .expand((element) => element)
              .toList());
    };
  }

  /// It can render chart items as widgets, and it only accepts [WidgetItemOptions] since it needs the
  /// [WidgetItemOptions.widgetItemBuilder] to build the chart item widgets.
  static ChartDataRendererFactory<T?> _widgetItemRenderer<T>(WidgetItemOptions itemOptions) {
    return (chartState) =>
        ChartLinearDataRenderer<T>(
            chartState,
            chartState.data.items
                .mapIndexed(
                  (lineKey, items) {
                return items
                    .mapIndexed(
                      (itemKey, e) =>
                      ChildChartItemRenderer<T?>(
                        e,
                        chartState.data,
                        itemOptions,
                        arrayKey: lineKey,
                        child: itemOptions.widgetItemBuilder(ItemBuilderData<T?>(e, itemKey, lineKey)),
                      ),
                )
                    .toList();
              },
            )
                .expand((element) => element)
                .toList());
  }
}
