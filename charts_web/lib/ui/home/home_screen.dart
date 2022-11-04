import 'package:charts_painter/chart.dart';
import 'package:charts_web/ui/common/respo/respo.dart';
import 'package:charts_web/ui/home/chart_options/chart_options.dart';
import 'package:charts_web/ui/home/presenter/chart_state_presenter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeScreen extends ConsumerStatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final _provider = ref.watch(chartStatePresenter);

    return Scaffold(
      backgroundColor: const Color(0xffefefef),
      body: Respo.of(context).size.maybeMap(small: (_) {
        return ListView(
          shrinkWrap: true,
          children: [
            ChartOptions(),
            const SizedBox(height: 500, child: _Chart()),
          ],
        );
      }, orElse: () {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
                width: 600.0,
                child: SingleChildScrollView(child: ChartOptions())),
            const Expanded(child: _Chart()),
          ],
        );
      }),
    );
  }
}

class _Chart extends ConsumerWidget {
  const _Chart({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final _provider = ref.watch(chartStatePresenter);

    return Container(
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.all(20),
      child: AnimatedChart<void>(
        duration: Duration(milliseconds: 450),
        state: _provider.state,
      ),
    );
  }
}
