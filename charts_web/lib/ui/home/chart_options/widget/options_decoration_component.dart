import 'package:charts_web/ui/home/decorations/decorations_sparkline.dart';
import 'package:flutter/material.dart';

import 'options_component_header.dart';

const _subtitle = '''Decorations bla bla...
''';

class DecorationsComponent extends StatelessWidget {
  const DecorationsComponent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const OptionsComponentHeader(title: 'Foreground decorations', subtitle: _subtitle),
        SizedBox(height: 24),
        DecorationsSparkline(),
      ],
    );
  }
}
