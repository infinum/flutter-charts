import 'package:charts_web/ui/common/layout/breakpoints.dart';
import 'package:charts_web/ui/playground/options/options_panel.dart';
import 'package:charts_web/ui/playground/chart_stage.dart';
import 'package:charts_web/ui/playground/code_panel.dart';
import 'package:charts_web/ui/playground/playground_providers.dart';
import 'package:charts_web/ui/playground/resizable_pane.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

class PlaygroundScreen extends ConsumerWidget {
  const PlaygroundScreen({super.key});

  static const Key optionsPaneKey = Key('playground.options');
  static const Key codePaneKey = Key('playground.code');

  static const double _codeWidth = 420;
  static const double _compactChartHeight = 320;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showCode = ref.watch(codePanelVisibleProvider);
    final optionsWidth = ref.watch(optionsPaneWidthProvider);

    final options = SingleChildScrollView(
      key: optionsPaneKey,
      padding: const EdgeInsets.all(16),
      child: const OptionsPanel(),
    );

    return switch (context.breakpoint) {
      AppBreakpoint.expanded => Row(
          children: [
            SizedBox(width: optionsWidth, child: options),
            const PaneDragHandle(),
            const Expanded(child: ChartStage()),
            if (showCode)
              const SizedBox(
                key: codePaneKey,
                width: _codeWidth,
                child: CodePanel(),
              ),
          ],
        ),
      AppBreakpoint.medium => Row(
          children: [
            SizedBox(width: optionsWidth, child: options),
            const PaneDragHandle(),
            Expanded(
              child: ChartStage(onToggleCode: () => _showCodeSheet(context)),
            ),
          ],
        ),
      AppBreakpoint.compact => Column(
          children: [
            SizedBox(
              height: _compactChartHeight,
              child: ChartStage(onToggleCode: () => _showCodeSheet(context)),
            ),
            Expanded(child: options),
          ],
        ),
    };
  }

  void _showCodeSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => const FractionallySizedBox(
        heightFactor: 0.9,
        child: CodePanel(),
      ),
    );
  }
}
