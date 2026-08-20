import 'package:charts_web/ui/design/code_block.dart';
import 'package:charts_web/ui/gallery/gallery_entry.dart';
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
          Text(entry.blurb, style: theme.textTheme.bodyLarge),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: entry.tags.map((tag) => Chip(label: Text(tag))).toList(),
          ),
          const SizedBox(height: 20),
          SizedBox(height: 320, child: Builder(builder: entry.buildChart)),
          const SizedBox(height: 24),
          CodeBlock(title: 'ChartState<void>', source: entry.snippet),
          const SizedBox(height: 20),
          Align(
            alignment: Alignment.centerLeft,
            child: FilledButton.icon(
              icon: const Icon(Icons.tune),
              label: const Text('Open in playground'),
              onPressed: () {
                entry.applyToPlayground(ref);
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
    );
  }
}
