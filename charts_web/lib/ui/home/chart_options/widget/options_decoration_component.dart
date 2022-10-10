import 'package:flutter/material.dart';

import 'options_component_header.dart';

const _subtitle = '''Decorations bla bla...
''';

class OptionsDecorationComponent extends StatelessWidget {
  const OptionsDecorationComponent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const OptionsComponentHeader(title: 'Foreground decorations', subtitle: _subtitle),
      ],
    );
  }
}
