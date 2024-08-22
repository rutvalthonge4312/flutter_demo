class TrainDetail {
  final String trainNo;
  final String trainName;
  final int numberOfCoaches;
  final Map<String, int> waterLevels; 

  TrainDetail({
    required this.trainNo,
    required this.trainName,
    required this.numberOfCoaches,
    required this.waterLevels,
  });

}
