import 'package:wrms.app/services/api_exception.dart';
import 'package:wrms.app/services/api_service.dart';
import 'package:wrms.app/types/station_list_response.dart';

class StationService {
  static Future<String> handleChangeStation(
    final String stationName,
    final String token,
  ) async {
    try {
      final request = {
        'token': token,
      };
      final responseJson =
          await ApiService.get('/user/change_station/$stationName', request);
      return responseJson['message'];
    } on ApiException catch (e) {
      throw (e.message);
    } catch (e) {
      print(e);
      return ("Error Occourded Changing User Status");
    }
  }

  static Future<String> changedAccessStation(
    final String stationName,
    final String token,
  ) async {
    try {
      final request = {
        'token': token,
      };
      final responseJson =
          await ApiService.get('/user/change_accessed_station/$stationName', request);
      return responseJson['message'];
    } on ApiException catch (e) {
      throw (e.message);
    } catch (e) {
      print(e);
      return ("Error Occourded Changing User Status");
    }
  }

  static Future<List<StationResponse>?> fetchAllStations(
    final String token,
  ) async {
    try {
      final request = {
        'token': token,
      };
      final responseJson =
          await ApiService.get('/station/stationslists/', request);
        final List<dynamic> stationsJson = responseJson;

        return stationsJson
            .map((station) => StationResponse.fromJson(station))
            .toList();
     
    } on ApiException catch (e) {
      throw (e.message);
    } catch (e) {
      print(e);
      return [];
    }
  }
}
