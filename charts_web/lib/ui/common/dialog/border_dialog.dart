import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../widget/double_option_input.dart';

class BorderSideDialog extends StatefulWidget {
  const BorderSideDialog({Key? key, required this.borderSide, required this.color}) : super(key: key);

  static Future<BorderSide?> show(BuildContext context, BorderSide borderSide, Color? color) {
    return showDialog<BorderSide>(
        context: context,
        builder: (_) {
          return AlertDialog(
            title: const Text('Set Border'),
            content: BorderSideDialog(borderSide: borderSide, color: color),
          );
        });
  }

  final BorderSide borderSide;
  final Color? color;

  @override
  State<BorderSideDialog> createState() => _BorderSideDialogState();
}

class _BorderSideDialogState extends State<BorderSideDialog> {
  late double width;
  late Color color;

  @override
  void initState() {
    super.initState();
    width = widget.borderSide.width;
    color = widget.color ?? Colors.black87;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
              'In this editor you can only edit uniform border. More advanced properties (like border sides, storck style) can be accessed in code.'),
          const SizedBox(height: 16),
          DoubleOptionInput(
            name: 'Border width',
            value: width,
            step: 2,
            onChanged: (a) {
              setState(() {
                width = a;
              });
            },
            defaultValue: widget.borderSide.width,
          ),
          const SizedBox(height: 16),
          Container(
            width: 150,
            height: 40,
            decoration: BoxDecoration(
              border: Border.all(color: color, width: width),
            ),
          ),
          const SizedBox(height: 8),
          ColorPicker(
            color: color,
            // Update the screenPickerColor using the callback.
            onColorChanged: (Color newColor) {
              color = newColor;
            },
            width: 44,
            height: 44,
            enableShadesSelection: false,
            pickersEnabled: {ColorPickerType.primary: true, ColorPickerType.accent: false},
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
          const SizedBox(height: 36),
          Row(
            children: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(BorderSide.none);
                },
                child: const Text('No Border'),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(BorderSide(color: color, width: width));
                  },
                  child: const Text('OK')),
            ],
          ),
        ],
      ),
    );
  }
}
