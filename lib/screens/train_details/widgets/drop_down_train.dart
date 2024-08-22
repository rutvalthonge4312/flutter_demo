import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:wrms.app/types/train_response.dart';

class DropDownTrain extends StatefulWidget {
  final void Function(TrainResponse) onSaved;
  final List<TrainResponse> trains;
  final String? initialTrainNumber;

  DropDownTrain({
    Key? key,
    required this.onSaved,
    required this.trains,
    this.initialTrainNumber,
  }) : super(key: key);

  @override
  _DropDownTrain createState() => _DropDownTrain();
}

class _DropDownTrain extends State<DropDownTrain> {
  TrainResponse? _selectedTrain;

  @override
  void initState() {
    super.initState();
    if (widget.initialTrainNumber != null) {
      _selectedTrain = widget.trains.firstWhere(
        (train) => train.trainNo.toString() == widget.initialTrainNumber,
        orElse: () => widget.trains.first,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DropdownSearch<int>(
      items: widget.trains.map((train) => train.trainNo).toList(),
      onChanged: (int? newValue) {
        setState(() {
          _selectedTrain = widget.trains.firstWhere((train) => train.trainNo == newValue);
        });
        if (_selectedTrain != null) {
          widget.onSaved(_selectedTrain!);
        }
      },
      selectedItem: _selectedTrain?.trainNo,
      dropdownDecoratorProps: DropDownDecoratorProps(
        dropdownSearchDecoration: InputDecoration(
          labelText: "Train Number",
          hintText: "Select Train Number",
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(color: Colors.grey),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(color: Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(color: Colors.blue),
          ),
        ),
      ),
      popupProps: const PopupProps.menu(
        showSearchBox: true,
      ),
      dropdownBuilder: (context, selectedItem) {
        return Text(selectedItem?.toString() ?? "Select Train Number");
      },
    );
  }
}
