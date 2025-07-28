// مسار الملف المقترح: lib/models/MenuSection.dart

import 'package:saba2v2/models/MenuItem.dart'; // تأكدي من أن المسار صحيح

class MenuSection {
  final int id; // إضافة: الـ API يرسل ID رقمي لكل قسم
  String title; // تعديل: تم تغيير الاسم من name إلى title
  final List<MenuItem> items; // تعديل: تم تغيير الاسم من menuItems إلى items

  MenuSection({
    required this.id,
    required this.title,
    required this.items,
  });

  // إضافة: دالة لتحويل الـ JSON القادم من الـ API إلى كائن MenuSection
  factory MenuSection.fromJson(Map<String, dynamic> json) {
    // استخراج قائمة الوجبات وتحويلها
    var itemsList = (json['menu_items'] as List<dynamic>?) ?? [];
    List<MenuItem> parsedItems = itemsList.map((i) => MenuItem.fromJson(i)).toList();

    return MenuSection(
      id: json['id'],
      title: json['title'] ?? '',
      items: parsedItems,
    );
  }
}