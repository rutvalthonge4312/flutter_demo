class CommentRequest {
  final String text;
  final String token;
  final String fetchInfo;

  CommentRequest({required this.text, required this.token, this.fetchInfo = ""});

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'token': token,
      'fetchInfo': fetchInfo,
    };
  }
}
