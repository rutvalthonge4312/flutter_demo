class ImageResponse {
  final int id;
  final String imageUrl;
  final int coachNumber;
  final String date;
  final String userName;
  final String createdAt;
  final String createdBy;
  final String updatedAt;
  final String updatedBy;
  final String latitude;
  final String longitude;
  final int train;
  final int user;

  ImageResponse({
    required this.id,
    required this.imageUrl,
    required this.coachNumber,
    required this.date,
    required this.userName,
    required this.createdAt,
    required this.createdBy,
    required this.updatedAt,
    required this.updatedBy,
    required this.latitude,
    required this.longitude,
    required this.train,
    required this.user,
  });

  factory ImageResponse.fromJson(Map<String, dynamic> json) {
    return ImageResponse(
      id: json['id'] ?? 0,
      imageUrl: json['image_url'] ?? '',
      coachNumber: json['coach_number'] ?? 0,
      date: json['date'] ?? '',
      userName: json['user_name'] ?? '',
      createdAt: json['created_at'] ?? '',
      createdBy: json['created_by'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      updatedBy: json['updated_by'] ?? '',
      latitude: json['latitude'] ?? '',
      longitude: json['longitude'] ?? '',
      train: json['train'] ?? 0,
      user: json['user'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'image_url': imageUrl,
      'coach_number': coachNumber,
      'date': date,
      'user_name': userName,
      'created_at': createdAt,
      'created_by': createdBy,
      'updated_at': updatedAt,
      'updated_by': updatedBy,
      'latitude': latitude,
      'longitude': longitude,
      'train': train,
      'user': user,
    };
  }
}
