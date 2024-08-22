class CoachData {
  final Map<String, bool> imageDict;
  final Map<String, bool> videoDict;
  final Map<String, String> taskDict;
  final Map<String, CoachDetails> coachDict;

  CoachData({
    required this.imageDict,
    required this.taskDict,
    required this.coachDict,
    required this.videoDict,
  });

  factory CoachData.fromJson(Map<String, dynamic> json) {
    return CoachData(
      imageDict: Map<String, bool>.from(json['image_dict']),
      videoDict: Map<String, bool>.from(json['video_dict']),
      taskDict: Map<String, String>.from(json['task_dict']),
      coachDict: Map<String, CoachDetails>.from(json['coach_dict'].map((key, value) => MapEntry(key, CoachDetails.fromJson(value)))),
    );
  }
}

class CoachDetails {
  
  
  final int coachNumber;
  final String coachStatus;
 
  final String? userName;
  final String? createdBy;
  final String? updatedBy;

  CoachDetails({
   
   
    required this.coachNumber,
    required this.coachStatus,
  
    this.userName,
    this.createdBy,
    this.updatedBy,
  });

  factory CoachDetails.fromJson(Map<String, dynamic> json) {
    return CoachDetails( 
      coachNumber: json['coach_number'],
      coachStatus: json['coach_status'] as String,
      userName: json['user_name'],
      createdBy: json['created_by'],
      updatedBy: json['updated_by'],
    );
  }
}
