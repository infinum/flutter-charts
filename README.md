# Charts painter
![chart_image]

Customizable charts library for flutter.

Idea behind this lib is to allow highly customizable charts. By having decorations painters (foreground and background) and item painters that can be easily changed. Customizing and adding new decorations will require some CustomPainter knowledge.

## Table of Contents
* [Showcase](#showcase)
* [Usage](#usage)
    * [Basic](#basic-charts)
    * [Decorations](#decoration)
* [Make your own](#make-your-chart)
* [More examples](#more-examples)

## Showcase
![showcase]

## Usage
Add it to your package's pubspec.yaml file
```yaml
dependencies:
  charts_painter: ^1.1.0
```

Install packages from the command line
```bash
flutter packages get
```

### Basic charts
By passing `ChartState.line` or `ChartState.bar` to Chart widget we will add appropriate decorations for the selected chart.

```dart
@override
Widget build(BuildContext context) {
  return Chart(
    state: ChartState.line(
      ChartData.fromList(
        <double>[1, 3, 4, 2, 7, 6, 2, 5, 4].map((e) => BubbleValue<void>(e)).toList(),
      ),
    ),
  );
}
```
![basic_line]

By charging `ChartState.line` to `ChartState.bar` we can change look of the chart.

```dart
@override
Widget build(BuildContext context) {
  return Chart(
    state: ChartState.bar(
      ChartData.fromList(
        <double>[1, 3, 4, 2, 7, 6, 2, 5, 4].map((e) => BarValue<void>(e)).toList(),
      ),
    ),
  );
}
```
![basic_bar]

#### ChartData
Chart data has some options that will change how the data is processed.
By changing `axisMin` or `axisMax` scale of the chart is changed in order to show that value, in case data has higher/lower data then axisMax/axisMin then this option is ignored. 

Adding `valueAxisMaxOver` will add that value to currently the highest value.

`strategy` will only have impact if chart has multiple lists, in that case it can stack those items with `DataStrategy.stack`. Strategy only affects how multiple lists are being processed, to change how the are drawn see `ChartBehaviour.multiItemStack` 

## Item options
Options that set how it draws each item and how it looks.
When using `BarItemOptions` or `BubbleItemOptions` geometry painters have been preset, and they include some extra options for their painters. 

## Geometry painter
What are geometry painters?

Geometry painters are responsible for drawing each item on the canvas.
Included in the lib are  2 `ItemPainter`'s. 

| Bar painter (default) | Bubble painter |
--- | ---
![bar_painter] | ![bubble_painter]
![candle_painter] | 

## Decoration
We use Decorations to enhance our charts. Chart decorations can be painted in the background or in a foreground of the items. Everything that is not chart item is a decoration.
[All decorations](./test/golden/GOLDENS.md)

Here are decorations we have included, bar items with opacity have been added for better visibility.
![decoration_golden_file]

##### Legend decorations
 - GridDecoration - _Decoration is just merging of HorizontalAxisDecoration and VerticalAxisDecoration_
    - HorizontalAxisDecoration - _Show horizontal lines on the chart, can show legend as well_ 
    - VerticalAxisDecoration - _Show vertical lines on the chart, can show legend as well_
 - ValueDecoration - _Show value of each item_

##### Target decorations
 - TargetLineDecoration - _Show target line on the chart, can pass `getTargetItemColor` to `colorForValue` to change item colors_
    - TargetLineLegendDecoration - _Show text legend on left side of the chart_
 - TargetAreaDecoration

##### Other decorations
 - BorderDecoration - _Add rectangular border around the chart_
 - SelectedItemDecoration - _When providing `ChartBehaviour.onItemClicked` then you can use `SelectedItemDecoration` for showing selected item on the chart_
 - SparkLineDecoration - _Show data with sparkline chart_

## Drawing charts
Now you are ready to use charts lib. If chart needs to animate the state changes then use `AnimatedChart<T>` widget instead of `Chart<T>` widget.
`AnimatedChart<T>` needs to specify `Duration` and it can accept `Curve` for animation.

#### Make your chart
This is how you can start, this is simple bar chart with grid decoration:
```dart
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Chart(
        state: ChartState.fromList(
          [1, 3, 4, 2, 7, 6, 2, 5, 4].map((e) => BarValue<void>(e.toDouble())).toList(),
          itemOptions: BarItemOptions(
            padding: const EdgeInsets.symmetric(horizontal: 2.0),
            radius: BorderRadius.vertical(top: Radius.circular(12.0)),
          ),
          options: BarChartOptions(valueAxisMax: 8),
          backgroundDecorations: [
            GridDecoration(
              verticalAxisStep: 1,
              horizontalAxisStep: 1,
              gridColor: Theme.of(context).dividerColor,
            ),
          ],
          foregroundDecorations: [
            BorderDecoration(
              color: Theme.of(context).colorScheme.secondary,
              width: 2.0,
            ),
          ],
        ),
      ),
    );
  }
```
Code above will draw this:
![simple_chart]

#### Line Chart
To turn any chart to line chart we just need to add `SparklineDecoration` to `foregroundDecorations` or `backgroundDecorations`. This will add decoration line on top/bottom of the chart.

By replacing the `BarValue` to `BubbleValue` and changing `geometryPainter` to `bubblePainter` we can show nicer line chart with small bubbles on data points:
```dart
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Chart(
        state: ChartState.fromList(
          /// CHANGE: Change [BarValue<void>] to [BubbleValue<void>]
          [1, 3, 4, 2, 7, 6, 2, 5, 4].map((e) => BubbleValue<void>(e.toDouble())).toList(),
          /// CHANGE: From [BarItemOptions] to [BubbleItemOptions]
          itemOptions: BubbleItemOptions(
            padding: const EdgeInsets.symmetric(horizontal: 2.0),
            /// REMOVED: Radius doesn't exist in [BubbleItemOptions]
            // radius: BorderRadius.vertical(top: Radius.circular(12.0)),

            /// ADDED: Make [BubbleValue] items smaller
            maxBarWidth: 4.0,
          ),
          options: ChartOptions(valueAxisMax: 8),
          backgroundDecorations: [
            GridDecoration(
              verticalAxisStep: 1,
              horizontalAxisStep: 1,
              gridColor: Theme.of(context).dividerColor,
            ),
          ],
          foregroundDecorations: [
            BorderDecoration(
              color: Theme.of(context).colorScheme.secondary,
              width: 2.0,
            ),

            /// ADDED: Add spark line decoration ([SparkLineDecoration]) on foreground
            SparkLineDecoration(),
          ],
        ),
      ),
    );
  }
```
Code above will make our nicer line graph:
![simple_line_chart]

#### Multi Chart
Charts can have multiple values that are grouped.
To turn any chart to multi value we need to use `ChartState` instead of `ChartState.fromList` constructor. Default constructor will accept `List<List<ChartItem<T>>` allowing us to pass multiple lists to same chart.
```dart
  @override
  Widget build(BuildContext context) {
    Padding(
      padding: const EdgeInsets.all(8.0),
      child: Chart(
        /// CHANGE: From [ChartState.fromList] to [ChartState]
        state: ChartState(
          /// CHANGE: Add list we had into bigger List
          [
            [1, 3, 4, 2, 7, 6, 2, 5, 4].map((e) => BubbleValue<void>(e.toDouble())).toList(),

            /// ADD: Another list
            [4, 6, 3, 3, 2, 1, 4, 7, 5].map((e) => BubbleValue<void>(e.toDouble())).toList(),
          ],
          itemOptions: BubbleItemOptions(
            padding: const EdgeInsets.symmetric(horizontal: 2.0),
            maxBarWidth: 4.0,

            /// ADDED: Color bubbles differently depending on List they came from. [ColorForIndex]
            colorForKey: (item, index) {
              return [Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.primaryVariant][index];
            },
          ),
          options: ChartOptions(valueAxisMax: 8),
          backgroundDecorations: [
            GridDecoration(
              verticalAxisStep: 1,
              horizontalAxisStep: 1,
              gridColor: Theme.of(context).dividerColor,
            ),
          ],
          foregroundDecorations: [
            SparkLineDecoration(),

            /// ADDED: Add another [SparkLineDecoration] for the second list
            SparkLineDecoration(
              // Specify key that this [SparkLineDecoration] will follow 
              // Throws if `lineKey` does not exist in chart data 
              lineKey: 1,
              lineColor: Theme.of(context).colorScheme.primaryVariant,
            ),
            BorderDecoration(
              color: Theme.of(context).colorScheme.secondary,
              width: 2.0,
            ),
          ],
        ),
      ),
    );
  }
```
Code above will make this multi line graph:
![simple_multi_line_chart]

#### Chart behaviour
- Setting `isScrollable` to `true` will make the chart ignore it's specified width and should be wrapped in some Scrollable widget in order to display properly.
- Get selected item, `onItemClick` will return index of the clicked item.
- Change how multiple values in the map get drawn, `multiItemStack` by default is set to `true`, and multiple items will just stack on same place, setting this to `false` will divide that place for each item, and they will be shown in `grouped` state.

## More examples
### Line charts
Line chart with multiple values [example code](./example/lib/charts/line_chart_screen.dart)
![line_chart_animating]

### Bar charts
Bar chart with area [example code](./example/lib/charts/bar_chart_screen.dart)
![bar_chart_animating]

### Scrollable chart
Scrollable bar chart [example code](./example/lib/charts/scrollable_chart_screen.dart)
![scrollable_chart]

[chart_image]: ./assets/chart_image.png

[bar_chart_animating]: ./assets/bar_chart_animating.gif
[scrollable_chart]: ./assets/scrollable_chart.gif
[line_chart_animating]: ./assets/line_chart_animating.gif

[simple_chart]: ./test/golden/examples/goldens/bar_chart.png
[simple_line_chart]: ./test/golden/examples/goldens/line_chart.png
[simple_multi_line_chart]: ./test/golden/examples/goldens/multi_line_chart.png

[decoration_golden_file]: ./test/golden/decoration/goldens/general_decorations_golden.png

[bar_painter]: ./test/golden/geometry/goldens/bar_geometry_golden.png
[candle_painter]: ./test/golden/geometry/goldens/candle_geometry_golden.png
[bubble_painter]: ./test/golden/geometry/goldens/bubble_geometry_golden.png

[basic_line]: ./test/golden/examples/goldens/simple_line_chart.png
[basic_bar]: ./test/golden/examples/goldens/simple_bar_chart.png
[showcase]: ./assets/showcase.gif