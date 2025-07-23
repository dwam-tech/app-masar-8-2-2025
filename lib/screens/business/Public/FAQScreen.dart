import 'package:flutter/material.dart';

class FAQScreen extends StatefulWidget {
  const FAQScreen({super.key});

  @override
  State<FAQScreen> createState() => _FAQScreenState();
}

class _FAQScreenState extends State<FAQScreen> {
  int? expandedIndex; // مؤشر العنصر المفتوح

  // بيانات افتراضية للأسئلة
  final List<Map<String, String>> faqList = List.generate(
    6,
        (i) => {
      'question': 'يمكنك وضع السؤال هنا مفصل',
      'answer':
      'نقوم بإخراج الفيزا السياحة وأيضًا تجديد المقيمين وتقديم العديد من الخدمات الحكومية، نقوم بإخراج الفيزا السياحة.',
    },
  );

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 700;
    final orangeColor = const Color(0xFFFC8700);

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
        body: ListView.builder(
          padding: EdgeInsets.symmetric(
            vertical: 20,
            horizontal: isTablet ? screenWidth * 0.14 : 12,
          ),
          itemCount: faqList.length,
          itemBuilder: (context, index) {
            final item = faqList[index];
            final isExpanded = expandedIndex == index;

            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: isExpanded
                    ? Border.all(color: orangeColor, width: 1.3)
                    : null,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 7,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: isExpanded
                  ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // عنوان السؤال + زر إغلاق
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close, color: Color(0xFFFC8700)),
                        onPressed: () => setState(() => expandedIndex = null),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                          child: Text(
                            item['question'] ?? '',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(
                      item['answer'] ?? '',
                      style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.7),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              )
                  : ListTile(
                leading: Container(
                  decoration: BoxDecoration(
                    color: orangeColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  width: 32,
                  height: 32,
                  child: Icon(Icons.add, color: orangeColor),
                ),
                title: Text(
                  item['question'] ?? '',
                  style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                ),
                onTap: () => setState(() => expandedIndex = index),
                minLeadingWidth: 0,
              ),
            );
          },
        ),
      ),
    );
  }
}
