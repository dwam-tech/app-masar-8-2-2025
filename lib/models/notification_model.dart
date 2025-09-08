class NotificationModel {
  final int id;
  final int userId;
  final String type;
  final String title;
  final String message;
  final bool isRead;
  final String? link;
  final DateTime createdAt;
  final DateTime updatedAt;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.message,
    required this.isRead,
    this.link,
    required this.createdAt,
    required this.updatedAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      type: json['type'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      // معالجة is_read كـ boolean أو int (0/1)
      isRead: json['is_read'] is bool 
          ? json['is_read'] as bool
          : (json['is_read'] as int) == 1,
      link: json['link'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'type': type,
      'title': title,
      'message': message,
      'is_read': isRead,
      'link': link,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // إنشاء نسخة محدثة من الإشعار
  NotificationModel copyWith({
    int? id,
    int? userId,
    String? type,
    String? title,
    String? message,
    bool? isRead,
    String? link,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      isRead: isRead ?? this.isRead,
      link: link ?? this.link,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'NotificationModel(id: $id, title: $title, isRead: $isRead)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NotificationModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

// نموذج الاستجابة من API
class NotificationsResponse {
  final bool status;
  final List<NotificationModel> notifications;
  final String? message;

  NotificationsResponse({
    required this.status,
    required this.notifications,
    this.message,
  });

  factory NotificationsResponse.fromJson(Map<String, dynamic> json) {
    return NotificationsResponse(
      status: json['status'] as bool,
      notifications: (json['notifications'] as List<dynamic>)
          .map((item) => NotificationModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      message: json['message'] as String?,
    );
  }
}

// نموذج الاستجابة للعمليات (تحديث/حذف)
class NotificationActionResponse {
  final bool status;
  final String message;

  NotificationActionResponse({
    required this.status,
    required this.message,
  });

  factory NotificationActionResponse.fromJson(Map<String, dynamic> json) {
    return NotificationActionResponse(
      status: json['status'] as bool,
      message: json['message'] as String,
    );
  }
}