import 'dart:math';

import 'package:charts_painter/chart.dart';
import 'package:charts_web/assets.gen.dart';
import 'package:charts_web/ui/common/dialog/color_picker_dialog.dart';
import 'package:charts_web/ui/common/widget/switch_with_image.dart';
import 'package:charts_web/ui/home/chart_options/widget/options_component_header.dart';
import 'package:charts_web/ui/home/presenter/chart_state_presenter.dart';
import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

const _subtitle = '''Here you can input the data that defines your chart. Each data point is called an item.
''';

class OptionsDataComponent extends HookConsumerWidget {
  const OptionsDataComponent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final _presenter = ref.watch(chartStatePresenter);

    return Column(
      children: [
        const OptionsComponentHeader(title: 'Data', subtitle: _subtitle),
        if (_presenter.isMultiItem)
          SwitchWithImage(
            value: _presenter.state.data.dataStrategy.runtimeType == DefaultDataStrategy,
            onChanged: (value) {
              _presenter.updateDataStrategy(_presenter.state.data.dataStrategy.runtimeType == DefaultDataStrategy
                  ? StackDataStrategy()
                  : const DefaultDataStrategy(stackMultipleValues: true));
            },
            title1: 'Default (one next to another)',
            title2: 'Stack (one on top of another)',
            image1: Assets.svg.strategyDefault,
            image2: Assets.svg.strategyStack,
            subtitle: 'Data Strategy - how to show multiple data values',
          ),
        if (_presenter.isMultiItem && _presenter.state.data.dataStrategy.runtimeType == DefaultDataStrategy)
          Row(
            children: [
              Text('Stack Multiple Values'),
              Switch(value: _presenter.stackMultipleValues, onChanged: _presenter.updateStackMultipleValues),
            ],
          ),
        const SizedBox(height: 12),
        ..._presenter.data.mapIndexed((index, list) {
          return _DataTextField(
            index,
            key: Key('data$index'),
          );
        }).toList(),
        const SizedBox(height: 8),
        if (!_presenter.showMaxDataListMessage)
          CupertinoButton(
            child: const Text('Add another list'),
            onPressed: () {
              final _lists = _presenter.data;
              _presenter.addDataList(
                  List.generate(_lists.first.length, (index) => BarValue<void>((Random().nextDouble() * 10))).toList());
            },
          ),
        if (_presenter.showMaxDataListMessage)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10.0),
            child: Text("You can have more lists, but for demo let's stop at 5.", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
      ],
    );
  }
}

class _DataTextField extends HookConsumerWidget {
  _DataTextField(this.listIndex, {Key? key}) : super(key: key);

  final int listIndex;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final _provider = ref.watch(chartStatePresenter);
    final controller = useTextEditingController(text: getValuesText(_provider));

    return Row(
      children: [
        Container(width: 10, height: 40, color: _provider.listColors[listIndex]),
        const SizedBox(width: 16),
        Expanded(
          child: TextField(
            controller: controller,
            onChanged: (value) {
              final _data = _provider.data;

              final _barValues = value.split(',').map((e) => BarValue(double.tryParse(e.trim()) ?? 0)).toList();
              _data[listIndex] = _barValues;

              _provider.updateData(_data);
            },
          ),
        ),
        IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () {
            _provider.removeDataList(listIndex);
          },
        ),
        IconButton(
          icon: Icon(Icons.format_paint, color: _provider.listColors[listIndex]),
          onPressed: () async {
            final color = await ColorPickerDialog.show(
              context,
              _provider.listColors[listIndex],
              additionalText:
                  'In code, with colorForValue you can also define different color for each value of the list.',
            );
            if (color != null) {
              _provider.updateListColor(color, listIndex);
            }
          },
        ),
      ],
    );
  }

  String getValuesText(ChartStatePresenter presenter) {
    return presenter.data[listIndex]
        .fold<StringBuffer>(
            StringBuffer(),
            (sb, e) => sb
              ..write(
                  '${(e.max ?? e.min)?.toStringAsFixed(0) ?? ''}${presenter.data[listIndex].last == e ? '' : ', '}'))
        .toString();
  }
}
