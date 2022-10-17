part of charts_painter;

typedef ChildChartItemBuilder<T> = Widget Function(
    ChartItem<T?> item, int itemKey, int listKey);

/// Child item renderer for chart items. It will render any [Widget] passed as child.
/// It will constrain it to exact size. Make sure you are not using transparent widgets that could
/// taint the data shown!
///
/// This is a [ChildRenderObjectWidget], single child can be passed to it.
class ChildChartItemRenderer<T> extends SingleChildRenderObjectWidget {
  ChildChartItemRenderer(this.item, this.state, this.itemOptions,
      {Key? key, Widget? child, this.arrayKey = 0})
      : super(key: key, child: child);

  final ChartItem<T> item;
  final ChartData<T> state;
  final ItemOptions itemOptions;
  final int arrayKey;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderChildChartItem(state, itemOptions, item, key: arrayKey);
  }

  @override
  void updateRenderObject(
      BuildContext context, _RenderChildChartItem<T?> renderObject) {
    renderObject
      ..state = state
      ..itemOptions = itemOptions
      ..key = arrayKey
      ..item = item;

    renderObject.markNeedsLayout();
  }
}

class _RenderChildChartItem<T> extends RenderShiftedBox {
  _RenderChildChartItem(this._state, this._itemOptions, this._item,
      {int? key, RenderBox? child})
      : _key = key ?? 0,
        super(child);

  int _key;

  int get key => _key;
  set key(int key) {
    if (key != _key) {
      _key = key;
      markNeedsPaint();
    }
  }

  ChartItem<T> _item;
  set item(ChartItem<T> item) {
    if (item != _item) {
      _item = item;
      markNeedsPaint();
    }
  }

  ChartItem<T> get item => _item;

  ChartData<T> _state;
  set state(ChartData<T> state) {
    if (state != _state) {
      _state = state;
      markNeedsPaint();
    }
  }

  ItemOptions _itemOptions;
  set itemOptions(ItemOptions itemOptions) {
    if (itemOptions != _itemOptions) {
      _itemOptions = itemOptions;
      markNeedsPaint();
    }
  }

  double get _defaultSize => _itemOptions.minBarWidth ?? 0;

  @override
  double computeMinIntrinsicWidth(double height) => _defaultSize;

  @override
  double computeMaxIntrinsicWidth(double height) => _defaultSize;

  @override
  double computeMinIntrinsicHeight(double width) => _defaultSize;

  @override
  double computeMaxIntrinsicHeight(double width) => _defaultSize;

  @override
  bool get sizedByParent => false;

  Size _computeSize(
      {required BoxConstraints constraints,
      required ChildLayouter layoutChild}) {
    if (child != null) {
      final childSize = layoutChild(child!, constraints);
      return constraints.constrain(childSize);
    }
    return Size.zero;
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    if (child != null) {
      return _computeSize(
        constraints: constraints,
        layoutChild: ChildLayoutHelper.dryLayoutChild,
      );
    }

    return constraints.biggest;
  }

  @override
  void performLayout() {
    size = _computeSize(
      constraints: constraints,
      layoutChild: ChildLayoutHelper.layoutChild,
    );

    // If child exists set it's offset based on [multiValueStacked] setting.
    if (child != null) {
      final childParentData = child!.parentData! as BoxParentData;

      final _stack = 1 - _itemOptions._multiValueStacked;

      final offset = Offset(size.width * key * _stack, 0.0);
      childParentData.offset = offset;
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (child != null) {
      final childParentData = child!.parentData! as BoxParentData;
      context.paintChild(child!, childParentData.offset + offset);
    }
  }
}
