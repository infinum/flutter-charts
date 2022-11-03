part of charts_painter;

/// Stacks multiple lists one on top of another.
///
/// ex.
/// List with:
/// [
///   [1, 3, 2],
///   [3, 2, 1]
/// ]
///
/// will become:
/// [
///   [1, 3, 2],
///   [4, 5, 3]
/// ]
class StackDataStrategy extends DataStrategy {
  const StackDataStrategy() : super(stackMultipleValues: true);

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
