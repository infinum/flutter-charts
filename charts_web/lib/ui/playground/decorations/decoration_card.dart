import 'package:charts_web/ui/design/color_swatch_button.dart';
import 'package:charts_web/ui/design/section_card.dart';
import 'package:charts_web/ui/design/segmented_choice.dart';
import 'package:charts_web/ui/playground/presenter/chart_decorations_presenter.dart';
import 'package:charts_web/ui/playground/presenter/chart_state_presenter.dart';
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

/// Shared frame for one decoration's editor: layer choice, optional series
/// picker, delete, and the decoration-specific controls.
class DecorationCard extends ConsumerWidget {
  const DecorationCard({
    super.key,
    required this.decorationIndex,
    required this.name,
    required this.child,
    this.onDataListSelected,
  });

  final int decorationIndex;
  final String name;
  final Widget child;
  final ValueChanged<int>? onDataListSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final decorations = ref.watch(chartDecorationsPresenter);
    final chartState = ref.watch(chartStatePresenter);
    final layer = decorations.getLayerOfDecoration(decorationIndex);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: SectionCard(
        title: name,
        trailing: IconButton(
          tooltip: 'Remove decoration',
          icon: const Icon(Icons.delete_outline),
          onPressed: () => decorations.removeDecoration(decorationIndex),
        ),
        children: [
          SegmentedChoice<DecorationLayer>(
            label: 'Layer',
            helper: 'Background draws under the items, foreground over them.',
            value: layer,
            options: const [
              SegmentedChoiceOption(
                  value: DecorationLayer.background, label: 'Background'),
              SegmentedChoiceOption(
                  value: DecorationLayer.foreground, label: 'Foreground'),
            ],
            onChanged: (value) =>
                decorations.moveDecorationToLayer(decorationIndex, value),
          ),
          if (onDataListSelected != null && chartState.isMultiItem)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Text('Series', style: Theme.of(context).textTheme.labelLarge),
                  const SizedBox(width: 12),
                  ...chartState.listColors.mapIndexed(
                    (index, color) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ColorSwatchButton(
                        color: color,
                        tooltip: 'Use series ${index + 1}',
                        onPressed: () => onDataListSelected!(index),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const Divider(),
          child,
        ],
      ),
    );
  }
}
