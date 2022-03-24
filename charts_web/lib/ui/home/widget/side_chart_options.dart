import 'package:charts_web/ui/home/provider/chart_state_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SideChartOptions extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final _provider = ref.watch(chartStateProvider);

    return Container(
      margin: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Charts painter example',
            style: Theme.of(context).textTheme.headline5,
          ),
          Divider(),
          Text(
            'Data',
            style: Theme.of(context).textTheme.headline6,
          ),
          ..._provider.state.data.items.map((list) {
            return Row(
              children: list
                  .map((item) =>
                      Text('${(item.max ?? item.min)?.toStringAsFixed(0) ?? ''}${list.last == item ? '' : ', '}'))
                  .toList(),
            );
          }).toList()
        ],
      ),
    );
  }
}
