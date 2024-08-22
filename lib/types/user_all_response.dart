class UserAllResponse {
  final String username;
  final bool enabled;
  final String email;
  final String phone;
  final String role;
  final String station;

  UserAllResponse({
    required this.username,
    required this.enabled,
    required this.email,
    required this.phone,
    required this.role,
    required this.station,
  });

  factory UserAllResponse.fromJson(Map<String, dynamic> json) {
    return UserAllResponse(
      username: json['username'] ?? '',
      enabled: json['enabled'] ?? false,
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      role: json['role'] ?? '',
      station: json['station'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'enabled': enabled,
      'email': email,
      'phone': phone,
      'role': role,
      'station': station,
    };
  }
}
