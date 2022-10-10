import 'package:charts_web/ui/home/presenter/chart_state_provider.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'options_component_header.dart';

const _subtitle = '''Options that define how each item looks. There are presets for Bar and Bubble. For super custom solutions you can extend GeomeryPainter and make your own item look.
''';

class OptionsItemsComponent extends HookConsumerWidget {
  const OptionsItemsComponent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final _provider = ref.watch(chartStatePresenter);

    return Column(
      children: [
        const OptionsComponentHeader(title: 'Item Options', subtitle: _subtitle),
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
        const SizedBox(height: 24),
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
