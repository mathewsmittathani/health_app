import 'package:flutter/material.dart';

class HealthDataCard extends StatelessWidget {
  final String type, unit;
  final double value;
  const HealthDataCard(
      {super.key, required this.type, required this.unit, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.teal, width: 0.7),
      ),
      margin: EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              type,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
            SizedBox(height: 8),
            Text(
              "${value.toStringAsFixed([
                'STEPS',
                'SLEEP SESSION'
              ].contains(type) ? 0 : 2)} ${unit == 'COUNT' ? 'STEP' : unit}S",
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
