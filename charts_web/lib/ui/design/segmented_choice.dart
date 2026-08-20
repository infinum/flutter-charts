import 'package:charts_web/ui/design/labeled_field.dart';
import 'package:material_ui/material_ui.dart';

class SegmentedChoiceOption<T> {
  const SegmentedChoiceOption({
    required this.value,
    required this.label,
    this.icon,
  });

  final T value;
  final String label;
  final IconData? icon;
}

/// Single-select control for enum-ish options. Replaces the hand-rolled
/// selected-border buttons and the image switch.
class SegmentedChoice<T> extends StatelessWidget {
  const SegmentedChoice({
    super.key,
    required this.value,
    required this.options,
    required this.onChanged,
    this.label,
    this.helper,
  });

  final T value;
  final List<SegmentedChoiceOption<T>> options;
  final ValueChanged<T> onChanged;
  final String? label;
  final String? helper;

  @override
  Widget build(BuildContext context) {
    final control = SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SegmentedButton<T>(
        showSelectedIcon: false,
        segments: options
            .map((option) => ButtonSegment<T>(
                  value: option.value,
                  label: Text(option.label),
                  icon: option.icon == null ? null : Icon(option.icon),
                ))
            .toList(),
        selected: {value},
        onSelectionChanged: (selection) => onChanged(selection.first),
      ),
    );

    if (label == null) return control;

    return LabeledField(label: label!, helper: helper, child: control);
  }
}
