import 'package:charts_painter/chart.dart';
import 'package:charts_web/ui/gallery/gallery_entry.dart';
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
    title: 'Simple bar chart',
    blurb: 'BarItemOptions with a grid behind it. The shortest useful chart.',
    tags: const ['bar', 'decoration'],
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
      ref.read(chartStatePresenter)
        ..updateItemPainter(SelectedPainter.bar)
        ..updateData([_items([4, 6, 3, 6, 7, 9, 3, 2])]);
      ref.read(chartDecorationsPresenter).addDecoration(
          HorizontalAxisDecoration(),
          layer: DecorationLayer.background);
    },
  ),
  GalleryEntry(
    id: 'stacked-bar',
    title: 'Stacked series',
    blurb: 'StackDataStrategy puts every series on top of the previous one.',
    tags: const ['bar', 'stacked'],
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
      final presenter = ref.read(chartStatePresenter)
        ..updateData([_items([3, 5, 2, 4, 6])]);
      presenter.addDataList(_items([2, 1, 4, 2, 3]));
      presenter.addDataList(_items([1, 3, 1, 3, 2]));
      presenter.updateDataStrategy(const StackDataStrategy());
    },
  ),
  GalleryEntry(
    id: 'grouped-bar',
    title: 'Grouped series',
    blurb: 'DefaultDataStrategy with stacking off draws series side by side.',
    tags: const ['bar', 'stacked'],
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
      final presenter = ref.read(chartStatePresenter)
        ..updateData([_items([3, 5, 2, 4, 6])]);
      presenter.addDataList(_items([2, 1, 4, 2, 3]));
      presenter.updateDataStrategy(
          const DefaultDataStrategy(stackMultipleValues: true));
      presenter.updateStackMultipleValues(false);
    },
  ),
  GalleryEntry(
    id: 'sparkline',
    title: 'Sparkline',
    blurb: 'A line is a decoration. Zero-width items plus SparkLineDecoration.',
    tags: const ['line', 'decoration'],
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
      ref.read(chartStatePresenter)
        ..updateData([_items([2, 7, 2, 4, 7, 6, 2, 5, 4])])
        ..updateItemPainter(SelectedPainter.none);
      ref.read(chartDecorationsPresenter).addDecoration(SparkLineDecoration(),
          layer: DecorationLayer.background);
    },
  ),
  GalleryEntry(
    id: 'bubble',
    title: 'Bubble chart',
    blurb: 'BubbleItemOptions draws a point per value instead of a bar.',
    tags: const ['bubble'],
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
      ref.read(chartStatePresenter)
        ..updateItemPainter(SelectedPainter.bubble)
        ..updateMinBarWidth(12)
        ..updateMaxBarWidth(12);
    },
  ),
  GalleryEntry(
    id: 'negative-values',
    title: 'Negative values',
    blurb: 'axisMin opens space below zero; bar radius flips automatically.',
    tags: const ['bar', 'axis'],
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
      ref.read(chartStatePresenter)
        ..updateData([_items([3, -2, 5, -4, 2, -1, 4])])
        ..updateAxisMin(-6);
      ref.read(chartDecorationsPresenter).addDecoration(
          HorizontalAxisDecoration(),
          layer: DecorationLayer.background);
    },
  ),
  GalleryEntry(
    id: 'gradient-bars',
    title: 'Gradient bars',
    blurb: 'Every item accepts a gradient instead of a flat colour.',
    tags: const ['bar'],
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
    applyToPlayground: (ref) => ref.read(chartStatePresenter).updateGradient(
          const LinearGradient(
            colors: [_red, _blue],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
          0,
        ),
  ),
  GalleryEntry(
    id: 'rounded-bars',
    title: 'Rounded bars',
    blurb: 'BorderRadius per item, flipped automatically for negative values.',
    tags: const ['bar'],
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
    applyToPlayground: (ref) => ref
        .read(chartStatePresenter)
        .updateBarBorderRadius(
            const BorderRadius.vertical(top: Radius.circular(8)), 0,
            forAll: true),
  ),
  GalleryEntry(
    id: 'axis-labels',
    title: 'Labelled axes',
    blurb: 'Both axis decorations with values shown, in the background layer.',
    tags: const ['axis', 'decoration'],
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
      final decorations = ref.read(chartDecorationsPresenter)
        ..addDecoration(HorizontalAxisDecoration(),
            layer: DecorationLayer.background);
      decorations.addDecoration(VerticalAxisDecoration(),
          layer: DecorationLayer.background);
    },
  ),
  GalleryEntry(
    id: 'target-line',
    title: 'Target line',
    blurb: 'A WidgetDecoration marks the target; the item builder recolours '
        'anything above it. This is the replacement for the deprecated '
        'TargetLineDecoration.',
    tags: const ['decoration', 'custom'],
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
      ref.read(chartStatePresenter).updateData([_items([4, 6, 3, 8, 7, 9, 5])]);
      ref
          .read(chartDecorationsPresenter)
          .addDecoration(WidgetDecoration(
            widgetDecorationBuilder: (_, __, ___, ____) =>
                const SizedBox.shrink(),
          ));
      // The playground's widget decoration draws its target line from this
      // value. Per-item colouring above the target is not a playground option,
      // so that part of the example does not carry over.
      ref.read(decorationWidgetPresenter(0))
        ..updateType(0)
        ..updateTargetValue(_target);
    },
  ),
  GalleryEntry(
    id: 'value-labels',
    title: 'Value labels',
    blurb: 'WidgetItemOptions draws the bar and its own label, which is what '
        'replaced the deprecated ValueDecoration.',
    tags: const ['custom'],
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
      ref.read(chartStatePresenter)
        ..updateData([_items([4, 6, 3, 6, 7])])
        ..updateItemPainter(SelectedPainter.widget)
        ..updateWidgetItemExample(WidgetItemExample.valueLabel);
    },
  ),
  GalleryEntry(
    id: 'scrollable',
    title: 'Scrollable chart',
    blurb: 'ScrollSettings fixes how many items are visible; wrap in a scroll '
        'view and the chart sizes itself.',
    tags: const ['bar', 'scroll'],
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
      ref.read(chartStatePresenter)
        ..updateData([
          _items([4, 6, 3, 6, 7, 9, 3, 2, 5, 8, 4, 7, 6, 2, 9, 3])
        ])
        ..updateVisibleItems(8);
    },
  ),
  GalleryEntry(
    id: 'widget-items',
    title: 'Widget items',
    blurb: 'WidgetItemOptions replaces the painter with any widget you like.',
    tags: const ['custom'],
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
    applyToPlayground: (ref) =>
        ref.read(chartStatePresenter).updateItemPainter(SelectedPainter.widget),
  ),
];
