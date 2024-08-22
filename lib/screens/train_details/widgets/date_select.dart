import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateSelect extends StatefulWidget {
  final void Function(DateTime) onDateSelected;
  final DateTime initialDate;

  DateSelect({required this.onDateSelected, required this.initialDate});

  @override
  _DateSelectState createState() => _DateSelectState();
}

class _DateSelectState extends State<DateSelect> {
  late TextEditingController _dateController;

  @override
  void initState() {
    super.initState();
    _dateController = TextEditingController(
      text: DateFormat('yyyy-MM-dd').format(widget.initialDate),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4.0),
          TextField(
            controller: _dateController,
            decoration: const InputDecoration(
              icon: Icon(Icons.calendar_today_rounded),
              labelText: "Select Date",
              border: OutlineInputBorder(),
            ),
            readOnly: true,
            onTap: () async {
              DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: widget.initialDate,
                firstDate: DateTime(2000),
                lastDate: DateTime(2101),
              );

              if (pickedDate != null) {
                setState(() {
                  _dateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
                });
                widget.onDateSelected(pickedDate);
              }
            },
          ),
        ],
      ),
    );
  }
}
