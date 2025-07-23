import 'package:flutter/material.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 700;
    final orangeColor = const Color(0xFFFC8700);

    // بيانات افتراضية للتكرار
    final List<Map<String, String>> termsList = List.generate(
      6,
          (i) => {
        'title': 'الشروط والأحكام',
        'body':
        'نقوم بإخراج الفيزا السياحة وأيضًا تجديد المقيمين وتقديم العديد من الخدمات الحكومية، نقوم بإخراج الفيزا السياحة.',
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
          title: const Text('الشروط والأحكام', style: TextStyle(fontWeight: FontWeight.bold)),
          centerTitle: true,
        ),
        body: ListView.builder(
          padding: EdgeInsets.symmetric(
            vertical: 20,
            horizontal: isTablet ? screenWidth * 0.14 : 12,
          ),
          itemCount: termsList.length,
          itemBuilder: (context, index) {
            final item = termsList[index];
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
                        // أيقونة مستطيلة فاتحة فيها أيقونة document
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
                            item['title']!,
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
                      item['body']!,
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
        ),
      ),
    );
  }
}
