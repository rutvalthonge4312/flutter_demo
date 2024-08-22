import 'package:flutter/material.dart';
import 'package:wrms.app/models/index.dart';
import 'package:wrms.app/routes.dart';
import 'package:wrms.app/screens/add_train/widgets/coach_number_filed.dart';
import 'package:wrms.app/screens/add_train/widgets/train_name_field.dart';
import 'package:wrms.app/screens/add_train/widgets/train_number_field.dart';
import 'package:wrms.app/screens/add_train/widgets/station_name_field.dart';
import 'package:wrms.app/services/train_details_service.dart';

class AddTrainForm extends StatefulWidget {
  final UserModel userModel;
  const AddTrainForm({Key? key, required this.userModel}) : super(key: key);

  @override
  _AddTrainForm createState() => _AddTrainForm();
}

class _AddTrainForm extends State<AddTrainForm> {
  final _formKey = GlobalKey<FormState>();
  String? _trainNumber;
  String? _trainName;
  String? _coachCount;
  String? _stationName;
  String? token;
  bool _isLoading = false;
  bool _showModal = false;

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      setState(() {
        _showErrorModal(context, 'Please fill all required fields correctly.');
      });
      return;
    }
    setState(() {
      _isLoading = true;
    });
    _formKey.currentState!.save();
    try {
      final addTrainResponse = await TrainDetailsService.addNewTrain(
          token!, _trainNumber!, _trainName!, _coachCount!, _stationName!);

      if (addTrainResponse == 'Train added successfully') {
        _showErrorModal(context, addTrainResponse);
        Future.delayed(const Duration(seconds: 2), () {
          Navigator.pushReplacementNamed(context, Routes.addTrain);
        });
        // Navigator.pushReplacementNamed(context, Routes.addTrain);
      } else {
        setState(() {
          _showErrorModal(context, '$addTrainResponse');
        });
      }
    } catch (e) {
      setState(() {
        _showErrorModal(context, 'Failed to add train: $e');
      });
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    token = widget.userModel.token;
  }

  void _showErrorModal(BuildContext context, String errorMessage) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(errorMessage),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                setState(() {
                  _showModal = false;
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double buttonWidth = screenWidth * 0.8;
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Image.asset(
                      'assets/Add.gif',
                      width: 200.0,
                      height: 200.0,
                    ),
                    const SizedBox(height: 10),
                    TrainNumberField(onSaved: (value) => _trainNumber = value),
                    const SizedBox(height: 10),
                    TrainNameField(onSaved: (value) => _trainName = value),
                    const SizedBox(height: 10),
                    CoachNumberFiled(onSaved: (value) => _coachCount = value),
                    const SizedBox(height: 10),
                    StationNameField(onSaved: (value) => _stationName = value),
                    const SizedBox(height: 16, width: 100),
                    Center(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF313256),
                          foregroundColor: Colors.white,
                          fixedSize: Size(buttonWidth, 50),
                        ),
                        onPressed: _submitForm,
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white)
                            : const Text('Add Train'),
                      ),
                    ),
                    const SizedBox(height: 25),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
