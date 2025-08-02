import 'package:saba2v2/models/MenuItem.dart';

class MenuSection {
  final int id;
  String title;
  final List<MenuItem> items;

  MenuSection({
    required this.id,
    required this.title,
    required this.items,
  });

  /// **النسخة النهائية المصححة لتطابق الـ JSON**
  factory MenuSection.fromJson(Map<String, dynamic> json) {
    // **التصحيح: الخادم يرسل الوجبات تحت مفتاح "items"**
    var itemsList = (json['items'] as List<dynamic>?) ?? [];
    List<MenuItem> parsedItems = itemsList.map((i) => MenuItem.fromJson(i)).toList();

    return MenuSection(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      items: parsedItems,
    );
  }
}