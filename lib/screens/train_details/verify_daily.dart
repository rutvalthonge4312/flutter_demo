import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wrms.app/models/index.dart';
import 'package:wrms.app/screens/train_details/widgets/date_select.dart';
import 'package:wrms.app/types/index.dart';
import 'package:wrms.app/types/verify_trains_response.dart';
import 'package:wrms.app/widgets/loader.dart';
import 'package:wrms.app/services/daily_verification_service.dart';
import 'package:pinput/pinput.dart';
import 'package:wrms.app/services/profile_service.dart';
import 'package:wrms.app/widgets/loader_new.dart';

class VerifyDaily extends StatefulWidget {
  final UserModel userModel;

  const VerifyDaily({required this.userModel, Key? key}) : super(key: key);

  @override
  _VerifyDailyFormState createState() => _VerifyDailyFormState();
}

class _VerifyDailyFormState extends State<VerifyDaily> {
  String? token;
  String _email = "";
  DateTime? _selectedDate = DateTime.now();
  bool _isLoading = false;
  bool _showModal = false;
  String? otp;
  bool _showEmailOtp = false;
  bool _emailVerified = false;
  bool _isEmailOtpSend = false;
  VerifyDateResponse? dayVerificationData;
  VerifiedTrainsResponse? dailyTrainData;
  bool _isEmailOtpVerify = false;
  bool _showEmailVerificationSection = false;
  int? _selectedTrainIndex;
  int page = 1;
  bool _isResendEnabled = false;
  late Timer? _timer;
  int _timerDuration = 30;

  Map<String, int> _waterLevelCounts = {
    'Overflow': 0,
    'Full': 0,
    'Partial': 0,
    'Empty': 0,
    'N/A': 0,
  };

  final TextEditingController emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    token = widget.userModel.token;
    await _getProfile();
    await _getVerification();
    _trainForDate();
  }

  void _startTimer() {
    _isResendEnabled = false;
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_timerDuration == 0) {
        setState(() {
          _isResendEnabled = true;
          _timer?.cancel();
        });
      } else {
        setState(() {
          _timerDuration--;
        });
      }
    });
  }

  Future<void> _getProfile() async {
    try {
      final profileResponse = await ProfileService.getProfile(token!);
      setState(() {
        _email = profileResponse.user?.email ?? 'user@gmail.com';
      });
    } catch (e) {
      setState(() {
        _showErrorModal(context, '$e');
      });
    }
  }

  Future<void> _getVerification() async {
    try {
      _showLoader(context, "Fetching Verification Data...");
      String payloadDate = DateFormat('yyyy-MM-dd').format(_selectedDate!);
      final profileResponse =
          await DailyVerificationService.isDayVerified(token!, payloadDate);
      setState(() {
        dayVerificationData = profileResponse;
      });
    } catch (e) {
      setState(() {
        _showErrorModal(context, '$e');
      });
    } finally {
      Navigator.of(context).pop();
    }
  }

  Future<void> _trainForDate() async {
    try {
      _showLoader(context, "Fetching Verified Trains...");
      String payloadDate = DateFormat('yyyy-MM-dd').format(_selectedDate!);
      final profileResponse = await DailyVerificationService.trainForDate(
          token!, payloadDate, page);
      Navigator.of(context).pop();
      Map<String, int> waterLevelCounts = {
        'Overflow': 0,
        'Full': 0,
        'Partial': 0,
        'Empty': 0,
        'N/A': 0,
      };

      if (profileResponse.details != null) {
        for (var trainDetail in profileResponse.details!) {
          final statusCounts = trainDetail.statusCounts;
          if (statusCounts != null) {
            waterLevelCounts['Overflow'] =
                waterLevelCounts['Overflow']! + (statusCounts.overflow ?? 0);
            waterLevelCounts['Full'] =
                waterLevelCounts['Full']! + (statusCounts.full ?? 0);
            waterLevelCounts['Partial'] =
                waterLevelCounts['Partial']! + (statusCounts.partial ?? 0);
            waterLevelCounts['Empty'] =
                waterLevelCounts['Empty']! + (statusCounts.empty ?? 0);
            waterLevelCounts['N/A'] =
                waterLevelCounts['N/A']! + (statusCounts.na ?? 0);
          }
        }
      }

      setState(() {
        dailyTrainData = profileResponse;
        _waterLevelCounts = waterLevelCounts; // Store counts for later use
      });
    } catch (e) {
      Navigator.of(context).pop();
      setState(() {
        _showErrorModal(context, '$e');
      });
    } finally {
      // Navigator.of(context).pop();
    }
  }

  void _showLoader(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const CircularProgressIndicator(),
                const SizedBox(width: 15),
                Text(message, textAlign: TextAlign.center),
              ],
            ),
          ),
        );
      },
    );
  }

  void _verifyData() async {
    final email = _email;
    if (email.isEmpty) {
      setState(() {
        _showErrorModal(context, 'Please enter a valid email address.');
      });
      return;
    }
    if (otp == null || otp!.isEmpty) {
      setState(() {
        _showErrorModal(context, 'Please enter the OTP sent to your email.');
      });
      return;
    }

    setState(() {
      _isEmailOtpVerify = true;
    });
    try {
      final verifyOtpResponse =
          await DailyVerificationService.verifyOtp(email, otp!, token!);
      setState(() {
        _showErrorModal(context, verifyOtpResponse);
      });
      if (verifyOtpResponse == 'OTP Verified') {
        setState(() {
          _emailVerified = true;
          _showEmailOtp = false;
          _isEmailOtpVerify = false;
        });
        _submitDailyVerification();
      }
    } catch (e) {
      setState(() {
        _isEmailOtpVerify = false;
        _showErrorModal(context, 'Verification Failed: $e');
      });
    }
  }

  void _sendOtp() async {
    final email = _email;
    if (email.isEmpty) {
      setState(() {
        _showErrorModal(context, 'Please enter a valid email address.');
      });
      return;
    }
    setState(() {
      _isEmailOtpSend = true;
    });
    try {
      loaderNew(context, "Sending Otp. Please Wait...");
      final sendOtpResponse =
          await DailyVerificationService.sendOtp(email, token!);
       Navigator.of(context).pop();
      _startTimer();
      setState(() {
        _showErrorModal(context, '$sendOtpResponse');
        _showEmailOtp = true;
        _isEmailOtpSend = false;
      });
    } catch (e) {
       Navigator.of(context).pop();
      setState(() {
        _showErrorModal(context, 'Send OTP Failed: $e');
        _isEmailOtpSend = false;
      });
    }
  }

  void _handleDateSelected(DateTime date) {
    setState(() {
      _selectedDate = date;
      page = 1;
    });
    _getVerification();
    _trainForDate();
  }

  void _submitData() async {
    if (_selectedDate != null) {
      if (!_emailVerified) {
        setState(() {
          _showEmailVerificationSection = true;
        });
      }
    } else {
      setState(() {
        _showErrorModal(context, 'Please select a date.');
      });
    }
  }

  void _submitDailyVerification() async {
    setState(() {
      _isLoading = true;
    });
    String payloadDate = DateFormat('yyyy-MM-dd').format(_selectedDate!);
    try {
      await DailyVerificationService.submitVerification(
          token!, payloadDate, true);
      setState(() {
        _isLoading = false;
        _showErrorModal(context, 'Verification submitted successfully.');
      });
      _getVerification();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _showErrorModal(context, 'Submission Failed: $e');
      });
      _getVerification();
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

  InputDecoration textFieldDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(
          color: Colors.grey,
        ),
      ),
    );
  }

  PinTheme get defaultPinTheme {
    return PinTheme(
      width: 56,
      height: 56,
      textStyle: const TextStyle(fontSize: 20, color: Colors.black),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  Widget _buildTrainDetailsCardForIndex(int index) {
    final trainDetail = dailyTrainData?.details?[index];
    if (trainDetail == null) return const SizedBox.shrink();
    final statusCounts = trainDetail.statusCounts;
    final totalCoaches = (statusCounts?.overflow ?? 0) +
        (statusCounts?.full ?? 0) +
        (statusCounts?.partial ?? 0) +
        (statusCounts?.empty ?? 0) +
        (statusCounts?.na ?? 0);

    return Card(
      elevation: 10,
      margin: const EdgeInsets.only(bottom: 20),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 1,
                  child: RichText(
                    text: TextSpan(
                      style: DefaultTextStyle.of(context).style,
                      children: [
                        const TextSpan(
                          text: 'Train No: ',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text: trainDetail.trainNumber?.toString() ?? 'NA',
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                    width:
                        20), // Add some spacing between Train No and Train Name
                Expanded(
                  flex: 2,
                  child: RichText(
                    text: TextSpan(
                      style: DefaultTextStyle.of(context).style,
                      children: [
                        const TextSpan(
                          text: 'Train Name: ',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text: trainDetail.trainName ?? 'N/A',
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            RichText(
              text: TextSpan(
                style: DefaultTextStyle.of(context).style,
                children: [
                  const TextSpan(
                    text: 'No of Coaches: ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: totalCoaches.toString(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Water Level Status',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            _buildWaterLevelTable(trainDetail.statusCounts ??
                StatusCounts(
                    overflow: 0, full: 0, partial: 0, empty: 0, na: 0)),
          ],
        ),
      ),
    );
  }

  Widget _buildWaterLevelTable(StatusCounts data) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    List<TableRow> rows = [
      TableRow(
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 238, 238, 238),
        ),
        children: ['Overflow', 'Full', 'Partial', 'Empty', 'N/A']
            .map((status) => Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Text(
                    status,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ))
            .toList(),
      ),
      TableRow(
        children: [
          _buildWaterLevelCell('Overflow', data.overflow!),
          _buildWaterLevelCell('Full', data.full!),
          _buildWaterLevelCell('Partial', data.partial!),
          _buildWaterLevelCell('Empty', data.empty!),
          _buildWaterLevelCell('N/A', data.na!),
        ],
      ),
    ];

    return Table(
      border: TableBorder.all(),
      columnWidths: isMobile
          ? null
          : const {
              0: FlexColumnWidth(),
              1: FlexColumnWidth(),
              2: FlexColumnWidth(),
              3: FlexColumnWidth(),
              4: FlexColumnWidth(),
            },
      children: rows,
    );
  }

  Widget _buildWaterLevelCell(String status, int? count) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Text(
        count != null && count > 0 ? count.toString() : '—',
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildStaticTable() {
    final isMobile = MediaQuery.of(context).size.width < 600;
    List<Map<String, dynamic>> trainData = dailyTrainData?.details
            ?.where((data) => data.trainNumber != null)
            ?.map((data) {
          final statusCounts = data.statusCounts;
          return {
            'trainNumber': data.trainNumber.toString() ?? 'N/A',
            'overflow': statusCounts?.overflow,
            'full': statusCounts?.full,
            'partial': statusCounts?.partial,
            'empty': statusCounts?.empty,
            'na': statusCounts?.na,
          };
        }).toList() ??
        [];

    final headers = ['Train No', 'Overflow', 'Full', 'Partial', 'Empty', 'N/A'];
    List<TableRow> tableRows = [
      TableRow(
        decoration: const BoxDecoration(
          color: Color.fromARGB(255, 238, 238, 238),
        ),
        children: headers.map((header) {
          return Padding(
            padding: const EdgeInsets.all(4.0),
            child: Text(
              header,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: isMobile ? 10 : 12,
              ),
            ),
          );
        }).toList(),
      ),
    ];

    for (int i = 0; i < trainData.length; i++) {
      tableRows.add(
        TableRow(
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  _selectedTrainIndex = i;
                });
              },
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Text(
                  trainData[i]['trainNumber'],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: isMobile ? 10 : 12,
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
            _buildWaterLevelCell('Overflow', trainData[i]['overflow']),
            _buildWaterLevelCell('Full', trainData[i]['full']),
            _buildWaterLevelCell('Partial', trainData[i]['partial']),
            _buildWaterLevelCell('Empty', trainData[i]['empty']),
            _buildWaterLevelCell('N/A', trainData[i]['na']),
          ],
        ),
      );
    }

    return Column(
      children: [
        Table(
          border: TableBorder.all(),
          children: tableRows,
        ),
        const SizedBox(height: 12),
        if (dailyTrainData?.next != null)
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                page = page + 1;
              });
              _trainForDate();
              setState(() {
                _selectedTrainIndex = null;
              });
            },
            label: const Text('Show Next Page'),
            icon: const Icon(Icons.arrow_forward, color: Colors.black),
          ),
        const SizedBox(height: 8),
        if (dailyTrainData?.previous != null)
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                page = page - 1;
              });
              _trainForDate();
              setState(() {
                _selectedTrainIndex = null;
              });
            },
            label: const Text('Show Previous Page'),
            icon: const Icon(Icons.arrow_back, color: Colors.black),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double buttonWidth = screenWidth * 0.8;
    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: _isLoading
                  ? const Loader(message: "Loading Trains...Please Wait")
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 50),
                        DateSelect(
                          onDateSelected: _handleDateSelected,
                          initialDate: _selectedDate ?? DateTime.now(),
                        ),
                        const SizedBox(height: 20),
                        _buildStaticTable(), // Train details table
                        const SizedBox(height: 20),
                        if (_selectedTrainIndex != null)
                          _buildTrainDetailsCardForIndex(_selectedTrainIndex!),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF313256),
                            foregroundColor: Colors.white,
                            fixedSize: Size(buttonWidth, 50),
                          ),
                          onPressed: dayVerificationData != null &&
                                  (dayVerificationData!.isVerified == null ||
                                      !dayVerificationData!.isVerified!)
                              ? _submitData
                              : null,
                          child: Text(
                            dayVerificationData != null
                                ? (dayVerificationData!.isVerified == null
                                    ? 'Submit'
                                    : (dayVerificationData!.isVerified!
                                        ? 'Day Verification Completed'
                                        : 'Submit'))
                                : 'Submit',
                          ),
                        ),
                        if (_showEmailVerificationSection) ...[
                          const SizedBox(height: 16),
                          TextFormField(
                            initialValue: _email,
                            readOnly: true,
                            keyboardType: TextInputType.emailAddress,
                            decoration: textFieldDecoration('Email Address'),
                          ),
                          const SizedBox(height: 5),
                          if (!_showEmailOtp && !_emailVerified)
                            Align(
                              alignment: Alignment.centerRight,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF313256),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: _sendOtp,
                                child: _isEmailOtpSend
                                    ? const CircularProgressIndicator(
                                        color: Colors.white,
                                      )
                                    : const Text('Verify Email'),
                              ),
                            ),
                          if (_emailVerified)
                            Wrap(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Image.asset(
                                      'assets/verified.png',
                                      width: 14.0,
                                      height: 14.0,
                                    ),
                                    const SizedBox(width: 5.0),
                                    const Text(
                                      'Verified',
                                      style: TextStyle(fontSize: 14.0),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          const SizedBox(height: 16),
                          if (_showEmailOtp)
                            Pinput(
                              length: 6,
                              defaultPinTheme: defaultPinTheme,
                              onChanged: (String? value) {
                                otp = value;
                              },
                              showCursor: true,
                              onCompleted: (pin) {
                                otp = pin;
                              },
                            ),
                          if (_showEmailOtp)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                            Align(
                              alignment: Alignment.centerRight,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: _verifyData,
                                child: const Text('Verify OTP'),
                              ),
                            ),
                          const  SizedBox(width: 5,),
                           Align(
                              alignment: Alignment.centerRight,
                          child:ElevatedButton(
                            onPressed: _isResendEnabled ? _sendOtp : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF313256),
                              foregroundColor: Colors.white,
                              minimumSize: Size(100, 50),
                            ),
                            child: Text(
                              _isResendEnabled
                                  ? 'Resend OTP'
                                  : 'Resend in $_timerDuration s',
                            ),
                          ),
                           ),
                            ]
                          )
                        ],
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
