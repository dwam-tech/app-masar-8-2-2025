import 'package:flutter/material.dart';
import 'package:saba2v2/services/auth_service.dart'; // تأكد من صحة هذا المسار

class FAQScreen extends StatefulWidget {
  const FAQScreen({super.key});

  @override
  State<FAQScreen> createState() => _FAQScreenState();
}

class _FAQScreenState extends State<FAQScreen> {
  // --- متغيرات الحالة لإدارة البيانات ---
  final AuthService _authService = AuthService();
  List<Map<String, dynamic>> _faqList = [];
  bool _isLoading = true;
  String? _errorMessage;

  int? expandedIndex; // مؤشر العنصر المفتوح حاليًا

  @override
  void initState() {
    super.initState();
    _loadFaqData();
  }

  /// دالة لجلب الإعدادات واستخراج بيانات "الأسئلة الشائعة"
  Future<void> _loadFaqData() async {
    try {
      final settings = await _authService.fetchSettings();

      // 1. البحث عن المفتاح الصحيح "faqs" والتأكد من أنه خريطة (Map)
      if (settings.containsKey('faqs') && settings['faqs'] is Map) {
        final faqDataMap = settings['faqs'] as Map<String, dynamic>;

        // 2. تحويل الخريطة (Map) إلى قائمة (List) بالهيكلية التي تتوقعها الواجهة
        // { "key": "value" }  ==>  [ { "question": "key", "answer": "value" } ]
        final transformedList = faqDataMap.entries.map((entry) {
          return {
            "question": entry.key,
            "answer": entry.value,
          };
        }).toList();

        if (mounted) {
          setState(() {
            _faqList = transformedList;
            _isLoading = false;
          });
        }
      } else {
        // إذا لم يتم العثور على المفتاح أو كان نوعه خاطئًا
        if (mounted) {
          setState(() {
            _errorMessage = "لم يتم العثور على محتوى 'الأسئلة الشائعة' في إعدادات الـ API.";
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
    
    if (_faqList.isEmpty) {
      return const Center(child: Text("لا توجد أسئلة شائعة لعرضها حاليًا."));
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 700;
    final orangeColor = const Color(0xFFFC8700);

    return ListView.builder(
      padding: EdgeInsets.symmetric(
        vertical: 20,
        horizontal: isTablet ? screenWidth * 0.14 : 12,
      ),
      itemCount: _faqList.length,
      itemBuilder: (context, index) {
        final item = _faqList[index];
        final isExpanded = expandedIndex == index;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: isExpanded ? Border.all(color: orangeColor, width: 1.5) : null,
            boxShadow: [
              if (!isExpanded) // إظهار الظل فقط عندما تكون مغلقة
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 7,
                  offset: const Offset(0, 3),
                ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(13),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  setState(() {
                    // إذا كان العنصر المفتوح هو نفسه، أغلقه. وإلا، افتح العنصر الجديد
                    expandedIndex = isExpanded ? null : index;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              item['question'] ?? 'سؤال غير متوفر',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            isExpanded ? Icons.remove_circle_outline : Icons.add_circle_outline,
                            color: orangeColor,
                          ),
                        ],
                      ),
                      // المحتوى الذي يظهر ويختفي
                      AnimatedSize(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        child: Container(
                          width: double.infinity,
                          child: isExpanded
                              ? Padding(
                                  padding: const EdgeInsets.only(top: 12.0, bottom: 8.0),
                                  child: Text(
                                    item['answer'] ?? 'إجابة غير متوفرة',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.black87,
                                      height: 1.7,
                                    ),
                                  ),
                                )
                              : const SizedBox.shrink(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
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
          title: const Text('الاسئلة الشائعة', style: TextStyle(fontWeight: FontWeight.bold)),
          centerTitle: true,
        ),
        body: _buildBody(),
      ),
    );
  }
}