import 'package:charts_web/ui/playground/presenter/chart_label_color_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

/// Keeps [chartLabelColorProvider] in step with the active theme.
///
/// The chart paints its own axis text on a canvas, so it cannot inherit the
/// text theme the way a widget does. This pushes the current `onSurface` down
/// to the decorations instead. Written in didChangeDependencies rather than
/// build, because riverpod forbids mutating a provider during a build.
class ChartThemeSync extends ConsumerStatefulWidget {
  const ChartThemeSync({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<ChartThemeSync> createState() => _ChartThemeSyncState();
}

class _ChartThemeSyncState extends ConsumerState<ChartThemeSync> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final scheme = Theme.of(context).colorScheme;
    final color = scheme.onSurface;
    final gridColor = scheme.outlineVariant;

    // didChangeDependencies still runs inside the build phase, and riverpod
    // refuses provider writes there, so defer to the end of the frame. The
    // cost is that the very first paint uses the previous colour.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (ref.read(chartLabelColorProvider) != color) {
        ref.read(chartLabelColorProvider.notifier).state = color;
      }
      if (ref.read(chartGridColorProvider) != gridColor) {
        ref.read(chartGridColorProvider.notifier).state = gridColor;
      }
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
