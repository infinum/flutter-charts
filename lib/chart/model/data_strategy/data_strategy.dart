part of charts_painter;

/// Data strategy will process the data one final time before being passed to painters
///
/// Data strategy is part of [ChartData] and it can be changed there.
abstract class DataStrategy {
  const DataStrategy({required this.stackMultipleValues})
      : _stackMultipleValuesProgress = stackMultipleValues ? 1.0 : 0.0;
  const DataStrategy._lerp(this._stackMultipleValuesProgress)
      : stackMultipleValues = _stackMultipleValuesProgress > 0.5;

  final double _stackMultipleValuesProgress;

  /// Return true if multi item drawing is set to stack
  final bool stackMultipleValues;

  List<List<ChartItem<T?>>> formatDataStrategy<T>(
    List<List<ChartItem<T?>>> items,
  );

  DataStrategy animateTo(DataStrategy dataStrategy, double t);
}
