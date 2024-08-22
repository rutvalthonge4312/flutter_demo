class RequestProfile {
  final String firstName;
  final String? middleName;
  final String lastName;
  final List<String> posts;

  RequestProfile({
    required this.firstName,
    this.middleName,
    required this.lastName,
    required this.posts,
  });

  Map<String, dynamic> toJson() {
    return {
      'fname': firstName,
      'mname': middleName,
      'lname': lastName,
      'posts': posts.join(', '),
    };
  }
}
