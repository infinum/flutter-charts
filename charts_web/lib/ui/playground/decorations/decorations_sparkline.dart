import 'package:charts_web/ui/common/dialog/color_picker_dialog.dart';
import 'package:charts_web/ui/common/dialog/gradient_dialog.dart';
import 'package:charts_web/ui/design/color_swatch_button.dart';
import 'package:charts_web/ui/design/labeled_field.dart';
import 'package:charts_web/ui/design/number_field.dart';
import 'package:charts_web/ui/playground/decorations/decoration_card.dart';
import 'package:charts_web/ui/playground/decorations/presenters/decorations_sparkline_presenter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';

class DecorationsSparkline extends HookConsumerWidget {
  const DecorationsSparkline({super.key, required this.decorationIndex});

  final int decorationIndex;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final presenter = ref.watch(decorationSparkLinePresenter(decorationIndex));

    return DecorationCard(
      decorationIndex: decorationIndex,
      name: 'SparkLine decoration',
      onDataListSelected: presenter.updateId,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Fill'),
            subtitle: const Text('Fill under the line instead of stroking it.'),
            value: presenter.filled,
            onChanged: presenter.updateFilled,
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Smooth points'),
            value: presenter.smoothPoints,
            onChanged: presenter.updateSmoothPoints,
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Dashed'),
            value: presenter.dashed,
            onChanged: presenter.updateDashed,
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Stretch line'),
            subtitle: const Text('Run the line to both chart edges.'),
            value: presenter.stretchLine,
            onChanged: presenter.updateStretchLine,
          ),
          NumberField(
            label: 'Line width',
            value: presenter.lineWidth,
            step: 0.5,
            fallback: 1,
            onChanged: presenter.updateLineWidth,
          ),
          NumberField(
            label: 'Start position',
            value: presenter.startPosition,
            step: 0.1,
            fallback: 0.5,
            onChanged: presenter.updateStartPosition,
          ),
          LabeledField(
            label: 'Line colour',
            child: Row(
              children: [
                ColorSwatchButton(
                  color: presenter.color,
                  tooltip: 'Line colour',
                  onPressed: () async {
                    final color =
                        await ColorPickerDialog.show(context, presenter.color);
                    if (color != null) presenter.updateColor(color);
                  },
                ),
                const SizedBox(width: 12),
                OutlinedButton(
                  onPressed: () async {
                    final gradient = await LinearGradientPickerDialog.show(
                      context,
                      presenter.gradient ??
                          LinearGradient(
                              colors: [presenter.color, Colors.transparent]),
                      onResetGradient: () => presenter.updateGradient(null),
                    );
                    if (gradient != null) presenter.updateGradient(gradient);
                  },
                  child: Text(
                      presenter.gradient == null ? 'Add gradient' : 'Gradient'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
