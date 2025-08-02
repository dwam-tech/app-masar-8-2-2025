import 'package:flutter/material.dart';
import 'package:saba2v2/services/auth_service.dart'; // تأكد من صحة هذا المسار

class AboutApp extends StatefulWidget {
  const AboutApp({super.key});

  @override
  State<AboutApp> createState() => _AboutAppState();
}

class _AboutAppState extends State<AboutApp> {
  // --- متغيرات الحالة لإدارة البيانات ---
  final AuthService _authService = AuthService();
  // القائمة لا تزال كما هي لأننا سنحول البيانات إليها
  List<Map<String, dynamic>> _aboutList = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadAboutData();
  }

  /// دالة لجلب الإعدادات وتحويل بيانات "عن التطبيق" لتناسب الواجهة
  Future<void> _loadAboutData() async {
    try {
      final settings = await _authService.fetchSettings();

      // --- <<<< بداية التعديل >>>> ---

      // 1. البحث عن المفتاح الصحيح "aboutUs" والتأكد من أنه خريطة (Map)
      if (settings.containsKey('aboutUs') && settings['aboutUs'] is Map) {

        final aboutDataMap = settings['aboutUs'] as Map<String, dynamic>;

        // 2. تحويل الخريطة (Map) إلى قائمة (List) بالهيكلية التي تتوقعها الواجهة
        // { "key": "value" }  ==>  [ { "title": "key", "desc": "value" } ]
        final transformedList = aboutDataMap.entries.map((entry) {
          return {
            "title": entry.key,
            "desc": entry.value,
          };
        }).toList();

        if (mounted) {
          setState(() {
            _aboutList = transformedList;
            _isLoading = false;
          });
        }
      } else {
        // إذا لم يتم العثور على المفتاح أو كان نوعه خاطئًا
        if (mounted) {
          setState(() {
            _errorMessage = "لم يتم العثور على محتوى 'عن التطبيق' بالهيكلية الصحيحة في الـ API.";
            _isLoading = false;
          });
        }
      }
      // --- <<<< نهاية التعديل >>>> ---

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
    
    if (_aboutList.isEmpty) {
      return const Center(child: Text("لا يوجد محتوى لعرضه حاليًا."));
    }
    
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 700;

    return ListView.builder(
      padding: EdgeInsets.symmetric(
        vertical: 20,
        horizontal: isTablet ? screenWidth * 0.18 : 16,
      ),
      itemCount: _aboutList.length,
      itemBuilder: (context, index) {
        final item = _aboutList[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 18),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.folder_copy_rounded, color: Color(0xFFFC8700)),
                  const SizedBox(width: 8),
                  Text(
                    item['title'] ?? 'عنوان غير متوفر',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                item['desc'] ?? 'وصف غير متوفر',
                style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.7),
              ),
            ],
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
          title: const Text('عن التطبيق', style: TextStyle(fontWeight: FontWeight.bold)),
          centerTitle: true,
        ),
        body: _buildBody(),
      ),
    );
  }
}