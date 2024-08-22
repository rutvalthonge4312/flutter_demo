class PdfResponse {
  final List<int> data;
  final String fileName;

  PdfResponse({required this.data, required this.fileName});

  factory PdfResponse.fromJson(Map<String, dynamic> json) {
    return PdfResponse(
      data: List<int>.from(json['data']),
      fileName: json['file_name'],
    );
  }
}
