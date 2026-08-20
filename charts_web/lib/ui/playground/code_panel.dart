import 'package:charts_web/codegen/chart_state_source.dart';
import 'package:charts_web/ui/design/code_block.dart';
import 'package:charts_web/ui/playground/presenter/chart_decorations_presenter.dart';
import 'package:charts_web/ui/playground/presenter/chart_state_presenter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

/// Generated Dart source for the current playground configuration.
class CodePanel extends ConsumerWidget {
  const CodePanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final state = ref.watch(chartStatePresenter);
    final decorations = ref.watch(chartDecorationsPresenter);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        border:
            Border(left: BorderSide(color: theme.colorScheme.outlineVariant)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Dart source', style: theme.textTheme.titleSmall),
          const SizedBox(height: 4),
          Text(
            'Pass this to Chart(state: ...). Needs charts_painter and '
            'material_ui imported.',
            style: theme.textTheme.bodySmall
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: CodeBlock(
              title: 'ChartState<void>',
              source: buildChartStateSource(state, decorations),
            ),
          ),
        ],
      ),
    );
  }
}
