import 'package:wrms.app/services/api_exception.dart';
import 'package:wrms.app/services/api_service.dart';
import 'package:wrms.app/types/access_handle_request.dart';
import 'package:wrms.app/types/access_hanle_response.dart';
import 'package:wrms.app/types/approve_deny_request.dart';
import 'package:wrms.app/types/index.dart';

class AccessService {
  static Future<List<AccessHanleResponse>> showRequests(
    final String token,
  ) async {
    //List<AccessHanleResponse> userArray = [];
    try {
      final request = AccessHandleRequest(token: token);
      final responseJson =
          await ApiService.get('/user/show_requested_user/', request.toJson());
      final List<dynamic> data = responseJson['user_requested'];
      final List<AccessHanleResponse> userArray = data.map((item) {
        return AccessHanleResponse.fromJson(item);
      }).toList();
      return userArray;
    } on ApiException catch (e) {
      throw (e.message);
    } catch (e) {
      print(e);
      print("Error Occourded while sending Otp");
      return [];
    }
  }

  static Future<String> approveUser(
    final String q,
    final String id,
    final String token,
  ) async {
    try {
      final request = ApproveDenyRequest(token: token, q: q);
      final responseJson =
          await ApiService.post('/user/user_requested/$id/', request.toJson());
      print(responseJson);
      return responseJson['message'];
    } on ApiException catch (e) {
      throw (e.message);
    } catch (e) {
      return '$e';
    }
  }

  static Future<String> requestLeave(
    final List<String> stationValue,
    final String startDate,
    final String endDate,
    final String token,
  ) async {
    try {
      final request = {
        'token': token,
        'station_value': stationValue,
        'start_date': startDate,
        'end_date': endDate,
      };
      final responseJson =
          await ApiService.post('/user/request/access_station', request);
      if (responseJson != null && responseJson['message'] != null) {
        return responseJson['message'][0];
      } else {
        throw Exception("Unexpected response: $responseJson");
      }
    } on ApiException catch (e) {
      throw (e.message);
    } catch (e) {
      print(e);
      throw '$e';
    }
  }

  static Future<List<AccessRequestedResponse>> getRequestedStationData(
    final String token,
  ) async {
    try {
      final request = {
        'token': token,
      };
      final responseJson =
          await ApiService.post('/user/new_station_access', request);
      final List<dynamic> data = responseJson;
      final List<AccessRequestedResponse> userArray = data.map((item) {
        return AccessRequestedResponse.fromJson(item);
      }).toList();
      return userArray;
    } on ApiException catch (e) {
      throw (e.message);
    } catch (e) {
      throw '$e';
    }
  }

   static Future<List<AccessStationResponse>> getAccessStationData(
    final String token,
  ) async {
    try {
      final request = {
        'token': token,
      };
      final responseJson =
          await ApiService.get('/user/new_station_access', request);
      final List<dynamic> data = responseJson['access_stations_data'];
      final List<AccessStationResponse> userArray = data.map((item) {
        return AccessStationResponse.fromJson(item);
      }).toList();
      return userArray;
    } on ApiException catch (e) {
      throw (e.message);
    } catch (e) {
      throw '$e';
    }
  }

  static Future<List<AccessRequestedResponse>> getAllRequestedUserData(
    final String token,
  ) async {
    try {
      final request = {
        'token': token,
      };
      final responseJson =
          await ApiService.get('/user/requested-access/', request);
      final List<dynamic> data = responseJson["user_requested"];
      final List<AccessRequestedResponse> userArray = data.map((item) {
        return AccessRequestedResponse.fromJson(item);
      }).toList();
      return userArray;
    } on ApiException catch (e) {
      throw (e.message);
    } catch (e) {
      throw '$e';
    }
  }

  static Future<String> handleLeaveStatus(
    final String status,
    final int userId,
    final String token,
  ) async {
    //access-requested/<int:user_id>/<str:access_requested>
    //APPROVE
    try {
      final request = {'q': status, 'token': token};
      final responseJson = await ApiService.post(
          '/user/access-requested/$userId/AccessStation', request);
      return responseJson['message'];
    } on ApiException catch (e) {
      throw (e.message);
    } catch (e) {
      throw e;
    }
  }
}
