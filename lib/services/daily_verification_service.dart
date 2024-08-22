import 'package:wrms.app/services/api_service.dart';
import 'package:wrms.app/services/api_exception.dart';
import 'package:wrms.app/types/index.dart';
import 'package:wrms.app/types/verify_trains_response.dart';

class DailyVerificationService {
  static Future<String> sendOtp(String email, String token) async {
    try {
      final responseJson = await ApiService.post(
          '/daily_verify/verify_email/', {'email': email, 'token': token});
      final message = responseJson['message'];
      return message;
    } on ApiException catch (e) {
      print('Error sending OTP: $e');
      throw (e.message);
    }
  }

  static Future<String> verifyOtp(
      String email, String otp, String token) async {
    try {
      final responseJson = await ApiService.post('/daily_verify/confirm_email/',
          {'email': email, 'otp': otp, 'token': token});

      final message = responseJson['message'];
      if (message == null) {
        throw ApiException(400, 'No message returned from the server');
      }
      return message;
    } on ApiException catch (e) {
      print('Error verifying OTP: $e');
      throw (e.message);
    }
  }

  static Future<void> submitVerification(
      String token, String date, bool isVerified) async {
    try {
      await ApiService.post(
        '/daily_verify/verifications/',
        {
          'token': token,
          'verification_date': date,
          'is_verified': isVerified,
        },
      );
    } on ApiException catch (e) {
      print('Error submitting verification: $e');
      throw (e.message);
    }
  }

  static Future<VerifyDateResponse> isDayVerified(
      String token, String date,) async {
    try {
      final responseJson = await ApiService.get(
        '/daily_verify/verifications/$date/',
        {
          'token': token,
        },
      );
      // final  data = responseJson;
      // final List<VerifyDateResponse> dayVerificationArray = data.map((item) {
      //   return VerifyDateResponse.fromJson(item);
      // }).toList();
      return VerifyDateResponse.fromJson(responseJson);
    } on ApiException catch (e) {
      print('Error submitting verification: $e');
      throw (e.message);
    }
  }
  static Future<VerifiedTrainsResponse> trainForDate(
      String token, String date,int page) async {
    try {
      final responseJson = await ApiService.get(
        '/coach-status/verify-date-trains/$date/?page=$page',
        {
          'token': token,
        },
      );
      return VerifiedTrainsResponse.fromJson(responseJson);
    } on ApiException catch (e) {
      print('Error submitting verification: $e');
      throw (e.message);
    }
  }
}
