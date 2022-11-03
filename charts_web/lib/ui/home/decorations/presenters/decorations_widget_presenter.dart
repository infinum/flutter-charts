import 'dart:math';
import 'dart:ui';

import 'package:charts_painter/chart.dart';
import 'package:charts_web/ui/home/presenter/chart_decorations_presenter.dart';
import 'package:charts_web/ui/home/presenter/chart_state_presenter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final decorationWidgetPresenter =
    ChangeNotifierProvider.family<DecorationWidgetPresenter, int>((ref, a) => DecorationWidgetPresenter(a, ref));

class DecorationWidgetPresenter extends ChangeNotifier implements DecorationBuilder {
  DecorationWidgetPresenter(this.index, Ref ref);

  final int index;
  int type = 0;

  void updateType(int type) {
    this.type = type;
    notifyListeners();
  }

  @override
  WidgetDecoration buildDecoration() {
    if (type == 0) {
      return WidgetDecoration(widgetDecorationBuilder: (context, chartState, itemWidth, verticalMultiplier) {
        return Stack(
          children: [
            Positioned(
              left: 0,
              right: 0,
              bottom: verticalMultiplier * 3,
              child: Container(color: Colors.blue, height: 2),
            ),
          ],
        );
      });
    } else if (type == 1) {
      return WidgetDecoration(
          widgetDecorationBuilder: (context, chartState, itemWidth, verticalMultiplier) {
            return Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(
                  top: null,
                  bottom: 2 * verticalMultiplier,
                  child: const RotatedBox(quarterTurns: 3, child: Text('This is target line')),
                ),
                Positioned.fill(
                  top: null,
                  left: 0,
                  bottom: 2 * verticalMultiplier,
                  child: Container(color: Colors.blue, width: double.infinity, height: 2),
                ),
              ],
            );
          },
          margin: const EdgeInsets.only(left: 20));
    } else if (type == 2) {
      return WidgetDecoration(widgetDecorationBuilder: (context, chartState, itemWidth, verticalMultiplier) {
        return Padding(
          padding: EdgeInsets.only(top: 5 * verticalMultiplier),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              border: Border.all(color: Colors.blue, width: 2),
              borderRadius: BorderRadius.circular(16),
            ),
            width: double.infinity,
            height: verticalMultiplier * 2,
          ),
        );
      });
    } else if (type == 3) {
      return WidgetDecoration(
          widgetDecorationBuilder: (context, chartState, itemWidth, verticalMultiplier) {
            return Container(
              decoration: BoxDecoration(border: Border.all(color: Colors.blue, width: 3)),
              width: double.infinity,
              height: double.infinity,
            );
          },
          margin: const EdgeInsets.all(3));
    } else if (type == 4) {
      return WidgetDecoration(widgetDecorationBuilder: (context, chartState, itemWidth, verticalMultiplier) {
        return Padding(
          padding: EdgeInsets.only(top: 5 * verticalMultiplier),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Material(
              color: Colors.blue.withOpacity(0.1),
              child: InkWell(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Thanks for clicking'),
                    duration: kThemeAnimationDuration,
                  ));
                },
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blue, width: 2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(child: Text('Click me')),
                  width: double.infinity,
                  height: verticalMultiplier * 2,
                ),
              ),
            ),
          ),
        );
      });
    } else {
      throw 'Unknown type $type';
    }
  }

  @override
  String buildDecorationCode() {
    return '''    WidgetDecoration(
          widgetDecorationBuilder: (context, chartState, itemWidth, verticalMultiplier) {
            return Container(
              decoration: BoxDecoration(border: Border.all(color: Colors.blue, width: 3)),
              width: double.infinity,
              height: double.infinity,
            );
          },
          margin: EdgeInsets.all(3),
    ''';
  }
}
