import 'package:charts_painter/chart.dart';
import 'package:charts_web/codegen/dart_literal.dart';
import 'package:charts_web/codegen/source_writer.dart';
import 'package:charts_web/ui/playground/presenter/chart_decorations_presenter.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final decorationWidgetPresenter =
    ChangeNotifierProvider.family<DecorationWidgetPresenter, int>(
        (ref, a) => DecorationWidgetPresenter(a, ref));

class DecorationWidgetPresenter extends ChangeNotifier
    implements DecorationBuilder {
  DecorationWidgetPresenter(this.index, Ref ref);

  final int index;
  int type = 0;

  /// Null means "use whatever this example needs". Types 1 and 2 position
  /// themselves with a margin, so overriding blindly would break their layout.
  EdgeInsets? _marginOverride;

  static const Map<int, EdgeInsets> _defaultMargins = {
    1: EdgeInsets.only(left: 20),
    3: EdgeInsets.all(3),
  };

  EdgeInsets get margin =>
      _marginOverride ?? _defaultMargins[type] ?? EdgeInsets.zero;

  void updateType(int type) {
    this.type = type;
    // Each example has its own layout needs; drop a stale override.
    _marginOverride = null;
    notifyListeners();
  }

  void updateMargin(EdgeInsets value) {
    _marginOverride = value;
    notifyListeners();
  }

  @override
  WidgetDecoration buildDecoration() {
    if (type == 0) {
      return WidgetDecoration(margin: margin, widgetDecorationBuilder:
          (context, chartState, itemWidth, verticalMultiplier) {
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
          widgetDecorationBuilder:
              (context, chartState, itemWidth, verticalMultiplier) {
            return Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(
                  top: null,
                  bottom: 2 * verticalMultiplier,
                  child: const RotatedBox(
                      quarterTurns: 3, child: Text('This is target line')),
                ),
                Positioned.fill(
                  top: null,
                  left: 0,
                  bottom: 2 * verticalMultiplier,
                  child: Container(
                      color: Colors.blue, width: double.infinity, height: 2),
                ),
              ],
            );
          },
          margin: margin);
    } else if (type == 2) {
      return WidgetDecoration(margin: margin, widgetDecorationBuilder:
          (context, chartState, itemWidth, verticalMultiplier) {
        return Padding(
          padding: EdgeInsets.only(top: 5 * verticalMultiplier),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.1),
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
          widgetDecorationBuilder:
              (context, chartState, itemWidth, verticalMultiplier) {
            return Container(
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.blue, width: 3)),
              width: double.infinity,
              height: double.infinity,
            );
          },
          margin: margin);
    } else if (type == 4) {
      return WidgetDecoration(margin: margin, widgetDecorationBuilder:
          (context, chartState, itemWidth, verticalMultiplier) {
        return Padding(
          padding: EdgeInsets.only(top: 5 * verticalMultiplier),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Material(
              color: Colors.blue.withValues(alpha: 0.1),
              child: InkWell(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Thanks for clicking'),
                    duration: kThemeAnimationDuration,
                  ));
                },
                child: Container(
                  width: double.infinity,
                  height: verticalMultiplier * 2,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blue, width: 2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(child: Text('Click me')),
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

  static const Map<int, String> _exampleNames = {
    0: 'target line',
    1: 'target line with a label',
    2: 'target area',
    3: 'border',
    4: 'clickable widget',
  };

  @override
  void writeDecorationSource(SourceWriter writer) {
    writer.open('WidgetDecoration(');
    writer.line('// This playground draws a ${_exampleNames[type]} here.');
    writer.line('// A widget decoration can return any widget; the demo builds');
    writer.line('// are in charts_web/lib/ui/playground/decorations/presenters/');
    writer.line('// decorations_widget_presenter.dart');
    writer.open(
        'widgetDecorationBuilder: (context, chartState, itemWidth, verticalMultiplier) {');
    writer.open('return DecoratedBox(');
    writer.open('decoration: BoxDecoration(');
    writer.line('border: Border.all(color: Color(0xFF2196F3), width: 3.0),');
    writer.close('),');
    writer.line('child: const SizedBox.expand(),');
    writer.close(');');
    writer.close('},');
    if (margin != EdgeInsets.zero) {
      writer.line('margin: ${edgeInsetsLiteral(margin)},');
    }
    writer.close('),');
  }
}
