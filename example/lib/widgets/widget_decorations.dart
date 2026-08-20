import 'package:charts_painter/chart.dart';
import 'package:flutter/material.dart';

/// Replacements for the decorations that were deprecated in charts_painter 3.x.
///
/// Each one is built on top of [WidgetDecoration], which is the sanctioned way
/// to draw custom overlays on a chart. Keeping them here means the example
/// screens read the same as they did with the old decorations.

/// Inset a decoration builder so its coordinate space matches the chart items.
Widget _inChartArea(ChartState chartState, {required Widget child}) {
  return Padding(
    padding: chartState.defaultMargin + chartState.defaultPadding,
    child: child,
  );
}

/// Draws the value of every item next to it, replacing `ValueDecoration`.
///
/// [alignment] works the same way it did before: `y` shifts the label by whole
/// label heights relative to the item value, so `Alignment.bottomCenter` puts
/// it just below the value line (inside a bar) and `Alignment.topCenter` above.
WidgetDecoration valueLabelsDecoration({
  TextStyle? textStyle,
  Alignment alignment = Alignment.topCenter,
  int listIndex = 0,
  double Function(ChartItem item)? valueGenerator,
  String Function(ChartItem item)? labelGenerator,
  bool hideZeroValues = false,
}) {
  return WidgetDecoration(
    widgetDecorationBuilder:
        (context, chartState, itemWidth, verticalMultiplier) {
      final items = chartState.data.items[listIndex];
      final minValue = chartState.data.minValue;

      return _inChartArea(
        chartState,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            for (var index = 0; index < items.length; index++)
              if (!hideZeroValues ||
                  (items[index].max ?? 0) != 0 ||
                  (items[index].min ?? 0) != 0)
                Positioned(
                  left: (index + alignment.x) * itemWidth,
                  width: itemWidth,
                  bottom: ((valueGenerator?.call(items[index]) ??
                              items[index].max ??
                              0.0) -
                          minValue) *
                      verticalMultiplier,
                  height: 0.0,
                  child: OverflowBox(
                    maxHeight: double.infinity,
                    child: FractionalTranslation(
                      translation: Offset(0.0, alignment.y),
                      child: Text(
                        labelGenerator?.call(items[index]) ??
                            '${(valueGenerator?.call(items[index]) ?? items[index].max ?? 0.0).toInt()}',
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        style: textStyle,
                      ),
                    ),
                  ),
                ),
          ],
        ),
      );
    },
  );
}

/// Draws a horizontal line at [target], replacing `TargetLineDecoration`.
WidgetDecoration targetLineDecoration({
  required double target,
  Color targetLineColor = Colors.red,
  double lineWidth = 2.0,
}) {
  return WidgetDecoration(
    widgetDecorationBuilder:
        (context, chartState, itemWidth, verticalMultiplier) {
      return _inChartArea(
        chartState,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: 0.0,
              right: 0.0,
              bottom: (target - chartState.data.minValue) * verticalMultiplier -
                  lineWidth / 2,
              height: lineWidth,
              child: ColoredBox(color: targetLineColor),
            ),
          ],
        ),
      );
    },
  );
}

/// The color an item should take when it misses [target].
///
/// This used to live on `TargetLineDecoration.getTargetItemColor`.
Color colorForTarget(
  Color defaultColor,
  ChartItem item, {
  required double target,
  Color? colorOverTarget,
  bool isTargetInclusive = true,
}) {
  final value = item.max ?? 0.0;
  final missedTarget = isTargetInclusive ? value > target : value >= target;

  return missedTarget ? (colorOverTarget ?? defaultColor) : defaultColor;
}

/// Rotated label to the left of the chart, replacing
/// `TargetLineLegendDecoration`.
WidgetDecoration targetLineLegendDecoration({
  required String legendDescription,
  required TextStyle legendStyle,
  double legendTarget = 0,
  EdgeInsets padding = EdgeInsets.zero,
}) {
  final legendWidth = (legendStyle.fontSize ?? 0) * 2;

  return WidgetDecoration(
    margin: EdgeInsets.only(left: legendWidth),
    widgetDecorationBuilder:
        (context, chartState, itemWidth, verticalMultiplier) {
      return _inChartArea(
        chartState,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: -legendWidth * 0.75,
              width: 0.0,
              bottom: (legendTarget - chartState.data.minValue) *
                      verticalMultiplier -
                  padding.top,
              height: 0.0,
              child: OverflowBox(
                maxWidth: double.infinity,
                maxHeight: double.infinity,
                alignment: Alignment.topCenter,
                child: RotatedBox(
                  quarterTurns: 3,
                  child: Text(
                    legendDescription,
                    maxLines: 1,
                    style: legendStyle,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}

/// Cupertino (Health app) style selected item marker, replacing
/// `SelectedItemDecoration`.
///
/// Pass a [child] to show your own widget above the selected item instead of
/// the default value chip.
WidgetDecoration selectedItemDecoration(
  int? selectedItem, {
  Color selectedColor = Colors.red,
  Color backgroundColor = Colors.grey,
  TextStyle selectedStyle = const TextStyle(fontSize: 13.0),
  bool showText = true,
  int selectedListIndex = 0,
  Widget? child,
  double topMargin = 0.0,
}) {
  final showsText = showText && child == null;
  final headerHeight = child != null
      ? topMargin
      : (showsText ? (selectedStyle.fontSize ?? 0) * 1.8 : 0.0);

  return WidgetDecoration(
    margin: EdgeInsets.only(top: headerHeight),
    widgetDecorationBuilder:
        (context, chartState, itemWidth, verticalMultiplier) {
      final items = chartState.data.items[selectedListIndex];
      final index = selectedItem;
      if (index == null || index < 0 || index >= items.length) {
        return const SizedBox.shrink();
      }

      final item = items[index];
      if (item.isEmpty || (item.max ?? 0.0) < chartState.data.minValue) {
        return const SizedBox.shrink();
      }

      final itemTop =
          ((item.max ?? 0.0) - chartState.data.minValue) * verticalMultiplier;

      return _inChartArea(
        chartState,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Tint the selected column. `BlendMode.overlay` matches what the
            // old decoration painted and keeps the bar underneath readable.
            if (child == null)
              Positioned(
                left: index * itemWidth,
                width: itemWidth,
                top: 0.0,
                bottom: 0.0,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    backgroundBlendMode: BlendMode.overlay,
                  ),
                  child: const SizedBox.expand(),
                ),
              ),
            if (child != null)
              Positioned(
                left: index * itemWidth,
                width: itemWidth,
                top: -headerHeight,
                height: 0.0,
                child: OverflowBox(
                  maxWidth: double.infinity,
                  maxHeight: double.infinity,
                  alignment: Alignment.topCenter,
                  child: child,
                ),
              )
            else if (showsText) ...[
              // Line from the top of the chart down to the selected item.
              Positioned(
                left: index * itemWidth + itemWidth / 2 - 1.0,
                width: 2.0,
                top: -headerHeight * 0.35,
                bottom: itemTop,
                child: ColoredBox(color: selectedColor),
              ),
              Positioned(
                left: index * itemWidth,
                width: itemWidth,
                top: -headerHeight,
                height: headerHeight,
                child: Center(
                  child: OverflowBox(
                    maxWidth: double.infinity,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: selectedColor,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6.0, vertical: 2.0),
                        child: Text(
                          item.max?.toStringAsFixed(2) ?? '',
                          maxLines: 1,
                          style: selectedStyle,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      );
    },
  );
}
