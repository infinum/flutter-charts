import 'package:charts_web/ui/design/labeled_field.dart';
import 'package:charts_web/ui/design/number_field.dart';
import 'package:material_ui/material_ui.dart';

/// Four-sided editor for an [EdgeInsets] option. The old panel only exposed
/// left and right, so top and bottom were unreachable from the UI.
class EdgeInsetsField extends StatelessWidget {
  const EdgeInsetsField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.helper,
    this.horizontalOnly = false,
  });

  final String label;
  final String? helper;
  final EdgeInsets value;
  final ValueChanged<EdgeInsets> onChanged;

  /// Some insets are only read horizontally by the library, so offering top
  /// and bottom would be offering controls that do nothing.
  final bool horizontalOnly;

  @override
  Widget build(BuildContext context) {
    return LabeledField(
      label: label,
      helper: helper,
      child: Column(
        children: [
          NumberField(
            label: 'Left',
            value: value.left,
            step: 2,
            onChanged: (side) => onChanged(value.copyWith(left: side)),
          ),
          if (!horizontalOnly)
            NumberField(
              label: 'Top',
              value: value.top,
              step: 2,
              onChanged: (side) => onChanged(value.copyWith(top: side)),
            ),
          NumberField(
            label: 'Right',
            value: value.right,
            step: 2,
            onChanged: (side) => onChanged(value.copyWith(right: side)),
          ),
          if (!horizontalOnly)
            NumberField(
              label: 'Bottom',
              value: value.bottom,
              step: 2,
              onChanged: (side) => onChanged(value.copyWith(bottom: side)),
            ),
        ],
      ),
    );
  }
}
