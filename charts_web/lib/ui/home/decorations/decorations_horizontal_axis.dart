import 'package:charts_web/ui/home/decorations/common_decoration_box.dart';
import 'package:charts_web/ui/home/decorations/presenters/decorations_horizontal_axis_presenter.dart';
import 'package:charts_web/ui/home/decorations/presenters/decorations_vertical_axis_presenter.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../common/dialog/color_picker_dialog.dart';
import '../../common/widget/double_option_input.dart';

class DecorationsHorizontalAxis extends HookConsumerWidget {
  const DecorationsHorizontalAxis({Key? key, required this.decorationIndex}) : super(key: key);

  final int decorationIndex;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final _presenter = ref.watch(decorationHorizontalAxisPresenter(decorationIndex));



    return CommonDecorationBox(
      // onDataListSelected: _presenter.updateId,
      decorationIndex: decorationIndex,
      child: Column(
        children: [
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              SizedBox(
                width: 200,
                child: SwitchListTile(
                  value: _presenter.showLines,
                  title: Text(_presenter.showLines ? 'Show lines' : 'Don\'t show lines'),
                  onChanged: _presenter.updateShowLines,
                ),
              ),
              SizedBox(
                width: 200,
                child: SwitchListTile(
                  value: _presenter.showValues,
                  title: Text(_presenter.showValues ? 'Show values' : 'Don\'t show values'),
                  onChanged: _presenter.updateShowValues,
                ),
              ),
              SizedBox(
                width: 200,
                child: SwitchListTile(
                  value: _presenter.endWithChart,
                  title: Text(_presenter.endWithChart ? 'End with chart' : 'Don\'t end with chart'),
                  onChanged: _presenter.updateEndWithChart,
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
                name: 'Axis step',
                value: _presenter.axisStep,
                step: 1,
                onChanged: _presenter.updateAxisStep,
                defaultValue: _presenter.axisStep,
                noInputField: true,
              ),
              TextButton(
                child: Row(
                  children: [Icon(Icons.format_paint, color: _presenter.lineColor), const Text('Set line color')],
                ),
                onPressed: () async {
                  final color = await ColorPickerDialog.show(
                    context,
                    _presenter.lineColor,
                  );
                  if (color != null) {
                    _presenter.updateColor(color);
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
