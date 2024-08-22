class ApiException implements Exception {
  final int statusCode;
  final String message;

  ApiException(this.statusCode, this.message);

  ApiException.fromJson(int statusCode, Map<String, dynamic> json)
      : statusCode = statusCode,
        message = json['message'] ?? 'Unknown error occoured';

  @override
  String toString() {
    return message;
  }
}