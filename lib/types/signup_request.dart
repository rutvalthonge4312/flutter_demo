class SignupRequest {
  final String fName;
  final String? mName;
  final String lName;
  final String email;
  final String phone;
  final String password;
  final String rePassword;
  final String userType;
  final String station;
  final String post;

  SignupRequest({
    required this.fName,
    required this.mName, // mName is now optional
    required this.lName,
    required this.email,
    required this.phone,
    required this.password,
    required this.rePassword,
    required this.userType,
    required this.station,
    required this.post,
  });

  Map<String, dynamic> toJson() {
    return {
      'f_name': fName,
    //'m_name': mName,
      if (mName != '') 'm_name': mName, // Only include mName if it's not null
      'l_name': lName,
      'email': email,
      'phone': phone,
      'password': password,
      're_password': rePassword,
      'user_type': userType,
      'station': station,
      'posts': post,
    };
  }
}
