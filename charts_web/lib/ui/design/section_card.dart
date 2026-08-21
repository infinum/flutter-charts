import 'package:material_ui/material_ui.dart';

/// A titled container for one group of options. Collapsible so a long option
/// panel stays navigable.
class SectionCard extends StatefulWidget {
  const SectionCard({
    super.key,
    required this.title,
    this.subtitle,
    required this.children,
    this.initiallyExpanded = true,
    this.collapsible = true,
    this.trailing,
    this.expanded,
    this.onExpandedChanged,
  });

  final String title;
  final String? subtitle;
  final List<Widget> children;
  final bool initiallyExpanded;
  final bool collapsible;
  final Widget? trailing;

  /// Set to drive expansion from outside, for a group of cards that should
  /// open one at a time. Null leaves the card in charge of itself.
  final bool? expanded;
  final ValueChanged<bool>? onExpandedChanged;

  @override
  State<SectionCard> createState() => _SectionCardState();
}

class _SectionCardState extends State<SectionCard> {
  late bool _ownExpanded = widget.initiallyExpanded;

  bool get _expanded => widget.expanded ?? _ownExpanded;

  void _toggle() {
    final next = !_expanded;

    if (widget.expanded == null) {
      setState(() => _ownExpanded = next);
    }

    widget.onExpandedChanged?.call(next);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: widget.collapsible
                      ? InkWell(
                          onTap: _toggle,
                          borderRadius: BorderRadius.circular(8),
                          child: _title(theme),
                        )
                      : _title(theme),
                ),
                if (widget.trailing != null) widget.trailing!,
                if (widget.collapsible)
                  IconButton(
                    tooltip: _expanded ? 'Collapse' : 'Expand',
                    icon:
                        Icon(_expanded ? Icons.expand_less : Icons.expand_more),
                    onPressed: _toggle,
                  ),
              ],
            ),
            if (_expanded) ...[
              const SizedBox(height: 12),
              ...widget.children,
            ],
          ],
        ),
      ),
    );
  }

  Widget _title(ThemeData theme) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.title, style: theme.textTheme.titleMedium),
          if (widget.subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              widget.subtitle!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      );
}
