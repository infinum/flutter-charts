part of charts_painter;

/// Used by default and it won't do anything to the data just pass it along
class DefaultDataStrategy extends DataStrategy {
  const DefaultDataStrategy() : super();

  @override
  List<List<ChartItem<T?>>> formatDataStrategy<T>(List<List<ChartItem<T?>>> items) => items;
}
