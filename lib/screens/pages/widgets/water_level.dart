import 'package:flutter/material.dart';
import 'package:collection/collection.dart';

enum WaterLevel { overflow, full, partial, empty, na }

class WaterLevelWidget extends StatefulWidget {
  final String? initialLevel;
  final Function(WaterLevel) onLevelChanged;

  WaterLevelWidget({required this.onLevelChanged, this.initialLevel});

  @override
  _WaterLevelWidgetState createState() => _WaterLevelWidgetState();
}

class _WaterLevelWidgetState extends State<WaterLevelWidget> {
  WaterLevel? _selectedLevel;

  @override
  void initState() {
    super.initState();
    _selectedLevel = widget.initialLevel != null
        ? WaterLevel.values.firstWhereOrNull(
            (e) => e.toString().split('.')[1].toLowerCase() == widget.initialLevel!.toLowerCase(),
          )
        : null;
       
  }

  void _handleLevelChange(WaterLevel? value) {
    setState(() {
      _selectedLevel = value;
    });
    widget.onLevelChanged(value!);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
       const Text(
          'Water Level:',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Row(
              children: <Widget>[
                Radio<WaterLevel>(
                  value: WaterLevel.overflow,
                  groupValue: _selectedLevel,
                  onChanged: _handleLevelChange,
                ),
                const Text('Overflow'),
              ],
            ),
            Row(
              children: <Widget>[
                Radio<WaterLevel>(
                  value: WaterLevel.full,
                  groupValue: _selectedLevel,
                  onChanged: _handleLevelChange,
                ),
                const Text('Full'),
              ],
            ),
            Row(
              children: <Widget>[
                Radio<WaterLevel>(
                  value: WaterLevel.partial,
                  groupValue: _selectedLevel,
                  onChanged: _handleLevelChange,
                ),
                const Text('Partial'),
              ],
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Row(
              children: <Widget>[
                Radio<WaterLevel>(
                  value: WaterLevel.empty,
                  groupValue: _selectedLevel,
                  onChanged: _handleLevelChange,
                ),
                const Text('Not Filled'),
              ],
            ),
            Row(
              children: <Widget>[
                Radio<WaterLevel>(
                  value: WaterLevel.na,
                  groupValue: _selectedLevel,
                  onChanged: _handleLevelChange,
                ),
                const Text('N/A'),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
