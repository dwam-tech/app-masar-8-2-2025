import 'package:flutter/material.dart';

class AboutApp extends StatelessWidget {
  const AboutApp({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 700;

    // بيانات افتراضية، يمكنك استبدالها بالداتا من السيرفر لاحقاً
    final List<Map<String, String>> aboutList = List.generate(
      4,
          (i) => {
        'title': 'كلمة عن التطبيق',
        'desc':
        'نقوم بإخراج الفيزا السياحة وأيضاً تجديد المقيمين وتقديم العديد من الخدمات الحكومية، نقوم بإخراج الفيزا السياحة.',
      },
    );

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
        body: ListView.builder(
          padding: EdgeInsets.symmetric(
            vertical: 20,
            horizontal: isTablet ? screenWidth * 0.18 : 16,
          ),
          itemCount: aboutList.length,
          itemBuilder: (context, index) {
            final item = aboutList[index];
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
                        item['title'] ?? '',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    item['desc'] ?? '',
                    style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.7),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
