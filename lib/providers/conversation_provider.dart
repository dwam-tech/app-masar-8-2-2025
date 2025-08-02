import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/conversation_model.dart';
import '../models/message_model.dart';
import '../services/conversation_service.dart';

class ConversationProvider with ChangeNotifier {
  // المحادثة الوحيدة للمستخدم مع الأدمن
  Conversation? _conversation;
  Conversation? get conversation => _conversation;

  // الرسائل للمحادثة
  List<Message> _messages = [];
  List<Message> get messages => _messages;

  // حالات التحميل
  bool _isLoadingConversation = false;
  bool get isLoadingConversation => _isLoadingConversation;
  bool get isLoading => _isLoadingConversation; // alias للتوافق مع الشاشات

  bool _isSendingMessage = false;
  bool get isSendingMessage => _isSendingMessage;

  // حالات الأخطاء
  String? _conversationError;
  String? get conversationError => _conversationError;
  String? get error => _conversationError; // alias للتوافق مع الشاشات

  // التوكن والمستخدم الحالي
  String? _token;
  int? _currentUserId;

  // حالة التهيئة
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  // Auto-refresh timer
  Timer? _refreshTimer;
  bool _isUserTyping = false;
  DateTime? _lastUserActivity;
  bool _isInChatScreen = false; // تتبع ما إذا كان المستخدم في شاشة الشات
  int _refreshSkipCounter = 0; // عداد لتخطي بعض التحديثات عند الكتابة
  
  // Auto-refresh settings
  static const Duration _refreshInterval = Duration(seconds: 1);
  static const Duration _typingCooldown = Duration(seconds: 2);
  static const int _typingSkipFrequency = 3; // تخطي كل 3 تحديثات عند الكتابة

  /// تهيئة المزود بالتوكن ومعرف المستخدم
  void initialize(String token, int userId) {
    _token = token;
    _currentUserId = userId;
    _isInitialized = true;
    // لا نبدأ auto-refresh هنا، سيتم بدؤه عند دخول شاشة الشات
    notifyListeners();
  }

  /// بدء Auto-refresh الذكي
  void _startAutoRefresh() {
    _stopAutoRefresh(); // إيقاف أي timer موجود
    
    _refreshTimer = Timer.periodic(_refreshInterval, (timer) {
      _performSmartRefresh();
    });
    
    debugPrint('🔄 Auto-refresh started with ${_refreshInterval.inSeconds}s interval');
    debugPrint('📱 Chat screen status: $_isInChatScreen');
  }

  /// إيقاف Auto-refresh
  void _stopAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
    debugPrint('⏹️ Auto-refresh stopped');
  }

  /// تنفيذ refresh ذكي
  void _performSmartRefresh() async {
    debugPrint('🔄 _performSmartRefresh called - isInChatScreen: $_isInChatScreen');
    
    // لا تعمل refresh إذا:
    // 1. المستخدم ليس في شاشة الشات
    // 2. في عملية إرسال رسالة
    // 3. في عملية تحميل
    
    if (!_isInChatScreen) {
      debugPrint('⏸️ Skipping refresh - user not in chat screen');
      return;
    }

    if (_isSendingMessage || _isLoadingConversation) {
      debugPrint('⏸️ Skipping refresh - operation in progress (sending: $_isSendingMessage, loading: $_isLoadingConversation)');
      return;
    }

    // إذا كان المستخدم يكتب، نقلل من تكرار التحديث
    if (_isUserTyping) {
      _refreshSkipCounter++;
      if (_refreshSkipCounter < _typingSkipFrequency) {
        debugPrint('⌨️ User typing - skipping refresh ${_refreshSkipCounter}/$_typingSkipFrequency');
        return;
      } else {
        debugPrint('⌨️ User typing - performing refresh after skip');
        _refreshSkipCounter = 0; // إعادة تعيين العداد
      }
    } else {
      _refreshSkipCounter = 0; // إعادة تعيين العداد عند عدم الكتابة
    }

    debugPrint('✅ Proceeding with silent refresh...');
    // تنفيذ refresh صامت (بدون تغيير حالة loading)
    await _silentRefresh();
  }

  /// التحقق من النشاط الحديث للمستخدم
  bool _isRecentUserActivity() {
    if (_lastUserActivity == null) return false;
    
    final timeSinceActivity = DateTime.now().difference(_lastUserActivity!);
    return timeSinceActivity < _typingCooldown;
  }

  /// Refresh صامت بدون تأثير على UI
  Future<void> _silentRefresh() async {
    if (_token == null) return;

    try {
      debugPrint('🔄 Silent refresh...');
      final response = await ConversationService.getUserConversation(token: _token!);
      
      if (response != null && response.status) {
        final newMessages = response.conversation?.messages ?? [];
        
        // تحديث الرسائل فقط إذا كان هناك تغيير
        if (_hasMessagesChanged(newMessages)) {
          _conversation = response.conversation;
          _messages = List<Message>.from(newMessages);
          notifyListeners();
          debugPrint('✅ Silent refresh: ${_messages.length} messages updated');
        } else {
          debugPrint('📭 Silent refresh: No changes detected');
        }
      }
    } catch (e) {
      debugPrint('❌ Silent refresh error: $e');
      // لا نعرض الخطأ للمستخدم في silent refresh
    }
  }

  /// التحقق من تغيير الرسائل
  bool _hasMessagesChanged(List<Message> newMessages) {
    if (_messages.length != newMessages.length) {
      return true;
    }
    
    for (int i = 0; i < _messages.length; i++) {
      if (_messages[i].id != newMessages[i].id ||
          _messages[i].content != newMessages[i].content ||
          _messages[i].isRead != newMessages[i].isRead) {
        return true;
      }
    }
    
    return false;
  }

  /// إشعار بأن المستخدم بدأ الكتابة
  void setUserTyping(bool isTyping) {
    if (_isUserTyping != isTyping) {
      _isUserTyping = isTyping;
      _lastUserActivity = DateTime.now();
      
      if (isTyping) {
        debugPrint('⌨️ User started typing - reducing auto-refresh frequency');
        _refreshSkipCounter = 0; // إعادة تعيين العداد عند بدء الكتابة
      } else {
        debugPrint('✋ User stopped typing - resuming normal auto-refresh');
        _refreshSkipCounter = 0; // إعادة تعيين العداد عند التوقف عن الكتابة
      }
    }
  }

  /// تسجيل نشاط المستخدم
  void recordUserActivity() {
    _lastUserActivity = DateTime.now();
  }

  /// إشعار بدخول المستخدم لشاشة الشات
  void enterChatScreen() {
    _isInChatScreen = true;
    _startAutoRefresh();
    debugPrint('📱 User entered chat screen - starting auto-refresh');
  }

  /// إشعار بخروج المستخدم من شاشة الشات
  void exitChatScreen() {
    _isInChatScreen = false;
    _stopAutoRefresh();
    debugPrint('📱 User exited chat screen - stopping auto-refresh');
  }

  /// جلب أو إنشاء المحادثة الوحيدة مع الأدمن
  Future<void> fetchConversation() async {
    debugPrint('🔄 ConversationProvider: Starting fetchConversation');
    debugPrint('🔑 Token available: ${_token != null}');
    debugPrint('👤 Current user ID: $_currentUserId');
    
    if (_token == null) {
      debugPrint('❌ No token available, returning');
      return;
    }

    _isLoadingConversation = true;
    _conversationError = null;
    notifyListeners();

    try {
      debugPrint('📡 Calling ConversationService.getUserConversation...');
      final response = await ConversationService.getUserConversation(token: _token!);
      
      debugPrint('📥 API Response received:');
      debugPrint('   - Response is null: ${response == null}');
      debugPrint('   - Response status: ${response?.status}');
      debugPrint('   - Conversation is null: ${response?.conversation == null}');
      debugPrint('   - Messages count: ${response?.conversation?.messages?.length ?? 0}');
      
      if (response != null && response.status) {
        _conversation = response.conversation;
        // Always update messages from the conversation data
        if (_conversation?.messages != null) {
          _messages = List<Message>.from(_conversation!.messages);
          debugPrint('✅ Messages loaded: ${_messages.length} messages');
          for (int i = 0; i < _messages.length; i++) {
            final msg = _messages[i];
            debugPrint('   Message $i: sender=${msg.senderId}, content="${msg.content.substring(0, msg.content.length > 50 ? 50 : msg.content.length)}..."');
          }
        } else {
          _messages = [];
          debugPrint('📭 No messages in conversation');
        }
        _conversationError = null;
      } else {
        // If no conversation exists yet, initialize empty state
        _conversation = null;
        _messages = [];
        _conversationError = null;
        debugPrint('📭 No conversation found, initializing empty state');
      }
    } catch (e) {
      _conversationError = 'خطأ في الاتصال: $e';
      debugPrint('❌ Error fetching conversation: $e');
    } finally {
      _isLoadingConversation = false;
      notifyListeners();
      debugPrint('🏁 fetchConversation completed. Messages count: ${_messages.length}');
    }
  }

  /// إرسال رسالة جديدة
  Future<bool> sendMessage(String content) async {
    if (_token == null || content.trim().isEmpty) {
      return false;
    }

    _isSendingMessage = true;
    notifyListeners();

    try {
      final response = await ConversationService.sendUserMessage(
        token: _token!,
        content: content.trim(),
      );

      if (response != null && response.status) {
        // After successfully sending, refresh the conversation to get the latest data
        await fetchConversation();
        return true;
      } else {
        debugPrint('Failed to send message: ${response?.errorMessage}');
        return false;
      }
    } catch (e) {
      debugPrint('Error sending message: $e');
      return false;
    } finally {
      _isSendingMessage = false;
      notifyListeners();
    }
  }

  /// تحديث حالة قراءة الرسائل
  Future<void> markMessagesAsRead() async {
    if (_token == null) return;

    try {
      await ConversationService.markMessagesAsRead(token: _token!);
    } catch (e) {
      debugPrint('Error marking messages as read: $e');
    }
  }

  /// تحديث المحادثة والرسائل
  Future<void> refreshConversation() async {
    await fetchConversation();
  }

  /// تنظيف البيانات
  void clearData() {
    _stopAutoRefresh(); // إيقاف auto-refresh
    _conversation = null;
    _messages.clear();
    _conversationError = null;
    _token = null;
    _currentUserId = null;
    _isInitialized = false;
    _isUserTyping = false;
    _lastUserActivity = null;
    notifyListeners();
  }

  /// تنظيف الموارد عند إغلاق المزود
  @override
  void dispose() {
    _stopAutoRefresh();
    super.dispose();
  }

  /// التحقق من كون الرسالة من المستخدم الحالي
  bool isMyMessage(Message message) {
    return message.senderId == _currentUserId;
  }

  /// التحقق من وجود رسائل غير مقروءة
  bool get hasUnreadMessages {
    return _messages.any((message) => 
        !isMyMessage(message) && !message.isRead);
  }

  /// عدد الرسائل غير المقروءة
  int get unreadMessagesCount {
    return _messages.where((message) => 
        !isMyMessage(message) && !message.isRead).length;
  }
}