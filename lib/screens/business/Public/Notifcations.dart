import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:saba2v2/router/app_router.dart';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

enum NotificationType {
  inAppNavigation,
  externalLink,
  information,
}

class NotificationModel {
  final String id;
  final String title;
  final String body;
  final DateTime date;
  final bool isRead;
  final NotificationType type;
  final String? actionData; // مسار داخلي أو رابط خارجي

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.date,
    this.isRead = false,
    required this.type,
    this.actionData,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    NotificationType type;
    switch (json['type']) {
      case 'inAppNavigation':
        type = NotificationType.inAppNavigation;
        break;
      case 'externalLink':
        type = NotificationType.externalLink;
        break;
      case 'information':
      default:
        type = NotificationType.information;
        break;
    }

    return NotificationModel(
      id: json['id'],
      title: json['title'],
      body: json['body'],
      date: DateTime.parse(json['date']),
      isRead: json['isRead'] ?? false,
      type: type,
      actionData: json['actionData'],
    );
  }

  Map<String, dynamic> toJson() {
    String typeStr;
    switch (type) {
      case NotificationType.inAppNavigation:
        typeStr = 'inAppNavigation';
        break;
      case NotificationType.externalLink:
        typeStr = 'externalLink';
        break;
      case NotificationType.information:
        typeStr = 'information';
        break;
    }

    return {
      'id': id,
      'title': title,
      'body': body,
      'date': date.toIso8601String(),
      'isRead': isRead,
      'type': typeStr,
      'actionData': actionData,
    };
  }
}

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<NotificationModel> notifications = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    // محاكاة جلب البيانات من الخادم
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    // هنا يمكنك استبدال هذا بطلب API حقيقي
    await Future.delayed(const Duration(seconds: 1));

    // بيانات تجريبية
    final String jsonData = '''
    [
      {
        "id": "1",
        "title": "تم قبول حسابك",
        "body": "تهانينا! تم قبول حسابك كمزود خدمة في تطبيقنا. يمكنك الآن البدء في استقبال الطلبات.",
        "date": "${DateTime.now().subtract(const Duration(hours: 2)).toIso8601String()}",
        "isRead": false,
        "type": "information"
      },
      {
        "id": "2",
        "title": "طلب جديد",
        "body": "لديك طلب جديد من العميل أحمد محمد. يرجى مراجعة تفاصيل الطلب والرد في أقرب وقت ممكن.",
        "date": "${DateTime.now().subtract(const Duration(days: 1)).toIso8601String()}",
        "isRead": true,
        "type": "externalLink",
        "actionData": "https://www.google.com"
      },
      {
        "id": "3",
        "title": "تحديث النظام",
        "body": "تم تحديث النظام إلى الإصدار الجديد. استمتع بالميزات الجديدة وتحسينات الأداء.",
        "date": "${DateTime.now().subtract(const Duration(days: 3)).toIso8601String()}",
        "isRead": false,
        "type": "information"
      }
    ]
    ''';

    final List<dynamic> decodedData = jsonDecode(jsonData);
    setState(() {
      notifications =
          decodedData.map((item) => NotificationModel.fromJson(item)).toList();
      isLoading = false;
    });
  }

  void deleteNotification(String id) {
    setState(() {
      notifications.removeWhere((notification) => notification.id == id);
    });
    // هنا يمكنك إضافة طلب API لحذف الإشعار من الخادم
  }

  void markAsRead(String id) {
    setState(() {
      final index =
          notifications.indexWhere((notification) => notification.id == id);
      if (index != -1) {
        final notification = notifications[index];
        notifications[index] = NotificationModel(
          id: notification.id,
          title: notification.title,
          body: notification.body,
          date: notification.date,
          isRead: true,
          type: notification.type,
          actionData: notification.actionData,
        );
      }
    });
    // هنا يمكنك إضافة طلب API لتحديث حالة الإشعار في الخادم
  }

  void handleNotificationTap(NotificationModel notification) async {
    // تحديث حالة القراءة
    if (!notification.isRead) {
      markAsRead(notification.id);
    }

    // التعامل مع الإجراء المطلوب حسب نوع الإشعار
    switch (notification.type) {
      case NotificationType.inAppNavigation:
        if (notification.actionData != null) {
          // التنقل إلى صفحة داخل التطبيق
          context.go(notification.actionData!);
        }
        break;
      case NotificationType.externalLink:
        if (notification.actionData != null) {
          // فتح رابط خارجي
          final Uri url = Uri.parse(notification.actionData!);
          if (await canLaunchUrl(url)) {
            await launchUrl(url, mode: LaunchMode.externalApplication);
          } else {
            // إظهار رسالة خطأ إذا تعذر فتح الرابط
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('لا يمكن فتح الرابط'),
                ),
              );
            }
          }
        }
        break;
      case NotificationType.information:
        // لا يوجد إجراء محدد للإشعارات الإخبارية
        break;
    }
  }

  String formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return 'منذ ${difference.inMinutes} دقيقة';
      }
      return 'منذ ${difference.inHours} ساعة';
    } else if (difference.inDays == 1) {
      return 'الأمس';
    } else if (difference.inDays < 7) {
      return 'منذ ${difference.inDays} أيام';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  // إضافة أيقونة مناسبة حسب نوع الإشعار
  IconData getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.inAppNavigation:
        return Icons.arrow_forward;
      case NotificationType.externalLink:
        return Icons.open_in_new;
      case NotificationType.information:
        return Icons.info_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الإشعارات'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                isLoading = true;
              });
              fetchNotifications();
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : notifications.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.notifications_off,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'لا توجد إشعارات',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    final notification = notifications[index];
                    return Dismissible(
                      key: Key(notification.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: const Icon(
                          Icons.delete,
                          color: Colors.white,
                        ),
                      ),
                      onDismissed: (direction) {
                        deleteNotification(notification.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('تم حذف الإشعار'),
                            action: SnackBarAction(
                              label: 'تراجع',
                              onPressed: () {
                                setState(() {
                                  notifications.insert(index, notification);
                                });
                              },
                            ),
                          ),
                        );
                      },
                      child: Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        elevation: 2,
                        child: InkWell(
                          onTap: () => handleNotificationTap(notification),
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border(
                                right: BorderSide(
                                  width: 4,
                                  color: notification.isRead
                                      ? Colors.transparent
                                      : Theme.of(context).primaryColor,
                                ),
                              ),
                              color: notification.isRead
                                  ? Colors.white
                                  : Colors.blue[50],
                            ),
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        notification.title,
                                        style: TextStyle(
                                          fontWeight: notification.isRead
                                              ? FontWeight.normal
                                              : FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.close),
                                      onPressed: () =>
                                          deleteNotification(notification.id),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  notification.body,
                                  style: const TextStyle(
                                    color: Colors.black87,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      formatDate(notification.date),
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                      ),
                                    ),
                                    if (notification.type !=
                                        NotificationType.information)
                                      Icon(
                                        getNotificationIcon(notification.type),
                                        size: 16,
                                        color: Colors.grey,
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }

}
