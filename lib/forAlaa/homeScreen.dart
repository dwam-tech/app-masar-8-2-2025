import 'package:flutter/material.dart';

class AlaaHome extends StatelessWidget {
  const AlaaHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // الصف الأول
              _buildCategoryRow(context, [
                _CategoryItem(
                  title: 'Cars Sales',
                  color: const Color(0xFF1B5E7E),
                  textColor: Colors.white,
                ),
                _CategoryItem(
                  title: 'Real Estate',
                  color: const Color(0xFFE8F4F8),
                  textColor: const Color(0xFF1B5E7E),
                ),
                _CategoryItem(
                  title: 'Electronics & Home\nAppliances',
                  color: const Color(0xFFE8F4F8),
                  textColor: const Color(0xFF1B5E7E),
                ),
                _CategoryItem(
                  title: 'Jobs',
                  color: const Color(0xFFE8F4F8),
                  textColor: const Color(0xFF1B5E7E),
                ),
              ]),

              const SizedBox(height: 12),

              // الصف الثاني
              _buildCategoryRow(context, [
                _CategoryItem(
                  title: 'Cars Rent',
                  color: const Color(0xFFE8F4F8),
                  textColor: const Color(0xFF1B5E7E),
                ),
                _CategoryItem(
                  title: 'Cars Services',
                  color: const Color(0xFFE8F4F8),
                  textColor: const Color(0xFF1B5E7E),
                ),
                _CategoryItem(
                  title: 'Restaurants',
                  color: const Color(0xFFE8F4F8),
                  textColor: const Color(0xFF1B5E7E),
                ),
                _CategoryItem(
                  title: 'Other Services',
                  color: const Color(0xFFE8F4F8),
                  textColor: const Color(0xFF1B5E7E),
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryRow(BuildContext context, List<_CategoryItem> items) {
    return Row(
      children: items.asMap().entries.map((entry) {
        int index = entry.key;
        _CategoryItem item = entry.value;

        // العنصر الثالث في الصف الأول (Electronics & Home Appliances) يكون أعرض
        int flex = (index == 2 && item.title.contains('Electronics')) ? 2 : 1;

        return Expanded(
          flex: flex,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: _buildCategoryCard(context, item),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCategoryCard(BuildContext context, _CategoryItem item) {
    // حساب عرض الشاشة للتجاوب
    double screenWidth = MediaQuery.of(context).size.width;

    // حساب حجم الخط بناءً على عرض الشاشة
    double fontSize = screenWidth > 600 ? 14 :
    screenWidth > 400 ? 12 : 10;

    return GestureDetector(
      onTap: () {
        // يمكنك إضافة الوظائف هنا
        print('Tapped on: ${item.title}');
      },
      child: Container(
        height: 40, // ارتفاع ثابت كما في التصميم
        decoration: BoxDecoration(
          color: item.color,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2.0),
            child: Text(
              item.title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: item.textColor,
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
                height: 1.2,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }
}

class _CategoryItem {
  final String title;
  final Color color;
  final Color textColor;

  _CategoryItem({
    required this.title,
    required this.color,
    required this.textColor,
  });
}