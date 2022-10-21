import 'package:charts_painter/chart.dart';
import 'package:charts_web/assets.gen.dart';
import 'package:charts_web/ui/common/dialog/gradient_dialog.dart';
import 'package:charts_web/ui/common/widget/switch_with_image.dart';
import 'package:charts_web/ui/home/decorations/common_decoration_box.dart';
import 'package:charts_web/ui/home/decorations/presenters/decorations_sparkline_presenter.dart';
import 'package:charts_web/ui/home/presenter/chart_decorations_presenter.dart';
import 'package:charts_web/ui/home/presenter/chart_state_presenter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:collection/collection.dart';

import '../../common/dialog/color_picker_dialog.dart';
import '../../common/widget/double_option_input.dart';
import '../chart_options/widget/options_items_component.dart';

class DecorationsSparkline extends HookConsumerWidget {
  const DecorationsSparkline({Key? key, required this.decorationIndex}) : super(key: key);

  final int decorationIndex;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final _presenter = ref.watch(decorationSparkLinePresenter(decorationIndex));

    return CommonDecorationBox(
      onDataListSelected: _presenter.updateId,
      decorationIndex: decorationIndex,
      child: Column(
        children: [
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              SizedBox(
                width: 200,
                child: SwitchWithImage(
                  value: _presenter.filled,
                  title1: 'Fill',
                  title2: 'Line',
                  image1: Assets.svg.lineNo,
                  image2: Assets.svg.lineYes,
                  onChanged: _presenter.updateFilled,
                ),
              ),
              SizedBox(
                width: 200,
                child: SwitchWithImage(
                  value: _presenter.smoothPoints,
                  title1: 'Smooth points',
                  title2: 'No smooth points',
                  image1: Assets.svg.smoothedYes,
                  image2: Assets.svg.smoothedNo,
                  onChanged: _presenter.updateSmoothPoints,
                ),
              ),
              DoubleOptionInput(
                name: 'Line Width',
                value: _presenter.lineWidth,
                step: 2,
                onChanged: _presenter.updateLineWidth,
                defaultValue: _presenter.lineWidth,
                noInputField: true,
              ),
              DoubleOptionInput(
                name: 'Start Position',
                value: _presenter.startPosition,
                step: 0.1,
                onChanged: _presenter.updateStartPosition,
                defaultValue: _presenter.startPosition,
                noInputField: true,
              ),
              Row(
                children: [
                  ElevatedButton(
                    child: Row(
                      children: [Icon(Icons.format_paint, color: _presenter.color), const Text('Set color')],
                    ),
                    onPressed: () async {
                      final color = await ColorPickerDialog.show(
                        context,
                        _presenter.color,
                      );
                      if (color != null) {
                        _presenter.updateColor(color);
                      }
                    },
                  ),
                  const SizedBox(width: 20),
                  const Text('OR'),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    child: Row(
                      children: [const Text('Set gradient')],
                    ),
                    onPressed: () async {
                      final gradient = await LinearGradientPickerDialog.show(
                          context, _presenter.gradient ?? LinearGradient(colors: [_presenter.color, Colors.black]),
                          onResetGradient: () => _presenter.updateGradient(null));
                      if (gradient != null) {
                        _presenter.updateGradient(gradient);
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
