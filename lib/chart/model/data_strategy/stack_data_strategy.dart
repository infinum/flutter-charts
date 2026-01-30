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
  List<ChartDataSection<T>> formatDataStrategy<T>(List<ChartDataSection<T>> sections) {
    final length = sections.fold<int>(0, (previousValue, element) => max(previousValue, element.length));
    final _incrementList = List<ChartItem<T?>>.generate(length, (index) => ChartItem<T?>(0.0));

    return sections.reversed
        .mapIndexed((sectionIndex, section) {
          final items = section.items.mapIndexed((itemIndex, item) {
            final index = itemIndex + section.offset;
            final _newValue = item + _incrementList[index];
            _incrementList[index] = (_incrementList[index] + item);

            return _newValue;
          }).toList();

          return ChartDataSection<T>(items: items, offset: section.offset);
        })
        .toList()
        .reversed
        .toList();
  }

  @override
  DataStrategy animateTo(DataStrategy dataStrategy, double t) {
    return dataStrategy;
  }
}
