import 'package:charts_web/ui/home/decorations/common_decoration_box.dart';
import 'package:charts_web/ui/home/decorations/presenters/decorations_widget_presenter.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class DecorationsWidget extends HookConsumerWidget {
  const DecorationsWidget({Key? key, required this.decorationIndex})
      : super(key: key);

  final int decorationIndex;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final _presenter = ref.watch(decorationWidgetPresenter(decorationIndex));

    return CommonDecorationBox(
      name: 'Widget decoration',
      decorationIndex: decorationIndex,
      child: Column(
        children: [
          const Text(
              'With widget decoration you provide your own widget and you can do a lot of customization this way. Here are some examples:'),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              TextButton(
                onPressed: () => _presenter.updateType(0),
                child: const Text('Target line'),
              ),
              TextButton(
                onPressed: () => _presenter.updateType(1),
                child: const Text('Target line with text'),
              ),
              TextButton(
                onPressed: () => _presenter.updateType(2),
                child: const Text('Target area'),
              ),
              TextButton(
                onPressed: () => _presenter.updateType(3),
                child: const Text('Border'),
              ),
              TextButton(
                onPressed: () => _presenter.updateType(4),
                child: const Text('Clickable widget'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
