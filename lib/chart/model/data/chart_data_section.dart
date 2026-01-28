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

  final List<ChartItem<T?>> items;
  final double _offset;

  int get offset => _offset.round();

  int get length => offset.round() + items.length;

  ChartItem<T?>? operator [](int index) {
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

  static List<ChartItem<T?>> _lerpItemList<T>(List<ChartItem<T?>?> a, List<ChartItem<T?>?> b, double t) {
    final _listLength = lerpDouble(a.length, b.length, t) ?? b.length;

    /// Empty value for generated list.
    final _emptyValue = ChartItem<T?>(0.0, value: null, min: 0.0);

    return List<ChartItem<T?>>.generate(_listLength.ceil(), (int index) {
      // If old list and new list have value at [index], then just animate from,
      // old list value to the new value
      final _firstItem = index < a.length ? a[index] : null;
      final _secondItem = index < b.length ? b[index] : null;

      if (index < a.length && index < b.length) {
        if (_secondItem != null && _firstItem != null) {
          return _secondItem.animateFrom(_firstItem, t);
        } else if (_secondItem != null) {
          return _secondItem.animateFrom(_emptyValue, t);
        } else if (_firstItem != null) {
          return _firstItem.animateTo(_emptyValue, t);
        }

        return _emptyValue;
      }

      // If new list is larger, then check if item in the list is not empty
      // In case item is not empty then animate to it from our [_emptyValue]
      if (index < b.length) {
        if (_secondItem == null || _secondItem.isEmpty) {
          return _secondItem ?? _emptyValue;
        }

        // If item is appearing then it's time to animate is
        // from time it first showed to end of the animation.
        final _value = _listLength.floor() == index ? ((_listLength - _listLength.floor()) * t) : t;
        return _secondItem.animateFrom(_emptyValue, _value);
      }

      // In case that our old list is bigger, and item is not empty
      // then we need to animate to empty value from current item value
      if (_firstItem == null || _firstItem.isEmpty) {
        return _firstItem ?? _emptyValue;
      }

      final _value = _listLength.floor() == index
          ? min(1, (1 - (_listLength - _listLength.floor())) + t / _listLength)
          : _listLength.floor() >= index
              ? 0
              : t;
      return _firstItem.animateTo(_emptyValue, _value.toDouble());
    });
  }
}
