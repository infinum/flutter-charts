part of flutter_charts;

typedef AxisGenerator = double Function(ChartItem item);

/// Main state of the charts. Painter will use this as state and it will format chart depending
/// on options.
///
/// [options] Modifiers for chart
///
/// [itemOptions] Contains all modifiers for separate bar item
///
/// [foregroundDecorations] and [backgroundDecorations] decorations that aren't connected directly to the
/// chart but can show important info (Axis, target line...)
///
/// More different decorations can be added by extending [DecorationPainter]
class ChartState {
  ChartState(
    this.items, {
    this.options = const ChartOptions(),
    this.itemOptions = const ChartItemOptions(),
    this.behaviour = const ChartBehaviour(),
    this.backgroundDecorations = const [],
    this.foregroundDecorations = const [],
  })  : assert((options?.padding?.vertical ?? 0.0) == 0.0, 'Chart padding cannot be vertical!'),
        minValue = _getMinValue(items, options),
        maxValue = _getMaxValue(items, options) {
    /// Set default padding and margin, decorations padding and margins will be added to this value
    defaultPadding = options?.padding ?? EdgeInsets.zero;
    defaultMargin = EdgeInsets.zero;
    _setUpDecorations();
  }

  ChartState._lerp(
    this.items, {
    this.options = const ChartOptions(),
    this.itemOptions = const ChartItemOptions(),
    this.behaviour = const ChartBehaviour(),
    this.backgroundDecorations = const [],
    this.foregroundDecorations = const [],
    this.maxValue,
    this.minValue,
    this.defaultMargin,
    this.defaultPadding,
  });

  final List<ChartItem> items;

  final ChartOptions options;
  final ChartItemOptions itemOptions;
  final ChartBehaviour behaviour;
  final List<DecorationPainter> backgroundDecorations;
  final List<DecorationPainter> foregroundDecorations;

  final double minValue;
  final double maxValue;

  /// Margin of chart drawing area where items are drawn. This is so decorations
  /// can be placed outside of the chart drawing area without actually scaling the chart.
  EdgeInsets defaultMargin;

  /// Padding is used for decorations that want other decorations to be drawn on them.
  /// Unlike [defaultMargin] decorations can draw inside the padding area.
  EdgeInsets defaultPadding;

  List<DecorationPainter> get allDecorations => [...foregroundDecorations, ...backgroundDecorations];

  /// Get max value of the chart
  /// Max value is max data item from [items] or [ChartOptions.valueAxisMax]
  static double _getMaxValue(List<ChartItem> items, ChartOptions options) {
    return max(options?.valueAxisMax ?? 0.0, items.map((e) => e.max ?? 0.0).reduce(max));
  }

  /// Get min value of the chart
  /// Min value is min data item from [items] or [ChartOptions.valueAxisMin]
  static double _getMinValue(List<ChartItem> items, ChartOptions options) {
    final _minItems = items
        .where((e) => (e.min != null && e.min != 0.0) || (e.min == null && e.max != 0.0))
        .map((e) => e.min ?? e.max ?? double.infinity);
    if (_minItems.isEmpty) {
      return options?.valueAxisMin ?? 0.0;
    }

    return min(options?.valueAxisMin ?? 0.0, _minItems.reduce(min));
  }

  /// Set up decorations and calculate chart's [defaultPadding] and [defaultMargin]
  /// Decorations are a bit special, calling init on them with current state
  /// this is required because some decorations need to know some stuff about chart
  /// before being able to tell how much padding or/and margin do they need in order to lay them out properly
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
  void _initDecorations() => allDecorations.forEach((decoration) => decoration.initDecoration(this));

  /// Get total padding needed by all decorations
  void _getDecorationsMargin() => allDecorations.forEach((element) => defaultMargin += element.marginNeeded());

  /// Get total margin needed by all decorations
  void _getDecorationsPadding() => allDecorations.forEach((element) => defaultPadding += element.paddingNeeded());

  /// For later in case charts will have to animate between states.
  static ChartState lerp(ChartState a, ChartState b, double t) {
    return ChartState._lerp(
      ChartItemsLerp().lerpValues(a.items, b.items, t),
      options: ChartOptions.lerp(a.options, b.options, t),
      behaviour: ChartBehaviour.lerp(a.behaviour, b.behaviour, t),
      itemOptions: ChartItemOptions.lerp(a.itemOptions, b.itemOptions, t),
      // Find background matches, if found, then animate to them, else just show them.
      backgroundDecorations: b.backgroundDecorations.map((e) {
        final DecorationPainter _match =
            a.backgroundDecorations.firstWhere((element) => element.runtimeType == e.runtimeType, orElse: () => null);
        if (_match != null) {
          return _match.animateTo(e, t);
        }

        return e;
      }).toList(),
      // Find foreground matches, if found, then animate to them, else just show them.
      foregroundDecorations: b.foregroundDecorations.map((e) {
        final DecorationPainter _match =
            a.foregroundDecorations.firstWhere((element) => element.runtimeType == e.runtimeType, orElse: () => null);
        if (_match != null) {
          return _match.animateTo(e, t);
        }

        return e;
      }).toList(),

      /// Those are usually calculated, but we need to have a control over them in the animation
      maxValue: lerpDouble(a.maxValue, b.maxValue, t),
      minValue: lerpDouble(a.minValue, b.minValue, t),
      defaultMargin: EdgeInsets.lerp(a.defaultMargin, b.defaultMargin, t),
      defaultPadding: EdgeInsets.lerp(a.defaultPadding, b.defaultPadding, t),
    );
  }
}

class ChartItemsLerp {
  List<ChartItem> lerpValues(List<ChartItem> a, List<ChartItem> b, double t) {
    /// Get list length in animation, we will add the items in steps.
    final double _listLength = lerpDouble(a.length, b.length, t);

    /// Empty value for generated list.
    final BubbleValue _emptyValue = BubbleValue(0.0);

    /// Generate new list fot animation step, add items depending on current [_listLength]
    return List<ChartItem>.generate(_listLength.ceil(), (int index) {
      // If old list and new list have value at [index], then just animate from,
      // old list value to the new value
      if (index < a.length && index < b.length) {
        return b[index].animateFrom(a[index], t);
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
        return b[index].animateFrom(_emptyValue, _value);
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
      return a[index].animateTo(_emptyValue, _value);
    });
  }
}
