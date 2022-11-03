import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

/// Small input used for double values, e.g. padding
class DoubleOptionInput extends HookWidget {
  DoubleOptionInput(
      {Key? key,
      required this.name,
      required this.value,
      required this.step,
      required this.onChanged,
      required this.defaultValue,
      this.noInputField = false})
      : super(key: key);

  final String name;
  final double? value;

  final double step;
  final Function(double) onChanged;
  final double defaultValue;
  final bool noInputField;

  late TextEditingController textEditingController;

  @override
  Widget build(BuildContext context) {
    textEditingController = useTextEditingController(text: value.toString());

    return ClipRRect(
      child: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: SizedBox(
          width: 230,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(child: Text('$name:')),
              const SizedBox(width: 8),
              if (!noInputField)
                SizedBox(
                  width: 50,
                  child: TextField(
                    decoration: InputDecoration(filled: true, isDense: true),
                    controller: textEditingController,
                    onChanged: (value) {
                      final newValue = double.parse(value);
                      onChanged(newValue);
                    },
                    style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold),
                  ),
                )
              else
                Text(value.toString()),
              const SizedBox(width: 8),
              SizedBox(
                height: 28,
                width: 28,
                child: FloatingActionButton(
                  elevation: 1,
                  mini: true,
                  backgroundColor: Colors.grey,
                  onPressed: decrease,
                  child: const Text('-', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                ),
              ),
              const SizedBox(width: 4),
              SizedBox(
                height: 28,
                width: 28,
                child: FloatingActionButton(
                  elevation: 1,
                  backgroundColor: Colors.grey,
                  mini: true,
                  onPressed: increase,
                  child: const Text('+', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void decrease() {
    if (value == null) {
      changeValue(defaultValue);
    } else {
      changeValue(roundTo(value! - step, 10));
    }
  }

  void increase() {
    if (value == null) {
      changeValue(defaultValue);
    } else {
      changeValue(roundTo(value! + step, 10));
    }
  }

  void changeValue(double value) {
    textEditingController.text = value.toString();
    onChanged(value);
  }

  double roundTo(double value, double precision) => (value * precision).round() / precision;
}
