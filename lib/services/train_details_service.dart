import 'package:wrms.app/services/api_exception.dart';
import 'package:wrms.app/services/api_service.dart';
import 'package:wrms.app/types/add_train_request.dart';
import 'package:wrms.app/types/all_coach_response.dart';
import 'dart:convert';

import 'package:wrms.app/types/train_response.dart';

class TrainDetailsService {
  static Future<List<TrainResponse>> getAllTrain(final String token) async {
    try {
      final responseJson = await ApiService.get('/train/get_all_station_train/', {'token': token});
      if (responseJson['Data'] is List) {
        return (responseJson['Data'] as List).map((train) => TrainResponse.fromJson(train)).toList();
      } else {
        throw Exception('Unexpected response format');
      }
    }
    on ApiException catch (e) {
      throw (e.message);
    }
     catch (e) {
      print(e);
      return [];
    }
  }
  static Future<String> updateTrainInformation(final String token,final String trainNumber,final String trainName,final String coachCounts,final String stationName) async {
    try {
      final payload={
        "token":token,
        "trainNumber":trainNumber,
        "trainName":trainName,
        "coachCounts":coachCounts,
        "stationName":stationName,
      };
      final responseJson = await ApiService.post('/train/update_train/', payload);
      return responseJson['message'];
    }
    on ApiException catch (e) {
      throw (e.message);
    }
     catch (e) {
      return "Unknown Error!";
    }
  }
  //delete_train/<int:train_no>/
  static Future<String> deleteTrain(final String token,final String trainNumber) async {
    try {
      final responseJson = await ApiService.delete('/train/delete_train/$trainNumber/', {"token":token,});
      return responseJson['message'];
    }
    on ApiException catch (e) {
      throw (e.message);
    }
     catch (e) {
      return "Unknown Error!";
    }
  }
  static Future<List<TrainResponse>> getTrainsWithoutStationFilter(final String token) async {
    try {
      final responseJson = await ApiService.get('/train/get_all_train/', {'token': token});
      if (responseJson['Data'] is List) {
        return (responseJson['Data'] as List).map((train) => TrainResponse.fromJson(train)).toList();
      } else {
        throw Exception('Unexpected response format');
      }
    }
    on ApiException catch (e) {
      throw (e.message);
    }
     catch (e) {
      return [];
    }
  }
  static Future<String> addNewTrain(final String token,final String trainNumber,final String trainName,final String coachCount,final String stationName) async {
    try {
      final payload=AddTrainRequest(token: token, trainNumber: trainNumber, trainName: trainName,coachCount:coachCount,stationName: stationName);
      final responseJson = await ApiService.post('/train/add_train/', payload.toJson());
      return responseJson['message'];
    }
    on ApiException catch (e) {
      throw (e.message);
    }
     catch (e) {
      return 'Error While Adding Train';
    }
  }
  static Future<String> fetchTrainDetails(final String token,final String trainNumber,final String date) async {
    try {
     
      final responseJson = await ApiService.get('/task-status/train_status/get/$date/$trainNumber',{'token':token});
      return responseJson['train_status'];
    }
    on ApiException catch (e) {
      throw (e.message);
    }
     catch (e) {
      print(e);
      return 'Error While Fetching Train';
    }
  }
  static Future<String> updateTrainDetails(final String token,final String trainNumber,final String date,final String status) async {
    try {
      final responseJson = await ApiService.post('/task-status/train_status/get/$date/$trainNumber',{'token':token,'status':status});
      return responseJson['message'];
    }
    on ApiException catch (e) {
      throw (e.message);
    }
     catch (e) {
      print(e);
      return 'Error While Fetching Train';
    }
  }
  static Future<Map<String, dynamic>> allCoachData(final String token,final String trainNumber,final String date) async {
    try {
      final responseJson = await ApiService.get('/coach-status/all-coach-statuses/$date/$trainNumber/',{"token":token});
      return responseJson['data'];
    }
    on ApiException catch (e) {
      throw (e.message);
    }
     catch (e) {
      print(e);
      return {};
    }
  }
}
