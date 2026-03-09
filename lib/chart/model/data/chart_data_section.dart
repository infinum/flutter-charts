part of charts_painter;

class ChartDataSection<T> {
  ChartDataSection({
    required this.items,
    int offset = 0,
  }) : _offset = offset.toDouble();

  ChartDataSection._lerp({
    required this.items,
    required double offset,
  }) : _offset = offset;

  final List<ChartItem<T>> items;
  final double _offset;

  int get offset => _offset.round();

  int get length => offset.round() + items.length;

  ChartItem<T>? operator [](int index) {
    if (index < offset || index >= length) {
      return null;
    }

    return items[index - offset];
  }

  static ChartDataSection<T> lerp<T>(ChartDataSection<T> a, ChartDataSection<T> b, double t) {
    return ChartDataSection<T>._lerp(
      items: _lerpItemList(a.items, b.items, t),
      offset: lerpDouble(a._offset, b._offset, t) ?? b._offset,
    );
  }

  static List<ChartItem<T>> _lerpItemList<T>(List<ChartItem<T>> a, List<ChartItem<T>> b, double t) {
    final _listLength = lerpDouble(a.length, b.length, t) ?? b.length;

    /// Empty value for generated list.
    final _emptyValue = ChartItem<T>(0.0, value: null, min: 0.0);

    return List<ChartItem<T>>.generate(_listLength.ceil(), (int index) {
      // If old list and new list have value at [index], then just animate from,
      // old list value to the new value
      final _firstItem = index < a.length ? a[index] : null;
      final _secondItem = index < b.length ? b[index] : null;

      if (index < a.length && index < b.length) {
        if (_secondItem != null && _firstItem != null) {
          return _secondItem.animateFrom(_firstItem, t);
        } else if (_secondItem != null) {
          // Newly inserted point with no corresponding previous value, start
          // from previous point value if possible.
          final _prevIndex = index > 0 ? index - 1 : 0;
          ChartItem<T> _start = _emptyValue;
          if (_prevIndex < b.length) {
            _start = b[_prevIndex];
          } else if (_prevIndex < a.length) {
            _start = a[_prevIndex];
          }
          return _secondItem.animateFrom(_start, t);
        } else if (_firstItem != null) {
          // Point was removed and there is no new value, animate towards
          // previous point value instead of zero.
          final _prevIndex = index > 0 ? index - 1 : 0;
          ChartItem<T> _end = _emptyValue;
          if (_prevIndex < b.length) {
            _end = b[_prevIndex];
          } else if (_prevIndex < a.length) {
            _end = a[_prevIndex];
          }
          return _firstItem.animateTo(_end, t);
        }

        return _emptyValue;
      }

      // If new list is larger, then check if item in the list is not empty
      // In case item is not empty then animate to it from our [_emptyValue]
      if (index < b.length) {
        // Purely new points (b has value, a does not). Start from previous
        // point value if it exists, otherwise from zero.
        if (_secondItem != null) {
          final _prevIndex = index > 0 ? index - 1 : 0;
          ChartItem<T> _start = _emptyValue;
          if (_prevIndex < b.length) {
            _start = b[_prevIndex];
          } else if (_prevIndex < a.length) {
            _start = a[_prevIndex];
          }
          return _secondItem.animateFrom(_start, t);
        }
        return _emptyValue;
      }

      // Points that exist only in the old list (a has value, b does not).
      // Animate them towards previous point value instead of dropping to zero.
      if (_firstItem != null) {
        final _prevIndex = index > 0 ? index - 1 : 0;
        ChartItem<T> _end = _emptyValue;
        if (_prevIndex < b.length) {
          _end = b[_prevIndex];
        } else if (_prevIndex < a.length) {
          _end = a[_prevIndex];
        }
        return _firstItem.animateTo(_end, t);
      }

      return _emptyValue;
    });
  }
}
