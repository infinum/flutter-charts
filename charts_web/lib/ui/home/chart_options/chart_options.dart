
import 'package:charts_web/ui/home/chart_options/widget/options_data_component.dart';
import 'package:charts_web/ui/home/chart_options/widget/options_decoration_component.dart';
import 'package:charts_web/ui/home/chart_options/widget/options_items_component.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ChartOptions extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CupertinoButton.filled(
            child: const Text('Show code'),
            onPressed: () {
              // todo
            },
          ),
          const SizedBox(height: 24),
          const OptionsDataComponent(),
          const SizedBox(height: 16),
          const OptionsItemsComponent(),
          const SizedBox(height: 16),
          const DecorationsComponent(),
        ],
      ),
    );
  }
}
