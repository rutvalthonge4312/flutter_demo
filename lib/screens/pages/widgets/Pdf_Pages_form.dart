import 'dart:typed_data';
import 'dart:io' as io;
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import "package:universal_html/html.dart" as html;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:wrms.app/models/user_model.dart';
import 'package:wrms.app/screens/train_details/widgets/date_select.dart';
import 'package:wrms.app/services/pdf_service.dart';
import 'package:wrms.app/screens/train_details/widgets/drop_down_train.dart';
import 'package:wrms.app/services/train_details_service.dart';
import 'package:wrms.app/types/train_response.dart';
import 'package:wrms.app/widgets/error_modal.dart';
import 'package:wrms.app/widgets/loader.dart';
import 'package:wrms.app/widgets/loader_new.dart';

class PdfPagesForm extends StatefulWidget {
  
  final UserModel userModel;

 
  const PdfPagesForm({Key? key, required this.userModel}) : super(key: key);
  
  @override
  _PdfPagesFormState createState() => _PdfPagesFormState();
}

class _PdfPagesFormState extends State<PdfPagesForm> {
  DateTime _selectedDate = DateTime.now();
  final TextEditingController _trainNameController = TextEditingController();
    String ? trainNumber;
     String ? token;
  bool  _isLoading=true;
  bool _showModal=false;
  List<TrainResponse> _trains = [];
  String ? _trainName;
  @override
  void initState() {
    super.initState();
    token = widget.userModel.token;
    fetchAllTrains();
  }
  void _handleDateSelected(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
  }

  void fetchAllTrains() async {
    setState(() {
      _isLoading=true;
    });
    try{
      final getTrainResponse = await TrainDetailsService.getAllTrain(token!);
      setState(() {
        _trains = getTrainResponse;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
       showErrorModal(context, '$e', "Error", (){});
      });
    }
  }

  void _onTrainSelected(TrainResponse trainNo) {
    setState(() {
      trainNumber = (trainNo.trainNo).toString();
      _trainName = trainNo.trainName;
      _trainNameController.text = _trainName ?? ''; 
    });
  }
  

 Future<void> _downloadReport(String reportType, String withImages, String isMail,String isHq) async {
  loaderNew(context, "Loading Pdf , Please Wait!");
    try {
      final Uint8List pdfBytes = await PdfService.downloadPdf(
        token!, reportType, _selectedDate, trainNumber!, withImages, isMail,isHq,
      );
      final now = DateTime.now();
      final timeFormatted = DateFormat('HH-mm-ss').format(now);
      if (isMail == 'false') {
        final fileName = '${reportType}_report_${trainNumber}_${_selectedDate.toIso8601String().split('T').first}_at_$timeFormatted.pdf';
        if (kIsWeb) {
          final blob = html.Blob([pdfBytes], 'application/pdf');
          final url = html.Url.createObjectUrlFromBlob(blob);
          final anchor = html.AnchorElement(href: url)
            ..setAttribute('download', fileName)
            ..click();
          html.Url.revokeObjectUrl(url);
        } else {
          if (await _requestPermissions()) {
            // final directory = await _getDownloadDirectory();
            final path = '/storage/emulated/0/Download/$fileName';
            print(path);
            final file = io.File(path);
            await file.writeAsBytes(pdfBytes);
            print(file);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('PDF downloaded successfully to ${path}')),
            );
          }
        }
         Navigator.of(context).pop();
        showErrorModal(context, "$reportType Report downloaded successfully!", "Success", (){});
      } else {
         Navigator.of(context).pop();
        showErrorModal(context, "$reportType Report downloaded successfully!", "Success", (){});
      }
    } catch (e) {
       Navigator.of(context).pop();
      showErrorModal(context, "$e", "Error", (){});
    }
  }

  Future<bool> _requestPermissions() async {
    if (await Permission.storage.request().isGranted) {
      return true;
    } else {
      print("Storage permission denied");
      return false;
    }
  }

  Future<io.Directory> _getDownloadDirectory() async {
    if (io.Platform.isAndroid) {
      final directories = await getExternalStorageDirectories(type: StorageDirectory.documents);
      return directories!.first;
    } else {
      return await getApplicationDocumentsDirectory();
    }
  }

  Widget _buildButton(String label, VoidCallback onPressed, BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 600;
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        minimumSize: Size(isMobile ? double.infinity : 200, 60), 
        foregroundColor: Colors.white,
        backgroundColor: const Color(0xFF313256), 
        padding: const EdgeInsets.symmetric(horizontal: 60), 
      ),
      child: Text(label),
    );
  }
  

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final bool isMobile = constraints.maxWidth < 600;

          return isMobile
              ? _buildMobileLayout(context)
              : _buildDesktopLayout(context); 
        },
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
  return SingleChildScrollView(
    child: Padding(
    padding: const EdgeInsets.all(16.0),
    child: _isLoading 
    ? const Loader(message: "Loading...")
    : Column(
    mainAxisAlignment: MainAxisAlignment.start,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: <Widget>[
      const SizedBox(height: 20),
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
      const SizedBox(height: 20),
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                child: DateSelect(
                  onDateSelected: _handleDateSelected,
                  initialDate: _selectedDate,
                ),
              ),
            ),
            
          ],
        ),
      ),
      const SizedBox(height: 30),
      _buildButton('Download Daily Report', () => _downloadReport('daily', 'false','false','true'), context),
      const SizedBox(height: 25),
      _buildButton('Mail Daily Report (With Low Quality Images)', () => _downloadReport('daily', 'true','true','false'), context),
      const SizedBox(height: 25),
      _buildButton('Mail Daily Report (With High Quality Images)', () => _downloadReport('daily', 'true','true','true'), context),
      const SizedBox(height: 25),
      _buildButton('Download Weekly Report', () => _downloadReport('weekly', 'false','false','false'), context),
      const SizedBox(height: 25),
      _buildButton('Download Monthly Report', () => _downloadReport('monthly', 'false','false','false'), context),
      const SizedBox(height: 25),
      _buildButton('Mail Weekly Report', () => _downloadReport('weekly', 'false','true','false'), context),
      const SizedBox(height: 25),
      _buildButton('Mail Weekly Report (With Images)', () => _downloadReport('weekly', 'true','true','true'), context),
      const SizedBox(height: 25),
      _buildButton('Mail Monthly Report', () => _downloadReport('monthly', 'false', 'true','true'), context),
      const SizedBox(height: 25),
      _buildButton('Mail Monthly Report (With Images)', () => _downloadReport('monthly', 'true','true','true'), context),
    ],
    ),
    ),
  );
}

  Widget _buildDesktopLayout(BuildContext context) {
    return Container(
      width:400, 
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start, 
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
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
          const SizedBox(height: 20), 
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Container(
                    width: double.infinity,
                    child: DateSelect(
                      onDateSelected: _handleDateSelected,
                      initialDate: _selectedDate,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          _buildButton('Download Daily Report', () => _downloadReport('daily', 'false','false','true'), context),
          const SizedBox(height: 25),
          _buildButton('Mail Daily Report (With Low Quality Images)', () => _downloadReport('daily', 'true','true','false'), context),
          const SizedBox(height: 25),
          _buildButton('Mail Daily Report (With High Quality Images)', () => _downloadReport('daily', 'true','true','true'), context),
          const SizedBox(height: 25),
          _buildButton('Download Weekly Report', () => _downloadReport('weekly', 'false','true','true'), context),
          const SizedBox(height: 25),
          _buildButton('Mail Weekly Report', () => _downloadReport('weekly', 'false','true','true'), context),
          const SizedBox(height: 25),
          _buildButton('Mail Weekly Report (With Images)', () => _downloadReport('weekly', 'true','true','true'), context),
          const SizedBox(height: 25),
          _buildButton('Mail Monthly Report', () => _downloadReport('monthly', 'false', 'true','true'), context),
          const SizedBox(height: 25),
          _buildButton('Mail Monthly Report (With Images)', () => _downloadReport('monthly', 'true','true','true'), context),
        ],
      ),
    );
  }
}
