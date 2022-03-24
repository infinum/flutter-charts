import 'package:charts_painter/chart.dart';
import 'package:charts_web/ui/home/provider/chart_state_provider.dart';
import 'package:charts_web/ui/home/widget/side_chart_options.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeScreen extends ConsumerStatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final _provider = ref.watch(chartStateProvider);

    return Scaffold(
      body: Row(
        children: [
          Expanded(
            child: Chart(
              state: _provider.state,
            ),
          ),
          Container(
            width: 400.0,
            color: Color(0xFF525F70),
            child: SideChartOptions(),
          ),
        ],
      ),
    );
  }
}
