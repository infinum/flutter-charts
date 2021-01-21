# Flutter charts

Customizable charts library for flutter.

Idea behind this lib is to allow highly customizable charts. By having decorations painters (foreground and background) and item painters that can be easily changed. Customizing and adding new decorations will require some CustomPainter knowledge.

## Showcase
Showcase some charts, animations and decorations

## Usage
Add it to your package's pubspec.yaml file
```yaml
dependencies:
  flutter_charts: ^0.1.0
```

Install packages from the command line
```bash
flutter packages get
```


## Drawing charts
Now you are ready to use charts lib. If chart needs to animate the state changes then use `AnimatedChart<T>` widget instead of `Chart<T>` widget.

`AnimatedChart<T>` needs to specify `Duration` and it can accept `Curve` for animation.
#### Bar Chart
This is how you can start, this is simple bar chart with grid decoration:
```dart
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Chart(
        state: ChartState.fromList(
          [1, 3, 4, 2, 7, 6, 2, 5, 4].map((e) => BarValue<void>(e.toDouble())).toList(),
          itemOptions: ChartItemOptions(
            padding: const EdgeInsets.symmetric(horizontal: 2.0),
            radius: BorderRadius.vertical(top: Radius.circular(12.0)),
          ),
          options: ChartOptions(
            valueAxisMax: 8,
          ),
          backgroundDecorations: [
            GridDecoration(
              itemAxisStep: 1,
              valueAxisStep: 1,
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

By replacing the `BarValue` to `BubbleValue` and changing `itemPainter` to `bubblePainter` we can show nicer line chart with small bubbles on data points:
```dart
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Chart(
        state: ChartState.fromList(
          /// CHANGE: Change [BarValue<void>] to [BubbleValue<void>]
          [1, 3, 4, 2, 7, 6, 2, 5, 4].map((e) => BubbleValue<void>(e.toDouble())).toList(),
          itemOptions: ChartItemOptions(
            padding: const EdgeInsets.symmetric(horizontal: 2.0),
            radius: BorderRadius.vertical(top: Radius.circular(12.0)),
            /// ADDED: Make [BubbleValue] items smaller
            maxBarWidth: 4.0,
          ),
          /// ADDED: Add item painter for BubbleValue ([bubbleItemPainter])
          itemPainter: bubbleItemPainter,
          options: ChartOptions(
            valueAxisMax: 8,
          ),
          backgroundDecorations: [
            GridDecoration(
              itemAxisStep: 1,
              valueAxisStep: 1,
              gridColor: Theme.of(context).dividerColor,
            ),
          ],
          foregroundDecorations: [
            /// ADDED: Add spark line decoration ([SparkLineDecoration]) on foreground
            SparkLineDecoration<void>(),
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
          itemOptions: ChartItemOptions(
            padding: const EdgeInsets.symmetric(horizontal: 2.0),
            radius: BorderRadius.vertical(top: Radius.circular(12.0)),
            maxBarWidth: 4.0,
            /// ADDED: Color bubbles differently depending on List they came from. [ColorForIndex]
            colorForKey: (item, index) {
              return [Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.primaryVariant][index];
            },
          ),
          itemPainter: bubbleItemPainter,
          options: ChartOptions(
            valueAxisMax: 8,
          ),
          backgroundDecorations: [
            GridDecoration(
              itemAxisStep: 1,
              valueAxisStep: 1,
              gridColor: Theme.of(context).dividerColor,
            ),
          ],
          foregroundDecorations: [
            SparkLineDecoration<void>(),

            /// ADDED: Add another [SparkLineDecoration] for the second list
            SparkLineDecoration<void>(
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

Control how multiple values are drawn with `ChartBehaviour.multiItemStack`, this is by default set to `true` and multiple items will just stack one on top of the other. Settings this to `false` will show them in `grouped` state, where they will split the items space between them.
## Chart state customizations 

#### Chart options
Options that will have effect on the whole chart.

- `padding` can only be horizontal, decorations usually ignore this `padding`.
- Options `valueAxisMin` and `valueAxisMax` are here to make sure we are showing some 
value on the chart, those items get ignored if some item in data is less than `valueAxisMin` or more than `valueAxisMax`.
```
┍━━━━━━━┯━━━━━━━┯━━━━━━━┑ --> valueAxisMax
│       │       │       │
│  ┌─┐  │       │       │
│  │ │  │       │  ┌─┐  │
│  │ │  │  ┌─┐  │  │ │  │
│  │ │  │  │ │  │  │ │  │
┕━━┷━┷━━┷━━┷━┷━━┷━━┷━┷━━┙ --> valueAxisMin
```

#### Chart item options
Options that apply to each individual item in the chart.
- `padding` of each chart item, can only be horizontal.
- `radius` of the `BarValue` or `CandleValue`. **`BubbleValue` ignores this.**
- `color` of the chart item, this is default color for chart items that can be changed for specific values with `colorForValue`.
- `maxBarWidth` and `minBarWidth` can control width of each item in the chart.
- `colorForValue` Items can change colors based on value, `AreaTargetDecoration` and `TargetLineDecoration` can pass `.getTargetItemColor()` to change color of items when they miss the target.
- `colorForKey` Multi value charts use this to change color of each dataset. [ex. multibar chart](example/lib/charts/multi_bar_chart_screen.dart) 

#### Chart behaviour
- Setting `isScrollable` to `true` will make the chart ignore it's specified width and should be wrapped in some Scrollable widget in order to display properly.
- Get selected item, `onItemClick` will return index of the clicked item.
- Change how multiple values in the map get drawn, `multiItemStack` by default is set to `true`, and multiple items will just stack on same place, setting this to `false` will divide that place for each item, and they will be shown in `grouped` state.

#### Chart decorations
Chart decorations are decorations that can be painted in the background or in a foreground of the items. Everything that is not chart item is a decoration.

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

### Decoration painter
You can make your own custom Decoration by extending `DecorationPainter`

### Item painters
You can also make your own item painters by extending `ItemPainter`

## More examples
### Line charts
Line chart with multiple values [example code](example/lib/charts/line_chart_screen.dart)
![line_chart_animating]

### Bar charts
Bar chart with area [example code](example/lib/charts/bar_chart_screen.dart)
![bar_chart_animating]

### Scrollable chart
Scrollable bar chart [example code](example/lib/charts/scrollable_chart_screen.dart)
![scrollable_chart]

[simple_chart]: ./assets/simple_chart.png
[simple_line_chart]: ./assets/simple_line_chart.png
[simple_multi_line_chart]: ./assets/simple_multi_line_chart.png
[bar_chart_animating]: ./assets/bar_chart_animating.gif
[scrollable_chart]: ./assets/scrollable_chart.gif
[line_chart_animating]: ./assets/line_chart_animating.gif