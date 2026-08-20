import 'package:charts_web/ui/common/dialog/border_dialog.dart';
import 'package:charts_web/ui/common/dialog/border_radius_dialog.dart';
import 'package:charts_web/ui/common/dialog/gradient_dialog.dart';
import 'package:charts_web/ui/design/color_swatch_button.dart';
import 'package:charts_web/ui/design/labeled_field.dart';
import 'package:charts_web/ui/design/number_field.dart';
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
        if (painter == SelectedPainter.widget)
          Text(
            'WidgetItemOptions draws any widget you hand it. This demo uses an '
            'image.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        if (painter == SelectedPainter.none)
          Text(
            'BarItemOptions with zero width. Pair it with a SparkLine '
            'decoration below.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        if (isGeometry) ...[
          NumberField(
            label: 'Min item width',
            value: presenter.minBarWidth,
            step: 2,
            fallback: 20,
            onChanged: presenter.updateMinBarWidth,
          ),
          NumberField(
            label: 'Max item width',
            value: presenter.maxBarWidth,
            step: 2,
            fallback: 30,
            onChanged: presenter.updateMaxBarWidth,
          ),
          NumberField(
            label: 'Item padding left',
            value: presenter.chartItemPadding.left,
            step: 2,
            onChanged: (value) => presenter.updateChartItemPadding(
                presenter.chartItemPadding.copyWith(left: value)),
          ),
          NumberField(
            label: 'Item padding right',
            value: presenter.chartItemPadding.right,
            step: 2,
            onChanged: (value) => presenter.updateChartItemPadding(
                presenter.chartItemPadding.copyWith(right: value)),
          ),
        ],
        if (presenter.isMultiItem && painter != SelectedPainter.none) ...[
          const Divider(),
          if (!presenter.stackMultipleValues) ...[
            NumberField(
              label: 'Group padding left',
              value: presenter.multiValuePadding.left,
              step: 2,
              onChanged: (value) => presenter.updateMultiValuePadding(
                  presenter.multiValuePadding.copyWith(left: value)),
            ),
            NumberField(
              label: 'Group padding right',
              value: presenter.multiValuePadding.right,
              step: 2,
              onChanged: (value) => presenter.updateMultiValuePadding(
                  presenter.multiValuePadding.copyWith(right: value)),
            ),
          ],
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

    return LabeledField(
      label: 'Series ${index + 1} style',
      child: Row(
        children: [
          // Identity marker, not a control: colour is edited in the Data
          // section, so this swatch only says which series the row belongs to.
          Container(
            width: 12,
            height: 28,
            decoration: BoxDecoration(
              color: presenter.listColors[index],
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton(
                  onPressed: () async {
                    final border = await BorderSideDialog.show(
                      context,
                      presenter.itemBorderSides[index],
                      presenter.itemBorderSides[index].color,
                    );
                    if (border != null) {
                      presenter.updateItemBorderSide(border, index);
                    }
                  },
                  child: const Text('Border'),
                ),
                OutlinedButton(
                  onPressed: () async {
                    final current = presenter.gradient[index] ??
                        LinearGradient(colors: [
                          presenter.listColors[index],
                          Colors.black,
                        ]);
                    final gradient = await LinearGradientPickerDialog.show(
                      context,
                      current,
                      onResetGradient: () =>
                          presenter.updateGradient(null, index),
                    );
                    if (gradient != null) {
                      presenter.updateGradient(gradient, index);
                    }
                  },
                  child: const Text('Gradient'),
                ),
                if (presenter.selectedPainter == SelectedPainter.bar)
                  OutlinedButton(
                    onPressed: () async {
                      final radius = await BorderRadiusDialog.show(
                          context, presenter.barBorderRadius[index]);
                      if (radius != null) {
                        presenter.updateBarBorderRadius(radius, index);
                      }
                    },
                    child: const Text('Radius'),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
