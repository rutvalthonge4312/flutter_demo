class TaskResponse {
  final int id;
  final String date;
  final int coachNumber;
  final String taskStatus;
  final String userName;
  final String createdAt;
  final String createdBy;
  final String updatedAt;
  final String updatedBy;
  final int train;
  final int user;

  TaskResponse({
    required this.id,
    required this.date,
    required this.coachNumber,
    required this.taskStatus,
    required this.userName,
    required this.createdAt,
    required this.createdBy,
    required this.updatedAt,
    required this.updatedBy,
    required this.train,
    required this.user,
  });

  factory TaskResponse.fromJson(Map<String, dynamic> json) {
    return TaskResponse(
      id: json['id'],
      date: json['date'],
      coachNumber: json['coach_number'],
      taskStatus: json['task_status'],
      userName: json['user_name'],
      createdAt: json['created_at'],
      createdBy: json['created_by'],
      updatedAt: json['updated_at'],
      updatedBy: json['updated_by'],
      train: json['train'],
      user: json['user'],
    );
  }
}
