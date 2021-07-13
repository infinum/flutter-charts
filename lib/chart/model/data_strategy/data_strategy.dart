part of charts_painter;

/// Data strategy will process the data one final time before being passed to painters
///
/// Data strategy is part of [ChartData] and it can be changed there.
abstract class DataStrategy {
  const DataStrategy();

  List<List<ChartItem<T?>>> formatDataStrategy<T>(
      List<List<ChartItem<T?>>> items);
}
