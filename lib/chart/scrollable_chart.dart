part of flutter_charts;

class ScrollableChart extends StatefulWidget {
  ScrollableChart({this.child, this.controller, Key key}) : super(key: key);

  final Widget child;
  final ScrollController controller;

  @override
  _ScrollableChartState createState() => _ScrollableChartState();
}

class _ScrollableChartState extends State<ScrollableChart> {
  ScrollController _scrollController;

  @override
  void initState() {
    super.initState();

    _scrollController = widget.controller;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      controller: _scrollController,
      child: widget.child,
    );
  }
}