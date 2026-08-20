import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

const double kMinOptionsWidth = 300;
const double kMaxOptionsWidth = 720;

/// The app opens with the options pane fully extended.
const double kDefaultOptionsWidth = kMaxOptionsWidth;

/// The chart never gets squeezed below this, however wide the options pane is
/// set. On a narrow window the stored width is clamped for layout only, so
/// widening the window restores the pane to its full size.
const double kMinChartWidth = 360;

/// Width of the playground's options pane, dragged by the user.
final optionsPaneWidthProvider =
    StateProvider<double>((ref) => kDefaultOptionsWidth);

/// Drag handle between the options pane and the chart.
class PaneDragHandle extends ConsumerWidget {
  const PaneDragHandle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return MouseRegion(
      cursor: SystemMouseCursors.resizeLeftRight,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onHorizontalDragUpdate: (details) {
          final next = ref.read(optionsPaneWidthProvider) + details.delta.dx;
          ref.read(optionsPaneWidthProvider.notifier).state =
              next.clamp(kMinOptionsWidth, kMaxOptionsWidth);
        },
        onDoubleTap: () => ref.read(optionsPaneWidthProvider.notifier).state =
            kDefaultOptionsWidth,
        child: Tooltip(
          message: 'Drag to resize, double-click to reset',
          child: SizedBox(
            width: 10,
            child: Center(
              child: Container(
                width: 2,
                decoration: BoxDecoration(
                  color: theme.colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
