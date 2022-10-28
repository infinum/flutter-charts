import 'package:charts_web/assets.gen.dart';
import 'package:charts_web/ui/home/presenter/chart_decorations_presenter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:collection/collection.dart';

import '../presenter/chart_state_presenter.dart';

class CommonDecorationBox extends HookConsumerWidget {
  const CommonDecorationBox({Key? key, this.onDataListSelected, required this.child, required this.decorationIndex, required this.name})
      : super(key: key);

  final ValueChanged<int>? onDataListSelected;
  final Widget child;
  final int decorationIndex;
  final String name;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final _chartStatePresenter = ref.watch(chartStatePresenter);
    final _chartDecorationsPresenter = ref.watch(chartDecorationsPresenter);
    final isInForeground =
        _chartDecorationsPresenter.getLayerOfDecoration(decorationIndex) == DecorationLayer.foreground;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white54,
        borderRadius: BorderRadius.circular(24),
      ),
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(name, style: TextStyle(fontWeight: FontWeight.bold)),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(width: 24),
              Column(
                children: [
                  IconButton(
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      _chartDecorationsPresenter.moveDecorationToLayer(decorationIndex, DecorationLayer.foreground);
                    },
                    icon: Opacity(
                      opacity: isInForeground ? 1.0 : 0.3,
                      child: SvgPicture.asset(Assets.svg.decoForeground),
                    ),
                  ),
                  const Text('Foreground', style: TextStyle(fontSize: 10)),
                ],
              ),
              const SizedBox(width: 6),
              Column(
                children: [
                  IconButton(
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      _chartDecorationsPresenter.moveDecorationToLayer(decorationIndex, DecorationLayer.background);
                    },
                    icon: Opacity(
                      opacity: !isInForeground ? 1.0 : 0.3,
                      child: SvgPicture.asset(Assets.svg.decoBackground),
                    ),
                  ),
                  const Text('Background', style: TextStyle(fontSize: 10)),
                ],
              ),
              if (onDataListSelected != null && _chartStatePresenter.isMultiItem) ...[
                const SizedBox(width: 24),
                const Text('Data list: '),
                ..._chartStatePresenter.data.mapIndexed(
                  (index, element) => IconButton(
                    onPressed: () => onDataListSelected!(index),
                    icon: Icon(
                      Icons.circle,
                      color: _chartStatePresenter.listColors[index],
                    ),
                  ),
                )
              ],
              const Spacer(),
              IconButton(
                onPressed: () {
                  ref.read(chartDecorationsPresenter).removeDecoration(decorationIndex);
                },
                icon: const Icon(Icons.delete_forever, color: Colors.black54),
              ),
            ],
          ),
          Divider(),
          child,
        ],
      ),
    );
  }
}
