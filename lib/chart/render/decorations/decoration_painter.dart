part of charts_painter;

/// Abstract class for decorations
/// Decorations are placed under and/or above items in the charts
abstract class DecorationPainter<T> {
  /// Draw decoration.
  /// Decoration can be foreground or background decoration that will be drawn on the chart
  /// decorations can ignore padding and can use whole available canvas to draw.
  void draw(Canvas canvas, Size size, ChartState<T> state);

  /// Controls whether this decoration is clipped to its render box bounds.
  ///
  /// Set to `false` to allow drawing outside of the chart frame.
  bool get clipToBounds => true;

  bool get animatable => true;

  /// Get extra margin (not definable by the user). This makes sure that any decoration
  /// that leaves original drawing window is not drawing outside of that window (This is not
  /// enforced right now but it's unwanted behaviour)
  ///
  /// Any decoration that needs space on side of the chart (any side) has to override this
  /// method and return how much space it needs and where as [EdgeInsets].
  EdgeInsets marginNeeded() {
    return EdgeInsets.zero;
  }

  /// Get extra padding (not definable by user, calculated by decoration if needed). This makes sure
  /// that decoration will fit with the chart in wanted area.
  ///
  /// Any decoration that needs padding can override this method and return [EdgeInsets] how much space it needs.
  EdgeInsets paddingNeeded() {
    return EdgeInsets.zero;
  }

  Size layoutSize(BoxConstraints constraints, ChartState<T> state) {
    return constraints.biggest;
  }

  Offset applyPaintTransform(ChartState<T> state, Size size) {
    return Offset.zero;
  }

  /// Init decoration is first thing called on decorations, it will pass current [ChartState]
  /// so decoration can easily calculate needed stuff for their layout.
  void initDecoration(ChartState<T> state) {
    return;
  }

  Widget getRenderer(ChartState<T> state) {
    return ChartDecorationRenderer(state, this, key: ValueKey(hashCode));
  }

  /// Animate to next decoration state, each decoration should implement this.
  /// This is just regular lerp function, but instead of static function where you pass start and
  /// end state, here we start with current state and animate to [endValue].
  DecorationPainter<T> animateTo(DecorationPainter<T> endValue, double t);

  /// Used for animating, we just need to find matching type, don't actually check for equality since we want to animate
  /// from one state to other. Some decorations may consider overriding this in case multiples are used
  bool isSameType(DecorationPainter<T> other) {
    return runtimeType == other.runtimeType;
  }
}
