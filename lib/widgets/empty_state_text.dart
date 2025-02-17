import 'package:flutter/material.dart';

class EmptyStateText extends StatelessWidget {
  const EmptyStateText({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      'No health data available',
      style: TextStyle(
        color: Colors.grey,
        fontSize: 16,
      ),
    );
  }
}
