import 'package:charts_web/codegen/source_writer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('open and close manage indentation', () {
    final writer = SourceWriter();

    writer.open('ChartState<void>(');
    writer.open('data: ChartData(');
    writer.line('valueAxisMaxOver: 2.0,');
    writer.close('),');
    writer.close(')');

    expect(writer.build(), '''
ChartState<void>(
  data: ChartData(
    valueAxisMaxOver: 2.0,
  ),
)''');
  });

  test('indentWidth is configurable', () {
    final writer = SourceWriter(indentWidth: 4);

    writer.open('a(');
    writer.line('b,');
    writer.close(')');

    expect(writer.build(), 'a(\n    b,\n)');
  });
}
