import 'package:flutter/material.dart';
import 'package:wrms.app/models/index.dart';
import 'package:wrms.app/routes.dart';
import 'package:wrms.app/screens/train_details/widgets/drop_down_train.dart';
import 'package:wrms.app/types/train_response.dart';
import 'package:wrms.app/services/train_details_service.dart';
import 'package:wrms.app/widgets/loader.dart';

class UpdateTrainForm extends StatefulWidget {
  final UserModel userModel;
  const UpdateTrainForm({Key? key, required this.userModel}) : super(key: key);
  
  @override
  _UpdateTrainFormState createState() => _UpdateTrainFormState();
}

class _UpdateTrainFormState extends State<UpdateTrainForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _stationController;
  late TextEditingController _trainNoController;
  late TextEditingController _trainNameController;
  late TextEditingController _noOfCoachesController;
  List<TrainResponse> _trains = [];
  String? _trainName;
  String? trainNumber;
  bool _isUpdatingTrainDetails = false;
  bool _isDeletingTrainDetails = false;
  String? token;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    token = widget.userModel.token;
    fetchAllTrains(token!);
    _stationController = TextEditingController();
    _trainNoController = TextEditingController();
    _trainNameController = TextEditingController();
    _noOfCoachesController = TextEditingController();
  }

  @override
  void dispose() {
    _stationController.dispose();
    _trainNoController.dispose();
    _trainNameController.dispose();
    _noOfCoachesController.dispose();
    super.dispose();
  }

  void _onTrainSelected(TrainResponse trainNo) {
    setState(() {
      trainNumber = (trainNo.trainNo).toString();
      _trainNoController.text=(trainNo.trainNo).toString();
      _trainName = trainNo.trainName;
      _trainNameController.text = _trainName ?? '';
     _noOfCoachesController.text = (trainNo.coachCounts != null) ? trainNo.coachCounts.toString() : '';
      _stationController.text = (trainNo.stationName != null) ? trainNo.stationName.toString() : '';
    });
      print(trainNumber);
  }
  void fetchAllTrains(String token) async {
    setState(() {
      _isLoading = true;
    });
    try {
      final getTrainResponse = await TrainDetailsService.getTrainsWithoutStationFilter(token);
      setState(() {
        _trains = getTrainResponse;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _showErrorModalNew('Failed to load train details',"Error");
      });
    }
  }
  void _showErrorModalNew(String errorMessage,String heading) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title:  Text(heading),
          content: Text(errorMessage),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateTrainDetails() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _isUpdatingTrainDetails = true;
      });
      try {
        final message = await TrainDetailsService.updateTrainInformation(token!,_trainNoController.text,_trainNameController.text,_noOfCoachesController.text, _stationController.text);
        _showErrorModalNew(message,"Success");
        await Future.delayed(const Duration(seconds: 2));
      } catch (e) {
         _showErrorModalNew('$e',"Error");
         await Future.delayed(const Duration(seconds: 2));
      } finally {
        setState(() {
          _isUpdatingTrainDetails = false;
        });
        Navigator.pushReplacementNamed(context, Routes.updateTrain);
      }
    }
  }
   Future<void> _deleteTrainDetails() async {
    setState(() {
      _isDeletingTrainDetails = true;
    });
    try {
      final message = await TrainDetailsService.deleteTrain(token!,_trainNoController.text,);
       _showErrorModalNew(message,"Success");
        await Future.delayed(const Duration(seconds: 2));
    } catch (e) {
       _showErrorModalNew('$e',"Error");
        await Future.delayed(const Duration(seconds: 2));
    } finally {
         setState(() {
          _isDeletingTrainDetails = false;
        });
        Navigator.pushReplacementNamed(context, Routes.updateTrain);
    } 
  }
  Future<void> _showConfirmationDialog(String action) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false, 
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('$action Confirmation',
        style:const TextStyle(
        color: Colors.blue,),),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text('Are you sure you want to $action the train?'),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child:const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              action=='Update' ? _updateTrainDetails() :
              _deleteTrainDetails();
              Navigator.of(context).pop(); 
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red, // Sets the background color to red
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0), // Adjust the roundness here
            ),
            ),
            child:Text(action), 
          ),
        ],
      );
    },
  );
}
Future<void> _handleDeleteConfirmation() async {
  await _showConfirmationDialog("Delete");
} 
Future<void> _handleUpdateConfirmation() async {
  await _showConfirmationDialog("Update");
} 
  Widget _buildTextField(String label, TextEditingController controller, FormFieldSetter<String?> onSaved, String? Function(String?)? validator) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        onSaved: onSaved,
        validator: validator,
      ),
    );
  }

  Widget _buildUpdateButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ElevatedButton(
        onPressed: _isUpdatingTrainDetails ? null : _handleUpdateConfirmation,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF313256),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          minimumSize: const Size(double.infinity, 50),
        ),
        child: _isUpdatingTrainDetails ? const CircularProgressIndicator(color: Colors.white) : const Text('Update Train Details'),
      ),
    );
  }
  Widget _buildDeleteButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ElevatedButton(
        onPressed: _isDeletingTrainDetails ? null : _handleDeleteConfirmation,
        style: ElevatedButton.styleFrom(
          backgroundColor:  const Color.fromARGB(255, 157, 44, 36),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          minimumSize: const Size(double.infinity, 50),
        ),
        child: _isDeletingTrainDetails ? const CircularProgressIndicator(color: Colors.white) : const Text('Delete Train Details'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<String> stationNames = ['PNBE', 'PPTA'];
    return Scaffold(
      body:
       Stack(
        children: [
          if(!_isLoading)
            SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                     Image.asset(
                    'assets/Reload.gif',
                    width: 200.0,
                    height: 200.0,
                    color:const Color.fromARGB(255, 196, 196, 196),
                  ),
                  const SizedBox(height: 10),
                  DropDownTrain(
                    trains: _trains,
                    onSaved: _onTrainSelected,
                    initialTrainNumber: trainNumber,
                  ),
                   Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: TextFormField(
                      controller: _trainNameController,
                      keyboardType: TextInputType.name,
                      decoration: InputDecoration(
                        labelText: 'Train Name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: DropdownButtonFormField<String>(
                    value: _stationController.text.isEmpty ? null : _stationController.text,
                    hint: const Text('Select Station Name'), // Hint text when no value is selected
                    decoration: InputDecoration(
                      labelText: 'Station Name',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide:const BorderSide(color: Colors.grey),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide:const BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide:const BorderSide(color: Colors.blue),
                      ),
                    ),
                    items: stationNames.map((String station) {
                      return DropdownMenuItem<String>(
                        value: station,
                        child: Text(station),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _stationController.text = newValue ?? '';
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Station Name is required';
                      }
                      return null;
                    },
                  ),
                  ),

                  _buildTextField('Number of Coaches', _noOfCoachesController, (value) => _noOfCoachesController.text = value!,
                    (value) {
                      if (value == null || value.isEmpty) {
                        return 'Number of Coaches is required';
                      }
                      if (!RegExp(r'^\d+$').hasMatch(value)) {
                        return 'Number of Coaches must be a number';
                      }
                      return null;
                    }),
                  const SizedBox(height: 10),
                  _buildUpdateButton(),
                  const SizedBox(height: 5,),
                  if(widget.userModel.userType=="officer" || widget.userModel.userType=="railway admin" || widget.userModel.userType=="railway manager" )
                    _buildDeleteButton(),
                ],
              ),
            ),
          ),
          if(_isLoading)
            const Center(
              child:Loader(message: "Loading Trains...Please Wait"),
            ),
        ],
      ),
    );
  }
}
