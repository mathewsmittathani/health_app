import 'package:arc_progress_bar_new/arc_progress_bar_new.dart';
import 'package:flutter/material.dart';

class ArcProgressBarWidget extends StatelessWidget {
  final int steps, goal;
  const ArcProgressBarWidget(
      {super.key, required this.steps, required this.goal});

  @override
  Widget build(BuildContext context) {
    return ArcProgressBar(
        percentage: (steps / goal) * 100,
        centerWidget: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 30),
            Text(
              '$steps/$goal',
              style: TextStyle(color: Colors.green, fontSize: 22),
            ),
            Text(
              'Steps Completed',
              style: TextStyle(color: Colors.green),
            ),
          ],
        ),
        arcThickness: 5,
        innerPadding: 16,
        animateFromLastPercent: true,
        handleSize: 10,
        backgroundColor: Colors.grey.withValues(blue: 123, alpha: .4),
        foregroundColor: Colors.green);
  }
}
