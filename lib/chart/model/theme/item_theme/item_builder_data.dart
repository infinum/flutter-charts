part of charts_painter;


typedef ItemBuilder<T> = dynamic Function(ItemBuilderData<T>);


/// Data that can be used when building items to make each item appear different.
class ItemBuilderData<T> {
  ItemBuilderData(this.item, this.itemKey, this.listKey);

  /// ChartItem contains value of an item and min/max heights.
  /// This is useful when you want to have different design/color based on item value or height.
  final ChartItem<T> item;

  /// Item key represents index of an item in the list. This is useful when you want to have different design/colors
  /// for each item.
  ///
  /// E.g. if your chart data is :
  ///
  /// [
  ///   [4, 6, 3, 6, 7, 9].map((e) => ChartValue(e.toDouble())).toList(),
  /// ]
  ///
  /// This will return 0 for first item (4), 1 for second item (6) and so on.
  final int itemKey;

  /// List key represents index of an list in the data. This is useful if you have multiple lists and want to have
  /// different design/colors for them.
  ///
  /// E.g. if your chart data is :
  ///
  /// [
  ///   [4, 6, 3, 6, 7, 9].map((e) => ChartValue(e.toDouble())).toList(),
  ///   [1, 5, 2, 3, 6, 4].map((e) => ChartValue(e.toDouble())).toList(),
  /// ]
  ///
  /// This will return 0 for first list ([4, 6, 3, 6, 7, 9]) and 1 for second list ([1, 5, 2, 3, 6, 4]) and so on.
  final int listKey;
}
