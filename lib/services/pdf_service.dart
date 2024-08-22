import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:wrms.app/services/api_exception.dart';
import 'package:wrms.app/constants/index.dart';

class PdfService {
  static Future<Uint8List> downloadPdf(String token, String reportType, DateTime date, String trainNumber ,String withImages , String isMail,String isHq) async {
    String url;

    switch (reportType) {
      case 'daily':
        url = '/pdf/daily-pdf/';
        break;
      case 'weekly':
        url = '/pdf/weekly-pdf/';
        break;
      case 'monthly':
        url = '/pdf/monthly-pdf/';
        break;
      default:
        throw ApiException(400, 'Invalid report type');
    }

    final String queryString = '?date=${date.toIso8601String().split('T').first}&train_number=$trainNumber&with_images=$withImages&is_mail=$isMail&is_hq=$isHq';
    url += queryString;

    try {
      // Perform the HTTP GET request directly
      final response = await http.get(
        Uri.parse('${ApiConstant.baseUrl}$url'), 
        headers: {
          'Authorization': 'Bearer $token',
        },
      );


      if (response.statusCode == 200) {
        return response.bodyBytes; 
      } else {
        throw ApiException(response.statusCode, 'Failed to download PDF');
      }
    } catch (e) {
      print('Error occurred while downloading PDF: $e');
      throw ApiException(500, 'Error occurred while downloading PDF: $e');
    }
  }
}
