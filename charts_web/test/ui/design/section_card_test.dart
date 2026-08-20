import 'package:charts_web/theme/app_theme.dart';
import 'package:charts_web/ui/design/section_card.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets('collapsing hides the children', (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: appTheme(Brightness.light),
      home: const Scaffold(
        body: SectionCard(
          title: 'Data',
          subtitle: 'Each data point is an item.',
          children: [Text('body')],
        ),
      ),
    ));

    expect(find.text('body'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.expand_less));
    await tester.pumpAndSettle();

    expect(find.text('body'), findsNothing);
    expect(find.text('Data'), findsOneWidget);
  });
}
