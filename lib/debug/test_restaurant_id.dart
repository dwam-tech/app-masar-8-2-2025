import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class TestRestaurantIdScreen extends StatefulWidget {
  @override
  _TestRestaurantIdScreenState createState() => _TestRestaurantIdScreenState();
}

class _TestRestaurantIdScreenState extends State<TestRestaurantIdScreen> {
  final AuthService _authService = AuthService();
  String _debugInfo = 'جاري التحقق...';

  @override
  void initState() {
    super.initState();
    _checkRestaurantId();
  }

  Future<void> _checkRestaurantId() async {
    try {
      // جلب بيانات المستخدم
      final userData = await _authService.getUserData();
      final token = await _authService.getToken();
      final realEstateId = await _authService.getRealEstateId();
      final restaurantId = await _authService.getRestaurantId();

      setState(() {
        _debugInfo = '''
=== معلومات التشخيص ===

التوكن: ${token != null ? 'موجود' : 'غير موجود'}

نوع المستخدم: ${userData?['user_type'] ?? 'غير محدد'}

Real Estate ID: $realEstateId

Restaurant ID: $restaurantId

بيانات المطعم في userData:
${userData?['restaurant_detail'] != null ? 'موجودة' : 'غير موجودة'}

ID المطعم من userData: ${userData?['restaurant_detail']?['id']}

بيانات العقار في userData:
${userData?['real_estate'] != null ? 'موجودة' : 'غير موجودة'}

ID العقار من userData: ${userData?['real_estate']?['id']}

=== تشخيص المشكلة ===
${_getDiagnosis(realEstateId, restaurantId, userData)}
        ''';
      });
    } catch (e) {
      setState(() {
        _debugInfo = 'خطأ في التحقق: $e';
      });
    }
  }

  String _getDiagnosis(int? realEstateId, int? restaurantId, Map<String, dynamic>? userData) {
    if (userData == null) {
      return '❌ المستخدم غير مسجل الدخول';
    }

    final userType = userData['user_type'];
    if (userType != 'restaurant') {
      return '⚠️ نوع المستخدم ليس مطعم (النوع: $userType)';
    }

    if (realEstateId == null && restaurantId == null) {
      return '❌ لم يتم العثور على ID المطعم في التخزين المحلي';
    }

    if (realEstateId != null || restaurantId != null) {
      return '✅ تم العثور على ID المطعم بنجاح';
    }

    return '❓ حالة غير معروفة';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('اختبار ID المطعم'),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'نتائج الاختبار:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Text(
                    _debugInfo,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _checkRestaurantId,
                child: Text('إعادة الاختبار'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}