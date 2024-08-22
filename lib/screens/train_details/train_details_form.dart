import 'dart:async';

import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wrms.app/models/index.dart';
import 'package:wrms.app/routes.dart';
import 'package:wrms.app/screens/train_details/widgets/VideoUploadWidget.dart';
import 'package:wrms.app/screens/train_details/widgets/coaches.dart';
import 'package:wrms.app/screens/train_details/widgets/date_select.dart';
import 'package:wrms.app/screens/train_details/widgets/drop_down_train.dart';
import 'package:wrms.app/services/train_details_service.dart';
import 'package:wrms.app/screens/pages/uploaded_video.dart';
import 'package:wrms.app/services/video_service.dart';
import 'package:wrms.app/types/all_coach_response.dart';
import 'package:wrms.app/types/train_response.dart';
import 'package:wrms.app/types/video_response.dart';
import 'package:wrms.app/widgets/error_modal.dart';
import 'package:wrms.app/widgets/loader.dart';
import 'package:wrms.app/widgets/loader_new.dart';

class TrainDetailsForm extends StatefulWidget {
  final UserModel userModel;
  const TrainDetailsForm({required this.userModel, Key? key}) : super(key: key);

  @override
  _TrainDetailsForm createState() => _TrainDetailsForm();
}

class _TrainDetailsForm extends State<TrainDetailsForm> {
  static const int trainCoachCount = 24;
  String? token;
  List<TrainResponse> _trains = [];
  String? _trainName;
  String? coachNumber;
  String? trainNumber;
  bool _isLoading = true;
  bool _showModal = false;
  DateTime? _selectedDate = DateTime.now();
  final TextEditingController _trainNameController = TextEditingController();
  String taskStatus = 'pending';
  CoachData? data;
  String trainStatus = '';
  List<VideoResponse> uploadedVideos = [];
  bool isVideoUploaded = false;
  bool showUploadWidget = true;
  bool _isVideoLoading = false;
  Timer? _timer;
  void handleVideoUpload(video) {
    setState(() {
      uploadedVideos.add(video);
    });
  }

  @override
  void initState() {
    super.initState();

    token = widget.userModel.token;
    fetchAllTrains();
        Future.delayed(Duration.zero, () {
    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    if (args != null) {
      setState(() {
        _trainName = args['selectedTrainName'];
        trainNumber = args['selectedTrainNumber'];
        coachNumber = args['selectedCoach'];
        _selectedDate = DateTime.parse(args['selectedDate']);
        _trainNameController.text = _trainName ?? '';
      });
      _fetchCoachDetails(trainNumber, _selectedDate);
      fetchVideos();
    }
  });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }


  void _removeVideo(VideoResponse video) {
    setState(() {
      uploadedVideos.remove(video);
    });
  }

  void fetchAllTrains() async {
    try {
      final getTrainResponse = await TrainDetailsService.getAllTrain(token!);
      setState(() {
        _trains = getTrainResponse;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _showErrorModal(context, 'Failed to load train details: $e');
      });
    }
  }

  void _onTrainSelected(TrainResponse trainNo) {
    setState(() {
      trainNumber = (trainNo.trainNo).toString();
      _trainName = trainNo.trainName;
      _trainNameController.text = _trainName ?? '';
    });
    _fetchCoachDetails(trainNumber, _selectedDate);
    _fetchTrainDetails(trainNumber, _selectedDate);
    fetchVideos();
  }

  void _handleDateSelected(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
    if (trainNumber != null) {
      _fetchCoachDetails(trainNumber, _selectedDate);
      fetchVideos();
    }
  }

  void getCoachNumber(String trainCoachNumber) {
    setState(() {
      coachNumber = trainCoachNumber;
      _submitDetails();
    });
  }

  void _fetchCoachDetails(String? trainNumber, DateTime? date) async {
    loaderNew(context, "Fetching Coach Details,Please Wait!");
    try {
      final coachData = await TrainDetailsService.allCoachData(
          token!, trainNumber!, DateFormat('yyyy-MM-dd').format(date!),);
       Navigator.of(context).pop();
      setState(() {
        data = CoachData.fromJson(coachData);
      });
    } catch (e) {
       Navigator.of(context).pop();
      setState(() {
        _isLoading = false;
        _showErrorModal(context, 'Failed to Fetch train details: $e');
      });
    }
  }

  void _submitDetails() {
    final selectedDate = _selectedDate;
    final selectedTrainNumber = trainNumber;
    final selectedCoachNumber = coachNumber;
    final selectedTrainName = _trainNameController.text;
    final selectedStatus = taskStatus;

    if (selectedDate != null &&
        selectedTrainNumber != null &&
        selectedCoachNumber != null) {
      final args = {
        'date': DateFormat('yyyy-MM-dd').format(selectedDate),
        'trainNumber': selectedTrainNumber,
        'trainName': selectedTrainName,
        'coachNumber': selectedCoachNumber,
        'status': selectedStatus,
      };
      Navigator.pushNamed(context, Routes.addRatings, arguments: args)
          .then((_) {});
    } else {
      print("Null Values Selected!");
      setState(() {
        _showErrorModal(context, 'Please Select the train number');
      });
      return;
    }
  }

  void _fetchTrainDetails(String? trainNumber, DateTime? date) async {
    try {
      final trainData = await TrainDetailsService.fetchTrainDetails(
          token!, trainNumber!, DateFormat('yyyy-MM-dd').format(date!));
      setState(() {
        taskStatus = trainData;
        trainStatus = trainData;
      });
    } catch (e) {
      print(e);
    }
  }

  void updateTrainStatus(
      String? trainNumber, DateTime? date, String taskStatus,) async {
    try {
      final trainData = await TrainDetailsService.updateTrainDetails(token!,
          trainNumber!, DateFormat('yyyy-MM-dd').format(date!), taskStatus,);
      _fetchCoachDetails(trainNumber, _selectedDate);
      _fetchTrainDetails(trainNumber, _selectedDate);
    } catch (e) {
      showErrorModal(context, '$e', "Error", (){});
    }
  }

  Widget getStatusText(String status) {
    Color color;
    switch (status) {
      case 'Overflow':
        color = Colors.blue;
        break;
      case 'Full':
        color = Colors.green;
        break;
      case 'Partial':
        color = Colors.yellow;
        break;
      case 'Not filled':
        color = Colors.red.shade900;
        break;
      case 'N/A':
        color = Colors.pink.shade200;
        break;
      default:
        color = Colors.black;
    }
    return Text(status, style: TextStyle(color: color));
  }

  Future<void> fetchVideos() async {
    try {
      setState(() {
        _isVideoLoading = true;
        uploadedVideos = [];
      });
      final List<VideoResponse> getStatusResponse =
          await VideoService.getVideos(
        token!,
        DateFormat('yyyy-MM-dd').format(_selectedDate!),
        int.parse(trainNumber!),
        0,
      );
      if (getStatusResponse.isNotEmpty) {
        setState(() {
          uploadedVideos = getStatusResponse;
          isVideoUploaded = true;
        });
      } else {
        setState(() {
          uploadedVideos = [];
          isVideoUploaded = false;
        });
      }
      setState(() {
        _isVideoLoading = false;
      });
    } catch (e) {
      setState(() {
        _isVideoLoading = false;
        isVideoUploaded = false;
      });
      if (e is StateError && e.toString().contains('mounted')) {
        print('Widget disposed before operation completes');
      } else {
        print('Error fetching images: $e');
      }
    }
  }

  void _showErrorModal(BuildContext context, String errorMessage) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Alert'),
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

  void _showPopup(BuildContext context) {
    Map<String, int> waterLevelCounts = {
      'Overflow': 0,
      'Full': 0,
      'Partial': 0,
      'Not filled': 0,
      'N/A': 0,
    };

    Map<String, List<String>> coachNumbers = {
      'Overflow': [],
      'Full': [],
      'Partial': [],
      'Not filled': [],
      'N/A': [],
    };

    if (data != null && data!.coachDict.isNotEmpty) {
      data!.coachDict.forEach((key, value) {
        if (value.coachStatus != null) {
          waterLevelCounts[value.coachStatus!] =
              (waterLevelCounts[value.coachStatus!] ?? 0) + 1;
          coachNumbers[value.coachStatus!]?.add(key);
        }
      });
    }
    TextStyle headerStyle = const TextStyle(
      color: Color(0xFF313256),
      fontWeight: FontWeight.bold,
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Waterlevel Status"),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Table(
                  border: TableBorder.all(),
                  children: [
                    TableRow(
                      children: [
                        TableCell(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child:
                                Text('Waterlevel Status', style: headerStyle),
                          ),
                        ),
                        TableCell(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text('Coach Number', style: headerStyle),
                          ),
                        ),
                        TableCell(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text('No. of Coaches', style: headerStyle),
                          ),
                        ),
                      ],
                    ),
                    TableRow(
                      children: [
                        TableCell(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: getStatusText('Overflow'),
                          ),
                        ),
                        TableCell(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(coachNumbers['Overflow']!.join(', ')),
                          ),
                        ),
                        TableCell(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child:
                                Text(waterLevelCounts['Overflow'].toString()),
                          ),
                        ),
                      ],
                    ),
                    TableRow(
                      children: [
                        TableCell(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: getStatusText('Full'),
                          ),
                        ),
                        TableCell(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(coachNumbers['Full']!.join(', ')),
                          ),
                        ),
                        TableCell(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(waterLevelCounts['Full'].toString()),
                          ),
                        ),
                      ],
                    ),
                    TableRow(
                      children: [
                        TableCell(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: getStatusText('Partial'),
                          ),
                        ),
                        TableCell(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(coachNumbers['Partial']!.join(', ')),
                          ),
                        ),
                        TableCell(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(waterLevelCounts['Partial'].toString()),
                          ),
                        ),
                      ],
                    ),
                    TableRow(
                      children: [
                        TableCell(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: getStatusText('Not filled'),
                          ),
                        ),
                        TableCell(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(coachNumbers['Not filled']!.join(', ')),
                          ),
                        ),
                        TableCell(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child:
                                Text(waterLevelCounts['Not filled'].toString()),
                          ),
                        ),
                      ],
                    ),
                    TableRow(
                      children: [
                        TableCell(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: getStatusText('N/A'),
                          ),
                        ),
                        TableCell(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(coachNumbers['N/A']!.join(', ')),
                          ),
                        ),
                        TableCell(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(waterLevelCounts['N/A'].toString()),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Stack(
      children: [
        SingleChildScrollView(
          // child: Stack(
          // children:<Widget> [

          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: _isLoading
                ? const Loader(message: "Loading Trains...Please Wait")
                : Column(
                    children: [
                      const SizedBox(height: 10),
                      DropDownTrain(
                        trains: _trains,
                        onSaved: _onTrainSelected,
                        initialTrainNumber: trainNumber,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: TextFormField(
                          readOnly: true,
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
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: DateSelect(
                          onDateSelected: _handleDateSelected,
                          initialDate: _selectedDate ?? DateTime.now(),
                        ),
                      ),
                      if (_selectedDate != null && trainNumber != null)
                        Container(
                          width: double.infinity,
                          margin: const EdgeInsets.all(20),
                          child: Card(
                            margin: EdgeInsets.zero,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: VideoUploadWidget(
                                date: DateFormat('yyyy-MM-dd')
                                    .format(_selectedDate!),
                                trainNumber: int.parse(trainNumber!),
                                coachNumber: 0,
                                onSubmit: (video) {
                                  handleVideoUpload(video);
                                },
                              ),
                            ),
                          ),
                        ),
                      if (uploadedVideos.isNotEmpty)
                        Container(
                          width: double.infinity,
                          margin: const EdgeInsets.all(20),
                          child: Card(
                            margin: EdgeInsets.zero,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  const Center(
                                    child: const Text(
                                      'Uploaded Videos',
                                      style: TextStyle(
                                        decoration: TextDecoration.underline,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Container(
                                    child: Column(
                                      children: [
                                        if (_isVideoLoading)
                                          const CircularProgressIndicator(
                                            color: Colors.blueAccent,
                                          ),
                                        if (!(_isVideoLoading) &&
                                            uploadedVideos != null)
                                          ...uploadedVideos
                                              .where(
                                            (videoData) =>
                                                videoData.videoUrl != null &&
                                                videoData.videoUrl != "" &&
                                                videoData.coachNumber == 0,
                                          )
                                              .map((videoData) {
                                            return UploadedVideo(
                                              videoResponse: videoData,
                                              onDelete: () =>
                                                  _removeVideo(videoData),
                                            );
                                          }).toList(),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                      const SizedBox(height: 8),
                      Column(
                        children: List.generate(
                          screenWidth < 450
                              ? (trainCoachCount / 2).ceil()
                              : (trainCoachCount / 3).ceil(),
                          (index) {
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(
                                  screenWidth < 450 ? 2 : 3,
                                  (j) {
                                    int coachIndex =
                                        index * (screenWidth < 450 ? 2 : 3) + j;
                                    if (coachIndex < trainCoachCount) {
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8.0),
                                        child: Coaches(
                                          isImagePresent: data?.imageDict[
                                                  "coach_${coachIndex + 1}"] ??
                                              false,
                                          isVideoPresent: data?.videoDict[
                                                  "coach_${coachIndex + 1}"] ??
                                              false,
                                          taskStatus: data?.taskDict[
                                                  "coach_${coachIndex + 1}"] ??
                                              'pending',
                                          selectedWaterLevel: data != null &&
                                                  data!.coachDict[
                                                          'coach_${coachIndex + 1}'] !=
                                                      null &&
                                                  data!
                                                          .coachDict[
                                                              'coach_${coachIndex + 1}']!
                                                          .coachStatus !=
                                                      null
                                              ? data!
                                                  .coachDict[
                                                      'coach_${coachIndex + 1}']!
                                                  .coachStatus
                                              : 'empty',
                                          index: coachIndex,
                                          onSaved: getCoachNumber,
                                          isSelected: coachNumber ==
                                              (coachIndex + 1).toString(),
                                        ),
                                      );
                                    } else {
                                      return const SizedBox.shrink();
                                    }
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      // if(isVideoUploaded)
                      //   const Text("Video Was Uploaded For This Train at this Date"),
                      Column(
                        children: [
                          if (trainStatus != 'completed')
                            Container(
                              alignment: Alignment.center,
                              child: LayoutBuilder(
                                builder: (context, constraints) {
                                  double widthFactor = constraints.maxWidth >
                                          600
                                      ? 0.2
                                      : 0.4; // Adjust width for desktop view

                                  return FractionallySizedBox(
                                    widthFactor: widthFactor,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey),
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 5.0),
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton<String>(
                                          value: taskStatus,
                                          items: const <DropdownMenuItem<
                                              String>>[
                                            DropdownMenuItem(
                                              value: 'pending',
                                              child: Center(
                                                  child: Text('Pending',
                                                      textAlign:
                                                          TextAlign.center)),
                                            ),
                                            DropdownMenuItem(
                                              value: 'completed',
                                              child: Center(
                                                  child: Text('Completed',
                                                      textAlign:
                                                          TextAlign.center)),
                                            ),
                                          ],
                                          onChanged: (String? newValue) {
                                            if (newValue != null) {
                                              setState(() {
                                                taskStatus = newValue;
                                              });
                                            }
                                          },
                                          isExpanded: true,
                                          icon:
                                              const Icon(Icons.arrow_drop_down),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            )
                          else
                            Container(
                              alignment: Alignment.center,
                              child: LayoutBuilder(
                                builder: (context, constraints) {
                                  double widthFactor = constraints.maxWidth >
                                          600
                                      ? 0.2
                                      : 0.4; // Adjust width for desktop view

                                  return FractionallySizedBox(
                                    widthFactor: widthFactor,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey),
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 5.0),
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton<String>(
                                          value: taskStatus,
                                          items: const <DropdownMenuItem<
                                              String>>[
                                            DropdownMenuItem(
                                              value: 'pending',
                                              child: Center(
                                                  child: Text('Pending',
                                                      textAlign:
                                                          TextAlign.center)),
                                            ),
                                            DropdownMenuItem(
                                              value: 'completed',
                                              child: Center(
                                                  child: Text('Completed',
                                                      textAlign:
                                                          TextAlign.center)),
                                            ),
                                          ],
                                          onChanged: null, // Disable dropdown
                                          isExpanded: true,
                                          icon:
                                              const Icon(Icons.arrow_drop_down),
                                          disabledHint:
                                              Center(child: Text(taskStatus)),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          if (taskStatus == 'completed')
                            Column(
                              children: [
                                const SizedBox(height: 2),
                                _buildWaterLevelTable(),
                              ],
                            ),
                          if (trainStatus != 'completed')
                            Column(
                              children: [
                                const SizedBox(
                                    height:
                                        2), // Add some space between the table and the button
                                Container(
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 30),
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF313256),
                                      foregroundColor: Colors.white,
                                      fixedSize: Size(
                                          screenWidth > 600 ? 150 : 200,
                                          50,), // Adjust button width based on screen size
                                    ),
                                    onPressed: () {
                                      updateTrainStatus(trainNumber,
                                          _selectedDate, taskStatus,);
                                    },
                                    child: const Text('Submit'),
                                  ),
                                ),
                              ],
                            )
                          else
                            Column(
                              children: [
                                const SizedBox(height: 2),
                                Container(
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 30),
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF313256),
                                      foregroundColor: Colors.white,
                                      fixedSize: Size(
                                          screenWidth > 600 ? 150 : 200,
                                          50), // Adjust button width based on screen size
                                    ),
                                    onPressed: null, // Disable button
                                    child: const Text('Submit'),
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildWaterLevelTable() {
    Map<String, int> waterLevelCounts = {
      'Overflow': 0,
      'Full': 0,
      'Partial': 0,
      'Not filled': 0,
      'N/A': 0,
    };

    Map<String, List<String>> coachNumbers = {
      'Overflow': [],
      'Full': [],
      'Partial': [],
      'Not filled': [],
      'N/A': [],
    };

    Map<String, String> statusMapping = {
      'overflow': 'Overflow',
      'full': 'Full',
      'partial': 'Partial',
      'not filled': 'Not filled',
      'na': 'N/A',
      'empty': 'Not filled',
    };

    if (data != null && data!.coachDict.isNotEmpty) {
      data!.coachDict.forEach((key, value) {
        if (value.coachStatus != null) {
          String mappedStatus = statusMapping[value.coachStatus!] ?? 'N/A';
          waterLevelCounts[mappedStatus] =
              (waterLevelCounts[mappedStatus] ?? 0) + 1;
          String coachNumber = key.replaceAll(RegExp(r'\D'), '');
          coachNumbers[mappedStatus]?.add(coachNumber);
        }
      });
    }

    TextStyle headerStyle = const TextStyle(
      color: Color(0xFF313256),
      fontWeight: FontWeight.bold,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        double containerWidth =
            constraints.maxWidth > 600 ? 800 : double.infinity;

        return Center(
          child: Container(
            width: containerWidth,
            padding:
                const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8.0),
                Table(
                  border: TableBorder.all(),
                  children: [
                    TableRow(
                      children: [
                        TableCell(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child:
                                Text('Waterlevel Status', style: headerStyle),
                          ),
                        ),
                        TableCell(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text('Coach Number', style: headerStyle),
                          ),
                        ),
                        TableCell(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text('No. of Coaches', style: headerStyle),
                          ),
                        ),
                      ],
                    ),
                    _buildTableRow('Overflow', coachNumbers, waterLevelCounts),
                    _buildTableRow('Full', coachNumbers, waterLevelCounts),
                    _buildTableRow('Partial', coachNumbers, waterLevelCounts),
                    _buildTableRow(
                        'Not filled', coachNumbers, waterLevelCounts),
                    _buildTableRow('N/A', coachNumbers, waterLevelCounts),
                  ],
                ),
                const SizedBox(
                  height: 14,
                ),
                Table(
                  border: TableBorder.all(),
                  children: [
                    TableRow(
                      decoration: BoxDecoration(color: Colors.grey[300]),
                      children: const [
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            'Date',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            'Is Video Uploaded',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    TableRow(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                              DateFormat('yyyy-MM-dd').format(_selectedDate!)),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                isVideoUploaded ? Icons.check : Icons.close,
                                color:
                                    isVideoUploaded ? Colors.green : Colors.red,
                              ),
                              const SizedBox(width: 4),
                              Text(isVideoUploaded ? 'Yes' : 'No'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  TableRow _buildTableRow(
    String status,
    Map<String, List<String>> coachNumbers,
    Map<String, int> waterLevelCounts,
  ) {
    return TableRow(
      children: [
        TableCell(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(status),
          ),
        ),
        TableCell(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(coachNumbers[status]?.join(', ') ?? ''),
          ),
        ),
        TableCell(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(waterLevelCounts[status]?.toString() ?? '0'),
          ),
        ),
      ],
    );
  }
}
