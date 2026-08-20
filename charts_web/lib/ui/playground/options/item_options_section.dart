import 'package:charts_web/ui/common/dialog/border_dialog.dart';
import 'package:charts_web/ui/common/dialog/border_radius_dialog.dart';
import 'package:charts_web/ui/common/dialog/gradient_dialog.dart';
import 'package:charts_web/ui/design/color_swatch_button.dart';
import 'package:charts_web/ui/design/edge_insets_field.dart';
import 'package:charts_web/ui/design/labeled_field.dart';
import 'package:charts_web/ui/design/number_field.dart';
import 'package:charts_web/ui/design/optional_number_field.dart';
import 'package:charts_web/ui/common/dialog/color_picker_dialog.dart';
import 'package:charts_web/ui/design/section_card.dart';
import 'package:charts_web/ui/design/segmented_choice.dart';
import 'package:charts_web/ui/playground/presenter/chart_state_presenter.dart';
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

class ItemOptionsSection extends ConsumerWidget {
  const ItemOptionsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final presenter = ref.watch(chartStatePresenter);
    final painter = presenter.selectedPainter;
    final isGeometry =
        painter == SelectedPainter.bar || painter == SelectedPainter.bubble;

    return SectionCard(
      title: 'Item options',
      subtitle: 'How each item is drawn. Presets for bar and bubble; '
          'WidgetItemOptions for anything else.',
      children: [
        SegmentedChoice<SelectedPainter>(
          value: painter,
          options: const [
            SegmentedChoiceOption(
                value: SelectedPainter.bar,
                label: 'Bar',
                icon: Icons.bar_chart),
            SegmentedChoiceOption(
                value: SelectedPainter.bubble,
                label: 'Bubble',
                icon: Icons.bubble_chart_outlined),
            SegmentedChoiceOption(
                value: SelectedPainter.none,
                label: 'Empty',
                icon: Icons.hide_source),
            SegmentedChoiceOption(
                value: SelectedPainter.widget,
                label: 'Widget',
                icon: Icons.widgets_outlined),
          ],
          onChanged: presenter.updateItemPainter,
        ),
        const SizedBox(height: 8),
        if (painter == SelectedPainter.widget) ...[
          Text(
            'WidgetItemOptions draws any widget you hand it.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          SegmentedChoice<WidgetItemExample>(
            label: 'Widget example',
            value: presenter.widgetItemExample,
            options: const [
              SegmentedChoiceOption(
                  value: WidgetItemExample.image, label: 'Image'),
              SegmentedChoiceOption(
                  value: WidgetItemExample.valueLabel, label: 'Value label'),
            ],
            onChanged: presenter.updateWidgetItemExample,
          ),
        ],
        if (painter == SelectedPainter.none)
          Text(
            'BarItemOptions with zero width. Pair it with a SparkLine '
            'decoration below.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        // WidgetItemOptions has no padding or startPosition, but does take
        // the width bounds.
        if (isGeometry || painter == SelectedPainter.widget) ...[
          OptionalNumberField(
            label: 'Min item width',
            helper: 'Unset means no lower limit.',
            value: presenter.minBarWidth,
            step: 2,
            fallback: 20,
            onChanged: presenter.updateMinBarWidthOrClear,
          ),
          OptionalNumberField(
            label: 'Max item width',
            helper: 'Unset means no upper limit.',
            value: presenter.maxBarWidth,
            step: 2,
            fallback: 30,
            onChanged: presenter.updateMaxBarWidthOrClear,
          ),
        ],
        if (isGeometry) ...[
          EdgeInsetsField(
            label: 'Item padding',
            helper: 'Space either side of each item. The library only reads '
                'the horizontal sides.',
            horizontalOnly: true,
            value: presenter.chartItemPadding,
            onChanged: presenter.updateChartItemPadding,
          ),
          if (painter == SelectedPainter.bar)
            NumberField(
              label: 'Start position',
              value: presenter.startPosition,
              step: 0.1,
              fallback: 0.5,
              onChanged: presenter.updateStartPosition,
            ),
        ],
        if (presenter.isMultiItem && painter != SelectedPainter.none) ...[
          const Divider(),
          if (!presenter.stackMultipleValues)
            EdgeInsetsField(
              label: 'Group padding',
              helper: 'Space either side of each series in a group. The '
                  'library only reads the horizontal sides.',
              horizontalOnly: true,
              value: presenter.multiValuePadding,
              onChanged: presenter.updateMultiValuePadding,
            ),
          if (painter == SelectedPainter.bar)
            Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton(
                onPressed: () async {
                  final radius = await BorderRadiusDialog.show(
                      context, presenter.barBorderRadius[0]);
                  if (radius != null) {
                    presenter.updateBarBorderRadius(radius, 0, forAll: true);
                  }
                },
                child: const Text('Border radius for all series'),
              ),
            ),
        ],
        if (isGeometry) ...[
          const Divider(),
          ...presenter.data
              .mapIndexed((index, _) => _PerSeriesOptions(index: index)),
        ],
      ],
    );
  }
}

class _PerSeriesOptions extends ConsumerWidget {
  const _PerSeriesOptions({required this.index});

  final int index;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final presenter = ref.watch(chartStatePresenter);
    final border = presenter.itemBorderSides[index];
    final gradient = presenter.gradient[index];
    final radius = presenter.barBorderRadius[index];

    return LabeledField(
      label: 'Series ${index + 1} style',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ColorSwatchButton(
                color: presenter.listColors[index],
                tooltip: 'Series colour',
                onPressed: () async {
                  final color = await ColorPickerDialog.show(
                    context,
                    presenter.listColors[index],
                  );
                  if (color != null) presenter.updateListColor(color, index);
                },
              ),
              const SizedBox(width: 12),
              Text('Colour', style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _ClearableAction(
                label: 'Border',
                isSet: border != BorderSide.none,
                onPressed: () async {
                  final updated = await BorderSideDialog.show(
                      context, border, border.color);
                  if (updated != null) {
                    presenter.updateItemBorderSide(updated, index);
                  }
                },
                onClear: () =>
                    presenter.updateItemBorderSide(BorderSide.none, index),
              ),
              _ClearableAction(
                label: 'Gradient',
                isSet: gradient != null,
                onPressed: () async {
                  final updated = await LinearGradientPickerDialog.show(
                    context,
                    gradient ??
                        LinearGradient(colors: [
                          presenter.listColors[index],
                          Colors.black,
                        ]),
                    onResetGradient: () =>
                        presenter.updateGradient(null, index),
                  );
                  if (updated != null) presenter.updateGradient(updated, index);
                },
                onClear: () => presenter.updateGradient(null, index),
              ),
              if (presenter.selectedPainter == SelectedPainter.bar)
                _ClearableAction(
                  label: 'Radius',
                  isSet: radius != BorderRadius.zero,
                  onPressed: () async {
                    final updated =
                        await BorderRadiusDialog.show(context, radius);
                    if (updated != null) {
                      presenter.updateBarBorderRadius(updated, index);
                    }
                  },
                  onClear: () =>
                      presenter.updateBarBorderRadius(BorderRadius.zero, index),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// An option button that shows whether it holds a value, with a way to put it
/// back. Border, gradient and radius were all one-way once set: the only route
/// back was through the dialog, and only the gradient dialog offered one.
class _ClearableAction extends StatelessWidget {
  const _ClearableAction({
    required this.label,
    required this.isSet,
    required this.onPressed,
    required this.onClear,
  });

  final String label;
  final bool isSet;
  final VoidCallback onPressed;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    if (!isSet) {
      return OutlinedButton(onPressed: onPressed, child: Text(label));
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        FilledButton.tonal(onPressed: onPressed, child: Text(label)),
        const SizedBox(width: 4),
        IconButton(
          tooltip: 'Clear $label',
          visualDensity: VisualDensity.compact,
          icon: const Icon(Icons.close, size: 16),
          onPressed: onClear,
        ),
      ],
    );
  }
}
