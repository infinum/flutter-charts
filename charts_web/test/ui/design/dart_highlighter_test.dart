import 'package:charts_web/ui/design/dart_highlighter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  final scheme = DartCodeScheme.of(
      ColorScheme.fromSeed(seedColor: const Color(0xFFD8262C)));

  TextSpan spanFor(List<TextSpan> spans, String text) =>
      spans.firstWhere((span) => span.text == text);

  test('classifies keywords, types, numbers and hex literals', () {
    final spans = highlightDart(
        'const BarItem(radius: 2.5, color: Color(0xFFD8262C))', scheme);

    expect(spanFor(spans, 'const').style!.color, scheme.keyword);
    expect(spanFor(spans, 'BarItem').style!.color, scheme.type);
    expect(spanFor(spans, '2.5').style!.color, scheme.number);
    expect(spanFor(spans, '0xFFD8262C').style!.color, scheme.number);
    expect(spanFor(spans, 'radius').style!.color, scheme.base);
  });

  test('classifies strings and line comments', () {
    final spans = highlightDart("// note\nid: 'main'", scheme);

    expect(spanFor(spans, '// note').style!.color, scheme.comment);
    expect(spanFor(spans, "'main'").style!.color, scheme.string);
  });

  test('reassembling the spans reproduces the source exactly', () {
    const source = 'ChartState<void>(\n  data: ChartData([[1.0, 2.0]]),\n)';

    final rebuilt =
        highlightDart(source, scheme).map((span) => span.text).join();

    expect(rebuilt, source);
  });
}
