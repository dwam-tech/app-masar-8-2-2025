class AdminSettings {
  // معرف حساب الإدارة الذي يستقبل رسائل الدعم الفني
  static const int supportAdminId = 59; // Deprecated: يُفضّل الآن استخدام البريد الإلكتروني
  
  // البريد الإلكتروني لحساب الأدمن المخصص للدعم الفني
  static const String supportAdminEmail = 'admin@msar.app';
  
  // يمكن إضافة إعدادات أخرى للإدارة هنا
  static const String supportChatTitle = 'الدعم الفني';
  static const String supportChatDescription = 'تواصل مع فريق الدعم الفني';
  
  // إعدادات أخرى للمحادثات
  static const int messagesPerPage = 20;
  static const int maxMessageLength = 1000;
  
  // أنواع المحادثات (يجب أن تتطابق مع قاعدة البيانات)
  static const String conversationTypeSupport = 'admin_user';
  static const String conversationTypeUser = 'user_user';
  static const String conversationTypeProvider = 'user_service_provider';
}