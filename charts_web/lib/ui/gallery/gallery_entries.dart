import 'package:charts_painter/chart.dart';
import 'package:charts_web/ui/gallery/gallery_entry.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:charts_web/ui/playground/decorations/presenters/decorations_grid_presenter.dart';
import 'package:charts_web/ui/playground/decorations/presenters/decorations_horizontal_axis_presenter.dart';
import 'package:charts_web/ui/playground/decorations/presenters/decorations_sparkline_presenter.dart';
import 'package:charts_web/ui/playground/decorations/presenters/decorations_vertical_axis_presenter.dart';
import 'package:charts_web/ui/playground/decorations/presenters/decorations_widget_presenter.dart';
import 'package:charts_web/ui/playground/presenter/chart_decorations_presenter.dart';
import 'package:charts_web/ui/playground/presenter/chart_state_presenter.dart';
import 'package:material_ui/material_ui.dart';

const Color _red = Color(0xFFD8262C);
const Color _sand = Color(0xFFD9A866);
const Color _plum = Color(0xFF916794);
const Color _blue = Color(0xFF6479C3);
const Color _green = Color(0xFF5A8772);

const List<Color> _palette = [_red, _sand, _plum, _blue, _green];

/// Axis text is painted by the chart, so it cannot inherit the text theme.
/// Without an explicit colour the library default paints black, which is
/// invisible in dark mode.
TextStyle _axisLabelStyle(BuildContext context) => TextStyle(
      fontSize: 12,
      color: Theme.of(context).colorScheme.onSurface,
    );

/// Applies the parts every template shares. Without this each entry drifted
/// from its own preview: the playground defaults to StackDataStrategy and 2px
/// padding, which almost no preview uses.
ChartStatePresenter _applyBase(
  WidgetRef ref,
  List<num> values, {
  Color? color,
  double padding = 2,
  double maxOver = 2,
}) {
  final presenter = ref.read(chartStatePresenter)
    ..updateData([_items(values)])
    ..updateDataStrategy(const DefaultDataStrategy(stackMultipleValues: true))
    ..updateChartItemPadding(EdgeInsets.symmetric(horizontal: padding))
    ..updateValueAxisMaxOver(maxOver.toDouble());

  if (color != null) presenter.updateListColor(color, 0);

  return presenter;
}

const LinearGradient _sparklineGradient = LinearGradient(
  colors: [Color(0x66D8262C), Color(0x00D8262C)],
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
);

List<ChartItem<void>> _items(List<num> values) =>
    values.map((value) => ChartItem<void>(value.toDouble())).toList();

// Top-level builders so the bar item options above can stay const.
BarItem _redBar(ItemBuilderData data) => const BarItem(color: _red);
BarItem _blueBar(ItemBuilderData data) => const BarItem(color: _blue);
BarItem _sandBar(ItemBuilderData data) => const BarItem(color: _sand);
/// The target the 'target-line' entry marks, in data units.
const double _target = 7;

BarItem _overTargetBar(ItemBuilderData data) =>
    BarItem(color: (data.item.max ?? 0) > _target ? _red : _green);

BarItem _roundedBar(ItemBuilderData data) => const BarItem(
      color: _green,
      radius: BorderRadius.vertical(top: Radius.circular(8)),
    );

BarItem _gradientBar(ItemBuilderData data) => const BarItem(
      // The gradient covers the fill, but a colour is still worth setting as
      // the fallback for anything that cannot draw the gradient.
      color: _red,
      gradient: LinearGradient(
        colors: [_red, _blue],
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
      ),
    );

BarItem _seriesBar(ItemBuilderData data) =>
    BarItem(color: _palette[data.listIndex % _palette.length]);

final List<GalleryEntry> galleryEntries = [
  GalleryEntry(
    id: 'simple-bar',
    title: 'Weekly activity',
    blurb: 'One bar per day with a light grid behind it. The default shape '
        'for any "last 7 days" card.',
    tags: const ['bar', 'decoration'],
    useCase: 'Step counts, sessions, orders per day — anything counted over a '
        'short, fixed window.',
    customization: const [
      'Swap the bar colour in barItemBuilder, or vary it per item from '
          'data.item.max to highlight outliers.',
      'showVerticalGrid: true adds column separators when days need dividing.',
      'Drop padding to let bars touch, raise it for an airier card.',
    ],
    buildChart: (context) => Chart<void>(
      state: ChartState<void>(
        data: ChartData.fromList(_items([4, 6, 3, 6, 7, 9, 3, 2]),
            valueAxisMaxOver: 2),
        itemOptions: const BarItemOptions(
          padding: EdgeInsets.symmetric(horizontal: 2),
          barItemBuilder: _redBar,
        ),
        backgroundDecorations: [
          GridDecoration(
            showVerticalGrid: false,
            gridColor: Theme.of(context).colorScheme.outlineVariant,
          ),
        ],
      ),
    ),
    snippet: '''ChartState<void>(
  data: ChartData.fromList(
    [4, 6, 3, 6, 7, 9, 3, 2]
        .map((e) => ChartItem<void>(e.toDouble()))
        .toList(),
    valueAxisMaxOver: 2,
  ),
  itemOptions: BarItemOptions(
    padding: EdgeInsets.symmetric(horizontal: 2),
    barItemBuilder: (_) => const BarItem(color: Color(0xFFD8262C)),
  ),
  backgroundDecorations: [
    GridDecoration(showVerticalGrid: false),
  ],
)''',
    applyToPlayground: (ref) {
      _applyBase(ref, [4, 6, 3, 6, 7, 9, 3, 2], color: _red, padding: 2);
      ref
          .read(chartDecorationsPresenter)
          .addDecoration(GridDecoration(), layer: DecorationLayer.background);
      ref.read(decorationGridPresenter(0)).updateShowVerticalGrid(false);
    },
  ),
  GalleryEntry(
    id: 'stacked-bar',
    title: 'Revenue by channel',
    blurb: 'Three series stacked into one bar per period, so the total and '
        'the split read at once.',
    tags: const ['bar', 'stacked'],
    useCase: 'Revenue or traffic split by source, storage by file type, time '
        'by project.',
    customization: const [
      'palette[data.listIndex] gives each channel its colour; use your brand '
          'ramp here.',
      'Switch to DefaultDataStrategy(stackMultipleValues: false) to compare '
          'channels side by side instead of stacked.',
      'Add a legend above the chart in your own widgets — the chart draws the '
          'bars, not the key.',
    ],
    buildChart: (context) => Chart<void>(
      state: ChartState<void>(
        data: ChartData(
          [
            _items([3, 5, 2, 4, 6]),
            _items([2, 1, 4, 2, 3]),
            _items([1, 3, 1, 3, 2]),
          ],
          dataStrategy: const StackDataStrategy(),
          valueAxisMaxOver: 2,
        ),
        itemOptions: const BarItemOptions(
          padding: EdgeInsets.symmetric(horizontal: 4),
          barItemBuilder: _seriesBar,
        ),
      ),
    ),
    snippet: '''ChartState<void>(
  data: ChartData(
    [seriesA, seriesB, seriesC],
    dataStrategy: const StackDataStrategy(),
    valueAxisMaxOver: 2,
  ),
  itemOptions: BarItemOptions(
    padding: const EdgeInsets.symmetric(horizontal: 4),
    barItemBuilder: (data) => BarItem(
      color: palette[data.listIndex % palette.length],
    ),
  ),
)''',
    applyToPlayground: (ref) {
      final presenter =
          _applyBase(ref, [3, 5, 2, 4, 6], color: _red, padding: 4);
      presenter.addDataList(_items([2, 1, 4, 2, 3]));
      presenter.addDataList(_items([1, 3, 1, 3, 2]));
      presenter.updateDataStrategy(const StackDataStrategy());
    },
  ),
  GalleryEntry(
    id: 'grouped-bar',
    title: 'This year vs last year',
    blurb: 'Two series side by side in each slot, the standard period-over- '
        'period comparison.',
    tags: const ['bar', 'stacked'],
    useCase: 'Year-on-year sales, budget against actual, A/B results.',
    customization: const [
      'multiValuePadding controls the gap inside a pair; padding controls the '
          'gap between pairs.',
      'Two colours is usually right here — a muted one for last year, your '
          'accent for this year.',
      'Set maxBarWidth so pairs stay readable when there are few periods.',
    ],
    buildChart: (context) => Chart<void>(
      state: ChartState<void>(
        data: ChartData(
          [
            _items([3, 5, 2, 4, 6]),
            _items([2, 1, 4, 2, 3]),
          ],
          dataStrategy: const DefaultDataStrategy(stackMultipleValues: false),
          valueAxisMaxOver: 2,
        ),
        itemOptions: const BarItemOptions(
          padding: EdgeInsets.symmetric(horizontal: 4),
          multiValuePadding: EdgeInsets.symmetric(horizontal: 1),
          barItemBuilder: _seriesBar,
        ),
      ),
    ),
    snippet: '''ChartState<void>(
  data: ChartData(
    [seriesA, seriesB],
    dataStrategy: const DefaultDataStrategy(stackMultipleValues: false),
    valueAxisMaxOver: 2,
  ),
  itemOptions: BarItemOptions(
    padding: const EdgeInsets.symmetric(horizontal: 4),
    multiValuePadding: const EdgeInsets.symmetric(horizontal: 1),
    barItemBuilder: (data) => BarItem(
      color: palette[data.listIndex % palette.length],
    ),
  ),
)''',
    applyToPlayground: (ref) {
      final presenter =
          _applyBase(ref, [3, 5, 2, 4, 6], color: _red, padding: 4);
      presenter.addDataList(_items([2, 1, 4, 2, 3]));
      presenter.updateStackMultipleValues(false);
      presenter.updateMultiValuePadding(
          const EdgeInsets.symmetric(horizontal: 1));
    },
  ),
  GalleryEntry(
    id: 'sparkline',
    title: 'Trend sparkline',
    blurb: 'A filled line with no items at all, sized to sit inside a KPI '
        'tile.',
    tags: const ['line', 'decoration'],
    useCase: 'The small trend line under a big number on a dashboard tile.',
    customization: const [
      'Items are zero-width on purpose; give them a size to show points on '
          'the line as well.',
      'fill: false leaves a plain stroke; smoothPoints: false makes it '
          'angular.',
      'The gradient fades the fill to transparent — recolour both stops to '
          'match the tile.',
    ],
    buildChart: (context) => Chart<void>(
      state: ChartState<void>(
        data: ChartData.fromList(_items([2, 7, 2, 4, 7, 6, 2, 5, 4]),
            valueAxisMaxOver: 2),
        // BubbleItemOptions has no const constructor, unlike BarItemOptions.
        itemOptions: BubbleItemOptions(
          maxBarWidth: 0,
          minBarWidth: 0,
          bubbleItemBuilder: (_) => const BubbleItem(color: Color(0x00000000)),
        ),
        backgroundDecorations: [
          SparkLineDecoration(
            fill: true,
            smoothPoints: true,
            lineWidth: 2,
            lineColor: _red,
            gradient: const LinearGradient(
              colors: [Color(0x66D8262C), Color(0x00D8262C)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ],
      ),
    ),
    snippet: '''ChartState<void>(
  data: ChartData.fromList(values, valueAxisMaxOver: 2),
  itemOptions: BubbleItemOptions(
    maxBarWidth: 0,
    minBarWidth: 0,
    bubbleItemBuilder: (_) => const BubbleItem(color: Color(0x00000000)),
  ),
  backgroundDecorations: [
    SparkLineDecoration(
      fill: true,
      smoothPoints: true,
      lineWidth: 2,
      lineColor: Color(0xFFD8262C),
      gradient: LinearGradient(
        colors: [Color(0x66D8262C), Color(0x00D8262C)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
    ),
  ],
)''',
    applyToPlayground: (ref) {
      _applyBase(ref, [2, 7, 2, 4, 7, 6, 2, 5, 4], padding: 0)
          .updateItemPainter(SelectedPainter.none);
      ref.read(chartDecorationsPresenter).addDecoration(SparkLineDecoration(),
          layer: DecorationLayer.background);
      ref.read(decorationSparkLinePresenter(0))
        ..updateFilled(true)
        ..updateSmoothPoints(true)
        ..updateLineWidth(2)
        ..updateColor(_red)
        ..updateGradient(_sparklineGradient);
    },
  ),
  GalleryEntry(
    id: 'bubble',
    title: 'Readings over time',
    blurb: 'A point per reading rather than a bar, with a grid for reference.',
    tags: const ['bubble'],
    useCase: 'Sensor readings, weights, prices — sampled values where the '
        'shape matters more than the magnitude.',
    customization: const [
      'min and max on ChartItem are equal here, which is what makes a point '
          'rather than a column.',
      'maxBarWidth and minBarWidth set the dot size; keep them equal for '
          'uniform dots.',
      'Add a SparkLineDecoration behind the points to join them up.',
    ],
    buildChart: (context) => Chart<void>(
      state: ChartState<void>(
        data: ChartData.fromList(
          [3, 6, 2, 8, 5, 7, 4]
              .map((value) =>
                  ChartItem<void>(value.toDouble(), min: value.toDouble()))
              .toList(),
          valueAxisMaxOver: 2,
        ),
        itemOptions: BubbleItemOptions(
          maxBarWidth: 12,
          minBarWidth: 12,
          bubbleItemBuilder: (_) => const BubbleItem(color: _plum),
        ),
        backgroundDecorations: [
          GridDecoration(
            gridColor: Theme.of(context).colorScheme.outlineVariant,
          ),
        ],
      ),
    ),
    snippet: '''ChartState<void>(
  data: ChartData.fromList(
    values.map((v) => ChartItem<void>(v, min: v)).toList(),
    valueAxisMaxOver: 2,
  ),
  itemOptions: BubbleItemOptions(
    maxBarWidth: 12,
    minBarWidth: 12,
    bubbleItemBuilder: (_) => const BubbleItem(color: Color(0xFF916794)),
  ),
  backgroundDecorations: [GridDecoration()],
)''',
    applyToPlayground: (ref) {
      _applyBase(ref, [3, 6, 2, 8, 5, 7, 4], color: _plum, padding: 0)
        ..updateItemPainter(SelectedPainter.bubble)
        ..updateMinBarWidth(12)
        ..updateMaxBarWidth(12);
      ref
          .read(chartDecorationsPresenter)
          .addDecoration(GridDecoration(), layer: DecorationLayer.background);
    },
  ),
  GalleryEntry(
    id: 'negative-values',
    title: 'Cash flow',
    blurb: 'Bars above and below zero, with axisMin opening the space beneath.',
    tags: const ['bar', 'axis'],
    useCase: 'Money in and out, temperature against freezing, net change of '
        'any kind.',
    customization: const [
      'axisMin is what reserves room below zero; without it the chart clips '
          'at the lowest value.',
      'Colour by sign in barItemBuilder — one colour for credits, another for '
          'debits.',
      'Bar radius flips automatically for negative bars, so rounded corners '
          'stay on the outer end.',
    ],
    buildChart: (context) => Chart<void>(
      state: ChartState<void>(
        data: ChartData.fromList(
          _items([3, -2, 5, -4, 2, -1, 4]),
          axisMin: -6,
          valueAxisMaxOver: 2,
        ),
        itemOptions: const BarItemOptions(
          padding: EdgeInsets.symmetric(horizontal: 3),
          barItemBuilder: _blueBar,
        ),
        backgroundDecorations: [
          HorizontalAxisDecoration(
            showValues: true,
            axisStep: 3,
            lineColor: Theme.of(context).colorScheme.outlineVariant,
            legendFontStyle: _axisLabelStyle(context),
          ),
        ],
      ),
    ),
    snippet: '''ChartState<void>(
  data: ChartData.fromList(values, axisMin: -6, valueAxisMaxOver: 2),
  itemOptions: BarItemOptions(
    padding: const EdgeInsets.symmetric(horizontal: 3),
    barItemBuilder: (_) => const BarItem(color: Color(0xFF6479C3)),
  ),
  backgroundDecorations: [
    HorizontalAxisDecoration(showValues: true, axisStep: 3),
  ],
)''',
    applyToPlayground: (ref) {
      _applyBase(ref, [3, -2, 5, -4, 2, -1, 4], color: _blue, padding: 3)
          .updateAxisMin(-6);
      ref.read(chartDecorationsPresenter).addDecoration(
          HorizontalAxisDecoration(),
          layer: DecorationLayer.background);
      ref.read(decorationHorizontalAxisPresenter(0))
        ..updateShowValues(true)
        ..updateAxisStep(3);
    },
  ),
  GalleryEntry(
    id: 'gradient-bars',
    title: 'Gradient bars',
    blurb: 'A vertical gradient per bar, for when a flat fill looks too plain '
        'on a marketing surface.',
    tags: const ['bar'],
    useCase: 'Highlight cards, onboarding screens, anywhere the chart is as '
        'much decoration as data.',
    customization: const [
      'Any Gradient works, not just LinearGradient — try a SweepGradient for '
          'a dial-like look.',
      'begin and end control the direction; bottomCenter to topCenter reads '
          'as "growth".',
      'Keep the darkest stop at the base so short bars stay legible.',
    ],
    buildChart: (context) => Chart<void>(
      state: ChartState<void>(
        data:
            ChartData.fromList(_items([4, 7, 3, 8, 5, 6]), valueAxisMaxOver: 2),
        itemOptions: const BarItemOptions(
          padding: EdgeInsets.symmetric(horizontal: 4),
          barItemBuilder: _gradientBar,
        ),
      ),
    ),
    snippet: '''ChartState<void>(
  data: ChartData.fromList(values, valueAxisMaxOver: 2),
  itemOptions: BarItemOptions(
    padding: const EdgeInsets.symmetric(horizontal: 4),
    barItemBuilder: (_) => const BarItem(
      gradient: LinearGradient(
        colors: [Color(0xFFD8262C), Color(0xFF6479C3)],
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
      ),
    ),
  ),
)''',
    applyToPlayground: (ref) {
      // The preview's BarItem sets only a gradient, so its colour is the
      // default black; the gradient covers the fill either way.
      _applyBase(ref, [4, 7, 3, 8, 5, 6], color: _red, padding: 4)
          .updateGradient(
        const LinearGradient(
          colors: [_red, _blue],
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
        ),
        0,
      );
    },
  ),
  GalleryEntry(
    id: 'rounded-bars',
    title: 'Storage usage',
    blurb: 'Rounded caps and generous spacing, the friendly settings-screen '
        'look.',
    tags: const ['bar'],
    useCase: 'Storage or quota breakdowns, profile stats, anything inside a '
        'consumer settings page.',
    customization: const [
      'BorderRadius.vertical rounds only the top; use BorderRadius.circular '
          'for pill bars.',
      'Radius larger than half the bar width will look clipped on short bars.',
      'Pair with a fixed axisMax so a full bar always means "full".',
    ],
    buildChart: (context) => Chart<void>(
      state: ChartState<void>(
        data:
            ChartData.fromList(_items([5, 8, 4, 6, 9, 3]), valueAxisMaxOver: 2),
        itemOptions: const BarItemOptions(
          padding: EdgeInsets.symmetric(horizontal: 5),
          barItemBuilder: _roundedBar,
        ),
      ),
    ),
    snippet: '''ChartState<void>(
  data: ChartData.fromList(values, valueAxisMaxOver: 2),
  itemOptions: BarItemOptions(
    padding: const EdgeInsets.symmetric(horizontal: 5),
    barItemBuilder: (_) => const BarItem(
      color: Color(0xFF5A8772),
      radius: BorderRadius.vertical(top: Radius.circular(8)),
    ),
  ),
)''',
    applyToPlayground: (ref) {
      _applyBase(ref, [5, 8, 4, 6, 9, 3], color: _green, padding: 5)
          .updateBarBorderRadius(
              const BorderRadius.vertical(top: Radius.circular(8)), 0,
              forAll: true);
    },
  ),
  GalleryEntry(
    id: 'axis-labels',
    title: 'Monthly report',
    blurb: 'Both axes labelled, the version you print or export rather than '
        'the one on a tile.',
    tags: const ['axis', 'decoration'],
    useCase: 'Reports and exports, where a reader needs to read values off '
        'the chart without tapping.',
    customization: const [
      'axisStep decides label density — raise it when labels start colliding.',
      'legendFontStyle needs an explicit colour: the chart paints this text '
          'itself, so it will not follow your text theme.',
      'valuesAlign and valuesPadding nudge labels off the lines.',
    ],
    buildChart: (context) {
      final outline = Theme.of(context).colorScheme.outlineVariant;
      final labelStyle = _axisLabelStyle(context);

      return Chart<void>(
        state: ChartState<void>(
          data: ChartData.fromList(_items([4, 6, 3, 6, 7, 9]),
              valueAxisMaxOver: 2),
          itemOptions: const BarItemOptions(
            padding: EdgeInsets.symmetric(horizontal: 4),
            barItemBuilder: _sandBar,
          ),
          backgroundDecorations: [
            HorizontalAxisDecoration(
              showValues: true,
              axisStep: 3,
              lineColor: outline,
              legendFontStyle: labelStyle,
            ),
            VerticalAxisDecoration(
              showValues: true,
              axisStep: 1,
              lineColor: outline,
              legendFontStyle: labelStyle,
            ),
          ],
        ),
      );
    },
    snippet: '''ChartState<void>(
  data: ChartData.fromList(values, valueAxisMaxOver: 2),
  itemOptions: BarItemOptions(
    padding: const EdgeInsets.symmetric(horizontal: 4),
    barItemBuilder: (_) => const BarItem(color: Color(0xFFD9A866)),
  ),
  backgroundDecorations: [
    HorizontalAxisDecoration(showValues: true, axisStep: 3),
    VerticalAxisDecoration(showValues: true, axisStep: 1),
  ],
)''',
    applyToPlayground: (ref) {
      _applyBase(ref, [4, 6, 3, 6, 7, 9], color: _sand, padding: 4);
      final decorations = ref.read(chartDecorationsPresenter)
        ..addDecoration(HorizontalAxisDecoration(),
            layer: DecorationLayer.background);
      decorations.addDecoration(VerticalAxisDecoration(),
          layer: DecorationLayer.background);
      ref.read(decorationHorizontalAxisPresenter(0))
        ..updateShowValues(true)
        ..updateAxisStep(3);
      ref.read(decorationVerticalAxisPresenter(1)).updateShowValues(true);
    },
  ),
  GalleryEntry(
    id: 'target-line',
    title: 'Goal tracking',
    blurb: 'A target marked with a widget, and bars recoloured once they pass '
        'it.',
    tags: const ['decoration', 'custom'],
    useCase: 'Sales quotas, step goals, SLA thresholds — any "did we hit it" '
        'chart.',
    customization: const [
      'verticalMultiplier converts a data value to pixels, which is how the '
          'line finds its height.',
      'The widget is a normal Flutter widget: add a label, a dashed border, '
          'or a tappable area.',
      'The threshold colour lives in barItemBuilder, so the line and the bars '
          'stay in sync through one constant.',
    ],
    buildChart: (context) => Chart<void>(
      state: ChartState<void>(
        data: ChartData.fromList(_items([4, 6, 3, 8, 7, 9, 5]),
            valueAxisMaxOver: 2),
        itemOptions: const BarItemOptions(
          padding: EdgeInsets.symmetric(horizontal: 4),
          barItemBuilder: _overTargetBar,
        ),
        foregroundDecorations: [
          WidgetDecoration(
            widgetDecorationBuilder:
                (context, state, itemWidth, verticalMultiplier) => Stack(
              children: [
                Positioned(
                  left: 0,
                  right: 0,
                  // verticalMultiplier converts a data value into pixels.
                  bottom: verticalMultiplier * _target,
                  child: Container(height: 2, color: _red),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
    snippet: '''ChartState<void>(
  data: ChartData.fromList(values, valueAxisMaxOver: 2),
  itemOptions: BarItemOptions(
    padding: const EdgeInsets.symmetric(horizontal: 4),
    barItemBuilder: (data) => BarItem(
      color: (data.item.max ?? 0) > 7
          ? const Color(0xFFD8262C)
          : const Color(0xFF5A8772),
    ),
  ),
  foregroundDecorations: [
    WidgetDecoration(
      widgetDecorationBuilder:
          (context, state, itemWidth, verticalMultiplier) => Stack(
        children: [
          Positioned(
            left: 0,
            right: 0,
            bottom: verticalMultiplier * 7,
            child: Container(height: 2, color: const Color(0xFFD8262C)),
          ),
        ],
      ),
    ),
  ],
)''',
    applyToPlayground: (ref) {
      _applyBase(ref, [4, 6, 3, 8, 7, 9, 5], color: _green, padding: 4);
      ref.read(chartDecorationsPresenter).addDecoration(WidgetDecoration(
            widgetDecorationBuilder: (_, __, ___, ____) =>
                const SizedBox.shrink(),
          ));
      // The playground's widget decoration draws its target line from this
      // value. Recolouring items above the target is not a playground option,
      // so that part of the example does not carry over.
      ref.read(decorationWidgetPresenter(0))
        ..updateType(0)
        ..updateTargetValue(_target);
    },
  ),
  GalleryEntry(
    id: 'value-labels',
    title: 'Values on bars',
    blurb: 'Each item draws its own number above the bar, so no axis is '
        'needed.',
    tags: const ['custom'],
    useCase: 'Short comparisons — five or six bars where exact values matter '
        'more than a scale.',
    customization: const [
      'The item is a plain Column, so the label can be anything: a Text, an '
          'icon, a Row with both.',
      'valueAxisMaxOver reserves headroom so the top label is not clipped.',
      'This replaces the deprecated ValueDecoration; the builder gives you '
          'far more control.',
    ],
    buildChart: (context) {
      final labelStyle = Theme.of(context)
          .textTheme
          .labelSmall!
          .copyWith(color: Theme.of(context).colorScheme.onSurface);

      return Chart<void>(
        state: ChartState<void>(
          data:
              ChartData.fromList(_items([4, 6, 3, 6, 7]), valueAxisMaxOver: 3),
          itemOptions: WidgetItemOptions(
            widgetItemBuilder: (data) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Column(
                children: [
                  Text((data.item.max ?? 0).toStringAsFixed(0),
                      style: labelStyle),
                  const Expanded(
                    child: DecoratedBox(
                      decoration: BoxDecoration(color: _plum),
                      child: SizedBox.expand(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
    snippet: '''ChartState<void>(
  data: ChartData.fromList(values, valueAxisMaxOver: 3),
  itemOptions: WidgetItemOptions(
    widgetItemBuilder: (data) => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Column(
        children: [
          Text('\${(data.item.max ?? 0).toStringAsFixed(0)}'),
          const Expanded(
            child: DecoratedBox(
              decoration: BoxDecoration(color: Color(0xFF916794)),
              child: SizedBox.expand(),
            ),
          ),
        ],
      ),
    ),
  ),
)''',
    applyToPlayground: (ref) {
      _applyBase(ref, [4, 6, 3, 6, 7], color: _plum, padding: 0, maxOver: 3)
        ..updateItemPainter(SelectedPainter.widget)
        ..updateWidgetItemExample(WidgetItemExample.valueLabel);
    },
  ),
  GalleryEntry(
    id: 'scrollable',
    title: 'Long time series',
    blurb: 'More points than fit on screen, with a fixed number visible and '
        'the rest a swipe away.',
    tags: const ['bar', 'scroll'],
    useCase: 'A year of daily data on a phone, log volumes, anything you '
        'would otherwise have to aggregate.',
    customization: const [
      'visibleItems sets how many fit; the chart sizes itself and ignores the '
          'width limit.',
      'It must be wrapped in a horizontal scroll view or it will overflow.',
      'Pair with a fixed axisMax so the scale does not jump as you scroll.',
    ],
    buildChart: (context) => SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Chart<void>(
        width: 900,
        state: ChartState<void>(
          data: ChartData.fromList(
            _items([4, 6, 3, 6, 7, 9, 3, 2, 5, 8, 4, 7, 6, 2, 9, 3]),
            valueAxisMaxOver: 2,
          ),
          itemOptions: const BarItemOptions(
            padding: EdgeInsets.symmetric(horizontal: 4),
            barItemBuilder: _redBar,
          ),
          behaviour: const ChartBehaviour(
            scrollSettings: ScrollSettings(visibleItems: 8),
          ),
        ),
      ),
    ),
    snippet: '''SingleChildScrollView(
  scrollDirection: Axis.horizontal,
  child: Chart<void>(
    state: ChartState<void>(
      data: ChartData.fromList(values, valueAxisMaxOver: 2),
      itemOptions: BarItemOptions(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        barItemBuilder: (_) => const BarItem(color: Color(0xFFD8262C)),
      ),
      behaviour: const ChartBehaviour(
        scrollSettings: ScrollSettings(visibleItems: 8),
      ),
    ),
  ),
)''',
    applyToPlayground: (ref) {
      _applyBase(ref, [4, 6, 3, 6, 7, 9, 3, 2, 5, 8, 4, 7, 6, 2, 9, 3],
              color: _red, padding: 4)
          .updateVisibleItems(8);
    },
  ),
  GalleryEntry(
    id: 'widget-items',
    title: 'Custom widget items',
    blurb: 'Every item is a widget you build, once the painters stop being '
        'enough.',
    tags: const ['custom'],
    useCase: 'Branded bars, avatars on a timeline, items that need to be '
        'tapped or animated individually.',
    customization: const [
      'Anything Flutter can build works here, including images, gradients and '
          'gesture detectors.',
      'The builder receives the item, its index and its series index, so '
          'items can differ from each other.',
      'This is the slowest option of the four; prefer a painter when the '
          'shape is simple.',
    ],
    buildChart: (context) => Chart<void>(
      state: ChartState<void>(
        data: ChartData.fromList(_items([4, 6, 3, 6, 7]), valueAxisMaxOver: 2),
        itemOptions: WidgetItemOptions(
          widgetItemBuilder: (data) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                gradient: const LinearGradient(
                  colors: [_blue, _plum],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
              child: const SizedBox.expand(),
            ),
          ),
        ),
      ),
    ),
    snippet: '''ChartState<void>(
  data: ChartData.fromList(values, valueAxisMaxOver: 2),
  itemOptions: WidgetItemOptions(
    widgetItemBuilder: (data) => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          gradient: const LinearGradient(
            colors: [Color(0xFF6479C3), Color(0xFF916794)],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
        ),
        child: const SizedBox.expand(),
      ),
    ),
  ),
)''',
    applyToPlayground: (ref) {
      _applyBase(ref, [4, 6, 3, 6, 7], padding: 0)
          .updateItemPainter(SelectedPainter.widget);
    },
  ),
];
