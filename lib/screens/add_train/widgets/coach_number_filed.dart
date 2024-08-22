import 'package:flutter/material.dart';

class CoachNumberFiled extends StatelessWidget {
  final void Function(String) onSaved;

  const CoachNumberFiled({super.key, required this.onSaved});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: 'Total Number of Coaches',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide:const BorderSide(
            color: Colors.grey,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide:const BorderSide(
            color: Colors.grey,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide:const BorderSide(
            color: Colors.blue,
            width: 2.0, 
          ),
        ),
      ),
      onChanged: (String ? value){
        onSaved(value!);
      },
    );
  }
}
