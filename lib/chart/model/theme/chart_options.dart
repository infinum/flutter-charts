part of flutter_charts;

/// Options that have effect on whole chart.
/// [padding] - Chart padding, this will affect all chart items, decorations will still be able to
/// draw outside of this padding.
class ChartOptions {
  const ChartOptions({
    this.padding,
  });

  final EdgeInsets padding;

  static ChartOptions lerp(ChartOptions a, ChartOptions b, double t) {
    return ChartOptions(
      padding: EdgeInsets.lerp(a?.padding, b?.padding, t),
    );
  }
}
