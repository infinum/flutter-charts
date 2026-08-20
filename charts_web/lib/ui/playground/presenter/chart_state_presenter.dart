import 'dart:async';

import 'package:charts_painter/chart.dart';
import 'package:charts_web/ui/playground/options/futurama_bar_widget.dart';
import 'package:charts_web/ui/playground/presenter/chart_decorations_presenter.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final chartStatePresenter = ChangeNotifierProvider((ref) {
  return ChartStatePresenter(ref);
});

const _itemBorderSideDefault = BorderSide.none;
const _barBorderRadiusDefault = BorderRadius.zero;

class ChartStatePresenter extends ChangeNotifier {
  ChartStatePresenter(this.ref) {
    _decorationsPresenter = ref.read(chartDecorationsPresenter);
    ref.read(chartDecorationsPresenter).addListener(() {
      notifyListeners();
    });
  }

  final Ref ref;
  late ChartDecorationsPresenter _decorationsPresenter;

  // data
  List<List<ChartItem<void>>> _data = [
    [4, 6, 3, 6, 7, 9, 3, 2].map((e) => ChartItem<void>(e.toDouble())).toList(),
  ];
  DataStrategy _strategy = const StackDataStrategy();
  bool showMaxDataListMessage = false;

  /// Axis bounds. Null lets the data decide; axisMin is what opens space below
  /// zero for negative values.
  double? axisMin;
  double? axisMax;

  /// Headroom above the tallest value. Templates that draw labels above their
  /// bars need more of it.
  double valueAxisMaxOver = 2.0;

  /// Non-null makes the chart scrollable and fixes how many items fit on
  /// screen. The chart must then be wrapped in a horizontal scroll view.
  double? visibleItems;

  List<Color> listColors = [_presetColors[0]];

  // Items
  EdgeInsets chartItemPadding =
      const EdgeInsets.only(left: 2, right: 2, top: 0, bottom: 0);
  SelectedPainter selectedPainter = SelectedPainter.bar;
  WidgetItemExample widgetItemExample = WidgetItemExample.image;
  double? maxBarWidth;
  double? minBarWidth;
  List<BorderSide> itemBorderSides = [_itemBorderSideDefault];
  Map<int, LinearGradient> gradient = {};

  // bar item specific
  List<BorderRadius> barBorderRadius = [_barBorderRadiusDefault];

  /// Where in its slot an item starts. BarItemOptions only; BubbleItemOptions
  /// has no startPosition.
  double startPosition = 0.5;

  // multi item specific
  bool stackMultipleValues = true;
  EdgeInsets multiValuePadding = EdgeInsets.zero;

  bool get isMultiItem => _data.length > 1;

  ChartData<void> get _defaultData => ChartData(
        _data,
        dataStrategy: _strategy,
        valueAxisMaxOver: valueAxisMaxOver,
        axisMin: axisMin,
        axisMax: axisMax,
      );

  bool get isScrollable => visibleItems != null;

  List<List<ChartItem<void>>> get data => _data;

  ChartBehaviour _behaviour = const ChartBehaviour();

  ChartState<void> get state => ChartState(
        data: _defaultData,
        itemOptions: _getItemOptions(),
        behaviour: visibleItems == null
            ? _behaviour
            : ChartBehaviour(
                scrollSettings: ScrollSettings(visibleItems: visibleItems),
                onItemClicked: _behaviour.onItemClicked,
              ),
        foregroundDecorations:
            _decorationsPresenter.foregroundDecorations.values.toList(),
        backgroundDecorations:
            _decorationsPresenter.backgroundDecorations.values.toList(),
      );

  void updateData(List<List<ChartItem<void>>> data) {
    _data = data;
    notifyListeners();
  }

  void addDataList(List<ChartItem<void>> list) {
    if (_data.length == 5) {
      showMaxDataListMessage = true;
      notifyListeners();
      return;
    }

    _data.add(list);

    /// Add all per-value collections
    listColors.add(_presetColors[_data.length - 1]);
    barBorderRadius.add(_barBorderRadiusDefault);
    itemBorderSides.add(_itemBorderSideDefault);

    notifyListeners();
  }

  void removeDataList(int listIndex) {
    if (showMaxDataListMessage) {
      showMaxDataListMessage = false;
    }

    data.removeAt(listIndex);

    _decorationsPresenter.removeDecorationsDependentOnData(listIndex);

    /// When deleting we still need data a little bit for lerp animation to finish
    scheduleMicrotask(() async {
      await Future.delayed(const Duration(milliseconds: 30));
      listColors.removeAt(listIndex);
      barBorderRadius.removeAt(listIndex);
      itemBorderSides.removeAt(listIndex);
      notifyListeners();
    });

    notifyListeners();
  }

  void updateListColor(Color color, int listIndex) {
    listColors[listIndex] = color;
    notifyListeners();
  }

  void updateDataStrategy(DataStrategy dataStrategy) {
    _strategy = dataStrategy;
    notifyListeners();
  }

  void updateStackMultipleValues(bool newValue) {
    if (_strategy is DefaultDataStrategy) {
      _strategy = DefaultDataStrategy(stackMultipleValues: newValue);
      stackMultipleValues = newValue;
      notifyListeners();
    }
    // Nothing to do for StackDataStrategy: stacking is already what it does,
    // and the UI only offers this toggle for DefaultDataStrategy.
  }

  void updateChartBehaviour(ChartBehaviour behaviour) {
    _behaviour = behaviour;
    notifyListeners();
  }

  void updateItemPainter(SelectedPainter painter) {
    selectedPainter = painter;
    notifyListeners();
  }

  void updateChartItemPadding(EdgeInsets newChartItemPadding) {
    chartItemPadding = newChartItemPadding;
    notifyListeners();
  }

  void updateItemWidth({
    double maxItemWidth = -1,
    double minItemWidth = -1,
  }) {
    maxBarWidth = maxItemWidth == -1 ? maxBarWidth : maxItemWidth;
    minBarWidth = minItemWidth == -1 ? minBarWidth : minItemWidth;
  }

  /// [ItemOptions] asserts `maxBarWidth >= minBarWidth`, so the pair has to
  /// stay ordered. Rather than refuse the edit, the other bound is carried
  /// along: raising the minimum above the maximum pushes the maximum up, and
  /// lowering the maximum below the minimum pulls the minimum down.
  void updateMinBarWidth(double newMinBarWidth) {
    minBarWidth = newMinBarWidth.clamp(0.0, double.infinity);

    final currentMax = maxBarWidth;
    if (currentMax != null && currentMax < minBarWidth!) {
      maxBarWidth = minBarWidth;
    }

    notifyListeners();
  }

  void updateMaxBarWidth(double newMaxBarWidth) {
    maxBarWidth = newMaxBarWidth.clamp(0.0, double.infinity);

    final currentMin = minBarWidth;
    if (currentMin != null && currentMin > maxBarWidth!) {
      minBarWidth = maxBarWidth;
    }

    notifyListeners();
  }

  void updateStartPosition(double newStartPosition) {
    startPosition = newStartPosition;
    notifyListeners();
  }

  void updateValueAxisMaxOver(double value) {
    valueAxisMaxOver = value;
    notifyListeners();
  }

  void updateAxisMin(double? value) {
    axisMin = value;
    notifyListeners();
  }

  void updateAxisMax(double? value) {
    axisMax = value;
    notifyListeners();
  }

  void updateVisibleItems(double? value) {
    visibleItems = value;
    notifyListeners();
  }

  void updateWidgetItemExample(WidgetItemExample example) {
    widgetItemExample = example;
    notifyListeners();
  }

  void updateMultiValuePadding(EdgeInsets newPadding) {
    multiValuePadding = newPadding;
    notifyListeners();
  }

  void updateBarBorderRadius(BorderRadius newValue, int index,
      {bool forAll = false}) {
    barBorderRadius[index] = newValue;

    if (forAll) {
      for (int i = 0; i < barBorderRadius.length; i++) {
        barBorderRadius[i] = newValue;
      }
    }

    notifyListeners();
  }

  void updateItemBorderSide(BorderSide newSize, int index) {
    itemBorderSides[index] = newSize;
    notifyListeners();
  }

  void updateGradient(LinearGradient? newGradient, int index) {
    if (newGradient == null) {
      gradient.removeWhere((key, value) => key == index);
    } else {
      gradient[index] = newGradient;
    }
    notifyListeners();
  }

  ItemOptions _getItemOptions() {
    if (selectedPainter == SelectedPainter.bubble) {
      return BubbleItemOptions(
        padding: chartItemPadding,
        bubbleItemBuilder: (data) {
          return BubbleItem(
            color: _getColorForList(data.listIndex),
            gradient: gradient[data.listIndex],
            border: itemBorderSides[data.listIndex],
          );
        },
        maxBarWidth: maxBarWidth,
        minBarWidth: minBarWidth,
        multiValuePadding: multiValuePadding,
      );
    } else if (selectedPainter == SelectedPainter.bar) {
      return BarItemOptions(
        padding: chartItemPadding,
        startPosition: startPosition,
        barItemBuilder: (data) {
          return BarItem(
            color: _getColorForList(data.listIndex),
            gradient: gradient[data.listIndex],
            border: itemBorderSides[data.listIndex],
            // null rather than zero, matching what you would write by hand.
            radius: barBorderRadius[data.listIndex] == BorderRadius.zero
                ? null
                : barBorderRadius[data.listIndex],
          );
        },
        maxBarWidth: maxBarWidth,
        minBarWidth: minBarWidth,
        multiValuePadding: multiValuePadding,
      );
    } else if (selectedPainter == SelectedPainter.none) {
      return BubbleItemOptions(
        bubbleItemBuilder: (_) {
          return const BubbleItem(color: Colors.transparent);
        },
        maxBarWidth: 0,
        minBarWidth: 0,
      );
    } else if (selectedPainter == SelectedPainter.widget) {
      return WidgetItemOptions(
        multiValuePadding: multiValuePadding,
        maxBarWidth: maxBarWidth,
        minBarWidth: minBarWidth,
        widgetItemBuilder: (data) {
          if (widgetItemExample == WidgetItemExample.valueLabel) {
            return _ValueLabelItem(
              color: _getColorForList(data.listIndex),
              value: data.item.max ?? 0,
            );
          }

          return FuturamaBarWidget(
              stackItems: stackMultipleValues,
              listKey: data.listIndex,
              item: data.item);
        },
      );
    } else {
      throw 'Unknown selected painter';
    }
  }

  Color _getColorForList(int listKey) {
    return listColors[listKey % 5];
  }
}

enum SelectedPainter { bar, bubble, none, widget }

/// Which demo widget `WidgetItemOptions` draws. The point of the painter is
/// that any widget works, so the playground offers more than one.
enum WidgetItemExample { image, valueLabel }

/// A bar that prints its own value, the modern replacement for the deprecated
/// `ValueDecoration`.
class _ValueLabelItem extends StatelessWidget {
  const _ValueLabelItem({required this.color, required this.value});

  final Color color;
  final double value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        children: [
          Text(
            value.toStringAsFixed(0),
            style: Theme.of(context).textTheme.labelSmall,
          ),
          Expanded(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: color,
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(4)),
              ),
              child: const SizedBox.expand(),
            ),
          ),
        ],
      ),
    );
  }
}

const _presetColors = [
  Color(0xFFD8555F),
  Color(0xFFD9A866),
  Color(0xFF916794),
  Color(0xFF6479C3),
  Color(0xFF5A8772),
];
