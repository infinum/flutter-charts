import 'package:flutter/material.dart';

class CounterItem extends StatelessWidget {
  CounterItem(
      {required this.title,
      required this.value,
      required this.onMinus,
      required this.onPlus,
      Key? key})
      : super(key: key);

  final int value;
  final String title;
  final VoidCallback onMinus;
  final VoidCallback onPlus;

  @override
  Widget build(BuildContext context) {
    return Container(
        child: ListTile(
      title: Text(title),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: onMinus,
            child: AspectRatio(
              aspectRatio: 1,
              child: Icon(Icons.remove),
            ),
          ),
          InkWell(
            onTap: onPlus,
            child: AspectRatio(
              aspectRatio: 1,
              child: Icon(Icons.add),
            ),
          ),
          AspectRatio(
            aspectRatio: 1,
            child: Center(child: Text('$value')),
          ),
        ],
      ),
    ));
  }
}
