import 'package:flutter/material.dart';
import 'package:wrms.app/types/video_response.dart';
import 'package:intl/intl.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

class VideoDetailPage extends StatefulWidget {
  final VideoResponse videoResponse;

  const VideoDetailPage({Key? key, required this.videoResponse}) : super(key: key);

  @override
  _UploadedVideoState createState() => _UploadedVideoState();
}

class _UploadedVideoState extends State<VideoDetailPage> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;

  @override
  void initState() {
    super.initState();
    _videoPlayerController = VideoPlayerController.network(widget.videoResponse.videoUrl ?? '');
    _videoPlayerController.initialize().then((_) {
      setState(() {});
      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController,
        aspectRatio: _videoPlayerController.value.aspectRatio,
        autoPlay: true,
        looping: true,
      );
    });
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    DateTime? createdAt = widget.videoResponse.createdAt != null
        ? DateTime.parse(widget.videoResponse.createdAt!)
        : null;
    String formattedDate = createdAt != null
        ? DateFormat('yyyy-MM-dd HH:mm:ss').format(createdAt)
        : 'Unknown';
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Detail'),
      ),
      body: Card(
        margin: const EdgeInsets.all(8),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: _chewieController != null &&
                        _chewieController!.videoPlayerController.value.isInitialized
                    ? AspectRatio(
                        aspectRatio: 16/9,
                        child: Chewie(
                          controller: _chewieController!,
                        ),
                      )
                    : Container(
                        width: double.infinity,
                        height: 200,
                        color: Colors.grey,
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
              ),
              const SizedBox(height: 8),
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
            ],
          ),
        ),
      ),
    );
  }
}
