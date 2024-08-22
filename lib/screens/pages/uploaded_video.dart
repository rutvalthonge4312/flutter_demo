import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wrms.app/models/index.dart';
import 'package:wrms.app/services/video_service.dart';
import 'package:wrms.app/types/video_response.dart';
import 'video_detail_page.dart'; 
import 'package:intl/intl.dart'; 
import 'package:video_player/video_player.dart';

class UploadedVideo extends StatefulWidget {
  final VideoResponse videoResponse;
   final VoidCallback onDelete;

  const UploadedVideo({Key? key, required this.videoResponse,required this.onDelete,}) : super(key: key);

  @override
  _UploadedVideoState createState() => _UploadedVideoState();
}

class _UploadedVideoState extends State<UploadedVideo> {
  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;
  bool _isVideoDeleteLoading=false;
  String ? token;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.videoResponse.videoUrl ?? '');
    _initializeVideoPlayerFuture = _controller.initialize();
    _controller.setLooping(true);
     final userModel = Provider.of<UserModel>(context, listen: false);
    token = userModel.token;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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

  void deleteVideo()async{
    try{
      setState(() {
        _isVideoDeleteLoading=true;
      });
      final responseData=await VideoService.deleteVideos(token!,widget.videoResponse.id,);
      _showErrorModalNew(responseData.toString(),"Success");
       widget.onDelete(); 
    }catch(error){
      print(error);
    }
    finally{
      setState(() {
        _isVideoDeleteLoading=false;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    DateTime? createdAt = widget.videoResponse.createdAt != null
        ? DateTime.parse(widget.videoResponse.createdAt)
        : null;
    DateTime localDateTime = createdAt!.toLocal();
    String formattedDate = createdAt != null
        ?  DateFormat('yyyy-MM-dd - kk:mm:ss').format(localDateTime)
        : 'Unknown';
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VideoDetailPage(videoResponse: widget.videoResponse),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: FutureBuilder(
                future: _initializeVideoPlayerFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return AspectRatio(
                      aspectRatio: 16/9,
                      child: VideoPlayer(_controller),
                    );
                  } else {
                    return Container(
                      width: double.infinity,
                      height: 100,
                      color: Colors.grey,
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                },
              ),
            ),
            // const SizedBox(height: 8),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.center,
            //   children: [
            //     IconButton(
            //       icon: Icon(
            //         _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
            //       ),
            //       onPressed: () {
            //         setState(() {
            //           _controller.value.isPlaying ? _controller.pause() : _controller.play();
            //         });
            //       },
            //     ),
            //   ],
            // ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Uploaded at: $formattedDate',
                    style: const TextStyle(fontSize: 14),
                  ),
                  Text(
                    'Uploaded by: ${widget.videoResponse.createdBy ?? 'Unknown'}',
                    style: const TextStyle(fontSize: 14),
                  ),
                  Text(
                    'Latitude: ${widget.videoResponse.latitude ?? 'Unknown'}',
                    style: const TextStyle(fontSize: 14),
                  ),
                  Text(
                    'Longitude: ${widget.videoResponse.longitude ?? 'Unknown'}',
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
             Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed:deleteVideo,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:  const Color.fromARGB(255, 157, 44, 36),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                   
                  ),
                  child: _isVideoDeleteLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Delete'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
