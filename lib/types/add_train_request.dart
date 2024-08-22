class AddTrainRequest {
  final String token;
  final String trainNumber;
  final String trainName;
   String ? coachCount;
   final String stationName;

  AddTrainRequest({required this.token, required this.trainNumber,required this.trainName,this.coachCount,required this.stationName});

  Map<String, dynamic> toJson() {
    return {
      'token':token,
      'train_no': trainNumber,
      'train_name': trainName,
      'coach_counts':coachCount,
      'stationName': stationName
    };
  }
}
