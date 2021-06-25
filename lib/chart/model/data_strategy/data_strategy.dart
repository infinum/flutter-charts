part of charts_painter;

abstract class DataStrategy {
  const DataStrategy();

  List<List<ChartItem<T?>>> formatDataStrategy<T>(List<List<ChartItem<T?>>> items);
}
