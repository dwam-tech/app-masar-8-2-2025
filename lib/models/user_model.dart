class User {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String userType;
  final String? profileImage; // قد تكون القيمة null
  final bool isApproved;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.userType,
    this.profileImage,
    required this.isApproved,
  });

  // دالة لتحويل البيانات من صيغة JSON إلى كائن User
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      userType: json['user_type'] ?? 'normal',
      profileImage: json['profile_image'],
      // التحقق من القيمة 1 أو true لتحديد حالة الموافقة
      isApproved: json['is_approved'] == 1 || json['is_approved'] == true,
    );
  }
}