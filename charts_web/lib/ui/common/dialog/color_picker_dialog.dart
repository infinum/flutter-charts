import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';

class ColorPickerDialog extends StatelessWidget {
  const ColorPickerDialog({Key? key, required this.startColor}) : super(key: key);

  static Future<Color?> show(BuildContext context, Color startColor) {
    return showDialog<Color>(
        context: context,
        builder: (_) {
          return AlertDialog(
            content: ColorPickerDialog(startColor: startColor),
          );
        });
  }

  final Color startColor;
  // final ValueChanged<Color> onColorChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: ColorPicker(
          color: startColor,
          // Update the screenPickerColor using the callback.
          onColorChanged: (Color color) {
            Navigator.of(context).pop(color);
          },
          width: 44,
          height: 44,
          enableShadesSelection: false,
          pickersEnabled: {ColorPickerType.primary: true, ColorPickerType.accent: false },
          borderRadius: 22,
          heading: Text(
            'Select color',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          subheading: Text(
            'Select color shade',
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ),
      ),
    );
  }
}
