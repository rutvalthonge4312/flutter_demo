import 'package:wrms.app/models/index.dart';
import 'package:wrms.app/services/api_exception.dart';
import 'package:wrms.app/services/api_service.dart';
import 'package:wrms.app/types/profile_response.dart';
import 'package:wrms.app/types/request_profile.dart';


class ProfileService {
   String _token = '';

  ProfileService() {
    _getToken();
  }

  Future<void> _getToken() async {
    final userModel = UserModel();
    await userModel.loadUserData();
    _token = userModel.token;
  }
  
  static Future<profileResponse> getProfile(final String token) async {
    try {
      final responseJson = await ApiService.get('/user/profile/', {'token': token});
      return profileResponse.fromJson(responseJson);
    } on ApiException catch (e) {
      throw (e.message);
    } catch (e) {
      throw Exception('Error occurred while fetching profile');
    }
  }

  static Future<String> updateProfile(
    final String token,
    final RequestProfile updatedProfile,
  ) async {
    try {
      final responseJson = await ApiService.post(
        '/user/profile/edit-profile/',
        {'token': token, ...updatedProfile.toJson()},
      );
      return responseJson['message'];
    } on ApiException catch (e) {
      throw (e.message);
    } catch (e) {
      return 'Error occurred while updating profile';
    }
  }

  static Future<String> changePassword(final String token, final Map<String, dynamic> data) async {
    try {
      final responseJson = await ApiService.post(
        '/user/profile/edit-profile/change_password/',
        {'token': token, ...data},
      );
      return responseJson['message'];
    } on ApiException catch (e) {
      throw (e.message);
    } catch (e) {

      throw '$e';
      
    }
  }

  static Future<String> changePasswordOTP(final String token, final Map<String, dynamic> data) async {
    try {
      final responseJson = await ApiService.post(
        '/user/profile/edit-profile/change-password/enter-otp/',
        {'token': token, ...data},
      );
      return responseJson['message'];
    } on ApiException catch (e) {
      throw (e.message);
    } catch (e) {
      throw '$e';
    }
  }

  static Future<String> changePhone(final String token, final Map<String, dynamic> data) async {
    try {
      final responseJson = await ApiService.post(
        '/user/profile/edit-profile/change-phone/',
        {'token': token, ...data},
      );
      return responseJson['message'];
    } on ApiException catch (e) {
      throw (e.message);
    } catch (e) {
      throw '$e';
    }
  }

  static Future<String> confirmChangePhone(final String token, final Map<String, dynamic> data) async {
    try {
      final responseJson = await ApiService.post(
        '/user/profile/edit-profile/change-phone/conf-otp/',
        {'token': token, ...data},
      );
      return responseJson['message'];
    } on ApiException catch (e) {
      throw (e.message);
    } catch (e) {
      throw '$e';
    }
  }

  static Future<String> changeEmail(final String token, final Map<String, dynamic> data) async {
    try {
      final responseJson = await ApiService.post(
        '/user/profile/edit-profile/change-email/',
        {'token': token, ...data},
      );
      return responseJson['message'];
    } on ApiException catch (e) {
      throw (e.message);
    } catch (e) {
      throw '$e';
    }
  }

  static Future<String> changeEmailOTP(final String token, final Map<String, dynamic> data) async {
    try {
      final responseJson = await ApiService.post(
        '/user/profile/edit-profile/change-email/enter-otp/',
        {'token': token, ...data},
      );
      return responseJson['message'];
    } on ApiException catch (e) {
      throw (e.message);
    } catch (e) {
      return 'Error occurred while verifying email OTP';
    }
  }
}
