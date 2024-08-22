
import 'package:wrms.app/services/api_exception.dart';
import 'package:wrms.app/services/api_service.dart';
import 'package:wrms.app/types/user_all_response.dart';



class UserServices {
  static Future<List<UserAllResponse>> showUsers(
    final String token,
  ) async {
    try{
        final request = {'token': token};
        final responseJson =await ApiService.get('/user/enable_disable_user/', request);
        final List<dynamic> data = responseJson['users'];
        final List<UserAllResponse> userArray = data.map((item) {
          return UserAllResponse.fromJson(item);
        }).toList();
        return userArray; 
    }
    on ApiException catch (e) {
      throw (e.message);
    }
    catch(e){
      print(e);
      print("Error Occourded while sending Otp");
      return [];
    }
  }

  static Future<String> handleUserStatus(
    final String status,
    final String username,
    final String token,
  ) async {

    try{
        final request = {'status': status,'username':username,'token':token};
        final responseJson =await ApiService.post('/user/enable_disable_user/', request);
        print(responseJson);
        return  responseJson['message'];
      }
    on ApiException catch (e) {
      throw (e.message);
    }
    catch(e){
      print(e);
      return("Error Occourded Changing User Status");
    }
  }

  static Future<String> handleChangeStation(
    final String stationName,
    final String token,
  ) async {
    try{
        final request = {'token': token,};
        final responseJson =await ApiService.post('user/change_station/$stationName/',request);
        return  responseJson['message'];
      }
    on ApiException catch (e) {
      throw (e.message);
    }
    catch(e){
      print(e);
      return("Error Occourded Changing User Status");
    }
  }

  
}