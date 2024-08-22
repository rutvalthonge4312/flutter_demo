import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wrms.app/models/index.dart';
import 'package:wrms.app/routes.dart';
import 'package:wrms.app/screens/pages/uploaded_image.dart';
import 'package:wrms.app/screens/pages/uploaded_video.dart';
import 'package:wrms.app/services/image_service.dart';
import 'package:wrms.app/services/index.dart';
import 'package:wrms.app/services/video_service.dart';
import 'package:wrms.app/types/image_response.dart';
import 'package:wrms.app/types/ratings_response.dart';
import 'package:wrms.app/types/video_response.dart';
import 'package:wrms.app/widgets/loader.dart';
import '../../constants/api_constant.dart';
import '../../utilities/Toast.dart';
import 'widgets/ImageUploadWidget.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'widgets/addComment.dart';
import 'widgets/water_level.dart';
import 'package:wrms.app/types/comment_response.dart';
import 'package:wrms.app/services/ratings_service.dart';
import 'package:wrms.app/types/water_status_response.dart';
import 'package:wrms.app/screens/train_details/widgets/VideoUploadWidget.dart';

class AddRating extends StatefulWidget {
  final UserModel userModel;

  const AddRating({Key? key, required this.userModel}) : super(key: key);

  @override
  _AddRatingState createState() => _AddRatingState();
}

class _AddRatingState extends State<AddRating> with RestorationMixin {
  final RestorableString _date = RestorableString('');
  final RestorableInt _trainNumber = RestorableInt(0);
  final RestorableString _trainName = RestorableString('');
  final RestorableInt _coachNumber = RestorableInt(0);

  String? fetchedTaskStatus;
  bool disableButton = false;

  String taskStatus = 'pending';

  String? token;
  String? latitude = '';
  String? longitude = '';

  bool _isImageLoading = false;
  bool _isSubmitFormLoading = false;
  bool _isPageLoading = true;
  bool _isVideoLoading = false;
  bool _showModal = false;
  String? errorMessage;

  List<ImageResponse>? uploadedImages;

  bool isLocationOn = false;
  XFile? selectedImage = null;
  bool isLoading = false;

  String? currentComment = '';
  String? commentCreatedAt;
  String? commentCreatedBy;
  String? commentUpdatedAt;
  String? commentUpdatedBy;
  String? waterStatus = 'na';
  bool isWaterStatusLoaded = false;
  List<VideoResponse> uploadedVideos = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      final userModel = Provider.of<UserModel>(context, listen: false);
      final Map<String, dynamic>? args =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
      if (args != null) {
        _date.value = args['date'] as String;
        _trainName.value = args['trainName'] as String;
        _trainNumber.value = int.parse(args['trainNumber'] as String);
        _coachNumber.value = int.parse(args['coachNumber'] as String);
        token = userModel.token;
        fetchData();
        fetchImages();
        fetchComments();
        fetchWaterStatus();
        getLatLong();
        fetchVideos();
      } else {
        _showErrorModal(context, "Please Select the Train Number and Coach");
        Future.delayed(const Duration(seconds: 2), () {
          Navigator.pushReplacementNamed(context, Routes.home);
        });
      }
    });
  }

  void handleVideoUpload(video) {
    setState(() {
      uploadedVideos.add(video);
    });
  }

  Future<void> fetchComments() async {
    try {
      final List<CommentResponse> commentResponse =
          await RatingsService.getComments(
        token!,
        _date.value,
        _trainNumber.value,
        _coachNumber.value,
      );
      if (commentResponse.isNotEmpty) {
        setState(() {
          currentComment = commentResponse.last.text;
          if (commentResponse.length > 1) {
            commentUpdatedAt = commentResponse.last.updatedAt;
            commentUpdatedBy = commentResponse.last.updatedBy;
            commentCreatedAt = null;
            commentCreatedBy = null;
          } else {
            commentCreatedAt = commentResponse.last.createdAt;
            commentCreatedBy = commentResponse.last.createdBy;
            commentUpdatedAt = null;
            commentUpdatedBy = null;
          }
        });
        print("Comments fetched successfully");
      } else {
        print("Failed to fetch comments: Response is empty");
      }
    } catch (e) {
      if (e is StateError && e.toString().contains('mounted')) {
        print('Widget disposed before operation completes');
      } else {
        print('Error fetching comments: $e');
      }
    }
  }

  Future<void> fetchWaterStatus() async {
    try {
      final List<CoachStatusResponse> waterStatusResponse =
          await RatingsService.getWaterStatus(
        token!,
        _date.value,
        _trainNumber.value,
        _coachNumber.value,
      );
      if (waterStatusResponse.isNotEmpty) {
        setState(() {
          waterStatus = waterStatusResponse[0].coachStatus;
          isWaterStatusLoaded = true;
        });
      } else {
        print("Failed to fetch water status: Response is empty");
        setState(() {
          isWaterStatusLoaded = true;
        });
      }
    } catch (e) {
      print('Error fetching water status: $e');
      setState(() {
        isWaterStatusLoaded = true;
      });
    }
  }

  void updateWaterStatus(WaterLevel level) async {
    try {
      String status = level.toString().split('.').last;
      await RatingsService.addWaterStatus(
        status,
        token!,
        _date.value,
        _trainNumber.value,
        _coachNumber.value,
      );
      setState(() {
        waterStatus = status;
      });
    } catch (e) {
      print('Error updating water status: $e');
    }
  }

  Future<Position?> _getCurrentPosition() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        await Geolocator.requestPermission();
      }
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        permission = await Geolocator.requestPermission();
      }
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      _showErrorModal(context, 'Please Enable the location service!');
      await Geolocator.requestPermission();
      return await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
    }
  }

  void submitForm(BuildContext context) async {
    try {
      setState(() {
        _isSubmitFormLoading = true;
      });
      _showLoader(context, "Submitting Coach Data...");
      if (selectedImage != null) {
        if (selectedImage != null &&
            token != null &&
            _date.value != null &&
            _trainNumber.value != null &&
            _coachNumber.value != null) {
          await _uploadFile(
            selectedImage!,
            token!,
            _date.value,
            _trainNumber.value,
            _coachNumber.value,
          );
          setState(() {
            selectedImage = null;
          });
        } else {
          ToastShow.showToast("Unable to Upload Image Data");
        }
      }
      if (currentComment != null && currentComment!.isNotEmpty) {
        await RatingsService.addComment(
          currentComment!,
          token!,
          _date.value,
          _trainNumber.value,
          _coachNumber.value,
        );
        setState(() {
          currentComment = '';
        });
      }

      await RatingsService.addStatus(
        taskStatus,
        token!,
        _date.value,
        _trainNumber.value,
        _coachNumber.value,
      );
      setState(() {
        _isSubmitFormLoading = false;
      });
      fetchData();
      fetchImages();
      fetchComments();
      fetchWaterStatus();
    } catch (e) {
      setState(() {
        _isSubmitFormLoading = false;
      });
      fetchData();
      fetchImages();
      fetchComments();
      fetchWaterStatus();
      if (e is StateError && e.toString().contains('mounted')) {
        print('Widget disposed before operation completes');
      } else {
        print('Task Submit Error: $e');
      }
    } finally {
      Navigator.of(context).pop(); 
    }
  }

  void _showErrorModal(BuildContext context, String errorMessage) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ErrorModal(
          message: errorMessage,
          onClose: () {
            setState(() {
              _showModal = false;
            });
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  void _showLoader(BuildContext context, String errorMessage) {
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
                Text(errorMessage, textAlign: TextAlign.center),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> fetchImages() async {
    try {
      setState(() {
        _isImageLoading = true;
      });
      final List<ImageResponse> getStatusResponse =
          await ImageService.getImages(
        token!,
        _date.value,
        _trainNumber.value,
        _coachNumber.value,
      );
      if (getStatusResponse.isNotEmpty) {
        setState(() {
          uploadedImages = getStatusResponse;
        });
        print("Images fetched successfully");
      } else {
        print("Failed to fetch images: Response is empty");
      }
      setState(() {
        _isImageLoading = false;
      });
    } catch (e) {
      setState(() {
        _isImageLoading = false;
      });
      if (e is StateError && e.toString().contains('mounted')) {
        print('Widget disposed before operation completes');
      } else {
        print('Error fetching images: $e');
      }
    }
  }

  Future<void> fetchVideos() async {
    try {
      print(_coachNumber.value);
      setState(() {
        _isVideoLoading = true;
        uploadedVideos = [];
      });
      final List<VideoResponse> getStatusResponse =
          await VideoService.getVideos(
        token!,
        (_date.value),
        _trainNumber.value,
        _coachNumber.value,
      );
      if (getStatusResponse.isNotEmpty) {
        setState(() {
          uploadedVideos = getStatusResponse;
        });
      } else {
        setState(() {
          uploadedVideos = [];
        });
      }
      setState(() {
        _isVideoLoading = false;
      });
    } catch (e) {
      setState(() {
        _isVideoLoading = false;
      });
      if (e is StateError && e.toString().contains('mounted')) {
        print('Widget disposed before operation completes');
      } else {
        print('Error fetching images: $e');
      }
    }
  }
  void _removeVideo(VideoResponse video) {
    setState(() {
      uploadedVideos.remove(video);
    });
  }

  Future<void> getLatLong() async {
    Position? position = await _getCurrentPosition();
    if (position != null) {
      latitude = position.latitude.toString();
      longitude = position.longitude.toString();

      isLocationOn = true;
    }
    //  if (position == null) {
    // // if(latitude == '' && longitude == ''){
    //    ToastShow.showToast('Please enable location to upload image');
    //    isLocationOn = false;
    //  }
  }

  Future<void> fetchData() async {
    try {
      final TaskResponse? ratingResponse = await RatingsService.getStatus(
        token!,
        taskStatus,
        _date.value,
        _trainNumber.value,
        _coachNumber.value,
      );

      if (ratingResponse != null) {
        setState(() {
          taskStatus = ratingResponse.taskStatus;
          _isPageLoading = false;
        });
        if (taskStatus == 'completed') {
          setState(() {
            disableButton = true;
          });
        }
      } else {
        setState(() {
          _isPageLoading = false;
        });
        print("Task Status Fetch Failed: Response is empty or invalid");
      }
    } catch (e) {
      setState(() {
        _isPageLoading = false;
      });
      print('Error fetching task status: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    //getLatLong();
    double availableSpace = MediaQuery.of(context).size.width * 0.8;
    double screenWidth = MediaQuery.of(context).size.width;
    double buttonWidth = screenWidth * 0.8;
    return Scaffold(
      body: Stack(
        children: [
          isLoading
              ? const Center(child: Loader())
              : SingleChildScrollView(
                  child: Center(
                    child: _isPageLoading
                        ? const Loader(
                            message: "Loading The Data...Please Wait",
                          )
                        : Column(
                            children: [
                              Container(
                                width: availableSpace,
                                margin: const EdgeInsets.all(20),
                                child: Card(
                                  margin: EdgeInsets.zero,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 20),
                                    child: Align(
                                      alignment: Alignment.topLeft,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Train No: ${_trainNumber.value}',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            'Train Name: ${_trainName.value}',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            'Date: ${_date.value}',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            'Coach: ${_coachNumber.value}',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              if (disableButton == false)
                                Container(
                                  width: availableSpace,
                                  margin: const EdgeInsets.all(20),
                                  child: Card(
                                    margin: EdgeInsets.zero,
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: CommentWidget(
                                        initialComment: currentComment,
                                        createdAt: commentCreatedAt,
                                        createdBy: commentCreatedBy,
                                        updatedAt: commentUpdatedAt,
                                        updatedBy: commentUpdatedBy,
                                        onCommentChanged: (comment) {
                                          setState(() {
                                            currentComment = comment;
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              Container(
                                width: availableSpace,
                                margin: const EdgeInsets.all(20),
                                child: Card(
                                  margin: EdgeInsets.zero,
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: ImageUploadWidget(
                                      onSubmit: (data) {
                                        setState(() {
                                          selectedImage = data;
                                        });
                                      },
                                    ),
                                    //  ImagePickFromCamAndGallery(),
                                  ),
                                ),
                              ),
                              Container(
                                width: availableSpace,
                                margin: const EdgeInsets.all(20),
                                child: Card(
                                  margin: EdgeInsets.zero,
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      children: [
                                        const Text(
                                          'Uploaded Images',
                                          style: TextStyle(
                                            decoration:
                                                TextDecoration.underline,
                                            fontSize: 18,
                                          ),
                                        ),
                                        Column(
                                          children: [
                                            if (_isImageLoading)
                                              const CircularProgressIndicator(
                                                  color: Colors.blueAccent),
                                            if (!_isImageLoading &&
                                                uploadedImages != null)
                                              ...uploadedImages!
                                                  .where((imageData) =>
                                                      imageData.imageUrl != "")
                                                  .map((imageData) {
                                                return UploadedImage(
                                                    imageResponse: imageData);
                                              }).toList(),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),

                              Container(
                                width: double.infinity,
                                margin: const EdgeInsets.all(20),
                                child: Card(
                                  margin: EdgeInsets.zero,
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: VideoUploadWidget(
                                      date: _date.value,
                                      trainNumber: (_trainNumber.value),
                                      coachNumber: _coachNumber.value,
                                      onSubmit: (video) {
                                        handleVideoUpload(video);
                                      },
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: double.infinity,
                                margin: const EdgeInsets.all(20),
                                child: Card(
                                  margin: EdgeInsets.zero,
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        const Center(
                                          child: const Text(
                                            'Uploaded Videos',
                                            style: TextStyle(
                                              decoration:
                                                  TextDecoration.underline,
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
                                              if (uploadedVideos != null)
                                                ...uploadedVideos
                                                    .where(
                                                  (videoData) =>
                                                      videoData.videoUrl !=
                                                          null &&
                                                      videoData.videoUrl != "",
                                                )
                                                    .map((videoData) {
                                                  return UploadedVideo(
                                                    onDelete: () => _removeVideo(videoData),
                                                    videoResponse: videoData,

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

                              isWaterStatusLoaded
                                  ? Container(
                                      width: availableSpace,
                                      margin: const EdgeInsets.all(20),
                                      child: Card(
                                        margin: EdgeInsets.zero,
                                        child: Padding(
                                          padding: const EdgeInsets.all(16.0),
                                          child: WaterLevelWidget(
                                            initialLevel: waterStatus,
                                            onLevelChanged: (data) {
                                              updateWaterStatus(data);
                                            },
                                          ),
                                        ),
                                      ),
                                    )
                                  : const CircularProgressIndicator(), // Show loader until water status is loaded
                              Container(
                                width: availableSpace,
                                margin: const EdgeInsets.all(20),
                                child: Card(
                                  margin: EdgeInsets.zero,
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Text('Task Status',
                                            style: TextStyle(fontSize: 16)),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12.0,
                                            vertical: 4.0,
                                          ),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                            border: Border.all(
                                              color:
                                                  Colors.grey, // Border color
                                              width: 1.0, // Border width
                                            ),
                                          ),
                                          child: DropdownButton<String>(
                                            value: taskStatus,
                                            onChanged: (String? newValue) {
                                              setState(() {
                                                taskStatus = newValue!;
                                              });
                                            },
                                            items: <String>[
                                              'pending',
                                              'completed'
                                            ].map<DropdownMenuItem<String>>(
                                                (String value) {
                                              return DropdownMenuItem<String>(
                                                value: value,
                                                child: Text(value),
                                              );
                                            }).toList(),
                                            underline:
                                                const SizedBox(), // Removing the default underline
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                margin:
                                    const EdgeInsets.symmetric(vertical: 30),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF313256),
                                    foregroundColor: Colors.white,
                                    fixedSize: Size(buttonWidth, 50),
                                  ),
                                  onPressed: disableButton
                                      ? null
                                      : () => {submitForm(context)},
                                  child: _isSubmitFormLoading
                                      ? const CircularProgressIndicator(
                                          color: Colors.white,)
                                      : Text(disableButton
                                          ? 'Task Completed'
                                          : 'Submit'),
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
          // ),
          Positioned(
            left: 0,
            top: MediaQuery.of(context).size.height * 0.20,
            child: SizedBox(
              width: 40,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    '/home',
                    arguments: {
                      'selectedTrainName': _trainName.value,
                      'selectedTrainNumber': _trainNumber.value.toString(),
                      'selectedCoach': _coachNumber.value.toString(),
                      'selectedDate': _date.value.toString(),
                    },
                  );
                },
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                 
                  padding:
                      const EdgeInsets.symmetric(vertical: 30, horizontal: 1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: const RotatedBox(
                  quarterTurns: 1,
                  child: Text(
                    'Home',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            top: MediaQuery.of(context).size.height * 0.4,
            child: SizedBox(
              width: 40,
              child: OutlinedButton(
                onPressed: (_coachNumber.value - 1) >= 1
                    ? () {
                        final args = {
                          'date': _date.value,
                          'trainName': _trainName.value,
                          'trainNumber': _trainNumber.value.toString(),
                          'coachNumber': (_coachNumber.value - 1).toString(),
                        };
                        Navigator.pushNamed(context, Routes.addRatings,
                            arguments: args);
                      }
                    : null,
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  
                  padding:
                      const EdgeInsets.symmetric(vertical: 30, horizontal: 1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: const RotatedBox(
                  quarterTurns: 1,
                  child: Text(
                    'Prev Coach',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            right: 0,
            top: MediaQuery.of(context).size.height * 0.4,
            child: SizedBox(
              width: 40,
              child: OutlinedButton(
                onPressed: (_coachNumber.value + 1) <= 24
                    ? () {
                        final args = {
                          'date': _date.value,
                          'trainName': _trainName.value,
                          'trainNumber': _trainNumber.value.toString(),
                          'coachNumber': (_coachNumber.value + 1).toString(),
                        };
                        Navigator.pushNamed(
                          context,
                          Routes.addRatings,
                          arguments: args,
                        );
                      }
                    : null,
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.brown, 
                  padding:
                      const EdgeInsets.symmetric(vertical: 30, horizontal: 1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: const RotatedBox(
                  quarterTurns: 3,
                  child: Text(
                    'Next Coach',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<dynamic> _uploadFile(XFile imageFile, String token, String date,
      int trainNumber, int coachNumber) async {
    try {
      Uint8List bytes = await imageFile.readAsBytes();
      String filename = imageFile.name;
      Position? position = await _getCurrentPosition();
      var uri = Uri.parse(
          '${ApiConstant.baseUrl}/media/add/$date/$trainNumber/$coachNumber');
      var request = http.MultipartRequest('POST', uri);

      request.headers['Authorization'] = 'Bearer $token';
      request.fields['latitude'] = position!.latitude.toString();
      request.fields['longitude'] = position!.longitude.toString();

      var multipartFile = http.MultipartFile(
        'file',
        http.ByteStream.fromBytes(bytes),
        bytes.length,
        filename: filename,
      );

      request.files.add(multipartFile);
      final response = await request.send();

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("Upload successful");
        ToastShow.showToast('Upload successful');
        var data = await response.stream.bytesToString();
        return jsonDecode(data);
      } else {
        print("Failed To Upload Image");
        ToastShow.showToast('Failed To Upload Image');
        return null;
      }
    } catch (e) {
      print(e);
      ToastShow.showToast('Failed To Upload Image');
    }
  }

  @override
  String get restorationId => 'addRatingState';

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(_date, 'date');
    registerForRestoration(_trainNumber, 'trainNumber');
    registerForRestoration(_trainName, 'trainName');
    registerForRestoration(_coachNumber, 'coachNumber');
  }
}
