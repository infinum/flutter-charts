import 'package:charts_painter/chart.dart';
import 'package:charts_web/ui/common/dialog/gradient_dialog.dart';
import 'package:charts_web/ui/home/decorations/presenters/decorations_sparkline_presenter.dart';
import 'package:charts_web/ui/home/presenter/chart_decorations_presenter.dart';
import 'package:charts_web/ui/home/presenter/chart_state_presenter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../common/dialog/color_picker_dialog.dart';

class DecorationsSparkline extends HookConsumerWidget {
  const DecorationsSparkline({Key? key, required this.decorationIndex}) : super(key: key);

  final int decorationIndex;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final _decorations = ref.watch(chartDecorationsPresenter);
    final _chartStatePresenter = ref.watch(chartStatePresenter);
    final _presenter = ref.watch(decorationSparkLinePresenter(decorationIndex));

    return Column(
      children: [
        Wrap(
          children: [
            SizedBox(
              width: 200,
              child: SwitchListTile(
                title: Text(_presenter.filled ? 'Fill' : 'Line'),
                value: _presenter.filled,
                onChanged: _presenter.updateFilled,
              ),
            ),
            SizedBox(
              width: 200,
              child: SwitchListTile(
                title: Text(_presenter.smoothPoints ? 'Smoothed' : 'No smooth points'),
                value: _presenter.smoothPoints,
                onChanged: _presenter.updateSmoothPoints,
              ),
            ),
          ],
        ),
        TextButton(
          child: Row(
            children: [Icon(Icons.format_paint, color: _presenter.color), Text('Set color')],
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
        ElevatedButton(
          child: Row(
            children: [Text('Set gradient')],
          ),
          onPressed: () async {
            final gradient = await LinearGradientPickerDialog.show(
              context,
              _presenter.gradient ?? LinearGradient(colors: [_presenter.color, Colors.black]),
              onResetGradient: () => _presenter.updateGradient(null)
            );
            if (gradient != null) {
              _presenter.updateGradient(gradient);
            }
          },
        ),
        const SizedBox(height: 40),
      ],
    );
  }
}
