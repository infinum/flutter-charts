import 'package:charts_web/theme/app_theme.dart';
import 'package:charts_web/ui/design/dart_highlighter.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

/// Monospaced, syntax-highlighted, copyable Dart source.
class CodeBlock extends StatelessWidget {
  const CodeBlock({
    super.key,
    required this.source,
    this.maxHeight,
    this.title,
  });

  final String source;
  final double? maxHeight;
  final String? title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final codeScheme = DartCodeScheme.of(theme.colorScheme);

    final code = SingleChildScrollView(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SelectableText.rich(
          TextSpan(
            style: const TextStyle(
              fontFamily: kMonoFontFamily,
              fontSize: 13,
              height: 1.5,
            ),
            children: highlightDart(source, codeScheme),
          ),
        ),
      ),
    );

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title ?? 'Dart',
                  style: theme.textTheme.labelSmall
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
              ),
              TextButton.icon(
                icon: const Icon(Icons.copy, size: 16),
                label: const Text('Copy'),
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: source));
                  if (context.mounted) {
                    ScaffoldMessenger.maybeOf(context)?.showSnackBar(
                      const SnackBar(content: Text('Copied to clipboard')),
                    );
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 4),
          if (maxHeight == null)
            code
          else
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: maxHeight!),
              child: code,
            ),
        ],
      ),
    );
  }
}
