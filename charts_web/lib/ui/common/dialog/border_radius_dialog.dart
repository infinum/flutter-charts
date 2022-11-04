import 'package:charts_web/ui/home/chart_options/widget/options_items_component.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';

import '../widget/double_option_input.dart';

class BorderRadiusDialog extends StatefulWidget {
  const BorderRadiusDialog({Key? key, required this.radius}) : super(key: key);

  static Future<BorderRadius?> show(BuildContext context, BorderRadius radius) {
    return showDialog<BorderRadius>(
        context: context,
        builder: (_) {
          return AlertDialog(
            title: const Text('Set Border Radius'),
            content: BorderRadiusDialog(radius: radius),
          );
        });
  }

  final BorderRadius radius;

  @override
  State<BorderRadiusDialog> createState() => _BorderRadiusDialogState();
}

class _BorderRadiusDialogState extends State<BorderRadiusDialog> {
  late BorderRadius state;

  @override
  void initState() {
    super.initState();

    state = widget.radius;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
              'In this editor you can only change circular border. More advances properties (like non-circular border) can be accessed in code.'),
          SizedBox(height: 16),
          Row(
            children: [
              Column(
                children: [
                  DoubleOptionInput(
                    name: 'Top-left',
                    value: state.topLeft.x,
                    step: 4,
                    onChanged: (a) {
                      setState(() {
                        state = state.copyWith(topLeft: Radius.circular(a));
                      });
                    },
                    defaultValue: widget.radius.topLeft.x,
                  ),
                  DoubleOptionInput(
                      name: 'Bottom-left',
                      value: state.bottomLeft.x,
                      step: 4,
                      onChanged: (a) {
                        setState(() => state =
                            state.copyWith(bottomLeft: Radius.circular(a)));
                      },
                      defaultValue: widget.radius.bottomLeft.x),
                ],
              ),
              const SizedBox(width: 16),
              Container(
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.7),
                  borderRadius: state,
                ),
              ),
              const SizedBox(width: 16),
              Column(
                children: [
                  DoubleOptionInput(
                      name: 'Top-right',
                      value: state.topRight.x,
                      step: 4,
                      onChanged: (a) {
                        setState(() => state =
                            state.copyWith(topRight: Radius.circular(a)));
                      },
                      defaultValue: widget.radius.topRight.x),
                  DoubleOptionInput(
                      name: 'Bottom-right',
                      value: state.bottomRight.x,
                      step: 4,
                      onChanged: (a) {
                        setState(() => state =
                            state.copyWith(bottomRight: Radius.circular(a)));
                      },
                      defaultValue: widget.radius.bottomRight.x),
                ],
              ),
            ],
          ),
          const SizedBox(height: 36),
          Row(
            children: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(BorderRadius.zero);
                },
                child: const Text('No Border radius'),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(state);
                },
                child: const Text('OK'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
