class TrainResponse {
  final int trainNo;
  final String trainName;
  final int? coachCounts; // Make coachCounts nullable
  final String ? stationName;
  TrainResponse({required this.trainNo, required this.trainName, this.coachCounts,required this.stationName});

  factory TrainResponse.fromJson(Map<String, dynamic> json) {
    return TrainResponse(
      trainNo: json['train_no'],
      trainName: json['train_name'],
      coachCounts: json['coach_counts'] != null ? json['coach_counts'] as int : null,
      stationName: json['station_name']
    );
  }
}
