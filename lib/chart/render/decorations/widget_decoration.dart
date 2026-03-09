part of charts_painter;

typedef WidgetDecorationBuilder<T> = Widget Function(
    BuildContext context, ChartState<T> chartState, double itemWidth, double verticalMultiplier);

/// Show widget as decoration on the chart
///
/// If using this as item that will show values make sure you apply margin from [ChartState.defaultMargin]
/// this will make sure you are in chart area when you draw your decoration.
///
/// Example of drawing TargetLineDecoration with [WidgetDecoration]:
/// ```dart
/// WidgetDecoration(
///  builder: (context, chartState, itemWidth, verticalMultiplier) {
///   return Container(
///
///   // This will make sure that child is in chart area.
///    margin: chartState.defaultMargin,
///    child: Stack(
///     children: [
///
///      // This will show a target line that can also be shown by using [TargetLineDecoration]
///      Positioned(
///       left: 0,
///       right: 0,
///
///       // Show target line at item height of 4
///       bottom: 4 * verticalMultiplier,
///       height: 2,
///       child: Container(color: Colors.red),
///      ),
///     ],
///    ),
///   );
///  },
/// ),
/// ```
///
/// In case you just want to add image or something that is not relevant to current chart data you don't have to set any margins
///
class WidgetDecoration<T> extends DecorationPainter<T> {
  /// Constructor for selected item decoration
  WidgetDecoration({
    required this.widgetDecorationBuilder,
    this.margin = EdgeInsets.zero,
    this.clipToBounds = true,
    this.animatable = true,
  });

  WidgetDecoration._lerp({
    required this.widgetDecorationBuilder,
    required this.margin,
    required this.clipToBounds,
    required this.animatable,
  });

  /// Builder for widget decoration
  final WidgetDecorationBuilder<T> widgetDecorationBuilder;

  final EdgeInsets margin;

  @override
  final bool clipToBounds;

  @override
  final bool animatable;

  @override
  Widget getRenderer(ChartState<T> state) {
    return ChartDecorationChildRenderer(
      state,
      this,
      LayoutBuilder(
        builder: (context, constraints) {
          // Get all the data we need to draw the decoration and pass to the builder
          // This will ensure that we have right data in the builder and that we can show decoration to scale.
          final _size = (state.defaultMargin + state.defaultPadding).deflateSize(constraints.biggest);
          final _listSize = state.data.animatedListSize;
          final _itemWidth = _listSize <= 0 ? 0.0 : _size.width / _listSize;

          final _maxValue = state.data.maxValue - state.data.minValue;
          final _verticalMultiplier = _size.height / max(1, _maxValue);

          return widgetDecorationBuilder(context, state, _itemWidth, _verticalMultiplier);
        },
      ),
    );
  }

  @override
  DecorationPainter<T> animateTo(DecorationPainter<T> endValue, double t) {
    if (endValue is WidgetDecoration<T>) {
      return WidgetDecoration<T>._lerp(
        clipToBounds: t > 0.5 ? endValue.clipToBounds : clipToBounds,
        widgetDecorationBuilder: t > 0.5 ? endValue.widgetDecorationBuilder : widgetDecorationBuilder,
        margin: EdgeInsets.lerp(margin, endValue.margin, t) ?? endValue.margin,
        animatable: endValue.animatable,
      );
    }

    return this;
  }

  @override
  EdgeInsets marginNeeded() {
    return margin;
  }

  @override
  void draw(Canvas canvas, Size size, ChartState state) {
    // NOOP
  }
}
