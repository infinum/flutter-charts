
import 'package:charts_painter/chart.dart';
import 'package:charts_web/ui/home/presenter/chart_decorations_presenter.dart';
import 'package:charts_web/ui/home/presenter/chart_state_presenter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../common/dialog/color_picker_dialog.dart';

class DecorationsSparkline extends HookConsumerWidget {
  const DecorationsSparkline({Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final _decorations = ref.watch(chartDecorationsPresenter);
    final _presenter = ref.watch(chartStatePresenter);

    final fillState = useState(false);
    final stretchLineState = useState(false);
    final smoothedState = useState(false);
    final colorState = useState(_presenter.listColors.first);

    return Column(
      children: [
        Wrap(
          children: [
            SizedBox(
              width: 200,
              child: SwitchListTile(
                title:
                Text(fillState.value ? 'Fill' : 'Line'),
                value: fillState.value,
                onChanged: (v) {
                  fillState.value = v;
                },
              ),
            ),
            SizedBox(
              width: 200,
              child: SwitchListTile(
                title:
                Text(stretchLineState.value ? 'Stretch line' : 'No stretch'),
                value: stretchLineState.value,
                onChanged: (v) {
                  stretchLineState.value = v;
                },
              ),
            ),
            SizedBox(
              width: 200,
              child: SwitchListTile(
                title:
                Text(smoothedState.value ? 'Smoothed' : 'No smooth points'),
                value: smoothedState.value,
                onChanged: (v) {
                  smoothedState.value = v;
                },
              ),
            ),
          ],
        ),
        IconButton(
          icon: Icon(Icons.format_paint, color: colorState.value),
          onPressed: () async {
            final color = await ColorPickerDialog.show(
              context,
              colorState.value,
              additionalText:
              'In code, with colorForValue you can also define different color for each value of the list.',
            );
            if (color != null) {
              colorState.value = color;
            }
          },
        ),
        const SizedBox(height: 40),
        ElevatedButton(onPressed: () {
          _decorations.addForegroundDecorations(SparkLineDecoration(fill: fillState.value));
        }, child: Text('OK')),
      ],
    );
  }
}


