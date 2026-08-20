import 'dart:math';

import 'package:charts_painter/chart.dart';
import 'package:charts_web/ui/playground/presenter/chart_decorations_presenter.dart';
import 'package:charts_web/ui/playground/presenter/chart_state_presenter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

/// The chart itself plus its toolbar. Kept separate from the layout so all
/// three breakpoints render the same stage.
class ChartStage extends ConsumerWidget {
  const ChartStage({super.key, this.onToggleCode});

  final VoidCallback? onToggleCode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final presenter = ref.watch(chartStatePresenter);
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                Text('Live chart', style: theme.textTheme.titleSmall),
                const SizedBox(width: 16),
                TextButton.icon(
                  icon: const Icon(Icons.casino_outlined, size: 18),
                  label: const Text('Randomize'),
                  onPressed: () => _randomize(presenter),
                ),
                TextButton.icon(
                  icon: const Icon(Icons.restart_alt, size: 18),
                  label: const Text('Reset'),
                  onPressed: () {
                    // Recreating the providers is the reset: it restores every
                    // default without the presenters needing a reset method.
                    ref.invalidate(chartDecorationsPresenter);
                    ref.invalidate(chartStatePresenter);
                  },
                ),
                if (onToggleCode != null)
                  TextButton.icon(
                    icon: const Icon(Icons.code, size: 18),
                    label: const Text('Dart source'),
                    onPressed: onToggleCode,
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: theme.colorScheme.outlineVariant),
              ),
              padding: const EdgeInsets.all(20),
              child: presenter.isScrollable
                  // Scrollable charts ignore the width limit and size
                  // themselves, so they need a scroll view around them.
                  ? SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: AnimatedChart<void>(
                        duration: const Duration(milliseconds: 450),
                        width: 1200,
                        state: presenter.state,
                      ),
                    )
                  : AnimatedChart<void>(
                      duration: const Duration(milliseconds: 450),
                      state: presenter.state,
                    ),
            ),
          ),
        ],
      ),
    );
  }

  void _randomize(ChartStatePresenter presenter) {
    final random = Random();

    presenter.updateData(presenter.data
        .map((list) => List<ChartItem<void>>.generate(
            list.length, (_) => ChartItem<void>(random.nextDouble() * 10)))
        .toList());
  }
}
