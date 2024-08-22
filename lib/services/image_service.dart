import 'package:wrms.app/services/api_exception.dart';
import 'package:wrms.app/services/api_service.dart';
import 'package:wrms.app/types/image_response.dart';


class ImageService {
  static Future<List<ImageResponse>> getImages(
    final String token,
    final String date,
    final int trainNumber,
    final int coachNumber,
  ) async {
    try{
      final responseJson = await ApiService.get(
        '/media/get/$date/$trainNumber/$coachNumber',
        {'token': token},
      );
      List<ImageResponse> images = List<ImageResponse>.from(
      responseJson.map((imageJson) => ImageResponse.fromJson(imageJson)),
    );
    return images;
    }
    on ApiException catch (e) {
      throw (e.message);
    }
    catch(e){
      print(e);
      return [];
    }
    
  }

  
}
