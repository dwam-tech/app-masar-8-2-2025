import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

class StrapiService {
  static const String baseUrl = 'http://192.168.1.28:1337';

  /// API token with full privileges used for pre-account actions.
  static const String adminApiToken =
      '93474d3881c0274f78c97c281d3a178cfbb139fe90794f42f4ae45bf7aae5f6f0277050f1e27dcc841a35fe14fb14a9fc6ce35a4528fa0738767a6f5233cdaecf2c23b088cdb891316218a6af07a8cafb2b57f4cbdcc9e18bec5b959537b40e91541df94696c7183ebf30981ae209a78b27c2f55d283064cca8097ab774b2c2b';

  /// Uploads a file to Strapi and returns the media ID when successful.
  ///
  /// If no [token] is provided, the [adminApiToken] is used.
  Future<int?> uploadMedia(String filePath, {String? token}) async {
    final authToken = token ?? adminApiToken;
    final uri = Uri.parse('$baseUrl/api/upload');
    final request = http.MultipartRequest('POST', uri);
    request.headers['Authorization'] = 'Bearer $authToken';

    final mimeType = lookupMimeType(filePath);
    final file = await http.MultipartFile.fromPath(
      'files',
      filePath,
      contentType: mimeType != null ? MediaType.parse(mimeType) : null,
    );
    request.files.add(file);
    final response = await request.send();
    final responseBody = await response.stream.bytesToString();
    // Log the response from Strapi for debugging purposes
    print('Upload response: ${response.statusCode} - $responseBody');
    if (response.statusCode == 200) {
      final data = jsonDecode(responseBody);
      if (data is List && data.isNotEmpty) {
        return data[0]['id'] as int?;
      }
    }
    return null;
  }
}
