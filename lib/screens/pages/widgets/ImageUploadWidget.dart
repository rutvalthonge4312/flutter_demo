import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:open_app_settings/open_app_settings.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wrms.app/models/index.dart';


class ImageUploadWidget extends StatefulWidget {
  String? token;
  String date = "date";
  int trainNumber = 0;
  String trainName = '';
  int coachNumber = 0;
  String? fetchedTaskStatus;
  bool disableButton = false;
  String? latitude = "11";
  String? longitude = "12";
  final Function onSubmit;

  ImageUploadWidget({required this.onSubmit});

  @override
  _ImageUploadWidgetState createState() => _ImageUploadWidgetState();
}

class _ImageUploadWidgetState extends State<ImageUploadWidget> {
  @override
  void initState() {
    super.initState();
    requestStoragePermission();
  }

  XFile? selectedImage;
  void requestStoragePermission() async {
    try{
      if (!kIsWeb) {
        var status = await Permission.storage.status;
        if (!status.isGranted) {
          await Permission.storage.request();
        }
        else if(status.isDenied || status.isPermanentlyDenied){
          await Permission.storage.request();
        }
      } 
      
    }catch(error){
      _showErrorModal(context,"Error was:$error");
    }
  }
  void showPermissionDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title:const Text("Location Permission Required"),
        content:const Text(
            "This app needs camera and storage access to function properly. Please enable camera and storage permission in the app settings."),
        actions: <Widget>[
          TextButton(
            child:const Text("Open Settings"),
            onPressed: () {
              Navigator.of(context).pop();
              OpenAppSettings.openAppSettings();
            },
          ),
          TextButton(
            child:const Text("Cancel"),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
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
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
  Future<void> _pickImage(ImageSource source) async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image;
    if (kIsWeb) {
      if (source == ImageSource.camera) {
        image = await _picker.pickImage(source: ImageSource.camera);
      } else {
        image = await _picker.pickImage(source: ImageSource.gallery);
      }
    } else {
      if (source == ImageSource.camera) {
        image = await _picker.pickImage(source: ImageSource.camera);
      } else {
        image = await _picker.pickImage(source: ImageSource.gallery);
      }
    }
    if (image != null) {
      setState(() {
        selectedImage = image;
        widget.onSubmit(selectedImage);
      });
    }
  }
  void _showPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading:const Icon(Icons.photo_library),
                title:const Text('Photo Library'),
                onTap: () {
                  _pickImage(ImageSource.gallery);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading:const Icon(Icons.photo_camera),
                title:const Text('Camera'),
                onTap: () {
                  _pickImage(ImageSource.camera);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        if (selectedImage != null)
          Container(
            height: 300, 
            width: double.infinity,
            child: _buildImageWidget(),
          ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () => _showPicker(context),
          child:const Text('Pick Image'),
        ),
      ],
    );
  }

  Widget _buildImageWidget() {
    if (selectedImage == null) return const SizedBox(); 
    if (kIsWeb) {
      return Image.network(selectedImage!.path);
    } else {
      return Image.file(File(selectedImage!.path));
    }
  }
}
