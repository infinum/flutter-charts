import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';

class ColorPickerDialog extends StatelessWidget {
  const ColorPickerDialog(
      {Key? key, required this.startColor, this.additionalText})
      : super(key: key);

  static Future<Color?> show(BuildContext context, Color startColor,
      {String? additionalText}) {
    return showDialog<Color>(
        context: context,
        builder: (_) {
          return AlertDialog(
            content: ColorPickerDialog(
                startColor: startColor, additionalText: additionalText),
          );
        });
  }

  final Color startColor;
  final String? additionalText;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
                'In this editor you can select only colors from given pallete. Any color can be given in code.\n$additionalText'),
            SizedBox(height: 16),
            ColorPicker(
              color: startColor,
              // Update the screenPickerColor using the callback.
              onColorChanged: (Color color) {
                Navigator.of(context).pop(color);
              },
              width: 44,
              height: 44,
              enableShadesSelection: false,
              pickersEnabled: {
                ColorPickerType.primary: true,
                ColorPickerType.accent: false
              },
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
          ],
        ),
      ),
    );
  }
}

String colorToCode(Color color) {
  return 'Color.fromARGB(${color.alpha}, ${color.red}, ${color.green}, ${color.blue})';
}
