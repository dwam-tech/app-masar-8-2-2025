import 'package:flutter/material.dart';
import 'package:saba2v2/services/auth_service.dart'; // تأكد من صحة هذا المسار

class TermsScreen extends StatefulWidget {
  const TermsScreen({super.key});

  @override
  State<TermsScreen> createState() => _TermsScreenState();
}

class _TermsScreenState extends State<TermsScreen> {
  // --- متغيرات الحالة لإدارة البيانات ---
  final AuthService _authService = AuthService();
  List<Map<String, dynamic>> _termsList = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadTermsData();
  }

  /// دالة لجلب الإعدادات واستخراج بيانات "الشروط والأحكام"
  Future<void> _loadTermsData() async {
    try {
      final settings = await _authService.fetchSettings();

      // 1. البحث عن المفتاح الصحيح "termsAndConditions" والتأكد من أنه خريطة (Map)
      if (settings.containsKey('termsAndConditions') && settings['termsAndConditions'] is Map) {

        final termsDataMap = settings['termsAndConditions'] as Map<String, dynamic>;

        // 2. تحويل الخريطة (Map) إلى قائمة (List) بالهيكلية التي تتوقعها الواجهة
        // { "key": "value" }  ==>  [ { "title": "key", "body": "value" } ]
        final transformedList = termsDataMap.entries.map((entry) {
          return {
            "title": entry.key,
            "body": entry.value,
          };
        }).toList();

        if (mounted) {
          setState(() {
            _termsList = transformedList;
            _isLoading = false;
          });
        }
      } else {
        // إذا لم يتم العثور على المفتاح أو كان نوعه خاطئًا
        if (mounted) {
          setState(() {
            _errorMessage = "لم يتم العثور على محتوى 'الشروط والأحكام' في إعدادات الـ API.";
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }
  
  /// دالة لبناء الواجهة الرئيسية التي تحتوي على القائمة أو حالات التحميل/الخطأ
  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFFFC8700)));
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text('حدث خطأ: $_errorMessage', textAlign: TextAlign.center, style: const TextStyle(color: Colors.red)),
        ),
      );
    }
    
    if (_termsList.isEmpty) {
      return const Center(child: Text("لا توجد شروط وأحكام لعرضها حاليًا."));
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 700;
    final orangeColor = const Color(0xFFFC8700);

    return ListView.builder(
      padding: EdgeInsets.symmetric(
        vertical: 20,
        horizontal: isTablet ? screenWidth * 0.14 : 12,
      ),
      itemCount: _termsList.length,
      itemBuilder: (context, index) {
        final item = _termsList[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 7,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: orangeColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(7),
                      ),
                      width: 28,
                      height: 28,
                      child: Icon(Icons.sticky_note_2_outlined, color: orangeColor, size: 20),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        item['title'] ?? 'عنوان غير متوفر', // حماية ضد القيمة الفارغة
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  item['body'] ?? 'نص غير متوفر', // حماية ضد القيمة الفارغة
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 14,
                    height: 1.7,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F6F6),
        appBar: AppBar(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 1,
          title: const Text('الشروط والأحكام', style: TextStyle(fontWeight: FontWeight.bold)),
          centerTitle: true,
        ),
        body: _buildBody(),
      ),
    );
  }
}