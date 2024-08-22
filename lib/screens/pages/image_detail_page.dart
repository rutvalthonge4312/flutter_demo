import 'dart:typed_data';
import 'dart:io' as io;
import "package:universal_html/html.dart" as html;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wrms.app/types/image_response.dart';
import 'package:intl/intl.dart'; 
import 'package:http/http.dart' as http;

class ImageDetailPage extends StatelessWidget {
  final ImageResponse imageResponse;

  const ImageDetailPage({Key? key, required this.imageResponse}) : super(key: key);

  Future<void> _downloadImage(BuildContext context) async {
    if (imageResponse.imageUrl == null || imageResponse.imageUrl!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No image URL provided')),
      );
      return;
    }

    try {
      // Get the image data
      final response = await http.get(Uri.parse(imageResponse.imageUrl!));
      if (response.statusCode == 200) {
        final bytes = response.bodyBytes;

        if (kIsWeb) {
          // Web specific code
          final blob = html.Blob([bytes]);
          final url = html.Url.createObjectUrlFromBlob(blob);
          final anchor = html.AnchorElement(href: url)
            ..setAttribute("download", "image.jpg")
            ..click();
          html.Url.revokeObjectUrl(url);
        } else {
          // Mobile specific code
          final directory = await getApplicationDocumentsDirectory();
          final path = '${directory.path}/image.jpg';

          final file = io.File(path);
          await file.writeAsBytes(bytes);

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Image downloaded successfully!')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to download image')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to download image: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    DateTime? createdAt = imageResponse.createdAt != null ? DateTime.parse(imageResponse.createdAt!) : null;
    String formattedDate = createdAt != null ? DateFormat('dd-MM-yyyy').format(createdAt) : 'Unknown';
    //DateFormat('yyyy-MM-dd HH:mm:ss').format(createdAt)
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Detail'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Image.network(
                imageResponse.imageUrl ?? '',
                width: double.infinity,
                fit: BoxFit.contain,
                errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                  return Container(
                    color: Colors.grey,
                    child: const Icon(Icons.error, color: Colors.red, size: 100),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
           Text(
              'Train: ${imageResponse.train}',
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              'Coach No: ${imageResponse.coachNumber}',
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              'Latitude: ${imageResponse.latitude}',
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              'Longitude: ${imageResponse.longitude}',
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              'Uploaded by: ${imageResponse.createdBy.isEmpty ? 'Unknown' : imageResponse.createdBy}',
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              'Uploaded at: $formattedDate',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _downloadImage(context),
              child: const Text('Download Image'),
            ),
          ],
        ),
      ),
    );
  }
}
