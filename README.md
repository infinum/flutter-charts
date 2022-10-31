![chart_image]

# Charts painter    [![pub package](https://img.shields.io/pub/v/charts_painter?logo=flutter&style=for-the-badge)](https://pub.dartlang.org/packages/charts_painter)
Idea behind this lib is to allow highly customizable charts. By having items and decorations as Widgets or predefined renderers where you can achieve the look of desired chart.

## [Web demo](https://infinum.github.io/flutter-charts/)

Check out [web demo](https://infinum.github.io/flutter-charts/) to see what’s possible to do with the charts_painter

<img src="https://raw.githubusercontent.com/infinum/flutter-charts/master/assets/showcase.gif" data-canonical-src="https://raw.githubusercontent.com/infinum/flutter-charts/master/assets/showcase.gif" height="250" />

## Usage

Add it to your package’s pubspec.yaml file

```yaml
charts_painter: latest
```

## Start with the Chart

The Widget you can use is `Chart` or `AnimatedChart` if you want to show animations when changing chart state. It has parameters of `height`, `width` and `ChartState`.

## Chart State

`ChartState` describes how the chart should look. The chart drawing is divided into three sections, so the `ChartState` has these parameters:

- **Data**: What is the data that needs to be shown
- **Item options**: How to draw that data points into items on chart
- **Decorations**: Various additional objects that enhance and completes look of the chart. They are divided into backgroundDecorations (behind items) or in foregroundDecorations (in front of items).

Now we will explain each of these:

## Data

The `ChartData` only required parameter is `List<List<ChartItem>>`. So, most basic data would look like:

```dart
ChartData([
    [
      ChartItem(2),
      ChartItem(5),
      ChartItem(7),
      ChartItem(11),
      ChartItem(4),
    ]
  ])
```

The reason for double list (`List<List<`) is that you can display multiple data lines alongside each other.

```dart
ChartData([
    [2, 6, 8, 4, 6, 8].map((e) => ChartItem<void>(e.toDouble())).toList(),
    [3, 5, 2, 7, 0, 4].map((e) => ChartItem<void>(e.toDouble())).toList(),
  ],);
```

When displaying multiple data lines, you might be interested in `dataStrategy` parameter. It controls how these multiple lines are drawn. For example, if you want to stack bars, one on top of another, you can use `StackDataStrategy`.

Parameter `valueAxisMaxOver` will add that value to currently the highest value that functions like a some sort of top padding.

## Item options

For item options, you can use one of three defined options:

- `BarItemOptions` - for drawing bar or candle items
- `BubbleItemOptions` - for draw bubble items
- `WidgetItemOptions` - for drawing any kind of widget.

You could create anything with `WidgetItemOptions`, but Bar and Bubble are often used and here they are drawn directly on canvas to make sure chart is performant. This graphic might help when choosing:

[insert graphic here]

Options have several parameter, and the required is `itemBuilder`. With it, you describe how to build an item. For example, to make bar item:

```dart
barItemBuilder: (data) {
    return BarItem(
      radius: const BorderRadius.vertical(
        top: Radius.circular(24.0),
      ),
      color: Colors.red.withOpacity(0.4),
    );
  },
```

The `data` that’s passed into the builder can be used to build different kind of item based on the item value (`data.item.value`), his index in data (`data.itemKey`) or based on which data list it belongs to (`data.listKey`).

Besides builder, the other useful parameters in item options are `maxBarWidth` , `minBarWidth` , `startPosition` and `padding`.

## Decorations

Decorations enhance and complete the look of the chart. Everything that’s drawn on a chart, and it’s not a chart item is considered a decoration. So that means a lot of the chart will be a decoration. Just like with the items, you can use ********************************WidgetDecoration******************************** to draw any kind of the decoration, but the most common cases for decoration are already made on a canvas and ready to be used:

[insert decorations here]

### Widget decoration

There are only two parameters in WidgetDecoration:

```dart
WidgetDecoration(
    widgetDecorationBuilder: (context, chartState, itemWidth, verticalMultiplayer) {
      return Container(); // Your widget goes here
    },
    margin: const EdgeInsets.only(left: 20),
)
```

The builder returns context, `chartState` where from you can read details like all the values. And `itemWidth` and `verticalMultiplier` can help with laying out and position the decoration:

[insert graphic here]

It's possible that you want to draw in the margins of the chart. For this case you can use `Transform.translate` or negative value in `Positioned` that's placed in `Stack`.

## Complete example

So, to wrap all of this up. The most minimal example of a bar chart with ******************************************data, barItemOptions****************************************** and no ************decorations************ would looks like:

```dart
Chart(
    state: ChartState<void>(
      data: ChartData(
          [[3,5,7,9,4,3,6].map((e) => ChartItem<void>(e.toDouble())).toList()]
      ),
      itemOptions: BarItemOptions()
    ),
  );
```

Which will produce a chart looking like:

[insert graphic here]

A bit more complex example with two data lists coloured differently and grid decoration would look like:

```dart
Chart(
    state: ChartState<void>(
        data: ChartData(
          [
            [3, 5, 7, 9, 4, 3, 6].map((e) => ChartItem<void>(e.toDouble())).toList(),
            [5, 2, 8, 4, 5, 5, 2].map((e) => ChartItem<void>(e.toDouble())).toList(),
          ],
        ),
        itemOptions: BarItemOptions(barItemBuilder: (itemBuilderData) {
          // Setting the different color based if the item is from first or second list
          return BarItem(color: itemBuilderData.listKey == 0 ? Colors.red : Colors.blue);
        }),
        backgroundDecorations: [
          HorizontalDecoration(axisStep: 2, showValues: true),
        ])
  );
```

Which produces a chart:

[insert graphic here]

There’s a lot more things possible with this package, but to keep this README readable, we recommend you checking out the [demo and showcase web app](https://infinum.github.io/flutter-charts/).

### Scrollable chart

Charts can also be scrollable, to use scroll first you have to wrap chart your chart in `SingleChildScrollView` widget. Then in `ChartBehaviuor` make sure you set `isScrollable` to true.

![https://raw.githubusercontent.com/infinum/flutter-charts/master/assets/scrollable_chart.gif](https://raw.githubusercontent.com/infinum/flutter-charts/master/assets/scrollable_chart.gif)

scrollable_chart

To make sure you can make any chart you want, we have included `DecorationsRenderer` as widget that you can use outside of the chart bounds. That is useful for fixed legends:

## More examples

### Line charts

Line chart with multiple values

[example code](https://raw.githubusercontent.com/infinum/flutter-charts/master/example/lib/charts/line_chart_screen.dart)

![https://raw.githubusercontent.com/infinum/flutter-charts/master/assets/line_chart_animating.gif](https://raw.githubusercontent.com/infinum/flutter-charts/master/assets/line_chart_animating.gif)

### Bar charts

Bar chart with area

[example code](https://raw.githubusercontent.com/infinum/flutter-charts/master/example/lib/charts/bar_chart_screen.dart)

![https://raw.githubusercontent.com/infinum/flutter-charts/master/assets/bar_chart_animating.gif](https://raw.githubusercontent.com/infinum/flutter-charts/master/assets/bar_chart_animating.gif)

### Scrollable chart

Scrollable bar chart

[example code](https://raw.githubusercontent.com/infinum/flutter-charts/master/example/lib/charts/scrollable_chart_screen.dart)
