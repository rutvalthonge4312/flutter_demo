class profileResponse {
  User? user;
  List<String>? posts;
  String? role;
  String ? station;

  profileResponse({this.user, this.posts, this.role,this.station});

  profileResponse.fromJson(Map<String, dynamic> json) {
    user = json['user'] != null ? User.fromJson(json['user']) : null;
    posts = json['posts'] != null ? List<String>.from(json['posts']) : null;
    role = json['role'];
    station=json['station'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (user != null) {
      data['user'] = user!.toJson();
    }
    data['posts'] = posts;
    data['role'] = role;
    data['station']=station;
    return data;
  }
}

class User {
  int? id;
  String? username;
  String? email;
  String? userTypeName;
  String? firstName;
  String? middleName;
  String? lastName;
  String? phone;
  String? stationName;

  User({
    this.id,
    this.username,
    this.email,
    this.userTypeName,
    this.firstName,
    this.middleName,
    this.lastName,
    this.phone,
    this.stationName,
  });

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    username = json['username'];
    email = json['email'];
    userTypeName = json['user_type_name'];
    firstName = json['first_name'];
    middleName = json['middle_name'];
    lastName = json['last_name'];
    phone = json['phone_number'];
    stationName = json['station_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['id'] = id;
    data['username'] = username;
    data['email'] = email;
    data['user_type_name'] = userTypeName;
    data['first_name'] = firstName;
    data['middle_name'] = middleName;
    data['last_name'] = lastName;
    data['phone_number'] = phone;
    data['station_name'] = stationName;
    return data;
  }
}
