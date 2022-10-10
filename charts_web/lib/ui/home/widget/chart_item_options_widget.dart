import 'package:charts_web/ui/home/presenter/chart_state_provider.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ChartItemOptionsWidget extends HookConsumerWidget {
  const ChartItemOptionsWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final _provider = ref.watch(chartStatePresenter);

    return Column(
      children: [
        Text(
          'Options',
          style: Theme.of(context).textTheme.headline4,
        ),
        Row(
          children: [
            Expanded(child: Text('Type')),
            DropdownButton<bool>(
              value: _provider.bubbleItemPainter,
              onChanged: (value) {
                _provider.updateGeometryRenderer(value ?? false);
              },
              items: [
                DropdownMenuItem(
                  value: true,
                  child: Text('Bubble'),
                ),
                DropdownMenuItem(
                  value: false,
                  child: Text('Bar'),
                ),
              ],
            ),

            // /// Max width of item in the chart
            // final double? maxBarWidth;
            //
            // /// Min width of item in the chart
            // final double? minBarWidth;
            // final EdgeInsets? padding;
            // final double? startPosition;
          ],
        ),
      ],
    );
  }
}

class _BarItemOptions extends ConsumerWidget {
  _BarItemOptions({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container();
  }
}
