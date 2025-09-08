import 'dart:convert';
import 'package:http/http.dart' as http;

class AmadeusAuthService {
  static const String apiKey = 'ukRWDfBhtsFQEK1bTiHNg1spgXLIiDBC';
  static const String apiSecret = 'hwGvfvIXjCpTMYXA';
  String? _token;
  DateTime? _expiry;

  Future<String> getToken() async {
    if (_token != null && _expiry != null && DateTime.now().isBefore(_expiry!)) {
      return _token!;
    }
    final resp = await http.post(
      Uri.parse('https://test.api.amadeus.com/v1/security/oauth2/token'),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'grant_type': 'client_credentials',
        'client_id': apiKey,
        'client_secret': apiSecret,
      },
    );
    if (resp.statusCode != 200) throw Exception('Token error');
    final json = jsonDecode(resp.body);
    _token = json['access_token'];
    _expiry = DateTime.now().add(Duration(seconds: json['expires_in']));
    return _token!;
  }
}
