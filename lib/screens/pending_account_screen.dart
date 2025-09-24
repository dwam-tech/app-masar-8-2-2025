// lib/screens/pending_account_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../providers/auth_provider.dart';
import '../providers/conversations_provider.dart';
import '../services/laravel_service.dart';
import 'conversations_screen.dart';

class PendingAccountScreen extends StatefulWidget {
  const PendingAccountScreen({super.key});

  @override
  State<PendingAccountScreen> createState() => _PendingAccountScreenState();
}

class _PendingAccountScreenState extends State<PendingAccountScreen> {
  final LaravelService _laravelService = LaravelService();
  bool _isLoggingOut = false;
  Timer? _approvalCheckTimer;

  @override
  void initState() {
    super.initState();
    // تحديث المحادثات عند دخول الصفحة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final conversationsProvider = Provider.of<ConversationsProvider>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      // تحديث التوكن في ConversationsProvider
      if (authProvider.token != null) {
        conversationsProvider.updateToken(authProvider.token);
      }
      
      conversationsProvider.loadConversations(refresh: true);
      
      // تسجيل FCM token للحسابات غير المقبولة
      _registerFCMToken(authProvider.token);
    });
    
    // إعداد استقبال الإشعارات الفورية
    _setupNotificationListener();
    
    // بدء فحص حالة الموافقة كل 10 ثواني (كنسخة احتياطية)
    _startApprovalCheck();
  }

  void _setupNotificationListener() {
    // استقبال الإشعارات عندما يكون التطبيق مفتوح
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Received notification while in pending screen: ${message.data}');
      
      // التحقق من نوع الإشعار
      if (message.data['type'] == 'account_approved' || 
          message.data['notification_type'] == 'account_approved') {
        _handleAccountApproval();
      }
    });

    // استقبال الإشعارات عند فتح التطبيق من الإشعار
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('App opened from notification: ${message.data}');
      
      if (message.data['type'] == 'account_approved' || 
          message.data['notification_type'] == 'account_approved') {
        _handleAccountApproval();
      }
    });
  }

  Future<void> _handleAccountApproval() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.reloadSession();
      
      // التحقق من حالة الموافقة
      if (authProvider.isApproved) {
        _approvalCheckTimer?.cancel();
        
        if (mounted) {
          final userType = authProvider.userType;
          String route = '/UserHomeScreen'; // افتراضي
          
          if (userType == 'delivery_person' || userType == 'driver') {
            route = '/driver-home';
          } else if (userType == 'car_rental_owner') {
            route = '/delivery-homescreen';
          }
          
          // إظهار رسالة تهنئة
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('🎉 تم قبول حسابك! مرحباً بك في منصة مسار'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );
          
          context.go(route);
        }
      }
    } catch (e) {
      debugPrint('Error handling account approval: $e');
    }
  }

  Future<void> _registerFCMToken(String? token) async {
    if (token != null) {
      try {
        // الحصول على FCM token
        final fcmToken = await FirebaseMessaging.instance.getToken();
        debugPrint('FCM token for pending account: $fcmToken');
        
        if (fcmToken != null) {
          // تسجيل FCM token مع الخادم
          final response = await http.post(
            Uri.parse('https://msar.app/api/device-tokens'),
            headers: {
              'Authorization': 'Bearer $token',
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'token': fcmToken, 
              'platform': 'android'
            }),
          );
          
          debugPrint('FCM token registration response: ${response.statusCode} - ${response.body}');
          
          if (response.statusCode == 200) {
            debugPrint('FCM token registered successfully for pending account');
          }
        }
      } catch (e) {
        debugPrint('Error registering FCM token: $e');
      }
    }
  }

  @override
  void dispose() {
    _approvalCheckTimer?.cancel();
    super.dispose();
  }

  void _startApprovalCheck() {
    _approvalCheckTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (!mounted) {
        timer.cancel();
        return;
      }
      
      try {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        await authProvider.reloadSession();
        
        // إذا تم قبول الحساب، توجه للصفحة المناسبة
        if (authProvider.isApproved) {
          timer.cancel();
          if (mounted) {
            final userType = authProvider.userType;
            String route = '/UserHomeScreen'; // افتراضي
            
            if (userType == 'delivery_person' || userType == 'driver') {
              route = '/driver-home';
            } else if (userType == 'car_rental_owner') {
              route = '/delivery-homescreen';
            }
            
            // إظهار رسالة تهنئة
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('🎉 تم قبول حسابك! مرحباً بك في منصة مسار'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 3),
              ),
            );
            
            context.go(route);
          }
        }
      } catch (e) {
        // تجاهل الأخطاء في الفحص الخلفي
      }
    });
  }

  Future<void> _handleLogout() async {
    if (_isLoggingOut) return;
    
    setState(() {
      _isLoggingOut = true;
    });

    try {
      await _laravelService.logout();
      if (mounted) {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        authProvider.logout();
        context.go('/login');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ أثناء تسجيل الخروج: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoggingOut = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: const Text(
            'حسابك قيد المراجعة',
            style: TextStyle(
              color: Colors.black87,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          automaticallyImplyLeading: false,
          actions: [
            // أيقونة المحادثات
            Consumer<ConversationsProvider>(
              builder: (context, provider, child) {
                final unreadCount = provider.totalUnreadCount;
                return Stack(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.message_outlined,
                        color: Color(0xFFFC8700),
                        size: 24,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ConversationsScreen(),
                          ),
                        );
                      },
                    ),
                    if (unreadCount > 0)
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            unreadCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
            // أيقونة الإشعارات
            IconButton(
              icon: const Icon(
                Icons.notifications_outlined,
                color: Color(0xFFFC8700),
                size: 24,
              ),
              onPressed: () {
                context.push("/NotificationsScreen");
              },
            ),
            const SizedBox(width: 8),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(
              height: 1,
              color: Colors.grey[200],
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              
              // أيقونة الانتظار
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: const Color(0xFFFC8700).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.hourglass_empty,
                  size: 50,
                  color: Color(0xFFFC8700),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // العنوان الرئيسي
              const Text(
                'حسابك قيد المراجعة',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 12),
              
              // الوصف
              Text(
                'مرحباً بك في منصة مسار!\n\nحسابك تم إنشاؤه بنجاح وهو الآن قيد المراجعة من قبل فريق الإدارة. سيتم إشعارك فور الموافقة على حسابك.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 32),
              
              // بطاقة المحادثات والإشعارات
              Row(
                children: [
                  // بطاقة المحادثات
                  Expanded(
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ConversationsScreen(),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFC8700).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.chat_bubble_outline,
                                  color: Color(0xFFFC8700),
                                  size: 24,
                                ),
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'المحادثات',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'تواصل مع الإدارة',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Consumer<ConversationsProvider>(
                                builder: (context, provider, child) {
                                  final unreadCount = provider.totalUnreadCount;
                                  if (unreadCount > 0) {
                                    return Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.red,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        unreadCount.toString(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
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
                    ),
                  ),
                  
                  const SizedBox(width: 16),
                  
                  // بطاقة الإشعارات
                  Expanded(
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: InkWell(
                        onTap: () {
                          context.push("/NotificationsScreen");
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.notifications_outlined,
                                  color: Colors.blue,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'الإشعارات',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'تابع التحديثات',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 32),
              
              // معلومات إضافية
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.blue.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: Colors.blue,
                      size: 24,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'نصائح مهمة',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[800],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '• تأكد من صحة البيانات المدخلة\n• تواصل معنا في حالة وجود أي استفسارات\n• ستصلك رسالة تأكيد فور الموافقة على حسابك',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.blue[700],
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // زر تسجيل الخروج
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoggingOut ? null : _handleLogout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: _isLoggingOut
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'تسجيل الخروج',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}