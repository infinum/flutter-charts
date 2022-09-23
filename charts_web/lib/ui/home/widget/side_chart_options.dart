import 'dart:math';

import 'package:charts_painter/chart.dart';
import 'package:charts_web/ui/home/provider/chart_state_provider.dart';
import 'package:charts_web/ui/home/widget/chart_item_options_widget.dart';
import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class SideChartOptions extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final _provider = ref.watch(chartStateProvider);

    return Container(
      margin: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Data',
            style: Theme.of(context).textTheme.headline4,
          ),
          const SizedBox(height: 12),
          if (_provider.data.length > 1)
            SwitchListTile(
              value: _provider.state.data.dataStrategy.runtimeType ==
                  DefaultDataStrategy,
              onChanged: (value) {
                _provider.updateDataStrategy(
                    _provider.state.data.dataStrategy.runtimeType ==
                            DefaultDataStrategy
                        ? StackDataStrategy()
                        : const DefaultDataStrategy());
              },
            ),
          const SizedBox(height: 12),
          ..._provider.data.mapIndexed((index, list) {
            final _values = list.fold<StringBuffer>(
                StringBuffer(),
                (sb, e) => sb
                  ..write(
                      '${(e.max ?? e.min)?.toStringAsFixed(0) ?? ''}${list.last == e ? '' : ', '}'));

            return DataTextField(_values.toString(), index);
          }).toList(),
          const SizedBox(height: 24),
          CupertinoButton.filled(
            child: const Text('Add list'),
            onPressed: () {
              final _lists = _provider.data;
              _provider.addList(List.generate(_lists.first.length,
                      (index) => BarValue<void>((Random().nextDouble() * 10)))
                  .toList());
            },
          ),
          SizedBox(height: 24),
          ChartItemOptionsWidget(),
          Expanded(
            child: Container(
              alignment: Alignment.bottomCenter,
              child: CupertinoButton.filled(
                child: const Text('Show code'),
                onPressed: () {
                  final _lists = _provider.data;
                  _provider.addList(List.generate(
                          _lists.first.length,
                          (index) =>
                              BarValue<void>((Random().nextDouble() * 10)))
                      .toList());
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DataTextField extends HookConsumerWidget {
  const DataTextField(this.currentValue, this.listIndex, {Key? key})
      : super(key: key);

  final String currentValue;
  final int listIndex;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final _provider = ref.watch(chartStateProvider);
    final controller = useTextEditingController();

    useEffect(() {
      controller.text = currentValue;
    }, [null]);

    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            onChanged: (value) {
              final _data = _provider.data;

              final _barValues = value
                  .split(',')
                  .map((e) => BarValue(double.tryParse(e.trim()) ?? 0))
                  .toList();
              _data[listIndex] = _barValues;

              _provider.updateData(_data);
            },
          ),
        ),
        IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () {
            final _data = _provider.data;
            _data.removeAt(listIndex);
            _provider.updateData(_data);
          },
        ),
      ],
    );
  }
}
