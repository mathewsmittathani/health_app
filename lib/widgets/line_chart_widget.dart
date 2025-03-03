import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:health_app/models/step_model.dart';

class LineChartWidget extends StatefulWidget {
  final int? goal;
  final int maxSteps;
  final List<StepModel> stepModels;
  final List<FlSpot> flspots;
  const LineChartWidget({
    super.key,
    required this.stepModels,
    required this.flspots,
    this.maxSteps = 50000,
    this.goal = 5000,
  });

  @override
  State<LineChartWidget> createState() => _LineChartWidgetState();
}

class _LineChartWidgetState extends State<LineChartWidget> {
  List<Color> gradientColors = [Colors.orangeAccent, Colors.green];

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        AspectRatio(
          aspectRatio: 1.70,
          child: Padding(
            padding:
                const EdgeInsets.only(right: 18, left: 12, top: 24, bottom: 12),
            child: Stack(
              children: [
                LineChart(mainData()),
                if (widget.flspots.isEmpty)
                  Center(
                    child: Text(
                      'No data',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ),
              ],
            ),
          ),
        ),
        widget.goal != null
            ? Positioned(
                right: 0,
                child: Text(
                  'Goal: ${widget.goal} Steps',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              )
            : SizedBox(),
      ],
    );
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(fontSize: 14, color: Colors.grey);
    Widget text;
    switch (value.toInt()) {
      case 0:
        text = const Text('0M', style: style);
        break;
      case 30:
        text = const Text('1M', style: style);
        break;
      case 60:
        text = const Text('2M', style: style);
        break;
      case 90:
        text = const Text('3M', style: style);
        break;

      default:
        text = const Text('', style: style);
        break;
    }

    return SideTitleWidget(meta: meta, child: text);
  }

  LineChartData mainData() {
    return LineChartData(
      clipData: FlClipData(top: false, bottom: true, left: false, right: false),
      extraLinesData: widget.goal != null
          ? ExtraLinesData(
              horizontalLines: [
                HorizontalLine(
                  y: widget.goal!.toDouble(),
                  color: Colors.grey,
                  strokeWidth: 0.6,
                  dashArray: [15, 5],
                  label: HorizontalLineLabel(
                    padding: EdgeInsets.only(right: 10, bottom: 14),
                    alignment: Alignment.centerRight,
                    show: true,
                    style: TextStyle(color: Colors.green, fontSize: 8),
                    labelResolver: (line) =>
                        'Goal - ${widget.goal}', // Label text
                  ),
                ),
              ],
            )
          : null,
      showingTooltipIndicators: widget.flspots.map((spot) {
        return ShowingTooltipIndicators([
          LineBarSpot(
            LineChartBarData(spots: widget.flspots),
            widget.flspots.indexOf(spot),
            spot,
          ),
        ]);
      }).toList(),
      lineTouchData: LineTouchData(
        enabled: false,
        touchTooltipData: LineTouchTooltipData(
          getTooltipColor: (touchedSpot) =>
              widget.flspots.last.x == touchedSpot.x
                  ? Colors.green
                  : Colors.orange,
          tooltipHorizontalOffset: 30,
          // fitInsideHorizontally: true,
          fitInsideVertically: true,
          tooltipRoundedRadius: 20,
          maxContentWidth: 65,
          showOnTopOfTheChartBoxArea: true,
          tooltipMargin: 2,
          tooltipPadding: EdgeInsets.all(5),
          tooltipHorizontalAlignment: FLHorizontalAlignment.left,
          getTooltipItems: (List<LineBarSpot> lineBarsSpot) {
            return lineBarsSpot.map((lineBarSpot) {
              if ((lineBarSpot.y != 0 && lineBarSpot.y == widget.maxSteps) ||
                  lineBarSpot.y == widget.goal ||
                  widget.flspots.last.x == lineBarSpot.x) {
                return LineTooltipItem(
                  "${lineBarSpot.y.toStringAsFixed(0)} steps\n ${widget.flspots.last.x == lineBarSpot.x ? 'You are here' : lineBarSpot.y == 500 ? 'You were here' : ''}",
                  const TextStyle(color: Colors.white, fontSize: 6),
                );
              }
            }).toList();
          },
        ),
      ),
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        horizontalInterval: 1,
        verticalInterval: 1,
        getDrawingHorizontalLine: (value) {
          return const FlLine(
            color: Colors.white12,
            strokeWidth: 1,
          );
        },
        getDrawingVerticalLine: (value) {
          return const FlLine(
            color: Colors.white10,
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: 1,
            getTitlesWidget: bottomTitleWidgets,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: false,
            // interval: 1,
            // getTitlesWidget: leftTitleWidgets,
            // reservedSize: 30,
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: const Border(
          left: BorderSide(color: Colors.black),
          bottom: BorderSide(color: Colors.black),
        ),
      ),
      minX: 0,
      maxX: 120,
      minY: 0,
      lineBarsData: [
        LineChartBarData(
          spots: widget.flspots,
          isCurved: true,
          curveSmoothness: 0.08,
          gradient: LinearGradient(colors: gradientColors),
          barWidth: 2,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
            checkToShowDot: (spot, barData) =>
                (spot.y != 0 && spot.y == widget.maxSteps) ||
                widget.flspots.last.x == spot.x ||
                spot.y == 500,
            getDotPainter: (spot, percent, barData, index) =>
                FlDotCirclePainter(
              radius: 1.09,
              color: Colors.green,
              strokeWidth: 0.7,
              strokeColor: Colors.black,
            ),
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: gradientColors
                  .map((color) => color.withValues(alpha: 0.1))
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }
}
