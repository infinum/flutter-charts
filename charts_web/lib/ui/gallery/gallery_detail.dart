import 'package:charts_web/ui/common/layout/breakpoints.dart';
import 'package:charts_web/ui/design/code_block.dart';
import 'package:charts_web/ui/design/section_card.dart';
import 'package:charts_web/ui/gallery/gallery_entry.dart';
import 'package:charts_web/ui/playground/applied_example.dart';
import 'package:charts_web/ui/shell/shell_destination.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

class GalleryDetail extends ConsumerWidget {
  const GalleryDetail({super.key, required this.entry});

  final GalleryEntry entry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(entry.title)),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
          Text(entry.blurb, style: theme.textTheme.bodyLarge),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.lightbulb_outline,
                  size: 18, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(entry.useCase,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    )),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: entry.tags.map((tag) => Chip(label: Text(tag))).toList(),
          ),
          const SizedBox(height: 20),
          SizedBox(height: 320, child: Builder(builder: entry.buildChart)),
          const SizedBox(height: 24),
          if (context.breakpoint == AppBreakpoint.compact) ...[
            CodeBlock(title: 'ChartState<void>', source: entry.snippet),
            const SizedBox(height: 16),
            _Customization(items: entry.customization),
          ] else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child:
                      CodeBlock(title: 'ChartState<void>', source: entry.snippet),
                ),
                const SizedBox(width: 20),
                Expanded(child: _Customization(items: entry.customization)),
              ],
            ),
          const SizedBox(height: 20),
          Align(
            alignment: Alignment.centerLeft,
            child: FilledButton.icon(
              icon: const Icon(Icons.tune),
              label: const Text('Open in playground'),
              onPressed: () {
                entry.applyToPlayground(ref);
                // Remember it so Reset returns here rather than to the
                // built-in defaults.
                ref.read(appliedGalleryEntryProvider.notifier).state = entry.id;
                // Close the detail route and put the rail on the playground,
                // so the configuration you just applied is what you land on.
                ref.read(shellDestinationProvider.notifier).state =
                    ShellDestination.playground;
                Navigator.of(context).pop();
              },
            ),
          ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// What to change to make the template yours. This is the part that turns an
/// example into something you can ship.
class _Customization extends StatelessWidget {
  const _Customization({required this.items});

  final List<String> items;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SectionCard(
      title: 'Make it yours',
      collapsible: false,
      children: [
        for (final item in items)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 6, right: 10),
                  child: Container(
                    width: 5,
                    height: 5,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(item, style: theme.textTheme.bodySmall),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
