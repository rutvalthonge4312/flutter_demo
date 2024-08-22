import 'package:wrms.app/services/api_exception.dart';
import 'package:wrms.app/services/api_service.dart';
import 'package:wrms.app/types/send_otp.dart';
import 'package:wrms.app/types/verify_request.dart';


class OtpService {
  static Future<String> veirfyOtp(
    final String value,
    final String otp,
    final String type,
  ) async {
    try{
      final request =VerifyRequest(value: value,otp: otp,type: type);
      print(request);
      if(type=="phone"){
        final responseJson =await ApiService.post('/user/request-user/confirm_phone_ver/', request.toJson());
        return responseJson['message'];
      }
      else{
        final responseJson =await ApiService.post('/user/request-user/confirm-email/', request.toJson());
        return responseJson['message'];
      }
    }
     on ApiException catch (e) {
      throw (e.message);
    }
    catch(e){
      print("Error Occourd At Verify Otp");
      return 'Error Occourd At Verify Otp';
    }
  }

  static Future<String> sendOtp(
    final String value,
    final String type,
  ) async {
    try{
      final request =SendOtp(value: value,type: type);
      if(type=='phone'){
        final responseJson =await ApiService.post('/user/request-user/verify_phone', request.toJson());
        return responseJson['message'];
      }
      else if(type=='phone_number'){
        final responseJson =await ApiService.post('/user/login-using-otp-send/', request.toJson());
        return responseJson['message'];
      }else if(type=='forgot_password_otp'){
        final responseJson =await ApiService.post('/user/password_reset/', request.toJson());
        return responseJson['message'];
      }
      else{
        final responseJson =await ApiService.post('/user/request-user/verify-email', request.toJson());
        return responseJson['message'];
      }
    }
     on ApiException catch (e) {
      throw (e.message);
    }
    catch(e){
      print(e);
      print("Error Occourded while sending Otp");
      return 'Error Occourded while sending Otp';
    }
  } 
}
