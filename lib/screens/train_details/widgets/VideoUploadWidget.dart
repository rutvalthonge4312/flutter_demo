import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';
import 'package:wrms.app/constants/api_constant.dart';
import 'package:wrms.app/models/index.dart';
import '../../../utilities/Toast.dart';
import 'package:http/http.dart' as http;


class VideoUploadWidget extends StatefulWidget {
  final Function(XFile) onSubmit;
  final int trainNumber;
  final String date;
  final int coachNumber;

  const VideoUploadWidget({required this.onSubmit, required this.date, required this.trainNumber,required this.coachNumber});
  
  @override
  _VideoUploadWidgetState createState() => _VideoUploadWidgetState();
}

class _VideoUploadWidgetState extends State<VideoUploadWidget> {
  XFile? selectedVideo;
  XFile? selectedShowVideo;
  VideoPlayerController? _videoController;
  bool showPickVideoButton = true;
  bool _isSubmitting = false; // Loading state for submit button
  String? token;
  

  @override
  void initState() {
    super.initState();
    final userModel = Provider.of<UserModel>(context, listen: false);
    token = userModel.token;
    requestStoragePermission();
  }

  void requestStoragePermission() async {
    if (!kIsWeb) {
      // PermissionStatus storageStatus = await Permission.storage.request();
      PermissionStatus cameraStatus = await Permission.camera.request();
      // if (!(storageStatus.isGranted && cameraStatus.isGranted)) {
      //   showPermissionDialog();
      // }
      if(cameraStatus.isPermanentlyDenied){
        showPermissionDialog();
      }
    }
  }

  Future<Position?> _getCurrentPosition() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        await Geolocator.requestPermission();
      }
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        permission = await Geolocator.requestPermission();
      }
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      await Geolocator.requestPermission();
      return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    }
  }

 Future<void> _uploadFile(XFile videoFile, String token, String date, int trainNumber) async {
  final prefs = await SharedPreferences.getInstance();
  int? videoUploadCount = prefs.getInt('videoUploadCount') ?? 0;

  try {
    await prefs.setBool('isVideoUpload', true);
    setState(() {
      _isSubmitting = false;
    });

    videoUploadCount++;
    await prefs.setInt('videoUploadCount', videoUploadCount);
    print('before: $videoUploadCount');

    Uint8List bytes = await videoFile.readAsBytes();
    String filename = videoFile.name;

    Position? position = await _getCurrentPosition();
    var uri = Uri.parse('${ApiConstant.baseUrl}/media/video/add/$date/$trainNumber/');
    var request = http.MultipartRequest('POST', uri);

    request.headers['Authorization'] = 'Bearer $token';
    request.fields['latitude'] = position!.latitude.toString();
    request.fields['longitude'] = position.longitude.toString();
    request.fields['coachNumber'] = widget.coachNumber.toString();

    var multipartFile = http.MultipartFile(
      'file',
      http.ByteStream.fromBytes(bytes),
      bytes.length,
      filename: filename,
    );

    request.files.add(multipartFile);
    final response = await request.send();
    String responseString = await response.stream.bytesToString();
    Map<String, dynamic> responseJson = jsonDecode(responseString);

    if (response.statusCode == 200 || response.statusCode == 201) {
      String message = responseJson['message'] ?? 'No message found';
      ToastShow.showToast(message);
    } else {
      ToastShow.showToast('Failed To Upload Video');
    }

  } catch (e) {
    print(e);
  } finally {
    int ? updatedVideoUploadCounter=await prefs.getInt('videoUploadCount');
    updatedVideoUploadCounter=updatedVideoUploadCounter!-1;
    await prefs.setInt('videoUploadCount', updatedVideoUploadCounter);
    print('after: $updatedVideoUploadCounter');
    if (updatedVideoUploadCounter == 0) {
      await prefs.setBool('isVideoUpload', false);
    }

    setState(() {
      selectedVideo = null;
    });
  }
}

  void showPermissionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title:const Text("Permission Required"),
          content:const Text("This app needs camera and storage access to function properly. Please enable permissions in the app settings."),
          actions: <Widget>[
            TextButton(
              child:const Text("Open Settings"),
              onPressed: () {
                Navigator.of(context).pop();
                openAppSettings();
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
  void showErrorDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title:const Text("Maximum Video Count Reached!"),
          content: const Text("This app allows a maximum of 3 videos to be uploaded. Please wait for existing video to upload!"),
          actions: <Widget>[
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

  Future<void> _pickVideo(ImageSource source) async {
    final ImagePicker _picker = ImagePicker();
    final XFile? video = await _picker.pickVideo(source: source);
    if (video != null) {
      setState(() {
        selectedVideo = video;
        showPickVideoButton = false;
      });
      _initializeVideoController(video);
    }
  }

  void _initializeVideoController(XFile video) {
    if (_videoController != null) {
      _videoController!.dispose();
    }

    if (kIsWeb) {
      _videoController = VideoPlayerController.network(video.path);
    } else {
      _videoController = VideoPlayerController.file(File(video.path));
    }

    _videoController!.initialize().then((_) {
      setState(() {});
      _videoController!.play();
    }).catchError((error) {
      print("Error initializing video player: $error");
    });
  }
  
  Future<void> _submitVideo() async {
    try{
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _isSubmitting = true;
      });
      selectedShowVideo=selectedVideo;
      setState(() {
        selectedVideo=null;
      });
      
      if (selectedVideo != null) {
        widget.onSubmit(selectedVideo!);
        setState(() {
          showPickVideoButton = true;
          selectedVideo = null;
          _videoController?.dispose();
          _videoController = null;
        });
      }
      else{
        setState(() {
          showPickVideoButton = true;
           _videoController?.dispose();
          _videoController = null;
        });
      }
      int? videoUploadCount = prefs.getInt('videoUploadCount')??0;
      print(videoUploadCount);
      if(videoUploadCount>=3){
        showErrorDialog();
        return;
      }
      else{
        await _uploadFile(selectedShowVideo!, token!, widget.date, widget.trainNumber);
      }
      
    }
    catch(error){
      setState(() {
        showPickVideoButton=true;
        selectedVideo = null;
          _videoController?.dispose();
          _videoController = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        if (selectedVideo != null)
          SizedBox(
            height: 300,
            width: double.infinity,
            child: _buildVideoWidget(),
          ),
        const SizedBox(height: 20),
        if (showPickVideoButton)
          ElevatedButton(
            onPressed: () => _showPicker(context),
            child:const Text('Pick Video'),
          ),
        if (selectedVideo != null)
          ElevatedButton(
            onPressed: _isSubmitting ? null : _submitVideo,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF313256),
              foregroundColor: Colors.white,
              minimumSize: const Size(200, 50),
            ),
            child: _isSubmitting
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text('Submit Video'),
          ),  
      ],
    );
  }

  Widget _buildVideoWidget() {
    if (selectedVideo == null || _videoController == null) return const SizedBox();
    return _videoController!.value.isInitialized
        ? AspectRatio(
            aspectRatio: 16/9,
            child: VideoPlayer(_videoController!),
          )
        : Container();
  }

  void _showPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading:const Icon(Icons.video_library),
                title:const Text('Video Library'),
                onTap: () {
                  _pickVideo(ImageSource.gallery);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading:const Icon(Icons.videocam),
                title:const Text('Camera'),
                onTap: () {
                  _pickVideo(ImageSource.camera);
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
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }
}

class VideoItem extends StatefulWidget {
  final XFile video;

  VideoItem({required this.video});

  @override
  _VideoItemState createState() => _VideoItemState();
}

class _VideoItemState extends State<VideoItem> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer();
  }

  void _initializeVideoPlayer() {
    if (kIsWeb) {
      _controller = VideoPlayerController.network(widget.video.path);
    } else {
      _controller = VideoPlayerController.file(File(widget.video.path));
    }
    _controller.initialize().then((_) {
      setState(() {});
    }).catchError((error) {
      print("Error initializing video player: $error");
    });
  }

  @override
  Widget build(BuildContext context) {
    return _controller.value.isInitialized
        ? AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: VideoPlayer(_controller),
          )
        : Container();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
