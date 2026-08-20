import 'package:charts_web/ui/common/layout/breakpoints.dart';
import 'package:charts_web/ui/home/home_screen.dart';
import 'package:charts_web/ui/shell/shell_header.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

enum ShellDestination {
  playground('Playground', Icons.tune),
  gallery('Gallery', Icons.grid_view),
  concepts('Concepts', Icons.school_outlined);

  const ShellDestination(this.label, this.icon);

  final String label;
  final IconData icon;
}

class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final isCompact = context.breakpoint == AppBreakpoint.compact;

    // IndexedStack, not a swap: a playground configuration must survive a trip
    // to the gallery and back.
    final body = IndexedStack(
      index: _index,
      children: [
        HomeScreen(),
        const _Placeholder(label: 'Gallery'),
        const _Placeholder(label: 'Concepts'),
      ],
    );

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
                        selectedIndex: _index,
                        onDestinationSelected: _select,
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
              selectedIndex: _index,
              onDestinationSelected: _select,
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

  void _select(int index) => setState(() => _index = index);
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) => Center(child: Text(label));
}
