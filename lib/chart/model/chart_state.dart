part of flutter_charts;

/// Item painter, use [barItemPainter] or [barItemPainter].
/// Custom painter can also be added by extending [ItemPainter]
typedef ChartItemPainter<T> = ItemPainter<T> Function(ChartItem<T> item, ChartState state);

/// Bar painter
ItemPainter<T> barItemPainter<T>(ChartItem<T> item, ChartState<T> state) => BarPainter<T>(item, state);

/// Bubble painter
ItemPainter<T> bubbleItemPainter<T>(ChartItem<T> item, ChartState<T> state) => BubblePainter<T>(item, state);

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
class ChartState<T> {
  ChartState(
    this.items, {
    this.options = const ChartOptions(),
    this.itemOptions = const ChartItemOptions(),
    this.behaviour = const ChartBehaviour(),
    this.backgroundDecorations = const <DecorationPainter>[],
    this.foregroundDecorations = const <DecorationPainter>[],
    this.itemPainter = barItemPainter,
  })  : assert(items.isNotEmpty, 'No items!'),
        assert((options?.padding?.vertical ?? 0.0) == 0.0, 'Chart padding cannot be vertical!'),
        minValue = _getMinValue(
            items.fold(<ChartItem<T>>[], (List<ChartItem<T>> list, element) => list..addAll(element)).toList(),
            options),
        maxValue = _getMaxValue(
            items.fold(<ChartItem<T>>[], (List<ChartItem<T>> list, element) => list..addAll(element)).toList(),
            options) {
    /// Set default padding and margin, decorations padding and margins will be added to this value
    defaultPadding = options?.padding ?? EdgeInsets.zero;
    defaultMargin = EdgeInsets.zero;
    _setUpDecorations();
  }

  factory ChartState.fromList(
    List<ChartItem<T>> values, {
    ChartOptions options = const ChartOptions(),
    ChartItemOptions itemOptions = const ChartItemOptions(),
    ChartBehaviour behaviour = const ChartBehaviour(),
    List<DecorationPainter> backgroundDecorations = const <DecorationPainter>[],
    List<DecorationPainter> foregroundDecorations = const <DecorationPainter>[],
    ChartItemPainter itemPainter = barItemPainter,
  }) =>
      ChartState<T>(
        [values],
        options: options,
        itemOptions: itemOptions,
        behaviour: behaviour,
        foregroundDecorations: foregroundDecorations,
        backgroundDecorations: backgroundDecorations,
        itemPainter: itemPainter,
      );

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
    this.itemPainter = barItemPainter,
  }) {
    _initDecorations();
  }

  final List<List<ChartItem<T>>> items;

  final ChartItemPainter itemPainter;
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
  static double _getMaxValue<T>(List<ChartItem<T>> items, ChartOptions options) {
    return max(options?.valueAxisMax ?? 0.0, items.map((e) => e.max ?? 0.0).reduce(max));
  }

  /// Get min value of the chart
  /// Min value is min data item from [items] or [ChartOptions.valueAxisMin]
  static double _getMinValue<T>(List<ChartItem<T>> items, ChartOptions options) {
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
  static ChartState<T> lerp<T>(ChartState<T> a, ChartState<T> b, double t) {
    return ChartState<T>._lerp(
      ChartItemsLerp().lerpValues<T>(a.items, b.items, t),
      options: ChartOptions.lerp(a.options, b.options, t),
      behaviour: ChartBehaviour.lerp(a.behaviour, b.behaviour, t),
      itemOptions: ChartItemOptions.lerp(a.itemOptions, b.itemOptions, t),
      // Find background matches, if found, then animate to them, else just show them.
      backgroundDecorations: b.backgroundDecorations.map((e) {
        final DecorationPainter _match =
            a.backgroundDecorations.firstWhere((element) => element.isSameType(e), orElse: () => null);
        if (_match != null) {
          return _match.animateTo(e, t);
        }

        return e;
      }).toList(),
      // Find foreground matches, if found, then animate to them, else just show them.
      foregroundDecorations: b.foregroundDecorations.map((e) {
        final DecorationPainter _match =
            a.foregroundDecorations.firstWhere((element) => element.isSameType(e), orElse: () => null);
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

      // Lerp missing
      itemPainter: t < 0.5 ? a.itemPainter : b.itemPainter,
    );
  }
}

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
    final BarValue<T> _emptyValue = BarValue<T>(0.0);

    return List<ChartItem<T>>.generate(_listLength.ceil(), (int index) {
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
      return _emptyValue.animateFrom(a[index], _value);
    });
  }
}
