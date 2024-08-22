
class AccessHanleResponse {
  final int id;
  final String userFName;
  final String userMName;
  final String userLName;
  final String userPassword;
  final String userEmail;
  final String userPhone;
  final String userType;
  final int userStation;
  final String userPosts;
  final bool approved;
  final bool seen;
  final String createdAt;
  final String createdBy;
  final String updatedAt;
  final String updatedBy;
  AccessHanleResponse({
    required this.id,
    required this.userFName,
    required this.userMName,
    required this.userLName,
    required this.userPassword,
    required this.userEmail,
    required this.userPhone,
    required this.userType,
    required this.userStation,
    required this.userPosts,
    required this.approved,
    required this.seen,
    required this.createdAt,
    required this.createdBy,
    required this.updatedAt,
    required this.updatedBy,
  });

  factory AccessHanleResponse.fromJson(Map<String, dynamic> json) {
    return AccessHanleResponse(
      id: json['id']  ?? 0,
      userFName: json['user_f_name'] ?? '',
      userMName: json['user_m_name'] ?? '',
      userLName: json['user_l_name'] ?? '',
      userPassword: json['user_password'] ?? '',
      userEmail: json['user_email'] ?? '',
      userPhone: json['user_phone'] ?? '',
      userType: json['user_type'] ?? '',
      userStation: json['user_station']   ?? 0,
      userPosts: json['user_posts'] ?? '',
      approved: json['approved'] ?? false,
      seen: json['seen'] ?? false,
      createdAt: json['created_at'] ?? '',
      createdBy: json['created_by'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      updatedBy: json['updated_by'] ?? '',

    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userFName': userFName,
      'userMName': userMName,
      'userLName': userLName,
      'userPassword': userPassword,
      'userEmail': userEmail,
      'userPhone': userPhone,
      'userType': userType,
      'userStation': userStation,
      'userPosts': userPosts,
      'approved': approved,
      'seen': seen,
      'createdAt': createdAt,
      'createdBy': createdBy,
      'updatedAt': updatedAt,
      'updatedBy': updatedBy,
    };
  }
}
