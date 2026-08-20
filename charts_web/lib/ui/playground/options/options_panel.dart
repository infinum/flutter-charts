import 'package:charts_web/ui/playground/options/decorations_section.dart';
import 'package:charts_web/ui/playground/options/data_section.dart';
import 'package:charts_web/ui/playground/options/item_options_section.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

class OptionsPanel extends ConsumerWidget {
  const OptionsPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DataSection(),
        SizedBox(height: 12),
        ItemOptionsSection(),
        SizedBox(height: 12),
        DecorationsSection(),
      ],
    );
  }
}
