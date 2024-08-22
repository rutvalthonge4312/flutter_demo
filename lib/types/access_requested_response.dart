import 'dart:convert';

class AccessRequestedResponse {
  final int id;
  final String userFName;
  final String? userMName;
  final String userLName;
  final String userEmail;
  final String userPhone;
  final String userType;
  final String userStation;
  final String accessRequested;
  final List<String> forStation;
  final String fromForStation;
  final String toForStation;
  final bool approved;
  final bool seen;
  final String createdAt;
  final String createdBy;
  final String updatedAt;
  final String updatedBy;

  AccessRequestedResponse({
    required this.id,
    required this.userFName,
    this.userMName,
    required this.userLName,
    required this.userEmail,
    required this.userPhone,
    required this.userType,
    required this.userStation,
    required this.accessRequested,
    required this.forStation,
    required this.fromForStation,
    required this.toForStation,
    required this.approved,
    required this.seen,
    required this.createdAt,
    required this.createdBy,
    required this.updatedAt,
    required this.updatedBy,
  });

  factory AccessRequestedResponse.fromJson(Map<String, dynamic> json) {
    List<String> forStation;
    forStation=(json['for_station']).split(',');


    return AccessRequestedResponse(
      id: json['id'],
      userFName: json['user_f_name'],
      userMName: json['user_m_name'],
      userLName: json['user_l_name'],
      userEmail: json['user_email'],
      userPhone: json['user_phone'],
      userType: json['user_type'],
      userStation: json['user_station'],
      accessRequested: json['access_requested'],
      forStation: forStation,
      fromForStation: json['from_for_station'],
      toForStation: json['to_for_station'],
      approved: json['approved'],
      seen: json['seen'],
      createdAt: json['created_at'],
      createdBy: json['created_by'],
      updatedAt: json['updated_at'],
      updatedBy: json['updated_by'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_f_name': userFName,
      'user_m_name': userMName,
      'user_l_name': userLName,
      'user_email': userEmail,
      'user_phone': userPhone,
      'user_type': userType,
      'user_station': userStation,
      'access_requested': accessRequested,
      'for_station': jsonEncode(forStation),
      'from_for_station': fromForStation,
      'to_for_station': toForStation,
      'approved': approved,
      'seen': seen,
      'created_at': createdAt,
      'created_by': createdBy,
      'updated_at': updatedAt,
      'updated_by': updatedBy,
    };
  }
}
