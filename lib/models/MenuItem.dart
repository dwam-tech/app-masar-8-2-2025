// مسار الملف المقترح: lib/models/MenuItem.dart

class MenuItem {
  final int id; // تعديل: الـ API يرسل ID رقمي (int) وليس نصي (String)
  final int menuSectionId; // إضافة: حقل ضروري لربط الوجبة بالقسم
  String name;
  String description;
  String imageUrl;
  double price; // تعديل: تم تغيير الاسم من basePrice إلى price ليتطابق مع الـ API
  bool isAvailable; // إضافة: حقل ضروري لمعرفة إذا كانت الوجبة متاحة

  MenuItem({
    required this.id,
    required this.menuSectionId,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.price,
    required this.isAvailable,
  });

  // إضافة: دالة لتحويل الـ JSON القادم من الـ API إلى كائن MenuItem
  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      id: json['id'],
      menuSectionId: json['menu_section_id'],
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['image_url'] ?? '', // تم تعديل اسم الحقل
      price: double.tryParse(json['price'].toString()) ?? 0.0, // تحويل آمن
      isAvailable: json['is_available'] == 1 || json['is_available'] == true, // تحويل آمن
    );
  }

  // ملاحظة: تم حذف List<MenuOption> لأنها غير موجودة في API إدارة المطاعم
}