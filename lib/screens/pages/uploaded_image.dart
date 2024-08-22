import 'package:flutter/material.dart';
import 'package:wrms.app/types/image_response.dart';
import 'image_detail_page.dart'; 
import 'package:intl/intl.dart'; 

class UploadedImage extends StatelessWidget {
  final ImageResponse imageResponse;

  const UploadedImage({Key? key, required this.imageResponse}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    DateTime? createdAt =  DateTime.parse(imageResponse.createdAt);
    DateTime locatTime = createdAt.toLocal();
    String formattedDate = createdAt != null 
      ? DateFormat('yyyy-MM-dd - kk:mm:ss').format(locatTime) 
      : 'Unknown';
  //DateFormat('yyyy-MM-dd HH:mm:ss').format(createdAt)
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ImageDetailPage(imageResponse: imageResponse),
          ),
        );
      },
      child: Card(
        margin:const EdgeInsets.all(5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                imageResponse.imageUrl,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
                errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                  return Container(
                    width: double.infinity,
                    height: 200,
                    color: Colors.grey,
                    child:const Icon(Icons.error, color: Colors.red),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Uploaded at: $formattedDate',
              style:const TextStyle(fontSize: 14),
            ),
            Text(
              'Uploaded by: ${imageResponse.createdBy}',
              style:const TextStyle(fontSize: 14),
            ),
            Text(
              'Latitude: ${imageResponse.latitude }',
              style:const TextStyle(fontSize: 14),
            ),
            Text(
              'Longitude: ${imageResponse.longitude}',
              style:const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
