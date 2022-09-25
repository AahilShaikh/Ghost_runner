import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../constants/palette.dart';

class SpeedLineChart extends StatefulWidget {
  const SpeedLineChart(this.data, {Key? key}) : super(key: key);
  final List<FlSpot> data;

  @override
  State<StatefulWidget> createState() => SpeedLineChartState();
}

class SpeedLineChartState extends State<SpeedLineChart> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.23,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          decoration:  BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(18)),
            gradient: const LinearGradient(
              colors: [
                Color.fromARGB(255, 228, 249, 236),
                Color.fromARGB(255,173, 235, 198),
              ],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
            boxShadow: [
              BoxShadow(offset: const Offset(0, 1), blurRadius: 5, spreadRadius: 5, color: Colors.grey[300]!)
            ]
          ),
          child: Stack(
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  const Spacer(flex: 2,),
                  const Text(
                    'Running Data',
                    style: TextStyle(
                      color: Color.fromARGB(255, 114, 158, 123),
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const Spacer(),
                  const Text(
                    'Average Speed',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const Spacer(),
                  Expanded(
                    flex: 50,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 16.0, left: 6.0),
                      child: LineChart(
                        LineChartData(
                          lineTouchData: LineTouchData(
                            handleBuiltInTouches: true,
                            touchTooltipData: LineTouchTooltipData(
                              tooltipBgColor: Colors.blueGrey.withOpacity(0.8),
                            ),
                          ),
                          gridData: gridData,
                          titlesData: FlTitlesData(
                            bottomTitles: AxisTitles(
                              sideTitles: bottomTitles,
                            ),
                            rightTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            topTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                          ),
                          borderData: borderData,
                          lineBarsData: [
                            lineChartBarData1_1,
                          ],
                          minX: 0,
                          minY: 0,
                        ),
                        swapAnimationDuration: const Duration(milliseconds: 250),
                      ),
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Color.fromARGB(255, 114, 158, 123),
      fontWeight: FontWeight.bold,
      fontSize: 16,
    );
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 10,
      child: Text(value.toInt().toString(), style: style),
    );
  }

  SideTitles get bottomTitles => SideTitles(
        showTitles: true,
        reservedSize: 32,
        interval: 3,
        getTitlesWidget: bottomTitleWidgets,
      );

  FlGridData get gridData => FlGridData(show: false);

  FlBorderData get borderData => FlBorderData(
        show: true,
        border: const Border(
          bottom: BorderSide(color: Color.fromARGB(255, 73, 101, 82), width: 4),
          left: BorderSide(color: Colors.transparent),
          right: BorderSide(color: Colors.transparent),
          top: BorderSide(color: Colors.transparent),
        ),
      );

  LineChartBarData get lineChartBarData1_1 => LineChartBarData(
        isCurved: true,
        color: lightGreen,
        barWidth: 8,
        isStrokeCapRound: true,
        dotData: FlDotData(show: true),
        belowBarData: BarAreaData(show: false),
        spots: widget.data,
      );
}
