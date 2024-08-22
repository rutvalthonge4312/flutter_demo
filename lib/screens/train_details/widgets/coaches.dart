import 'package:flutter/material.dart';
import './waterlevel.dart';

class Coaches extends StatefulWidget {
  final int index;
  final void Function(String) onSaved;
  final bool isSelected;
  final bool isImagePresent;
  final bool isVideoPresent;
  final String selectedWaterLevel;
  final String taskStatus;
  const Coaches({
    required this.index,
    required this.selectedWaterLevel,
    required this.onSaved,
    this.isSelected = false,
    required this.isImagePresent,
    required this.isVideoPresent,
    required this.taskStatus,
    Key? key,
  }) : super(key: key);

  @override
  _Coaches createState() => _Coaches();
}

class _Coaches extends State<Coaches> {
  // String selectedWaterLevel = 'full';
  // bool isImagePresent = true;

  void _updateWaterLevel(String level) {
    widget.onSaved(level);
  }

  Widget _getWaterLevelIcon() {
    switch (widget.selectedWaterLevel) {
      case 'full':
      return Stack(
        alignment: Alignment.center,
        children: [
          const Icon(Icons.check, color: Colors.green, size: 24),
          if (widget.taskStatus == 'completed') 
            const Positioned(
              top: 0,
              left: 3,
              child: Icon(Icons.check, color: Colors.green, size: 16),
            ),
        ],
      );
      case 'overflow':
      return Stack(
        alignment: Alignment.center,
        children: [
          const Icon(Icons.check, color: Colors.blue, size: 24),
          if (widget.taskStatus == 'completed') 
            const Positioned(
              top: 0,
              left: 3,
              child: Icon(Icons.check, color: Colors.blue, size: 16),
            ),
        ],
      );
      case 'partial':
        return Stack(
        alignment: Alignment.center,
        children: [
          const Icon(Icons.check, color: Colors.yellow, size: 24),
          if (widget.taskStatus == 'completed') 
            const Positioned(
              top: 0,
              left: 3,
              child: Icon(Icons.check, color: Colors.yellow, size: 16),
            ),
        ],
      );
      case 'empty':
        return Stack(
        alignment: Alignment.center,
        children: [
          if (widget.taskStatus == 'pending') 
            const Icon(Icons.close, color: Colors.yellow, size: 24),
          if (widget.taskStatus == 'completed') 
            const Icon(Icons.close, color: Colors.red, size: 24),
        ],
      );
      case 'na':
        default:
         return Stack(
        alignment: Alignment.center,
        children: [
          if(widget.taskStatus == 'pending')
            const Icon(Icons.close, color: Colors.pinkAccent, size: 24),
          if (widget.taskStatus == 'completed') 
            const Icon(Icons.close, color: Colors.brown, size: 24),
        ],
      );
    }
  }

  Color _getWaterLevelColor() {
    switch (widget.selectedWaterLevel) {
      case 'full':
        return Colors.green;
      case 'partial':
        return Colors.yellow;
      case 'empty':
      default:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 4.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  widget.onSaved((widget.index + 1).toString());
                },
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        widget.onSaved((widget.index + 1).toString());
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: widget.isSelected ? Colors.blue : Colors.white,
                        fixedSize: const Size(100, 40),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Stack(
                        children: [
                          if (widget.isImagePresent)
                          Positioned(
                            left: 36,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 12, left: 3),
                              child: Image.asset(
                                'assets/image_exists.jpg',
                                width: 24,
                                height: 12,
                              ),
                            ),
                          )
                         else if (widget.isVideoPresent)
                          Positioned(
                            left: 36,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 12, left: 3),
                              child: Image.asset(
                                'assets/video_exists.png',
                                width: 20,
                                height: 12,
                              ),
                            ),
                          )
                        else if (widget.isImagePresent && widget.isVideoPresent)
                          Positioned(
                            left: 36,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 12, left: 30),
                              child: Row(
                                children: [
                                  Image.asset(
                                    'assets/image_exists.jpg',
                                    width: 24,
                                    height: 12,
                                  ),
                                  SizedBox(width: 8),
                                  Image.asset(
                                    'assets/videos.png',
                                    width: 20,
                                    height: 12,
                                  ),
                                ],
                              ),
                            ),
                          ),
                            // const SizedBox(width: 8.0), // Add some padding between image and text
                          Positioned(
                              top:5,
                              right: 16, 
                              child: Text(
                                '${widget.index + 1}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: Color.fromARGB(255, 77, 6, 144),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      bottom: 10,
                      left: 20, // Position the double tick to the left
                      child: _getWaterLevelIcon(),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4.0),
              const Icon(Icons.keyboard_tab, size: 24),
            ],
          ),
          const SizedBox(height: 8.0),
          WaterLevelWidget(
            onLevelChanged: _updateWaterLevel,
          ),
        ],
      ),
    );
  }
}
