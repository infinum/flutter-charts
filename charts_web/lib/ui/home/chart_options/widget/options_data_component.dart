import 'dart:math';

import 'package:charts_painter/chart.dart';
import 'package:charts_web/ui/common/dialog/color_picker_dialog.dart';
import 'package:charts_web/ui/home/chart_options/widget/options_component_header.dart';
import 'package:charts_web/ui/home/presenter/chart_state_provider.dart';
import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

const _subtitle = '''Here you can input the data that defines your chart. Each data point is called an item.
''';

class OptionsDataComponent extends HookConsumerWidget {
  const OptionsDataComponent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final _provider = ref.watch(chartStatePresenter);

    return Column(
      children: [
        const OptionsComponentHeader(title: 'Data', subtitle: _subtitle),
        if (_provider.isMultiItem)
          SwitchListTile(
            value: _provider.state.data.dataStrategy.runtimeType == DefaultDataStrategy,
            title: _provider.state.data.dataStrategy.runtimeType == DefaultDataStrategy
                ? const Text('Default (one next to another)')
                : const Text('Stack (one on top of another)'),
            subtitle: const Text('Data Strategy - how to show multiple data values'),
            onChanged: (value) {
              _provider.updateDataStrategy(_provider.state.data.dataStrategy.runtimeType == DefaultDataStrategy
                  ? StackDataStrategy()
                  : const DefaultDataStrategy());
            },
          ),
        const SizedBox(height: 12),
        ..._provider.data.mapIndexed((index, list) {
          return _DataTextField(index, key: Key('data$index'),);
        }).toList(),
        const SizedBox(height: 24),
        CupertinoButton(
          child: const Text('Add another list'),
          onPressed: () {
            final _lists = _provider.data;
            _provider.addDataList(
                List.generate(_lists.first.length, (index) => BarValue<void>((Random().nextDouble() * 10))).toList());
          },
        ),
        const SizedBox(height: 24),
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
            final color = await ColorPickerDialog.show(context, _provider.listColors[listIndex]);
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
