import 'dart:math';

import 'package:charts_painter/chart.dart';
import 'package:charts_web/ui/common/dialog/color_picker_dialog.dart';
import 'package:charts_web/ui/design/color_swatch_button.dart';
import 'package:charts_web/ui/design/labeled_field.dart';
import 'package:charts_web/ui/design/number_field.dart';
import 'package:charts_web/ui/design/section_card.dart';
import 'package:charts_web/ui/design/segmented_choice.dart';
import 'package:charts_web/ui/playground/presenter/chart_state_presenter.dart';
import 'package:collection/collection.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';

enum _StrategyKind { grouped, stacked }

class DataSection extends HookConsumerWidget {
  const DataSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final presenter = ref.watch(chartStatePresenter);
    final isGrouped = presenter.state.data.dataStrategy is DefaultDataStrategy;

    return SectionCard(
      title: 'Data',
      subtitle: 'Every data point is an item. Lists become series.',
      children: [
        if (presenter.isMultiItem)
          SegmentedChoice<_StrategyKind>(
            label: 'Data strategy',
            helper: 'How multiple lists share the same slot.',
            value: isGrouped ? _StrategyKind.grouped : _StrategyKind.stacked,
            options: const [
              SegmentedChoiceOption(
                  value: _StrategyKind.grouped, label: 'Grouped'),
              SegmentedChoiceOption(
                  value: _StrategyKind.stacked, label: 'Stacked'),
            ],
            onChanged: (kind) => presenter.updateDataStrategy(
              kind == _StrategyKind.stacked
                  ? const StackDataStrategy()
                  : const DefaultDataStrategy(stackMultipleValues: true),
            ),
          ),
        if (presenter.isMultiItem && isGrouped)
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Stack multiple values'),
            subtitle: const Text('Stack values inside one group.'),
            value: presenter.stackMultipleValues,
            onChanged: presenter.updateStackMultipleValues,
          ),
        const SizedBox(height: 4),
        ...presenter.data.mapIndexed(
          (index, _) => _DataRow(listIndex: index, key: Key('data$index')),
        ),
        const Divider(),
        NumberField(
          label: 'Value axis headroom',
          value: presenter.valueAxisMaxOver,
          step: 1,
          fallback: 2,
          onChanged: presenter.updateValueAxisMaxOver,
        ),
        _NullableNumber(
          label: 'Axis min',
          helper: 'Opens space below zero. Leave off to let the data decide.',
          value: presenter.axisMin,
          fallback: -5,
          onChanged: presenter.updateAxisMin,
        ),
        _NullableNumber(
          label: 'Axis max',
          value: presenter.axisMax,
          fallback: 10,
          onChanged: presenter.updateAxisMax,
        ),
        _NullableNumber(
          label: 'Visible items',
          helper: 'Makes the chart scrollable and fixes how many items fit.',
          value: presenter.visibleItems,
          fallback: 8,
          onChanged: presenter.updateVisibleItems,
        ),
        const SizedBox(height: 8),
        if (presenter.showMaxDataListMessage)
          Text(
            'Five lists is the demo limit. In code there is no limit.',
            style: Theme.of(context).textTheme.bodySmall,
          )
        else
          Align(
            alignment: Alignment.centerLeft,
            child: FilledButton.tonalIcon(
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add another list'),
              onPressed: () {
                final random = Random();
                presenter.addDataList(List<ChartItem<void>>.generate(
                  presenter.data.first.length,
                  (_) => ChartItem<void>(random.nextDouble() * 10),
                ));
              },
            ),
          ),
      ],
    );
  }
}

class _DataRow extends HookConsumerWidget {
  const _DataRow({super.key, required this.listIndex});

  final int listIndex;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final presenter = ref.watch(chartStatePresenter);
    final controller = useTextEditingController(text: _valuesText(presenter));

    return LabeledField(
      label: 'Series ${listIndex + 1}',
      child: Row(
        children: [
          ColorSwatchButton(
            color: presenter.listColors[listIndex],
            tooltip: 'Series colour',
            onPressed: () async {
              final color = await ColorPickerDialog.show(
                context,
                presenter.listColors[listIndex],
                additionalText:
                    'In code, colorForValue can give every value its own colour.',
              );
              if (color != null) {
                presenter.updateListColor(color, listIndex);
              }
            },
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              decoration: const InputDecoration(hintText: '4, 6, 3, 6'),
              onChanged: (text) {
                final data = presenter.data;
                data[listIndex] = text
                    .split(',')
                    .map((value) =>
                        ChartItem<void>(double.tryParse(value.trim()) ?? 0))
                    .toList();
                presenter.updateData(data);
              },
            ),
          ),
          IconButton(
            tooltip: 'Remove series',
            icon: const Icon(Icons.delete_outline),
            onPressed: () => presenter.removeDataList(listIndex),
          ),
        ],
      ),
    );
  }

  String _valuesText(ChartStatePresenter presenter) => presenter.data[listIndex]
      .map((item) => (item.max ?? item.min)?.toStringAsFixed(0) ?? '')
      .join(', ');
}

/// A number option that can also be off. `axisMin`, `axisMax` and
/// `visibleItems` all behave differently when null, so the switch is part of
/// the control rather than a separate row.
class _NullableNumber extends StatelessWidget {
  const _NullableNumber({
    required this.label,
    required this.value,
    required this.fallback,
    required this.onChanged,
    this.helper,
  });

  final String label;
  final String? helper;
  final double? value;
  final double fallback;
  final ValueChanged<double?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Switch(
          value: value != null,
          onChanged: (on) => onChanged(on ? fallback : null),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: value == null
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: LabeledField(
                    label: label,
                    helper: helper,
                    child: Text(
                      'off',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ),
                )
              : NumberField(
                  label: label,
                  value: value,
                  step: 1,
                  fallback: fallback,
                  onChanged: onChanged,
                ),
        ),
      ],
    );
  }
}
