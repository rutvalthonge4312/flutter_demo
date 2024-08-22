import 'package:flutter/material.dart';

class MobileFiled extends StatelessWidget {
  final void Function(String) onSaved;
  const MobileFiled({super.key, required this.onSaved});
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      keyboardType: TextInputType.phone,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your mobile number';
        }
        return null;
      },
      onChanged: (String? value) {
        onSaved(value!);
      },
      decoration: InputDecoration(
        labelText: 'Mobile Number',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: Colors.grey, // Specify the border color
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: Colors.grey, // Specify the border color when enabled
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: Colors.blue, // Specify the border color when focused
            width: 2.0, // Optional: change the border width when focused
          ),
        ),
      ),
    );
  }
}
