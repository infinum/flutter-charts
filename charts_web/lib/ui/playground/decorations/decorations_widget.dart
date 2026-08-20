import 'package:charts_web/ui/design/edge_insets_field.dart';
import 'package:charts_web/ui/design/number_field.dart';
import 'package:charts_web/ui/design/segmented_choice.dart';
import 'package:charts_web/ui/playground/decorations/decoration_card.dart';
import 'package:charts_web/ui/playground/decorations/presenters/decorations_widget_presenter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';

class DecorationsWidget extends HookConsumerWidget {
  const DecorationsWidget({super.key, required this.decorationIndex});

  final int decorationIndex;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final presenter = ref.watch(decorationWidgetPresenter(decorationIndex));

    return DecorationCard(
      decorationIndex: decorationIndex,
      name: 'Widget decoration',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'A widget decoration draws any widget you give it, so anything you '
            'can build in Flutter can sit on the chart.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 8),
          SegmentedChoice<int>(
            label: 'Example',
            value: presenter.type,
            options: const [
              SegmentedChoiceOption(value: 0, label: 'Target line'),
              SegmentedChoiceOption(value: 1, label: 'Labelled target'),
              SegmentedChoiceOption(value: 2, label: 'Target area'),
              SegmentedChoiceOption(value: 3, label: 'Border'),
              SegmentedChoiceOption(value: 4, label: 'Clickable'),
            ],
            onChanged: presenter.updateType,
          ),
          if (presenter.type <= 2)
            NumberField(
              label: 'Target value',
              value: presenter.targetValue,
              step: 1,
              fallback: 3,
              onChanged: presenter.updateTargetValue,
            ),
          EdgeInsetsField(
            label: 'Margin',
            helper: 'Resets when you pick another example, since each one '
                'positions itself differently.',
            value: presenter.margin,
            onChanged: presenter.updateMargin,
          ),
        ],
      ),
    );
  }
}
