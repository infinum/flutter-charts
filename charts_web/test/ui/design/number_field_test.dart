import 'package:charts_web/theme/app_theme.dart';
import 'package:charts_web/ui/design/number_field.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

Widget _wrap(Widget child) => MaterialApp(
      theme: appTheme(Brightness.light),
      home: Scaffold(body: Center(child: child)),
    );

void main() {
  testWidgets('steppers move the value by step', (tester) async {
    final changes = <double>[];
    await tester.pumpWidget(_wrap(NumberField(
      label: 'Max bar width',
      value: 10,
      step: 2,
      onChanged: changes.add,
    )));

    await tester.tap(find.byIcon(Icons.add));
    await tester.tap(find.byIcon(Icons.remove));

    expect(changes, [12.0, 8.0]);
  });

  testWidgets('a null value steps from the fallback', (tester) async {
    final changes = <double>[];
    await tester.pumpWidget(_wrap(NumberField(
      label: 'Min bar width',
      value: null,
      step: 2,
      fallback: 20,
      onChanged: changes.add,
    )));

    await tester.tap(find.byIcon(Icons.add));

    expect(changes, [20.0]);
  });

  testWidgets('unparseable text does not throw and does not report',
      (tester) async {
    final changes = <double>[];
    await tester.pumpWidget(_wrap(NumberField(
      label: 'Padding',
      value: 4,
      onChanged: changes.add,
    )));

    await tester.enterText(find.byType(TextField), '');
    await tester.pump();

    expect(changes, isEmpty);
    expect(tester.takeException(), isNull);
  });
}
