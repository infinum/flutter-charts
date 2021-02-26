import 'package:flutter/material.dart';

class ToggleItem extends StatelessWidget {
  ToggleItem({this.title, this.value, this.onChanged, Key key})
      : super(key: key);

  final bool value;
  final String title;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: SwitchListTile(
        value: value,
        title: Text(title),
        onChanged: onChanged,
      ),
    );
  }
}
