# flutter_charts

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
Options that will have effect on the whole chart.

Padding can only be horizontal, decorations usually ignore this padding.

Options valueAxisMin and valueAxisMax are here to make sure we are showing some 
value on the chart, those items get ignored if some item in data is less than valueAxisMin or more than valueAxisMax.
```
┍━━━━━━━┯━━━━━━━┯━━━━━━━┯━━━━━━━┑ --> valueAxisMax
│       │       │       │       │
│  ┌─┐  │       │       │       │
│  │ │  │       │  ┌─┐  │       │
│  │ │  │  ┌─┐  │  │ │  │       │
│  │ │  │  │ │  │  │ │  │  ┌─┐  │
┕━━┷━┷━━┷━━┷━┷━━┷━━┷━┷━━┷━━┷━┷━━┙ --> valueAxisMin
```

#### Chart item options
Options that apply to each individual item in the chart.

#### Chart behaviour
Scroll + click

#### Chart decorations
Chart decorations are decorations that can be painted in the background or in a foreground of the items.
Everything that is not chart item is a decoration.

### Decorations
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
SelectedItemDecoration
SparkLineDecoration

### Decoration painter
You can make your own custom Decoration by extending `DecorationPainter`

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