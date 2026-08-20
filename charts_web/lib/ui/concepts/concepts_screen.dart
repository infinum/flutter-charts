import 'package:charts_painter/chart.dart';
import 'package:charts_web/ui/common/layout/breakpoints.dart';
import 'package:charts_web/ui/design/code_block.dart';
import 'package:charts_web/ui/design/section_card.dart';
import 'package:material_ui/material_ui.dart';

const Color _red = Color(0xFFD8262C);
const Color _blue = Color(0xFF6479C3);

List<ChartItem<void>> _items(List<num> values) =>
    values.map((value) => ChartItem<void>(value.toDouble())).toList();

BarItem _redBar(ItemBuilderData data) => const BarItem(color: _red);
BarItem _blueBar(ItemBuilderData data) => const BarItem(color: _blue);

BarItem _twoSeriesBar(ItemBuilderData data) =>
    BarItem(color: data.listIndex == 0 ? _red : _blue);

BarItem _thresholdBar(ItemBuilderData data) => BarItem(
      color: (data.item.max ?? 0) > 5 ? _red : _blue,
      radius: const BorderRadius.vertical(top: Radius.circular(6)),
    );

class ConceptsScreen extends StatelessWidget {
  const ConceptsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final outline = theme.colorScheme.outlineVariant;

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        // Full-bleed text on a wide monitor gives unreadably long lines, and
        // stretches every mini-chart into a letterbox.
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
        Text('How charts_painter fits together',
            style: theme.textTheme.headlineSmall),
        const SizedBox(height: 4),
        Text(
          'Four pieces. Once these click, every option in the playground has '
          'an obvious home.',
          style: theme.textTheme.bodyMedium
              ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 20),
        _Concept(
          title: 'ChartState',
          summary: 'The object you hand to a chart widget.',
          body: 'The single object a chart renders. It holds the data, the '
              'item options, the behaviour, and two lists of decorations. '
              'Build one and hand it to Chart or AnimatedChart.',
          snippet: '''Chart<void>(
  state: ChartState<void>(
    data: ChartData.fromList(values),
    itemOptions: BarItemOptions(
      barItemBuilder: (_) => const BarItem(color: Color(0xFFD8262C)),
    ),
  ),
)''',
          chart: Chart<void>(
            height: 140,
            state: ChartState<void>(
              data: ChartData.fromList(_items([4, 6, 3, 6, 7]),
                  valueAxisMaxOver: 2),
              itemOptions: const BarItemOptions(
                padding: EdgeInsets.symmetric(horizontal: 6),
                barItemBuilder: _redBar,
              ),
            ),
          ),
        ),
        _Concept(
          title: 'ChartData and DataStrategy',
          summary: 'Your numbers, and how several series share a slot.',
          body: 'Data is a list of lists: one inner list per series. The '
              'strategy decides what happens when several series share a slot '
              '- stacked on top of each other, or grouped side by side.',
          snippet: '''ChartData(
  [seriesA, seriesB],
  dataStrategy: const StackDataStrategy(),
  valueAxisMaxOver: 2,
)''',
          chart: Chart<void>(
            height: 140,
            state: ChartState<void>(
              data: ChartData(
                [
                  _items([3, 5, 2, 4]),
                  _items([2, 1, 4, 2]),
                ],
                dataStrategy: const StackDataStrategy(),
                valueAxisMaxOver: 2,
              ),
              itemOptions: const BarItemOptions(
                padding: EdgeInsets.symmetric(horizontal: 6),
                barItemBuilder: _twoSeriesBar,
              ),
            ),
          ),
        ),
        _Concept(
          title: 'ItemOptions',
          summary: 'How a single data point is drawn.',
          body: 'How one data point is drawn. BarItemOptions and '
              'BubbleItemOptions cover the common cases; the builder receives '
              'the item, its index and its series index, so colour, gradient, '
              'border and radius can vary per point. WidgetItemOptions hands '
              'the whole job to a widget.',
          snippet: '''BarItemOptions(
  maxBarWidth: 20,
  barItemBuilder: (data) => BarItem(
    color: (data.item.max ?? 0) > 5 ? Colors.red : Colors.blue,
    radius: const BorderRadius.vertical(top: Radius.circular(6)),
  ),
)''',
          chart: Chart<void>(
            height: 140,
            state: ChartState<void>(
              data: ChartData.fromList(_items([4, 6, 3, 7, 5]),
                  valueAxisMaxOver: 2),
              itemOptions: const BarItemOptions(
                padding: EdgeInsets.symmetric(horizontal: 6),
                barItemBuilder: _thresholdBar,
              ),
            ),
          ),
        ),
        _Concept(
          title: 'Decorations',
          summary: 'Everything painted around the items.',
          body: 'Everything that is not an item: grids, axes, sparklines, '
              'target lines, value labels, or any widget. Background '
              'decorations paint under the items, foreground over them, and '
              'the same decoration can sit in either list.',
          snippet: '''ChartState<void>(
  data: ChartData.fromList(values),
  itemOptions: BarItemOptions(...),
  backgroundDecorations: [GridDecoration()],
  foregroundDecorations: [
    WidgetDecoration(
      widgetDecorationBuilder: (context, state, itemWidth, multiplier) =>
          Stack(children: [
        Positioned(
          left: 0,
          right: 0,
          bottom: multiplier * 6,
          child: Container(height: 2, color: const Color(0xFFD8262C)),
        ),
      ]),
    ),
  ],
)''',
          chart: Chart<void>(
            height: 140,
            state: ChartState<void>(
              data: ChartData.fromList(_items([4, 6, 3, 7, 5]),
                  valueAxisMaxOver: 2),
              itemOptions: const BarItemOptions(
                padding: EdgeInsets.symmetric(horizontal: 6),
                barItemBuilder: _blueBar,
              ),
              backgroundDecorations: [
                GridDecoration(
                  gridColor: outline,
                  textStyle: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
              foregroundDecorations: [
                WidgetDecoration(
                  widgetDecorationBuilder:
                      (context, state, itemWidth, verticalMultiplier) => Stack(
                    children: [
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: verticalMultiplier * 6,
                        child: Container(height: 2, color: _red),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Concept extends StatelessWidget {
  const _Concept({
    required this.title,
    required this.summary,
    required this.body,
    required this.snippet,
    required this.chart,
  });

  final String title;

  /// One line under the heading, for skimming.
  final String summary;
  final String body;
  final String snippet;
  final Widget chart;

  @override
  Widget build(BuildContext context) {
    // Stacked, the chart spans the full column and reads as a letterbox strip.
    // Side by side it keeps a sane aspect ratio and the code sits next to what
    // it produces.
    final sideBySide = context.breakpoint != AppBreakpoint.compact;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: SectionCard(
        title: title,
        subtitle: summary,
        collapsible: false,
        children: [
          Text(body, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 16),
          if (sideBySide)
            // No IntrinsicHeight here: Chart uses a LayoutBuilder internally
            // and LayoutBuilder refuses intrinsic sizing, so the row gets an
            // explicit height instead.
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: SizedBox(height: 200, child: chart)),
                const SizedBox(width: 20),
                Expanded(child: CodeBlock(source: snippet)),
              ],
            )
          else ...[
            chart,
            const SizedBox(height: 16),
            CodeBlock(source: snippet),
          ],
        ],
      ),
    );
  }
}
