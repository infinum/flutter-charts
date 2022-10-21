import 'package:charts_painter/chart.dart';
import 'package:charts_web/assets.gen.dart';
import 'package:flutter/material.dart';

class FuturamaBarWidget extends StatelessWidget {
  FuturamaBarWidget({Key? key, required this.stackItems, required this.listKey, required this.item}) : super(key: key);

  final bool stackItems;
  final int listKey;
  final ChartItem<dynamic> item;

  final _images = [
    Assets.png.futurama1.path,
    Assets.png.futurama2.path,
    Assets.png.futurama5.path,
    Assets.png.futurama4.path,
    Assets.png.futurama1.path,
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 3.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular((!stackItems || listKey == 0) ? 12 : 0)),
      ),
      foregroundDecoration: BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular((!stackItems || listKey == 0) ? 12 : 0)),
        color: Colors.accents[listKey].withOpacity(0.2),
        border: Border.all(
          width: 2,
          color: Colors.accents[listKey],
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.vertical(top: Radius.circular((!stackItems || listKey == 0) ? 12 : 0)),
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                _images[listKey],
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              top: 8.0,
              left: 0.0,
              right: 0.0,
              child: Text(
                '${item.max?.toStringAsFixed(2)}',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.subtitle1!.copyWith(
                      color: Colors.black87,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
