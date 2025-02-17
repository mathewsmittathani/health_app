import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FilterButton extends StatelessWidget {
  final String buttonName;
  final Function() onTap;
  final bool isSelected;
  const FilterButton(
      {super.key,
      required this.buttonName,
      required this.onTap,
      this.isSelected = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
              color: isSelected ? Colors.tealAccent : Colors.transparent,
              width: 2),
          color: isSelected ? Colors.blueAccent : Colors.blueGrey,
        ),
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
          style: TextStyle(
            fontSize: 11,
            color: isSelected ? Colors.white : Colors.black,
          ),
          child: Text(buttonName),
        ),
      ),
    );
  }
}
