import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

/// Generated Dart source for the current playground configuration.
class CodePanel extends ConsumerWidget {
  const CodePanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        border:
            Border(left: BorderSide(color: theme.colorScheme.outlineVariant)),
      ),
      padding: const EdgeInsets.all(16),
      child: Text('Dart source', style: theme.textTheme.titleSmall),
    );
  }
}
