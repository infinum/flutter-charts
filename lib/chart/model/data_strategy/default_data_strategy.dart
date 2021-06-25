part of charts_painter;

class DefaultDataStrategy extends DataStrategy {
  const DefaultDataStrategy() : super();

  @override
  List<List<ChartItem<T?>>> formatDataStrategy<T>(List<List<ChartItem<T?>>> items) {
    return items;
  }
}
