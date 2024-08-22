import 'package:flutter/material.dart';

class WaterLevelWidget extends StatefulWidget {
  final Function(String) onLevelChanged;
  final bool isImagePresent;

  const WaterLevelWidget({
    Key? key,
    required this.onLevelChanged,
    this.isImagePresent = true,
  }) : super(key: key);

  @override
  _WaterLevelWidgetState createState() => _WaterLevelWidgetState();
}

class _WaterLevelWidgetState extends State<WaterLevelWidget> {
  String selectedLevel = '';

  @override
  Widget build(BuildContext context) {
    return Row();
  }

  Widget _buildWaterLevelOption(String level, IconData icon, [int tickMarks = 0]) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedLevel = level;
          widget.onLevelChanged(level);
        });
      },
      child: Column(
        children: [
          if (tickMarks == 0)
            Icon(
              icon,
              color: selectedLevel == level ? Colors.red : Colors.white,
              size: 50,
            ),
          if (tickMarks == 1)
            Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  Icons.check,
                  color: selectedLevel == level ? Colors.orange : Colors.white,
                  size: 50,
                ),
              ],
            ),
          if (tickMarks == 2)
            Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  Icons.check,
                  color: selectedLevel == level ? Colors.green : Colors.white,
                  size: 50,
                ),
                Positioned(
                  top: 5,
                  right: 10,
                  child: Icon(
                    Icons.check,
                    color: selectedLevel == level ? Colors.green : Colors.grey,
                    size: 30,
                  ),
                ),
              ],
            ),
          const SizedBox(height: 8),
          Text(
            level.toUpperCase(),
            style: TextStyle(
              color: selectedLevel == level ? Colors.black : Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
