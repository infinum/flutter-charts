import 'package:charts_web/assets.gen.dart';
import 'package:charts_web/ui/home/chart_options/widget/options_data_component.dart';
import 'package:charts_web/ui/home/chart_options/widget/options_decoration_component.dart';
import 'package:charts_web/ui/home/chart_options/widget/options_items_component.dart';
import 'package:example/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
          Text(
            'Welcome to charts_painter playground. Here we exposed some options to see what kind of charts you can build. Make sure to check showcase for more examples.',
            style: Theme.of(context).textTheme.bodyText1,
          ),
          const SizedBox(height: 16),
          CupertinoButton.filled(
            child: Row(
              children: [
                Opacity(
                    opacity: 0.8,
                    child: SvgPicture.asset(Assets.svg.showcase, width: 50)),
                const SizedBox(width: 16),
                const Text('Showcase'),
              ],
            ),
            padding: const EdgeInsets.all(24),
            onPressed: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (_) => ChartDemo()));
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
