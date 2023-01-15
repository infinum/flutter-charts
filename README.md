![](https://raw.githubusercontent.com/infinum/flutter-charts/master/assets/chart_image.png)

# Charts painter    [![pub package](https://img.shields.io/pub/v/charts_painter?logo=flutter&style=for-the-badge)](https://pub.dartlang.org/packages/charts_painter)
Idea behind this lib is to allow highly customizable charts. By having items and decorations as Widgets or predefined renderers where you can achieve the look of desired chart.

### [3.0 Migration guide](https://github.com/infinum/flutter-charts/wiki/Migration-guide-to-3.0)
Read the migration guide if you are interested in migrating from 2.0 to 3.0.

## [Web demo](https://infinum.github.io/flutter-charts/)

Check out [web demo](https://infinum.github.io/flutter-charts/) to see what’s possible to do with the charts_painter

<img src="https://raw.githubusercontent.com/infinum/flutter-charts/master/assets/showcase.gif" data-canonical-src="https://raw.githubusercontent.com/infinum/flutter-charts/master/assets/showcase.gif" height="300" />

## Usage

Add it to your package’s pubspec.yaml file

```yaml
charts_painter: latest
```

## Start with the Chart

The Widget you can use is `Chart` or `AnimatedChart` if you want to show animations when changing chart state. It has parameters of `height`, `width` and `ChartState`.

## Chart State

`ChartState` describes how the chart should look. The chart drawing is divided into sections, so the `ChartState` has these parameters:

- **Data**: What is the data that needs to be shown
- **Item options**: How to draw that data points into items on chart
- **Decorations**: Various additional objects that enhance and completes look of the chart. They are divided into backgroundDecorations (behind items) or in foregroundDecorations (in front of items).
- **Chart behaviour**: Not used for drawing, but contain scrollable and item click logic

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

Chart Item requires `max` height parameter, but also has optional `min` and `T value` which can be any kind of value
that you can attach to your items, if you have need for it.

![](https://user-images.githubusercontent.com/11093480/199758353-998db45a-6184-430a-9818-b3f2e5f50b7c.png)

When displaying multiple data lines, you might be interested in `dataStrategy` parameter. It controls how these multiple lines are drawn. For example, if you want to stack bars, one on top of another, you can use `StackDataStrategy`.

Parameter `valueAxisMaxOver` will add that value to currently the highest value that functions like a some sort of top padding.

## Item options

For item options, you can use one of three defined options:

- `BarItemOptions` - for drawing bar or candle items
- `BubbleItemOptions` - for draw bubble items
- `WidgetItemOptions` - for drawing any kind of widget.

You could create anything with `WidgetItemOptions`, but Bar and Bubble are often used and here they are drawn directly on canvas to make sure chart is performant. This graphic might help when choosing:

![](https://user-images.githubusercontent.com/11093480/198997421-d8474537-4192-4005-862c-baaaab6b1822.png)

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

The `data` that’s passed into the builder can be used to build different kind of item based on the item value (`data.item.value`), his index in data (`data.itemIndex`) or based on which data list it belongs to (`data.listIndex`).

Besides builder, the other useful parameters in item options are `maxBarWidth` , `minBarWidth` , `startPosition` , `padding` and `widthCalculator`.
`widthCalculator` is used in scrollable charts when `visibleItems` is not `null` and it provides a way to control the width of items.

If you want to listen to **item taps** you can do it by setting `ChartBehaviour(onItemClicked)` - you can read more about ChartBehaviour below.
In case of a WidgetItemOptions, you could also provide GestureDetectors and Buttons and they will all work.

## Decorations

Decorations enhance and complete the look of the chart. Everything that’s drawn on a chart, and it’s not a chart item is considered a decoration. So that means a lot of the chart will be a decoration. Just like with the items, you can use **WidgetDecoration** to draw any kind of the decoration, but the most common cases for decoration are already made on a canvas and ready to be used:

|   |   |   |
:------: | :------: | :------:
[![horizontal_decoration] Horizontal decoration](https://github.com/infinum/flutter-charts/blob/master/test/golden/GOLDENS.md#horizontal-decoration-golden) | [![vertical_decoration] Vertical decoration](https://github.com/infinum/flutter-charts/blob/master/test/golden/GOLDENS.md#vertical-decoration-golden) | [![grid_decoration] Grid decoration](https://github.com/infinum/flutter-charts/blob/master/test/golden/GOLDENS.md#grid-decoration-golden)
[![sparkline_decoration] Sparkline decoration](https://github.com/infinum/flutter-charts/blob/master/test/golden/GOLDENS.md#sparkline-decoration-golden) |


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

![](https://user-images.githubusercontent.com/11093480/198998268-698593c3-11d3-4d77-a1a1-6f998c6a64b3.png)

If you do add margins to the chart, your decoration widget will be positioned from start of the chart (not affected by the margins), so you can draw in the margins.
You can add padding that equals the chart margins which will set you to the start of the first item so calculations including `itemWidth` or `verticalMultiplier` works correctly:

```dart
    widgetDecorationBuilder: (context, chartState, itemWidth, verticalMultiplayer) {
      return Padding(padding: chartState.defaultMargin, child: YourWidget());
    },
```

## Chart behaviour

Chart behaviour has just three parameters:

- `isScrollable` - will render a chart that can support scrolling. You still need to wrap it with SingleChildScrollView.
- `visibleItems` - used when `isScrollable` is set to `true`. Indicates how many items should visible on the screen
- `onItemClicked` - when set the tap events on items are registered and will invoke this method.
If you're using WidgetItemOptions, you could set a gesture detector there, but this works with both BarItemOptions, BubbleItemOptions and WidgetItemOptions.

## Complete example

So, to wrap all of this up. The most minimal example of a bar chart with *data, barItemOptions** and no **decorations** would looks like:

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

![](https://user-images.githubusercontent.com/11093480/198998394-43252209-4c0c-47f0-9f9f-43db897b7606.png)

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
          return BarItem(color: itemBuilderData.listIndex == 0 ? Colors.red : Colors.blue);
        }),
        backgroundDecorations: [
          HorizontalDecoration(axisStep: 2, showValues: true),
        ])
  );
```

Which produces a chart:

![](https://user-images.githubusercontent.com/11093480/198998481-2e98eaae-2ee9-4e49-9e0d-c9a3edb0250b.png)

There’s a lot more things possible with this package, but to keep this README readable, we recommend you checking out the [demo and showcase web app](https://infinum.github.io/flutter-charts/).

### Scrollable chart

Charts can also be scrollable, to use scroll first you have to wrap chart your chart in `SingleChildScrollView` widget. Then in `ChartBehaviour` make sure you set `isScrollable` to true.

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


[horizontal_decoration]: https://raw.githubusercontent.com/infinum/flutter-charts/master/test/golden/decoration/goldens/macos/general_horizontal_decoration_golden.png
[vertical_decoration]: https://raw.githubusercontent.com/infinum/flutter-charts/master/test/golden/decoration/goldens/macos/general_vertical_decoration_golden.png
[grid_decoration]: https://raw.githubusercontent.com/infinum/flutter-charts/master/test/golden/decoration/goldens/macos/general_grid_decoration_golden.png
[border_decoration]: https://raw.githubusercontent.com/infinum/flutter-charts/master/test/golden/decoration/goldens/macos/general_border_decoration_golden.png
[sparkline_decoration]: https://raw.githubusercontent.com/infinum/flutter-charts/master/test/golden/decoration/goldens/macos/general_sparkline_decoration_golden.png
[target_line_decoration]: https://raw.githubusercontent.com/infinum/flutter-charts/master/test/golden/decoration/goldens/macos/general_target_line_decoration_golden.png
[target_area_decoration]: https://raw.githubusercontent.com/infinum/flutter-charts/master/test/golden/decoration/goldens/macos/general_target_area_decoration_golden.png
[target_line_legend_decoration]: https://raw.githubusercontent.com/infinum/flutter-charts/master/test/golden/decoration/goldens/macos/general_target_line_text_decoration_golden.png
[selected_item_decoration]: https://raw.githubusercontent.com/infinum/flutter-charts/master/test/golden/decoration/goldens/macos/general_selected_item_decoration_golden.png
[target_values_decoration]: https://raw.githubusercontent.com/infinum/flutter-charts/master/test/golden/decoration/goldens/macos/general_value_decoration_golden.png

<p align="center">
  <a href='https://infinum.com'>
    <picture>
        <source srcset="https://assets.infinum.com/brand/logo/static/white.svg" media="(prefers-color-scheme: dark)">
        <img src="https://assets.infinum.com/brand/logo/static/default.svg">
    </picture>
  </a>
</p>
