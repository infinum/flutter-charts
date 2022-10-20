import 'dart:ui';

import 'package:charts_painter/chart.dart';
import 'package:charts_web/ui/common/dialog/border_dialog.dart';
import 'package:charts_web/ui/common/dialog/border_radius_dialog.dart';
import 'package:charts_web/ui/common/dialog/gradient_dialog.dart';
import 'package:charts_web/ui/home/presenter/chart_state_presenter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:collection/collection.dart';

import '../../../../assets.gen.dart';
import '../../../common/widget/double_option_input.dart';
import 'options_component_header.dart';

const _subtitle =
    '''Options that define how each item looks. There are presets for Bar and Bubble. For super custom solutions use WidgetItemOptions or you can extend GeomeryPainter and draw on canvas.
''';

class OptionsItemsComponent extends HookConsumerWidget {
  const OptionsItemsComponent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final _provider = ref.watch(chartStatePresenter);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const OptionsComponentHeader(title: 'Item Options', subtitle: _subtitle),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _BarOptionButton(
              asset: Assets.svg.barChartIcon,
              name: 'Bar',
              selected: _provider.selectedPainter == SelectedPainter.bar,
              onPressed: () {
                _provider.updateItemPainter(SelectedPainter.bar);
              },
            ),
            _BarOptionButton(
              asset: Assets.svg.bubbleChartIcon,
              name: 'Bubble',
              selected: _provider.selectedPainter == SelectedPainter.bubble,
              onPressed: () {
                _provider.updateItemPainter(SelectedPainter.bubble);
              },
            ),
            _BarOptionButton(
              name: 'Empty',
              selected: _provider.selectedPainter == SelectedPainter.none,
              onPressed: () {
                _provider.updateItemPainter(SelectedPainter.none);
              },
            ),
            _BarOptionButton(
              imageAsset: Assets.png.futurama1.path,
              name: 'Widget',
              selected: _provider.selectedPainter == SelectedPainter.widget,
              onPressed: () {
                _provider.updateItemPainter(SelectedPainter.widget);
              },
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (_provider.selectedPainter == SelectedPainter.widget)
          const Text('With WidgetItemOptions you can provide any kind of widget that you want!'),
        if (_provider.selectedPainter == SelectedPainter.bar || _provider.selectedPainter == SelectedPainter.bubble)
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              DoubleOptionInput(
                name: 'Min bar width',
                value: _provider.minBarWidth,
                step: 2,
                onChanged: _provider.updateMinBarWidth,
                defaultValue: 20,
              ),
              DoubleOptionInput(
                name: 'Max bar width',
                value: _provider.maxBarWidth,
                step: 2,
                onChanged: _provider.updateMaxBarWidth,
                defaultValue: 30,
              ),
              DoubleOptionInput(
                name: 'Padding Left',
                value: _provider.chartItemPadding.left,
                step: 2,
                onChanged: (v) => _provider.updateChartItemPadding(_provider.chartItemPadding.copyWith(left: v)),
                defaultValue: _provider.chartItemPadding.left,
                noInputField: true,
              ),
              DoubleOptionInput(
                name: 'Padding Right',
                value: _provider.chartItemPadding.right,
                step: 2,
                onChanged: (v) => _provider.updateChartItemPadding(_provider.chartItemPadding.copyWith(right: v)),
                defaultValue: _provider.chartItemPadding.right,
                noInputField: true,
              ),
            ],
          ),
        if (_provider.selectedPainter == SelectedPainter.bar || _provider.selectedPainter == SelectedPainter.bubble)
          ..._provider.data.mapIndexed((index, list) {
            return _PerValueOptions(index: index);
          }).toList(),
        if (_provider.isMultiItem) const _MultiValueOptions(),
        // final double? startPosition;
        const SizedBox(height: 16),
      ],
    );
  }
}

/// Options only applicable for multi-value
class _MultiValueOptions extends ConsumerWidget {
  const _MultiValueOptions({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final _provider = ref.watch(chartStatePresenter);

    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Wrap(
        spacing: 16,
        runSpacing: 4,
        children: [
          Text(
            'Multi Item options:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Row(
            children: [
              Text('Multi Item Stack'),
              Switch(value: _provider.multiItemStack, onChanged: _provider.updateMultiItemStack),
            ],
          ),
          if (!_provider.multiItemStack)
            DoubleOptionInput(
              name: 'Padding Left',
              value: _provider.multiValuePadding.left,
              step: 2,
              onChanged: (v) => _provider.updateMultiValuePadding(_provider.multiValuePadding.copyWith(left: v)),
              defaultValue: _provider.multiValuePadding.left,
              noInputField: true,
            ),
          if (!_provider.multiItemStack)
            DoubleOptionInput(
              name: 'Padding Right',
              value: _provider.multiValuePadding.right,
              step: 2,
              onChanged: (v) => _provider.updateMultiValuePadding(_provider.multiValuePadding.copyWith(right: v)),
              defaultValue: _provider.multiValuePadding.right,
              noInputField: true,
            ),
        ],
      ),
    );
  }
}

/// If you have multi-value, you might want to have different optionsItems per each value
class _PerValueOptions extends ConsumerWidget {
  const _PerValueOptions({Key? key, required this.index}) : super(key: key);

  final int index;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final _provider = ref.watch(chartStatePresenter);

    return Row(
      children: [
        Container(width: 10, height: 50, color: _provider.listColors[index]),
        const SizedBox(width: 16),
        Expanded(
          child: Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              ElevatedButton(
                child: const Text('Set border side'),
                onPressed: () async {
                  final border = await BorderSideDialog.show(
                      context, _provider.itemBorderSides[index], _provider.itemBorderSides[index].color);
                  if (border != null) {
                    _provider.updateItemBorderSide(border, index);
                  }
                },
              ),
              ElevatedButton(
                child: const Text('Set gradient'),
                onPressed: () async {
                  final currentGradient =
                      _provider.gradient[index] ?? LinearGradient(colors: [_provider.listColors[index], Colors.black]);
                  final gradient = await LinearGradientPickerDialog.show(context, currentGradient, onResetGradient: () {
                    _provider.updateGradient(null, index);
                  });
                  if (gradient != null) {
                    _provider.updateGradient(gradient, index);
                  }
                },
              ),
              if (_provider.selectedPainter == SelectedPainter.bar)
                ElevatedButton(
                  child: const Text('Set border radius'),
                  onPressed: () async {
                    final radius = await BorderRadiusDialog.show(context, _provider.barBorderRadius[index]);
                    if (radius != null) {
                      _provider.updateBarBorderRadius(radius, index);
                    }
                  },
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Used for Bar or Bubble selection
class _BarOptionButton extends StatelessWidget {
  const _BarOptionButton({
    Key? key,
    this.asset,
    required this.name,
    required this.selected,
    required this.onPressed,
    this.imageAsset,
  }) : super(key: key);

  final String? asset;
  final String? imageAsset;
  final String name;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        height: 50,
        width: 200,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(width: 3, color: selected ? Theme.of(context).primaryColor : Colors.grey)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (imageAsset == null)
              const SizedBox(width: 8),
            if (asset != null)
              SvgPicture.asset(asset!, height: 30, color: selected ? Theme.of(context).primaryColor : Colors.grey),
            if (imageAsset != null)
              ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(
                    imageAsset!,
                    height: 50,
                    width: 45,
                    fit: BoxFit.cover,
                  )),
            if (asset != null || imageAsset != null) const SizedBox(width: 16),
            Expanded(child: Text(name, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
          ],
        ),
      ),
    );
  }
}
