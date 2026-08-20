import 'package:charts_web/ui/common/dialog/color_picker_dialog.dart';
import 'package:charts_web/ui/design/color_swatch_button.dart';
import 'package:charts_web/ui/design/labeled_field.dart';
import 'package:charts_web/ui/design/number_field.dart';
import 'package:charts_web/ui/playground/decorations/decoration_card.dart';
import 'package:charts_web/ui/playground/decorations/presenters/decorations_grid_presenter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';

class DecorationsGrid extends HookConsumerWidget {
  const DecorationsGrid({super.key, required this.decorationIndex});

  final int decorationIndex;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final presenter = ref.watch(decorationGridPresenter(decorationIndex));

    return DecorationCard(
      decorationIndex: decorationIndex,
      name: 'Grid decoration',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Horizontal lines'),
            value: presenter.showHorizontalGrid,
            onChanged: presenter.updateShowHorizontalGrid,
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Vertical lines'),
            value: presenter.showVerticalGrid,
            onChanged: presenter.updateShowVerticalGrid,
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Horizontal values'),
            value: presenter.showHorizontalValues,
            onChanged: presenter.updateShowHorizontalValues,
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Vertical values'),
            value: presenter.showVerticalValues,
            onChanged: presenter.updateShowVerticalValues,
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Dashed'),
            value: presenter.dashed,
            onChanged: presenter.updateDashed,
          ),
          NumberField(
            label: 'Grid width',
            value: presenter.gridWidth,
            step: 0.5,
            fallback: 1,
            onChanged: presenter.updateGridWidth,
          ),
          NumberField(
            label: 'Horizontal step',
            value: presenter.horizontalAxisStep,
            step: 1,
            fallback: 1,
            onChanged: presenter.updateHorizontalAxisStep,
          ),
          NumberField(
            label: 'Vertical step',
            value: presenter.verticalAxisStep,
            step: 1,
            fallback: 1,
            onChanged: presenter.updateVerticalAxisStep,
          ),
          // Only affects drawn values, so it is hidden until there are some.
          if (presenter.showHorizontalValues || presenter.showVerticalValues)
            NumberField(
              label: 'Text scale',
              value: presenter.textScale,
              step: 0.1,
              fallback: 1,
              onChanged: presenter.updateTextScale,
            ),
          LabeledField(
            label: 'Grid colour',
            child: ColorSwatchButton(
              color: presenter.gridColor,
              tooltip: 'Grid colour',
              onPressed: () async {
                final color =
                    await ColorPickerDialog.show(context, presenter.gridColor);
                if (color != null) presenter.updateColor(color);
              },
            ),
          ),
        ],
      ),
    );
  }
}
