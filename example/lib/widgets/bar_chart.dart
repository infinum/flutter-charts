import 'package:charts_painter/chart.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

typedef DataToValue<T> = double Function(T item);
typedef DataToAxis<T> = String Function(int item);

class BarChart<T> extends StatelessWidget {
  BarChart({
    required List<T> data,
    required DataToValue<T> dataToValue,
    this.height = 240.0,
    this.backgroundDecorations = const [],
    this.foregroundDecorations = const [],
    this.chartBehaviour = const ChartBehaviour(),
    this.itemOptions = const BarItemOptions(),
    this.itemOptionsBuilder,
    this.stack = false,
    Key? key,
  })  : _mappedValues = [data.map((e) => BarValue<T>(dataToValue(e))).toList()],
        super(key: key);

  const BarChart.map(
    this._mappedValues, {
    this.height = 240.0,
    this.backgroundDecorations = const [],
    this.foregroundDecorations = const [],
    this.chartBehaviour = const ChartBehaviour(),
    this.itemOptions = const BarItemOptions(),
    this.itemOptionsBuilder,
    this.stack = false,
    Key? key,
  }) : super(key: key);

  final List<List<BarValue<T>>> _mappedValues;
  final double height;

  final bool stack;
  final ItemOptions itemOptions;
  final ItemOptionsBuilder? itemOptionsBuilder;
  final ChartBehaviour chartBehaviour;
  final List<DecorationPainter> backgroundDecorations;
  final List<DecorationPainter> foregroundDecorations;

  @override
  Widget build(BuildContext context) {
    final _data = ChartData<T>(
      _mappedValues,
      valueAxisMaxOver: 1,
      dataStrategy: stack ? StackDataStrategy() : DefaultDataStrategy(),
    );

    return AnimatedChart<T>(
      height: height,
      width: MediaQuery.of(context).size.width - 24.0,
      duration: const Duration(milliseconds: 450),
      state: ChartState<T>(
        _data,
        dataRenderer: ChartState.widgetItemRenderer(
          _data.items.mapIndexed((e, _) => (itemOptionsBuilder ?? ((int i) => itemOptions))(e)).toList(),
          (item, itemKey, listKey) {
            // if (listKey == 0) {
            //   return Container(
            //     margin: const EdgeInsets.symmetric(horizontal: 3.0),
            //     decoration: BoxDecoration(
            //       borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            //       border: Border.all(),
            //     ),
            //     child: ClipRRect(
            //       borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            //       child: Image.network(
            //         'https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Ftse1.mm.bing.net%2Fth%3Fid%3DOIP.LxlHIr73N2FnqJ3t0TEn-gHaFr%26pid%3DApi&f=1&ipt=afa66b22e9421c69abbb25704c5e4bcb39e4799643ebbdedcabf90ab8af40a6f&ipo=images',
            //         fit: BoxFit.fill,
            //       ),
            //     ),
            //   );
            // }

            final _images = [
              'https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Ftse1.mm.bing.net%2Fth%3Fid%3DOIP.LxlHIr73N2FnqJ3t0TEn-gHaFr%26pid%3DApi&f=1&ipt=afa66b22e9421c69abbb25704c5e4bcb39e4799643ebbdedcabf90ab8af40a6f&ipo=images',
              'https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Fimages3.alphacoders.com%2F283%2F28305.jpg&f=1&nofb=1&ipt=901963091e95b05a0e8de0829ed79cfb7a310a1c45c155f3a7e5bb9d299b4a56&ipo=images',
              'https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2F66.media.tumblr.com%2F737584aa0cc9d02de5a24bb151f57b53%2Ftumblr_inline_o8xhyaVYPH1sss5ih_1280.png&f=1&nofb=1&ipt=d00e38cf1c3af3a8e42ba24f516da8d696495d9b989a77beedb04d7534c8fb9d&ipo=images',
            ];
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 3.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(listKey == 0 ? 12 : 0)),
                border: Border.all(
                  width: 2,
                  color: Colors.accents[listKey],
                ),
              ),
              foregroundDecoration: BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(listKey == 0 ? 12 : 0)),
                color: Colors.accents[listKey].withOpacity(0.2),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(listKey == 0 ? 12 : 0)),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Image.network(
                        _images[listKey],
                        fit: BoxFit.fill,
                      ),
                    ),
                    Positioned(
                      left: 0.0,
                      right: 0.0,
                      child: Text(
                        '${item.max?.toStringAsFixed(2)}',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.subtitle1!.copyWith(
                              color: Colors.black87,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            );

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 3.0),
              color: listKey == 1 ? Colors.red : Colors.blue,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text('${item.max?.toStringAsFixed(2)}'),
                  SizedBox(height: 8),
                  Text('Item: $itemKey'),
                  Text('Key: $listKey'),
                ],
              ),
            );
          },
        ),
        itemOptions: itemOptions,
        itemOptionsBuilder: itemOptionsBuilder,
        behaviour: chartBehaviour,
        foregroundDecorations: foregroundDecorations,
        backgroundDecorations: [
          ...backgroundDecorations,
        ],
      ),
    );
  }
}
