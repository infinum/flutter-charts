import 'package:charts_painter/chart.dart';
import 'package:charts_web/assets.gen.dart';
import 'package:charts_web/ui/home/decorations/decorations_horizontal_axis.dart';
import 'package:charts_web/ui/home/decorations/decorations_sparkline.dart';
import 'package:charts_web/ui/home/decorations/decorations_vertical_axis.dart';
import 'package:charts_web/ui/home/decorations/decorations_widget.dart';
import 'package:charts_web/ui/home/presenter/chart_decorations_presenter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collection/collection.dart';

import 'options_component_header.dart';

const _subtitle =
    '''Various decorations to finalize your chart look. They are divided into background and foreground decorations.
''';

class DecorationsComponent extends ConsumerWidget {
  const DecorationsComponent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final _presenter = ref.watch(chartDecorationsPresenter);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const OptionsComponentHeader(title: 'Decorations', subtitle: _subtitle),
        const Text('Add a decoration:',
            style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Wrap(
          spacing: 8,
          runSpacing: 16,
          children: [
            _DecorationItem(
              name: 'SparkLine',
              image: Assets.png.generalSparklineDecorationGolden.path,
              onPressed: () {
                _presenter.addDecoration(SparkLineDecoration());
              },
            ),
            _DecorationItem(
              name: 'Horizontal',
              image: Assets.png.generalHorizontalDecorationGolden.path,
              onPressed: () {
                _presenter.addDecoration(HorizontalAxisDecoration());
              },
            ),
            _DecorationItem(
              name: 'Vertical',
              image: Assets.png.generalVerticalDecorationGolden.path,
              onPressed: () {
                _presenter.addDecoration(VerticalAxisDecoration());
              },
            ),
            _DecorationItem(
              name: 'Widget',
              image: Assets.png.futuramaSmall.path,
              onPressed: () {
                _presenter.addDecoration(
                  WidgetDecoration(
                    widgetDecorationBuilder:
                        (context, state, itemHeight, verticalMultiplier) {
                      return SizedBox.shrink();
                    },
                  ),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Text('Current decorations:',
            style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ...mapToWidgets(_presenter.foregroundDecorations),
        const Divider(),
        ...mapToWidgets(_presenter.backgroundDecorations),
        const SizedBox(height: 24),
      ],
    );
  }

  List<Widget> mapToWidgets(Map<int, DecorationPainter> decorations) {
    final widgets = <Widget>[];

    decorations.forEach((index, decoration) {
      if (decoration is SparkLineDecoration) {
        widgets.add(DecorationsSparkline(decorationIndex: index));
      } else if (decoration is VerticalAxisDecoration) {
        widgets.add(DecorationsVerticalAxis(decorationIndex: index));
      } else if (decoration is HorizontalAxisDecoration) {
        widgets.add(DecorationsHorizontalAxis(decorationIndex: index));
      } else if (decoration is WidgetDecoration) {
        widgets.add(DecorationsWidget(
          decorationIndex: index,
        ));
      }
      // todo: add other decoration (here and in chart_decorations_presenter)
    });

    return widgets;
  }
}

class _DecorationItem extends StatelessWidget {
  const _DecorationItem(
      {Key? key,
      required this.name,
      required this.image,
      required this.onPressed})
      : super(key: key);

  final String name;
  final String image;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            image,
            width: 100,
            height: 100,
          ),
          Text(name),
        ],
      ),
    );
  }
}
