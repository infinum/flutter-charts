part of charts_painter;

class StackDataStrategy extends DataStrategy {
  @override
  List<List<ChartItem<T?>>> formatDataStrategy<T>(List<List<ChartItem<T?>>> items) {
    final _incrementList = <ChartItem<T?>>[];
    return items.reversed
        .map((entry) {
          return entry.asMap().entries.map((e) {
            if (_incrementList.length > e.key) {
              final _newValue = e.value + _incrementList[e.key];
              _incrementList[e.key] = (_incrementList[e.key] + e.value);
              return _newValue;
            } else {
              _incrementList.add(e.value);
            }

            return e.value;
          }).toList();
        })
        .toList()
        .reversed
        .toList();
  }
}
