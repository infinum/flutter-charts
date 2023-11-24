import 'package:charts_painter/chart.dart';
import 'package:flutter/material.dart';

const double axisWidth = 80.0;

void main() {
  runApp(MaterialApp(
    home: Scaffold(
      body: LineChart(),
    ),
  ));
}

class LineChart extends StatelessWidget {
  final bool useAxis;

  LineChart({Key? key, this.useAxis = true}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<double> precios = [0.1, -0.1, 0.0, -0.0, 0.0, 0.0, -0.1, -0.0, -0.0, -0.0];
    double altoScreen = MediaQuery.of(context).size.height;

    return Container(
      color: Colors.blue,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      width: double.infinity,
      height: altoScreen / 3,
      child: Chart(
        state: ChartState<void>(
          data: ChartData.fromList(
            precios.map((e) => ChartItem<void>(e)).toList(),
            //axisMin: axisMin,
            axisMin: -0.1,
            axisMax: 0.1,
          ),
          itemOptions: BarItemOptions(
            maxBarWidth: 4,
            barItemBuilder: (data) {
              return BarItem(color: Colors.white.withOpacity(0.4));
            },
          ),
          backgroundDecorations: [
            HorizontalAxisDecoration(
              axisStep: 0.1,
              showLines: true,
              lineWidth: 1,
              legendFontStyle: Theme.of(context).textTheme.bodySmall!.copyWith(fontSize: 10, color: Colors.white54),
              showValues: true,
              legendPosition: HorizontalLegendPosition.start,
            ),
            VerticalAxisDecoration(
              showLines: true,
              lineWidth: 0.1,
              legendFontStyle: Theme.of(context).textTheme.bodySmall!.copyWith(fontSize: 10, color: Colors.white54),
              legendPosition: VerticalLegendPosition.bottom,
              axisStep: 1.0,
              showValues: true,
            ),
            /* TargetLineDecoration(
              target: dataHoy.calcularPrecioMedio(dataHoy.preciosHora),
              targetLineColor: Colors.blue,
              lineWidth: 1,
            ), */
          ],
          foregroundDecorations: [
            SparkLineDecoration(
              lineColor: Colors.white,
              lineWidth: 2,
              smoothPoints: true,
            ),
          ],
        ),
      ),
    );
  }
}

class DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    double dashWidth = 8, dashSpace = 8, startX = 0;
    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 1;
    while (startX < size.width) {
      canvas.drawLine(Offset(startX, 0), Offset(startX + dashWidth, 0), paint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
