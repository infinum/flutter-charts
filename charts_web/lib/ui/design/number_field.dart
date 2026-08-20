import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:material_ui/material_ui.dart';

/// Numeric input with decrement / increment steppers, used for every double
/// option (widths, paddings, line widths, axis steps).
class NumberField extends HookWidget {
  const NumberField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.step = 1,
    this.fallback = 0,
    this.suffix,
    this.showInput = true,
  });

  final String label;
  final double? value;
  final ValueChanged<double> onChanged;
  final double step;

  /// Used when [value] is null and the user presses a stepper.
  final double fallback;
  final String? suffix;

  /// When false only the current value is shown, without a text field. Used for
  /// options where free typing is not useful.
  final bool showInput;

  @override
  Widget build(BuildContext context) {
    final controller = useTextEditingController(text: _format(value));
    final lastValue = useRef(value);

    // Keep the field in sync when the value changes from elsewhere (a preset
    // being applied, a reset) without fighting the user mid-edit.
    useEffect(() {
      if (lastValue.value != value) {
        lastValue.value = value;
        controller.text = _format(value);
      }
      return null;
    }, [value]);

    return Row(
      children: [
        Expanded(
          child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
        ),
        const SizedBox(width: 8),
        if (showInput)
          SizedBox(
            width: 76,
            child: TextField(
              controller: controller,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              textAlign: TextAlign.end,
              decoration: InputDecoration(suffixText: suffix),
              onChanged: (text) {
                final parsed = double.tryParse(text);
                if (parsed != null) {
                  lastValue.value = parsed;
                  onChanged(parsed);
                }
              },
            ),
          )
        else
          Text(_format(value), style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(width: 4),
        IconButton.filledTonal(
          visualDensity: VisualDensity.compact,
          icon: const Icon(Icons.remove, size: 16),
          onPressed: () => _step(-step),
        ),
        IconButton.filledTonal(
          visualDensity: VisualDensity.compact,
          icon: const Icon(Icons.add, size: 16),
          onPressed: () => _step(step),
        ),
      ],
    );
  }

  void _step(double delta) {
    final current = value;
    onChanged(current == null ? fallback : _round(current + delta));
  }

  static double _round(double value) => (value * 10).round() / 10;

  static String _format(double? value) => value == null
      ? ''
      : (value == value.roundToDouble()
          ? value.toStringAsFixed(0)
          : value.toString());
}
