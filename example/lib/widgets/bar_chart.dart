import 'package:charts_painter/chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

typedef DataToValue<T> = double Function(T item);
typedef DataToAxis<T> = String Function(int item);

class BarChart<T> extends StatelessWidget {
  BarChart({
    @required List<T> data,
    @required this.dataToValue,
    this.height = 240.0,
    this.backgroundDecorations,
    this.foregroundDecorations,
    this.chartBehaviour = const ChartBehaviour(),
    this.itemOptions = const BarItemOptions(),
    this.stack = false,
    Key key,
  })  : _mappedValues = [data.map((e) => BarValue<T>(dataToValue(e))).toList()],
        super(key: key);

  const BarChart.map(
    this._mappedValues, {
    this.height = 240.0,
    this.backgroundDecorations,
    this.foregroundDecorations,
    this.chartBehaviour = const ChartBehaviour(),
    this.itemOptions = const BarItemOptions(),
    this.stack = false,
    Key key,
  })  : dataToValue = null,
        super(key: key);

  final DataToValue<T> dataToValue;
  final List<List<ChartItem<T>>> _mappedValues;
  final double height;

  final bool stack;
  final ItemOptions itemOptions;
  final ChartBehaviour chartBehaviour;
  final List<DecorationPainter> backgroundDecorations;
  final List<DecorationPainter> foregroundDecorations;

  @override
  Widget build(BuildContext context) {
    final _foregroundDecorations = foregroundDecorations ?? <DecorationPainter>[];
    final _backgroundDecorations = backgroundDecorations ?? <DecorationPainter>[];

    return AnimatedChart<T>(
      height: height,
      width: MediaQuery.of(context).size.width - 24.0,
      duration: const Duration(milliseconds: 450),
      state: ChartState<T>(
        ChartData(
          _mappedValues,
          valueAxisMaxOver: 1,
          dataStrategy: stack ? StackDataStrategy() : DefaultDataStrategy(),
        ),
        dataRenderer: ChartState.widgetItemRenderer(
          [itemOptions],
          (item, listKey) => Container(
            margin: const EdgeInsets.symmetric(horizontal: 3.0),
            color: Colors.blue,
            // child: Image.network(
            //   'https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Ftse1.mm.bing.net%2Fth%3Fid%3DOIP.LxlHIr73N2FnqJ3t0TEn-gHaFr%26pid%3DApi&f=1&ipt=afa66b22e9421c69abbb25704c5e4bcb39e4799643ebbdedcabf90ab8af40a6f&ipo=images',
            //   fit: BoxFit.fitHeight,
            // ),
          ),
        ),
        itemOptions: itemOptions,
        behaviour: chartBehaviour,
        foregroundDecorations: _foregroundDecorations,
        backgroundDecorations: [
          ..._backgroundDecorations,
        ],
      ),
    );
  }
}
