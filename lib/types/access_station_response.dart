import 'dart:convert';

class AccessStationResponse {
  final String stationName;
  final String from;
  final String to;
  final String status;

  AccessStationResponse({
    required this.stationName,
    required this.from,
    required this.to,
    required this.status,
  });

  factory AccessStationResponse.fromJson(Map<String, dynamic> json) {
    return AccessStationResponse(
      stationName: json['station_name'],
      from: json['from'],
      to: json['to'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'station_name': stationName,
      'from': from,
      'to': to,
      'status': status,
    };
  }
}