import 'dart:math';

import 'package:charts_painter/chart.dart';
import 'package:charts_web/ui/common/respo/respo.dart';
import 'package:charts_web/ui/home/chart_options/widget/options_data_component.dart';
import 'package:charts_web/ui/home/chart_options/widget/options_decoration_component.dart';
import 'package:charts_web/ui/home/chart_options/widget/options_items_component.dart';
import 'package:charts_web/ui/home/presenter/chart_state_provider.dart';
import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ChartOptions extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final _provider = ref.watch(chartStatePresenter);

    return Container(
      margin: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 150,
            child: CupertinoButton.filled(
              child: const Text('Show code'),
              onPressed: () {
                // todo
              },
            ),
          ),
          const SizedBox(height: 24),
          const OptionsDataComponent(),
          const OptionsItemsComponent(),
          const OptionsDecorationComponent(),
        ],
      ),
    );
  }
}
