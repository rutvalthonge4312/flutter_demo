import 'package:flutter/material.dart';

class TrainNameField extends StatelessWidget {
  final void Function(String) onSaved;

  const TrainNameField({super.key, required this.onSaved});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      keyboardType: TextInputType.name,
      decoration: InputDecoration(
        labelText: 'Train Name',
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
