class MenuItem {
  final int id;
  final int menuSectionId;
  String name;
  String description;
  String imageUrl;
  double price;
  bool isAvailable;

  MenuItem({
    required this.id,
    required this.menuSectionId,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.price,
    required this.isAvailable,
  });

  /// **النسخة النهائية المصححة لتطابق الـ JSON**
  factory MenuItem.fromJson(Map<String, dynamic> json) {
    // تنظيف رابط الصورة من المسافات الإضافية
    String cleanImageUrl = (json['image'] ?? '').toString().trim();
    
    return MenuItem(
      id: json['id'] ?? 0,
      // **التصحيح: الخادم يرسل "section_id"**
      menuSectionId: json['section_id'] ?? 0, 
      // **التصحيح: الخادم يرسل "title"**
      name: (json['title'] ?? '').toString().trim(), 
      description: (json['description'] ?? '').toString().trim(),
      // **التصحيح: الخادم يرسل "image" مع تنظيف المسافات**
      imageUrl: cleanImageUrl, 
      price: double.tryParse(json['price'].toString()) ?? 0.0,
      // **التصحيح: الخادم لا يرسل هذا الحقل، لذا نعطيه قيمة افتراضية**
      isAvailable: json['is_available'] ?? true, 
    );
  }
}