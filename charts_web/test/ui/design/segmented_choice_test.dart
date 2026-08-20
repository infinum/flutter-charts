import 'package:charts_web/theme/app_theme.dart';
import 'package:charts_web/ui/design/segmented_choice.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

enum _Painter { bar, bubble }

void main() {
  testWidgets('tapping a segment reports its value', (tester) async {
    final picked = <_Painter>[];
    await tester.pumpWidget(MaterialApp(
      theme: appTheme(Brightness.light),
      home: Scaffold(
        body: SegmentedChoice<_Painter>(
          label: 'Painter',
          value: _Painter.bar,
          options: const [
            SegmentedChoiceOption(value: _Painter.bar, label: 'Bar'),
            SegmentedChoiceOption(value: _Painter.bubble, label: 'Bubble'),
          ],
          onChanged: picked.add,
        ),
      ),
    ));

    await tester.tap(find.text('Bubble'));

    expect(picked, [_Painter.bubble]);
  });
}
