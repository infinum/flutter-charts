part of charts_painter;

/// Child item renderer for chart items. It will render any [Widget] passed as child.
/// It will constrain it to exact size. Make sure you are not using transparent widgets that could
/// taint the data shown!
///
/// This is a [ChildRenderObjectWidget], single child can be passed to it.
class ChildChartItemRenderer<T> extends SingleChildRenderObjectWidget {
  ChildChartItemRenderer(this.item, this.state, this.itemOptions,
      {Key? key, Widget? child, this.itemKey = 0, this.listKey = 0})
      : super(key: key, child: child);

  final ChartItem<T> item;
  final ChartState<T> state;
  final ItemOptions itemOptions;
  final int listKey;
  final int itemKey;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderChildChartItem(state, itemOptions, item, listKey: listKey, itemKey: itemKey);
  }

  @override
  void updateRenderObject(BuildContext context, _RenderChildChartItem<T?> renderObject) {
    renderObject
      ..state = state
      ..itemOptions = itemOptions
      ..listKey = listKey
      ..itemKey = itemKey
      ..item = item;

    renderObject.markNeedsLayout();
  }
}

class _RenderChildChartItem<T> extends RenderShiftedBox {
  _RenderChildChartItem(this._state, this._itemOptions, this._item, {int? listKey, int? itemKey, RenderBox? child})
      : _listKey = listKey ?? 0,
        _itemKey = itemKey ?? 0,
        super(child);

  int _listKey;

  int get listKey => _listKey;

  set listKey(int key) {
    if (key != _listKey) {
      _listKey = key;
      markNeedsPaint();
    }
  }

  int _itemKey;

  int get itemKey => _itemKey;

  set itemKey(int key) {
    if (key != _itemKey) {
      _itemKey = key;
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

  ChartState<T> _state;

  set state(ChartState<T> state) {
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

  Size _computeSize({required BoxConstraints constraints, required ChildLayouter layoutChild}) {
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
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    final _onClick = _state.behaviour.onItemClicked;

    // Hit test will be added to [result] in [child.hitTest] if it is not null.
    final _hitTest = child?.hitTest(result, position: position) ?? false;

    if (_hitTest) {
      // If we also have click handler in [ChartBehaviour] call it.
      _onClick?.call(ItemBuilderData<T>(_item, itemKey, listKey));
    }

    return _hitTest;
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

      final _stack = 1 - _state.data.dataStrategy._stackMultipleValuesProgress;

      final offset = Offset(size.width * listKey * _stack, 0.0);
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
