import 'package:flutter/material.dart';

class StationNameField extends StatelessWidget {
  final void Function(String) onSaved;

  const StationNameField({super.key, required this.onSaved});

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: 'Station Name',
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
      items: ['PNBE', 'PPTA'].map((String station) {
        return DropdownMenuItem<String>(
          value: station,
          child: Text(station),
        );
      }).toList(),
      onChanged: (String ? value){
        onSaved(value!);
      },
    );
  }
}
