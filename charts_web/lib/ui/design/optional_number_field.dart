import 'package:charts_web/ui/design/labeled_field.dart';
import 'package:charts_web/ui/design/number_field.dart';
import 'package:material_ui/material_ui.dart';

/// A number option that can also be unset, with a switch to clear it.
///
/// Several chart options behave differently when null rather than zero — an
/// unset `maxBarWidth` means "no limit", not "zero width" — so filling one in
/// has to be reversible.
class OptionalNumberField extends StatelessWidget {
  const OptionalNumberField({
    super.key,
    required this.label,
    required this.value,
    required this.fallback,
    required this.onChanged,
    this.helper,
    this.step = 1,
  });

  final String label;
  final String? helper;
  final double? value;

  /// What the field starts at when it is switched on.
  final double fallback;
  final double step;
  final ValueChanged<double?> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Switch(
          value: value != null,
          onChanged: (on) => onChanged(on ? fallback : null),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: value == null
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: LabeledField(
                    label: label,
                    helper: helper,
                    child: Text(
                      'not set',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                )
              : NumberField(
                  label: label,
                  value: value,
                  step: step,
                  fallback: fallback,
                  onChanged: onChanged,
                ),
        ),
      ],
    );
  }
}
