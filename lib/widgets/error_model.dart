import 'package:flutter/material.dart';

class ErrorModal extends StatelessWidget {
  final String message;
  final VoidCallback onClose;

  const ErrorModal({
    Key? key,
    required this.message,
    required this.onClose,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Container(
          constraints:const BoxConstraints(maxHeight: 200, maxWidth: 400),
          padding:const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
             const Text(
                'Alert',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18.0,
                  color:Color.fromARGB(255, 61, 16, 120),
                ),
              ),
              const SizedBox(height: 8.0),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    child: Text(
                      message,
                      style:const TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 16,
                        color: Colors.black,
                        wordSpacing: 1,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: onClose,
                  style: buttonStyle(),
                  child:const Text(
                    'Close',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  ButtonStyle buttonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor:const Color.fromARGB(255, 61, 16, 120),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}
