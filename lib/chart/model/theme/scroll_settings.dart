part of charts_painter;

class ScrollSettings {
  const ScrollSettings({
    this.visibleItems,
  })  : assert(visibleItems == null || visibleItems > 0,
            'visibleItems must be greater than 0'),
        _isScrollable = 1.0;

  const ScrollSettings.none()
      : _isScrollable = 0.0,
        visibleItems = null;

  ScrollSettings._lerp(this._isScrollable, this.visibleItems);

  final double _isScrollable;

  /// Number of visible items on the screen.
  final double? visibleItems;

  static ScrollSettings lerp(ScrollSettings a, ScrollSettings b, double t) {
    // This values should never return null, this is for null-safety
    // But if it somehow does occur, then revert to default values
    final scrollableLerp =
        lerpDouble(a._isScrollable, b._isScrollable, t) ?? 0.0;
    final visibleLerp = lerpDouble(a.visibleItems, b.visibleItems, t);

    return ScrollSettings._lerp(scrollableLerp, visibleLerp);
  }
}
