class VerifyDetails {
  final String trainNo;
  final String trainName;
  final int noOfCoaches;
  final String waterLevelStatus;

  VerifyDetails({
    required this.trainNo,
    required this.trainName,
    required this.noOfCoaches,
    required this.waterLevelStatus,
  });

  // Optionally add a factory method if you need to create `VerifyDetails` from JSON
  factory VerifyDetails.fromJson(Map<String, dynamic> json) {
    return VerifyDetails(
      trainNo: json['trainNo'],
      trainName: json['trainName'],
      noOfCoaches: json['noOfCoaches'],
      waterLevelStatus: json['waterLevelStatus'],
    );
  }
}
