import 'package:flutter/cupertino.dart';

Widget verifiedBadge() {
  return Row(
    mainAxisAlignment: MainAxisAlignment.end,
    children: [
      Image.asset(
        'assets/verified.png', // Your image asset path
        width: 14.0, // Adjust image width as needed
        height: 14.0, // Adjust image height as needed
      ),
      const SizedBox(width: 5.0), // Add spacing between image and text
      const Text(
        'Verified', // Your text content
        style: TextStyle(fontSize: 14.0), // Adjust text style as needed
      ),
    ],
  );
}
