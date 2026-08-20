import 'package:charts_web/ui/common/layout/breakpoints.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  test('breakpointForWidth maps widths to buckets', () {
    expect(breakpointForWidth(360), AppBreakpoint.compact);
    expect(breakpointForWidth(799), AppBreakpoint.compact);
    expect(breakpointForWidth(800), AppBreakpoint.medium);
    expect(breakpointForWidth(1399), AppBreakpoint.medium);
    expect(breakpointForWidth(1400), AppBreakpoint.expanded);
    expect(breakpointForWidth(2560), AppBreakpoint.expanded);
  });

  testWidgets('context.breakpoint reads the real viewport width',
      (tester) async {
    tester.view.physicalSize = const Size(1000, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    late AppBreakpoint seen;
    await tester.pumpWidget(MaterialApp(
      home: Builder(builder: (context) {
        seen = context.breakpoint;
        return const SizedBox.shrink();
      }),
    ));

    expect(seen, AppBreakpoint.medium);
  });
}
