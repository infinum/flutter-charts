part of charts_painter;

/// Used by default and it won't do anything to the data just pass it along
class DefaultDataStrategy extends DataStrategy {
  const DefaultDataStrategy({required bool stackMultipleValues}) : super(stackMultipleValues: stackMultipleValues);
  const DefaultDataStrategy._lerp(double stackMultipleValuesProgress) : super._lerp(stackMultipleValuesProgress);

  @override
  List<ChartDataSection<T>> formatDataStrategy<T>(List<ChartDataSection<T>> sections) => sections;

  @override
  DataStrategy animateTo(DataStrategy dataStrategy, double t) {
    if (dataStrategy is DefaultDataStrategy) {
      return DefaultDataStrategy._lerp(
          lerpDouble(_stackMultipleValuesProgress, dataStrategy._stackMultipleValuesProgress, t) ??
              dataStrategy._stackMultipleValuesProgress);
    }

    return dataStrategy;
  }
}
