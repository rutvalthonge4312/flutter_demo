class StationResponse {
  final int id;
  final String stationName;
  final String stationZone;
  final int stationId;
  final String stationCategory;
  final bool isHq;
  final bool isChiSm;
  final String? parentStation;

  StationResponse({
    required this.id,
    required this.stationName,
    required this.stationZone,
    required this.stationId,
    required this.stationCategory,
    required this.isHq,
    required this.isChiSm,
    this.parentStation,
  });

  factory StationResponse.fromJson(Map<String, dynamic> json) {
    return StationResponse(
      id: json['id'],
      stationName: json['station_name'],
      stationZone: json['station_zone'],
      stationId: json['station_id'],
      stationCategory: json['station_category'],
      isHq: json['is_hq'],
      isChiSm: json['is_chi_sm'],
      parentStation: json['parent_station'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'station_name': stationName,
      'station_zone': stationZone,
      'station_id': stationId,
      'station_category': stationCategory,
      'is_hq': isHq,
      'is_chi_sm': isChiSm,
      'parent_station': parentStation,
    };
  }
}
