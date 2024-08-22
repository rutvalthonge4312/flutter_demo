class CommentResponse {
  final int id;
  final String date;
  final String text;
  final int coachNumber;
  final String userName;
  final String createdAt;
  final String createdBy;
  final String updatedAt;
  final String updatedBy;
  final int train;
  final int user;

  CommentResponse({
    required this.id,
    required this.date,
    required this.text,
    required this.coachNumber,
    required this.userName,
    required this.createdAt,
    required this.createdBy,
    required this.updatedAt,
    required this.updatedBy,
    required this.train,
    required this.user,
  });

  factory CommentResponse.fromJson(Map<String, dynamic> json) {
    return CommentResponse(
      id: json['id'],
      date: json['date'],
      text: json['text'],
      coachNumber: json['coach_number'],
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
