import 'package:wrms.app/services/api_exception.dart';
import 'package:wrms.app/services/api_service.dart';
import 'package:wrms.app/types/video_response.dart';


class VideoService {
  static Future<List<VideoResponse>> getVideos(
    final String token,
    final String date,
    final int trainNumber,
    final int coachNumber,
  ) async {
    try{
      final responseJson = await ApiService.get(
        '/media/video/get/$date/$trainNumber/$coachNumber/',
        {'token': token,},
      );
      List<VideoResponse> videos = List<VideoResponse>.from(
      responseJson.map((videoJson) => VideoResponse.fromJson(videoJson)),
    );
    return videos;
    }
    on ApiException catch (e) {
      throw (e.message);
    }
    catch(e){
      print(e);
      return [];
    }
    
  }

  static Future<String> deleteVideos(
    final String token,
    final int id,
  ) async {
    try{
      final responseJson = await ApiService.delete(
        '/media/video/delete/$id',
        {'token': token,},
      );
      return responseJson['message'];
      //return responseJson['message'];
    }
    on ApiException catch (e) {
      throw (e.message);
    }
    catch(e){
      print(e);
      return "Unknown Error Happned!";
    }
    
  }

  
}
