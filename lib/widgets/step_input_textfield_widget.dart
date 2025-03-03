import 'package:flutter/material.dart';

class StepInputTextfieldWidget extends StatelessWidget {
  final TextEditingController controller;
  const StepInputTextfieldWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      cursorOpacityAnimates: true,
      onTapOutside: (event) => FocusScope.of(context).unfocus(),
      decoration: InputDecoration(
        floatingLabelBehavior: FloatingLabelBehavior.always,
        label: Text('TODAY\'S GOAL'),
        hintText: '____',
        hintStyle: TextStyle(fontSize: 19, color: Colors.grey),
        suffix: Text(
          'Steps',
          style: TextStyle(fontSize: 16),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.greenAccent, width: 2),
        ),
        labelStyle: TextStyle(fontSize: 16, color: Colors.grey),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.greenAccent),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.greenAccent),
        ),
      ),
    );
  }
}
