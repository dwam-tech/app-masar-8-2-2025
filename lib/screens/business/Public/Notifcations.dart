import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../providers/notification_provider.dart';
import '../../../models/notification_model.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';

/// شاشة الإشعارات الرئيسية
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  /// عرض رسالة نجاح
  void _showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF2E7D32),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }
  @override
  void initState() {
    super.initState();
    // جلب الإشعارات عند تحميل الشاشة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().fetchNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
      backgroundColor: const Color(0xFFF8FFFE),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF2E7D32),
                Color(0xFF388E3C),
                Color(0xFF43A047),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Color(0x1A2E7D32),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: AppBar(
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.notifications_active,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'الإشعارات',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  Navigator.of(context).pop();
                },
              ),
            ),
        actions: [
          Consumer<NotificationProvider>(
            builder: (context, provider, child) {
              if (provider.unreadCount > 0) {
                return Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, color: Colors.white),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 8,
                    onSelected: (value) {
                      HapticFeedback.selectionClick();
                      if (value == 'mark_all_read') {
                        provider.markAllAsRead();
                        _showSuccessSnackBar(context, 'تم تمييز جميع الإشعارات كمقروءة');
                      } else if (value == 'delete_all_read') {
                        _showDeleteAllReadDialog(context, provider);
                      }
                    },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'mark_all_read',
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: const Row(
                          children: [
                            Icon(Icons.done_all, color: Color(0xFF2E7D32), size: 20),
                            SizedBox(width: 12),
                            Text(
                              'تمييز الكل كمقروء',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete_all_read',
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: const Row(
                          children: [
                            Icon(Icons.delete_sweep, color: Colors.red, size: 20),
                            SizedBox(width: 12),
                            Text(
                              'حذف المقروءة',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                   ),
                 );
               }
               return const SizedBox.shrink();
             },
           ),
         ],
           ),
         ),
       ),
      body: Consumer<NotificationProvider>(
        builder: (context, provider, child) {
          // إضافة فلترة لإخفاء الإشعارات التي يبدأ عنوانها بـ "رسالة جديدة من "
          final visibleNotifications = provider.notifications.where((n) {
            final title = n.title;
            return !title.startsWith('رسالة جديدة من ');
          }).toList();

          // حالة التحميل الأولي
          if (provider.isLoading && provider.notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF2E7D32), Color(0xFF43A047)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF2E7D32).withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      strokeWidth: 3,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'جاري تحميل الإشعارات...',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'يرجى الانتظار قليلاً',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          }

          // حالة الخطأ
          if (provider.errorMessage != null && provider.notifications.isEmpty) {
            return Center(
              child: Container(
                margin: const EdgeInsets.all(24),
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.wifi_off_rounded,
                        size: 48,
                        color: Colors.red[400],
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'حدث خطأ في تحميل الإشعارات',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E2E2E),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      provider.errorMessage!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 28),
                    Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF2E7D32), Color(0xFF43A047)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF2E7D32).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton.icon(
                        onPressed: () {
                          HapticFeedback.mediumImpact();
                          provider.clearError();
                          provider.fetchNotifications();
                        },
                        icon: const Icon(Icons.refresh_rounded, size: 20),
                        label: const Text(
                          'إعادة المحاولة',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          // حالة عدم وجود إشعارات
          if (provider.notifications.isEmpty) {
            return Center(
              child: Container(
                margin: const EdgeInsets.all(24),
                padding: const EdgeInsets.all(40),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2E7D32).withOpacity(0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF2E7D32).withOpacity(0.1),
                            const Color(0xFF43A047).withOpacity(0.1),
                          ],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.notifications_none_rounded,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'لا توجد لديك إشعارات بعد',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E2E2E),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'ستظهر إشعاراتك هنا عند وصولها\nسنقوم بإشعارك فور توفر أي تحديثات جديدة',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          // عرض قائمة الإشعارات (بعد الفلترة)
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFFF8F9FA),
                  Colors.grey[50]!,
                ],
              ),
            ),
            child: RefreshIndicator(
              onRefresh: () async {
                HapticFeedback.lightImpact();
                await provider.refreshNotifications();
              },
              color: const Color(0xFF2E7D32),
              backgroundColor: Colors.white,
              strokeWidth: 3,
              displacement: 60,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                itemCount: visibleNotifications.length,
                itemBuilder: (context, index) {
                  final notification = visibleNotifications[index];
                  return AnimatedContainer(
                    duration: Duration(milliseconds: 300 + (index * 50)),
                    curve: Curves.easeOutBack,
                    child: _buildNotificationCard(context, notification, provider),
                  );
                },
              ),
            ),
          );
        },
      ),
    ));
  }

  /// بناء كارت الإشعار
  Widget _buildNotificationCard(
    BuildContext context,
    NotificationModel notification,
    NotificationProvider provider,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Dismissible(
        key: Key('notification_${notification.id}'),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFE53E3E), Color(0xFFFC8181)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.red.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.delete_sweep_rounded,
                color: Colors.white,
                size: 32,
              ),
              SizedBox(height: 6),
              Text(
                'حذف',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
        confirmDismiss: (direction) async {
          HapticFeedback.mediumImpact();
          return await _showDeleteConfirmationDialog(context, notification);
        },
        onDismissed: (direction) {
          HapticFeedback.heavyImpact();
          provider.deleteNotification(notification.id);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_circle_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'تم حذف الإشعار بنجاح',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              backgroundColor: const Color(0xFF2E7D32),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.all(16),
              action: SnackBarAction(
                label: 'تراجع',
                textColor: Colors.white,
                backgroundColor: Colors.white.withOpacity(0.2),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  // يمكن إضافة وظيفة التراجع هنا إذا لزم الأمر
                },
              ),
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            gradient: notification.isRead
                ? LinearGradient(
                    colors: [Colors.white, Colors.grey[50]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : const LinearGradient(
                    colors: [Color(0xFFF0F9FF), Color(0xFFE0F2FE)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
            borderRadius: BorderRadius.circular(20),
            border: notification.isRead
                ? Border.all(color: Colors.grey[200]!, width: 1)
                : Border.all(color: const Color(0xFF2E7D32), width: 2),
            boxShadow: [
              BoxShadow(
                color: notification.isRead
                    ? Colors.grey.withOpacity(0.1)
                    : const Color(0xFF2E7D32).withOpacity(0.15),
                blurRadius: notification.isRead ? 8 : 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                HapticFeedback.selectionClick();
                _handleNotificationTap(context, notification, provider);
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.all(20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // أيقونة الإشعار
                    Hero(
                      tag: 'notification_${notification.id}',
                      child: Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          gradient: notification.isRead
                              ? LinearGradient(
                                  colors: [Colors.grey[400]!, Colors.grey[500]!],
                                )
                              : const LinearGradient(
                                  colors: [Color(0xFF2E7D32), Color(0xFF43A047)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: notification.isRead
                                  ? Colors.grey.withOpacity(0.3)
                                  : const Color(0xFF2E7D32).withOpacity(0.4),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          _getNotificationIcon(notification.type),
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    // محتوى الإشعار
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // العنوان مع حالة القراءة
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  notification.title,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: notification.isRead
                                        ? FontWeight.w600
                                        : FontWeight.bold,
                                    color: notification.isRead
                                        ? Colors.grey[700]
                                        : const Color(0xFF2E2E2E),
                                    height: 1.3,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (!notification.isRead)
                                Container(
                                  margin: const EdgeInsets.only(left: 8),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFF2E7D32), Color(0xFF43A047)],
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Text(
                                    'جديد',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          // الرسالة
                          if (notification.message.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: notification.isRead
                                    ? Colors.grey[100]
                                    : const Color(0xFF2E7D32).withOpacity(0.05),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: notification.isRead
                                      ? Colors.grey[300]!
                                      : const Color(0xFF2E7D32).withOpacity(0.2),
                                ),
                              ),
                              child: Text(
                                notification.message,
                                style: TextStyle(
                                  fontSize: 15,
                                  color: notification.isRead
                                      ? Colors.grey[700]
                                      : const Color(0xFF2E2E2E),
                                  height: 1.5,
                                ),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          const SizedBox(height: 16),
                          // الوقت مع أيقونة
                          Row(
                            children: [
                              Icon(
                                Icons.access_time_rounded,
                                size: 16,
                                color: Colors.grey[500],
                              ),
                              const SizedBox(width: 6),
                              Text(
                                provider.formatNotificationTime(notification.createdAt),
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const Spacer(),
                              if (notification.link != null && notification.link!.isNotEmpty)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF2E7D32).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.link_rounded,
                                        size: 14,
                                        color: const Color(0xFF2E7D32),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'رابط',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: const Color(0xFF2E7D32),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      );
  }

  /// معالجة الضغط على الإشعار
  void _handleNotificationTap(
    BuildContext context,
    NotificationModel notification,
    NotificationProvider provider,
  ) async {
    // تمييز الإشعار كمقروء إذا لم يكن مقروءاً
    if (!notification.isRead) {
      await provider.markNotificationAsRead(notification.id);
    }

    // التنقل إذا كان هناك رابط
    if (notification.link != null && notification.link!.isNotEmpty) {
      _handleNotificationNavigation(context, notification.link!);
    }
  }

  /// معالجة التنقل من الإشعار
  void _handleNotificationNavigation(BuildContext context, String link) {
    try {
      // التحقق من نوع الرابط
      if (link.startsWith('http://') || link.startsWith('https://')) {
        // رابط خارجي
        _launchExternalUrl(link);
      } else {
        // رابط داخلي في التطبيق
        context.push(link);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ في فتح الرابط: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// فتح رابط خارجي
  Future<void> _launchExternalUrl(String url) async {
    try {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw 'لا يمكن فتح الرابط: $url';
      }
    } catch (e) {
      debugPrint('خطأ في فتح الرابط: $e');
    }
  }

  /// الحصول على أيقونة الإشعار حسب النوع
  IconData _getNotificationIcon(String type) {
    switch (type.toLowerCase()) {
      case 'new_order':
        return Icons.shopping_bag_rounded;
      case 'order_update':
        return Icons.update_rounded;
      case 'payment':
        return Icons.credit_card_rounded;
      case 'promotion':
        return Icons.local_offer_rounded;
      case 'system':
        return Icons.settings_rounded;
      case 'message':
        return Icons.message_rounded;
      case 'delivery':
        return Icons.local_shipping_rounded;
      case 'security':
        return Icons.security_rounded;
      case 'reminder':
        return Icons.schedule_rounded;
      case 'warning':
        return Icons.warning_rounded;
      case 'success':
        return Icons.check_circle_rounded;
      case 'info':
        return Icons.info_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  /// حوار تأكيد الحذف
  Future<bool?> _showDeleteConfirmationDialog(
    BuildContext context,
    NotificationModel notification,
  ) async {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 10,
          backgroundColor: Colors.white,
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFE53E3E), Color(0xFFFC8181)],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.warning_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'تأكيد الحذف',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E2E2E),
                ),
              ),
            ],
          ),
          content: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'هل أنت متأكد من حذف هذا الإشعار؟',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.red[200]!,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        color: Colors.red[600],
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'لا يمكن التراجع عن هذا الإجراء',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.red[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            Container(
              margin: const EdgeInsets.only(bottom: 8, left: 8, right: 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        Navigator.of(context).pop(false);
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Colors.grey[300]!),
                        ),
                      ),
                      child: Text(
                        'إلغاء',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        HapticFeedback.heavyImpact();
                        Navigator.of(context).pop(true);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE53E3E),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.delete_rounded,
                            size: 20,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'حذف',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  /// حوار تأكيد حذف جميع الإشعارات المقروءة
  void _showDeleteAllReadDialog(
    BuildContext context,
    NotificationProvider provider,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 15,
          backgroundColor: Colors.white,
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFE53E3E), Color(0xFFFC8181)],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.delete_sweep_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'حذف جميع المقروءة',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E2E2E),
                  ),
                ),
              ),
            ],
          ),
          content: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'هل أنت متأكد من حذف جميع الإشعارات المقروءة؟',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.red[50]!, Colors.red[100]!],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.red[200]!,
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            color: Colors.red[600],
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'تحذير مهم',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.red[700],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'لا يمكن التراجع عن هذا الإجراء وسيتم حذف جميع الإشعارات المقروءة نهائياً',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.red[700],
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            Container(
              margin: const EdgeInsets.only(bottom: 8, left: 8, right: 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        Navigator.of(context).pop();
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Colors.grey[300]!),
                        ),
                      ),
                      child: Text(
                        'إلغاء',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        HapticFeedback.heavyImpact();
                        Navigator.of(context).pop();
                        provider.deleteAllRead();
                        _showSuccessSnackBar(context, 'تم حذف جميع الإشعارات المقروءة');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE53E3E),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 3,
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.delete_sweep_rounded,
                            size: 22,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'حذف الكل',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
