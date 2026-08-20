import 'package:charts_painter/chart.dart';
import 'package:charts_web/ui/common/dialog/color_picker_dialog.dart';
import 'package:charts_web/ui/design/color_swatch_button.dart';
import 'package:charts_web/ui/design/edge_insets_field.dart';
import 'package:charts_web/ui/design/labeled_field.dart';
import 'package:charts_web/ui/design/number_field.dart';
import 'package:charts_web/ui/design/segmented_choice.dart';
import 'package:charts_web/ui/playground/decorations/decoration_card.dart';
import 'package:charts_web/ui/playground/decorations/presenters/decorations_horizontal_axis_presenter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';

class DecorationsHorizontalAxis extends HookConsumerWidget {
  const DecorationsHorizontalAxis({super.key, required this.decorationIndex});

  final int decorationIndex;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final presenter =
        ref.watch(decorationHorizontalAxisPresenter(decorationIndex));

    return DecorationCard(
      decorationIndex: decorationIndex,
      name: 'Horizontal axis decoration',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Show lines'),
            value: presenter.showLines,
            onChanged: presenter.updateShowLines,
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Show values'),
            value: presenter.showValues,
            onChanged: presenter.updateShowValues,
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('End with chart'),
            subtitle: const Text('Stop the axis at the last item.'),
            value: presenter.endWithChart,
            onChanged: presenter.updateEndWithChart,
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Dashed'),
            value: presenter.dashed,
            onChanged: presenter.updateDashed,
          ),
          NumberField(
            label: 'Line width',
            value: presenter.lineWidth,
            step: 0.5,
            fallback: 1,
            onChanged: presenter.updateLineWidth,
          ),
          NumberField(
            label: 'Axis step',
            value: presenter.axisStep,
            step: 1,
            fallback: 1,
            onChanged: presenter.updateAxisStep,
          ),
          NumberField(
            label: 'Text scale',
            value: presenter.textScale,
            step: 0.1,
            fallback: 1,
            onChanged: presenter.updateTextScale,
          ),
          LabeledField(
            label: 'Line colour',
            child: ColorSwatchButton(
              color: presenter.lineColor,
              tooltip: 'Line colour',
              onPressed: () async {
                final color =
                    await ColorPickerDialog.show(context, presenter.lineColor);
                if (color != null) presenter.updateColor(color);
              },
            ),
          ),
          SegmentedChoice<TextAlign>(
            label: 'Values align',
            value: presenter.valuesAlign,
            options: const [
              SegmentedChoiceOption(value: TextAlign.start, label: 'Start'),
              SegmentedChoiceOption(value: TextAlign.center, label: 'Center'),
              SegmentedChoiceOption(value: TextAlign.end, label: 'End'),
            ],
            onChanged: presenter.updateValuesAlign,
          ),
          SegmentedChoice<HorizontalLegendPosition>(
            label: 'Legend position',
            value: presenter.legendPosition,
            options: const [
              SegmentedChoiceOption(
                  value: HorizontalLegendPosition.start, label: 'Start'),
              SegmentedChoiceOption(
                  value: HorizontalLegendPosition.end, label: 'End'),
            ],
            onChanged: presenter.updateLegendPosition,
          ),
          EdgeInsetsField(
            label: 'Values padding',
            value: presenter.valuesPadding,
            onChanged: presenter.updateValuesPadding,
          ),
        ],
      ),
    );
  }
}
