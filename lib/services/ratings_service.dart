import 'package:wrms.app/services/api_exception.dart';
import 'package:wrms.app/services/api_service.dart';
import 'package:wrms.app/types/ratings_request.dart';
import 'package:wrms.app/types/ratings_response.dart';
import 'package:wrms.app/types/comment_request.dart';
import 'package:wrms.app/types/comment_response.dart';
import 'package:wrms.app/types/water_status_request.dart';
import 'package:wrms.app/types/water_status_response.dart';

class RatingsService {
  static Future<String> addStatus(
    final String status,
    final String token,
    final String date,
    final int trainNumber,
    final int coachNumber,
  ) async {
    try {
      final request = RatingsRequest(
        fetchInfo: "",
        status: status,
        token: token,
      );
      print(request.toJson());
      final responseJson = await ApiService.post(
          '/task-status/task_status/add/$date/$trainNumber/$coachNumber', request.toJson());
      print(responseJson['message']);
      return responseJson['message'];
    }
    on ApiException catch (e) {
      throw (e.message);
    } 
    catch (e) {
      print("Error Occourd At Submiting Task Status");
      return 'Error Occourd At Submiting Task Status';
    }
  }

 static Future<TaskResponse?> getStatus(
  final String token,
  final String status,
  final String date,
  final int trainNumber,
  final int coachNumber,
) async {
  try {
    final request = RatingsRequest(fetchInfo: "fetchData", status: "", token: token);
    final responseJson = await ApiService.get('/task-status/task_status/get/$date/$trainNumber/$coachNumber', request.toJson());

    print("Response Data");
    print(responseJson);

    if (responseJson != null && responseJson is Map<String, dynamic>) {
      return TaskResponse.fromJson(responseJson);
    } else {
      throw Exception('Expected a JSON object in the response');
    }
  } on ApiException catch (e) {
    throw (e.message);
  } catch (e) {
    print("Error occurred while fetching status: $e");
    return null;
  }
}
static Future<String> addComment(
  final String text,
  final String token,
  final String date,
  final int trainNumber,
  final int coachNumber,
) async {
  try {
    final request = CommentRequest(text: text, token: token);
    final responseJson = await ApiService.post(
      '/comment/add/$date/$trainNumber/$coachNumber',
      request.toJson(),
    );
    return responseJson['message'];
  } on ApiException catch (e) {
    throw (e.message);
  } catch (e) {
    print("Error occurred while adding comment: $e");
    return 'Error occurred while adding comment';
  }
}

static Future<List<CommentResponse>> getComments(
  final String token,
  final String date,
  final int trainNumber,
  final int coachNumber,
) async {
  try {
    final request = CommentRequest(fetchInfo: "fetchData", token: token, text: '');
    final responseJson = await ApiService.get(
      '/comment/get/$date/$trainNumber/$coachNumber',
      request.toJson(),
    );

    if (responseJson is List) {
      return responseJson.map((item) => CommentResponse.fromJson(item)).toList();
    } else {
      throw Exception('Expected a list in the response');
    }
  } on ApiException catch (e) {
    throw (e.message);
  } catch (e) {
    print("Error occurred while fetching comments: $e");
    return [];
  }
}
static Future<String> addWaterStatus(
    final String coachStatus,
    final String token,
    final String date,
    final int trainNumber,
    final int coachNumber,
  ) async {
    try {
      final request = CoachStatusRequest(
        coachStatus: coachStatus,
        token: token,
      );
      final responseJson = await ApiService.post(
          '/coach-status/coach/add/$date/$trainNumber/$coachNumber', request.toJson());
      return responseJson['message'];
    } on ApiException catch (e) {
      throw (e.message);
    } catch (e) {
      print("Error occurred while adding coach status: $e");
      return 'Error occurred while adding coach status';
    }
  }

  static Future<List<CoachStatusResponse>> getWaterStatus(
    final String token,
    final String date,
    final int trainNumber,
    final int coachNumber,
  ) async {
    try {
      final responseJson = await ApiService.get(
          '/coach-status/coach/get/$date/$trainNumber/$coachNumber', {'token': token});
      
      if (responseJson is List) {
        return responseJson.map((item) => CoachStatusResponse.fromJson(item)).toList();
      } else {
        throw Exception('Expected a list in the response');
      }
    } on ApiException catch (e) {
      throw (e.message);
    } catch (e) {
      print("Error occurred while fetching coach status: $e");
      return [];
    }
  }

}