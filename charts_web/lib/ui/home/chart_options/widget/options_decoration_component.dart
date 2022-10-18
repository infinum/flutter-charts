import 'package:charts_painter/chart.dart';
import 'package:charts_web/ui/home/decorations/decorations_sparkline.dart';
import 'package:charts_web/ui/home/presenter/chart_decorations_presenter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collection/collection.dart';

import 'options_component_header.dart';

const _subtitle = '''Decorations bla bla...
''';

class DecorationsComponent extends ConsumerWidget {
  const DecorationsComponent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final _presenter = ref.watch(chartDecorationsPresenter);
    return Column(
      children: [
        const OptionsComponentHeader(title: 'Foreground decorations', subtitle: _subtitle),
        SizedBox(height: 24),
        ElevatedButton(
          onPressed: () {
            _presenter.addForegroundDecorations(SparkLineDecoration());
          },
          child: Text('Add SparkLine decoration'),
        ),
        ...mapToWidgets(_presenter.foregroundDecorations),
      ],
    );
  }

  List<Widget> mapToWidgets(Map<int, DecorationPainter> decorations) {
    final widgets = <Widget>[];

    decorations.forEach((index, decoration) {
      if (decoration is SparkLineDecoration) {
        return widgets.add(DecorationsSparkline(decorationIndex: index));
      }
      // todo: add other decoration
    });

    return widgets;
  }
}
