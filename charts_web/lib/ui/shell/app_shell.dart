import 'package:charts_web/ui/common/layout/breakpoints.dart';
import 'package:charts_web/ui/concepts/concepts_screen.dart';
import 'package:charts_web/ui/shell/chart_theme_sync.dart';
import 'package:charts_web/ui/gallery/gallery_screen.dart';
import 'package:charts_web/ui/playground/playground_screen.dart';
import 'package:charts_web/ui/shell/shell_destination.dart';
import 'package:charts_web/ui/shell/shell_header.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

class AppShell extends ConsumerWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isCompact = context.breakpoint == AppBreakpoint.compact;
    final index = ref.watch(shellDestinationProvider).index;

    // IndexedStack, not a swap: a playground configuration must survive a trip
    // to the gallery and back.
    final body = ChartThemeSync(
        child: IndexedStack(
      index: index,
      children: [
        const PlaygroundScreen(),
        const GalleryScreen(),
        const ConceptsScreen(),
      ],
    ));

    return Scaffold(
      body: Column(
        children: [
          const ShellHeader(),
          Expanded(
            child: isCompact
                ? body
                : Row(
                    children: [
                      NavigationRail(
                        selectedIndex: index,
                        onDestinationSelected: (value) => _select(ref, value),
                        destinations: ShellDestination.values
                            .map((destination) => NavigationRailDestination(
                                  icon: Icon(destination.icon),
                                  label: Text(destination.label),
                                ))
                            .toList(),
                      ),
                      Expanded(child: body),
                    ],
                  ),
          ),
        ],
      ),
      bottomNavigationBar: isCompact
          ? NavigationBar(
              selectedIndex: index,
              onDestinationSelected: (value) => _select(ref, value),
              destinations: ShellDestination.values
                  .map((destination) => NavigationDestination(
                        icon: Icon(destination.icon),
                        label: destination.label,
                      ))
                  .toList(),
            )
          : null,
    );
  }

  void _select(WidgetRef ref, int index) =>
      ref.read(shellDestinationProvider.notifier).state =
          ShellDestination.values[index];
}
