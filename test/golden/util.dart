import 'dart:math';

import 'package:charts_painter/chart.dart';
import 'package:flutter/material.dart';

TextStyle get defaultTextStyle =>
    const TextStyle(fontFamily: 'Roboto', color: Colors.black54, fontSize: 12);

Widget getDefaultChart({
  List<DecorationPainter>? foregroundDecorations,
  List<DecorationPainter>? backgroundDecorations,
}) {
  return Padding(
    padding: EdgeInsets.zero,
    child: Chart<void>(
      state: ChartState(
        data: ChartData.fromList(
          [5, 6, 8, 4, 3, 5, 2, 6, 7]
              .map((e) => BarValue<void>(e.toDouble()))
              .toList(),
          valueAxisMaxOver: 2,
        ),
        itemOptions: BarItemOptions(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          barItemBuilder: (_) => BarItem(color: Colors.red.withOpacity(0.1)),
        ),
        backgroundDecorations: backgroundDecorations ?? [],
        foregroundDecorations: foregroundDecorations ?? [],
      ),
    ),
  );
}

Widget getMultiValueChart({
  int size = 2,
  List<DecorationPainter>? foregroundDecorations,
  List<DecorationPainter>? backgroundDecorations,
  ItemOptions? options,
  ChartBehaviour? behaviour,
  DataStrategy strategy = const DefaultDataStrategy(stackMultipleValues: true),
}) {
  return Padding(
    padding: EdgeInsets.zero,
    child: Chart<void>(
      state: ChartState(
        data: ChartData(
          List.generate(
            size,
            (index) => List.generate(
              8,
              (i) => BarValue<void>(
                (Random((index + 1) * (i + 1)).nextDouble() * 15) + 5,
              ),
            ),
          ),
          valueAxisMaxOver: 2,
          dataStrategy: strategy,
        ),
        itemOptions: options ?? const BarItemOptions(),
        behaviour: behaviour ?? const ChartBehaviour(),
        backgroundDecorations: backgroundDecorations ?? [],
        foregroundDecorations: foregroundDecorations ?? [],
      ),
    ),
  );
}
