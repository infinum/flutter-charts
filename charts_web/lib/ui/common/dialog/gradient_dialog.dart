import 'package:charts_web/ui/home/presenter/chart_state_provider.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LinearGradientPickerDialog extends ConsumerStatefulWidget {
  const LinearGradientPickerDialog({Key? key, required this.startGradient, this.onResetGradient}) : super(key: key);

  static Future<LinearGradient?> show(BuildContext context, LinearGradient startGradient,
      {VoidCallback? onResetGradient}) {
    return showDialog<LinearGradient>(
        context: context,
        builder: (_) {
          return AlertDialog(
            content: LinearGradientPickerDialog(startGradient: startGradient, onResetGradient: onResetGradient),
          );
        });
  }

  final LinearGradient startGradient;
  final VoidCallback? onResetGradient;

  @override
  ConsumerState<LinearGradientPickerDialog> createState() => _LinearGradientPickerDialogState();
}

class _LinearGradientPickerDialogState extends ConsumerState<LinearGradientPickerDialog> {
  late Color start;
  late Color end;
  late bool isAlignmentHorizontal = false;

  @override
  void initState() {
    super.initState();
    start = widget.startGradient.colors[0];
    end = widget.startGradient.colors[1];
    isAlignmentHorizontal = widget.startGradient.begin == Alignment.centerLeft;
  }

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
                'In this editor you can select only simple two-stop linear gradient. You can add any kind of gradient in code.'),
            SizedBox(height: 16),
            ColorPicker(
              color: widget.startGradient.colors[0],
              onColorChanged: (Color color) {
                setState(() {
                  start = color;
                });
              },
              title: const Text('Start color'),
              width: 44,
              height: 44,
              enableShadesSelection: false,
              pickersEnabled: {ColorPickerType.primary: true, ColorPickerType.accent: false},
            ),
            ColorPicker(
              color: widget.startGradient.colors[0],
              onColorChanged: (Color color) {
                setState(() {
                  end = color;
                });
              },
              title: const Text('End color'),
              width: 44,
              height: 44,
              enableShadesSelection: false,
              pickersEnabled: {ColorPickerType.primary: true, ColorPickerType.accent: false},
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: 400,
              child: SwitchListTile(
                title:
                    Text(isAlignmentHorizontal ? 'Horizontal alignment Left->Right' : 'Vertical alignment Bottom->Top'),
                value: isAlignmentHorizontal,
                onChanged: (v) {
                  setState(() {
                    isAlignmentHorizontal = v;
                  });
                },
              ),
            ),
            const SizedBox(height: 40),
            Container(
              height: 50,
              width: 30,
              decoration: BoxDecoration(
                gradient: _getGradient(),
              ),
            ),
            Row(
              children: [
                TextButton(
                    onPressed: () {
                      widget.onResetGradient?.call();
                      Navigator.of(context).pop();
                    },
                    child: Text('No gradient')),
                ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(_getGradient());
                    },
                    child: Text('OK')),
              ],
            )
          ],
        ),
      ),
    );
  }

  LinearGradient _getGradient() {
    return LinearGradient(
        colors: [start, end],
        begin: isAlignmentHorizontal ? Alignment.centerLeft : Alignment.bottomCenter,
        end: isAlignmentHorizontal ? Alignment.centerRight : Alignment.topCenter);
  }
}
