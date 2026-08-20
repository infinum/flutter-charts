import 'package:charts_web/theme/theme_mode_provider.dart';
import 'package:charts_web/ui/common/layout/breakpoints.dart';
import 'package:charts_web/ui/common/platform/open_external.dart';
import 'package:charts_web/ui/shell/app_version.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

class ShellHeader extends ConsumerWidget {
  const ShellHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final mode = ref.watch(themeModeProvider);
    // On a phone the wordmark, version chip and three actions do not fit; the
    // chip and the external links are the parts that can wait.
    final isCompact = context.breakpoint == AppBreakpoint.compact;

    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        border: Border(
          bottom: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.insights, color: theme.colorScheme.primary),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              'charts_painter',
              style: theme.textTheme.titleMedium,
              overflow: TextOverflow.ellipsis,
              softWrap: false,
            ),
          ),
          if (!isCompact) ...[
            const SizedBox(width: 10),
            Chip(
              label: Text('v$kChartsPainterVersion'),
              visualDensity: VisualDensity.compact,
              labelStyle: theme.textTheme.labelSmall,
            ),
          ],
          const Spacer(),
          if (!isCompact) ...[
            IconButton(
              tooltip: 'pub.dev',
              icon: const Icon(Icons.inventory_2_outlined),
              onPressed: () => openExternal(kPubDevUrl),
            ),
            IconButton(
              tooltip: 'GitHub',
              icon: const Icon(Icons.code),
              onPressed: () => openExternal(kGitHubUrl),
            ),
          ] else
            IconButton(
              tooltip: 'Open on GitHub',
              icon: const Icon(Icons.code),
              onPressed: () => openExternal(kGitHubUrl),
            ),
          IconButton(
            tooltip: switch (mode) {
              ThemeMode.system => 'Theme: follow system',
              ThemeMode.light => 'Theme: light',
              ThemeMode.dark => 'Theme: dark',
            },
            icon: Icon(switch (mode) {
              ThemeMode.system => Icons.brightness_auto,
              ThemeMode.light => Icons.light_mode,
              ThemeMode.dark => Icons.dark_mode,
            }),
            onPressed: () {
              ref.read(themeModeProvider.notifier).state = switch (mode) {
                ThemeMode.system => ThemeMode.light,
                ThemeMode.light => ThemeMode.dark,
                ThemeMode.dark => ThemeMode.system,
              };
            },
          ),
        ],
      ),
    );
  }
}
