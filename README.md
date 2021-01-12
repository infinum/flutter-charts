# flutter_charts

Customizable charts library for flutter.

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

Now you are ready to use charts lib.
This is how you can start, this is simple bar chart with grid decoration:

```dart
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsents.all(8.0),
      child: Chart(
        state: ChartState(
          [1, 3, 4, 2, 7, 6, 2, 5, 4].map((e) => BarValue<void>(e.toDouble())).toList().asMap(),
          itemOptions: ChartItemOptions(
            padding: const EdgeInsets.symmetric(horizontal: 2.0),
            radius: BorderRadius.vertical(top: Radius.circular(12.0)),
          ),
          backgroundDecorations: [
            GridDecoration(
              itemAxisStep: 1,
              valueAxisStep: 1,
              gridColor: Theme.of(context).dividerColor,
            ),
          ],
        ),
      ),
    );
  }
```
Code above will draw this:

![simple_chart]

#### Chart options
Chart options apply to the whole chart widget

#### Chart item options
Chart item options are options that apply to individual items.

#### Chart behaviour
Scroll + click

#### Chart decorations
This deserves more details

### Decorations
There are few of them...

### Decoration painter
You can make your own! Need to lerp!

### Item painters
Draw items! Custom!

## More examples

### Line charts
![line_chart_animating]

### Bar charts
![bar_chart_animating]

### Scrollable chart
![scrollable_chart]

### Candle charts

### Bubble charts

[simple_chart]: ./assets/simple_chart.png
[bar_chart_animating]: ./assets/bar_chart_animating.gif
[scrollable_chart]: ./assets/scrollable_chart.gif
[line_chart_animating]: ./assets/line_chart_animating.gif