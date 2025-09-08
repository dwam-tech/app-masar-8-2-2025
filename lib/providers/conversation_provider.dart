import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/conversation_model.dart';
import '../models/message_model.dart';
import '../services/conversation_service.dart';
import '../services/conversations_service.dart';

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

  bool _isLoadingMoreMessages = false;
  bool get isLoadingMoreMessages => _isLoadingMoreMessages;

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

  // Pagination للرسائل
  int _currentMessagesPage = 1;
  bool _hasMoreMessages = true;
  PaginationInfo? _messagesPagination;
  bool get hasMoreMessages => _hasMoreMessages;
  PaginationInfo? get messagesPagination => _messagesPagination;

  // Auto-refresh timer
  Timer? _refreshTimer;
  bool _isUserTyping = false;
  DateTime? _lastUserActivity;
  bool _isInChatScreen = false; // تتبع ما إذا كان المستخدم في شاشة الشات
  int _refreshSkipCounter = 0; // عداد لتخطي بعض التحديثات عند الكتابة
  
  // إتاحة قراءة الحالة لباقي الطبقات (مثلاً FCM لقمع الإشعار داخل الشات)
  bool get isInChatScreen => _isInChatScreen;
  // منع الاستدعاء المتكرر المكثف لتعليم الرسائل كمقروءة
  DateTime? _lastMarkedReadAt;
  
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

      // 1) تأكد من وجود محادثة حالية أو احصل على واحدة
      if (_conversation?.id == null) {
        final convRes = await ConversationService.getUserConversation(token: _token!);
        if (convRes != null && convRes.status && convRes.conversation != null) {
          _conversation = convRes.conversation;
        } else {
          debugPrint('ℹ️ Silent refresh: لا توجد محادثة متاحة بعد');
          return;
        }
      }

      // 2) اجلب الرسائل عبر endpoint الرسائل لضمان الحصول على أحدث البيانات
      final msgsRes = await ConversationsService.getConversationMessages(
        token: _token!,
        conversationId: _conversation!.id!,
        page: 1,
        perPage: 20,
      );

      if (msgsRes == null || !msgsRes.status) {
        debugPrint('⚠️ Silent refresh messages fetch failed or status=false');
        return;
      }

      final newMessages = msgsRes.messages ?? [];

      // إذا رجعت قائمة فارغة مؤقتًا، لا نفرغ الرسائل الحالية لتجنب وميض الشاشة
      if (newMessages.isEmpty) {
        if (_messages.isNotEmpty) {
          debugPrint('⚠️ Silent refresh returned empty list; keeping existing ${_messages.length} messages');
          return;
        } else {
          debugPrint('ℹ️ Silent refresh empty and no existing messages');
          return;
        }
      }

      // 3) دمج الرسائل الجديدة مع الحالية بدون حذف الموجودة
      bool changed = false;

      // أنشئ خريطة سريعة للوصول حسب id
      final existingById = { for (final m in _messages) m.id: m };

      for (final nm in newMessages) {
        final existing = existingById[nm.id];
        if (existing == null) {
          _messages.add(nm);
          changed = true;
        } else if (existing.content != nm.content || existing.isRead != nm.isRead) {
          final idx = _messages.indexOf(existing);
          if (idx >= 0) {
            _messages[idx] = nm;
            changed = true;
          }
        }
      }

      if (changed) {
        // تأكد من ترتيب القائمة بما يتوافق مع واجهة العرض الحالية إن لزم
        notifyListeners();
        debugPrint('✅ Silent refresh merge: total messages now ${_messages.length}');
      } else {
        debugPrint('📭 Silent refresh: No changes applied');
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
    // محاولة تعليم الرسائل كمقروءة مباشرة إن وُجدت
    if (hasUnreadMessages) {
      _lastMarkedReadAt = DateTime.now();
      // ignore: unawaited_futures
      markMessagesAsRead();
    }
  }

  /// إشعار بخروج المستخدم من شاشة الشات
  void exitChatScreen() {
    _isInChatScreen = false;
    _stopAutoRefresh();
    debugPrint('📱 User exited chat screen - stopping auto-refresh');
  }

  /// تحميل المزيد من الرسائل القديمة
  Future<void> loadMoreMessages() async {
    if (_token == null || _conversation?.id == null || _isLoadingMoreMessages || !_hasMoreMessages) {
      return;
    }

    debugPrint('📜 Loading more messages (page ${_currentMessagesPage + 1})');
    
    _isLoadingMoreMessages = true;
    notifyListeners();

    try {
      final response = await ConversationsService.getConversationMessages(
        token: _token!,
        conversationId: _conversation!.id!,
        page: _currentMessagesPage + 1,
        perPage: 20,
      );

      if (response != null && response.status && response.messages != null) {
        // إضافة الرسائل القديمة في بداية القائمة
        final olderMessages = response.messages!;
        _messages.insertAll(0, olderMessages);
        
        _currentMessagesPage++;
        _messagesPagination = response.pagination;
        _hasMoreMessages = response.pagination?.hasMorePages ?? false;
        
        debugPrint('✅ Loaded ${olderMessages.length} older messages. Total: ${_messages.length}');
        debugPrint('📄 Has more messages: $_hasMoreMessages');
      } else {
        _hasMoreMessages = false;
        debugPrint('📭 No more messages to load');
      }
    } catch (e) {
      debugPrint('❌ Error loading more messages: $e');
    } finally {
      _isLoadingMoreMessages = false;
      notifyListeners();
    }
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
      final conversationResponse = await ConversationService.getUserConversation(token: _token!);
      
      if (conversationResponse != null && conversationResponse.status && conversationResponse.conversation != null) {
        _conversation = conversationResponse.conversation;
        debugPrint('✅ Conversation found: ${_conversation!.id}');
        
        // تحميل الرسائل باستخدام pagination
        debugPrint('📡 Loading messages with pagination...');
        final messagesResponse = await ConversationsService.getConversationMessages(
          token: _token!,
          conversationId: _conversation!.id!,
          page: 1,
          perPage: 20,
        );
        
        if (messagesResponse != null && messagesResponse.status) {
          _messages = messagesResponse.messages ?? [];
          _currentMessagesPage = 1;
          _messagesPagination = messagesResponse.pagination;
          _hasMoreMessages = messagesResponse.pagination?.hasMorePages ?? false;
          
          debugPrint('✅ Messages loaded: ${_messages.length} messages');
          debugPrint('📄 Has more messages: $_hasMoreMessages');
          
          for (int i = 0; i < _messages.length; i++) {
            final msg = _messages[i];
            debugPrint('   Message $i: sender=${msg.senderId}, content="${msg.content.substring(0, msg.content.length > 50 ? 50 : msg.content.length)}..."');
          }

          // تعليم كمقروءة تلقائياً إذا كان المستخدم داخل شاشة الشات ووجدت رسائل غير مقروءة
          if (_isInChatScreen && hasUnreadMessages) {
            final now = DateTime.now();
            if (_lastMarkedReadAt == null || now.difference(_lastMarkedReadAt!) > const Duration(seconds: 2)) {
              _lastMarkedReadAt = now;
              // ignore: unawaited_futures
              markMessagesAsRead();
            }
          }
        } else {
          // لا نقوم بتفريغ الرسائل عند فشل الجلب المؤقت لتجنب الوميض في الواجهة
          debugPrint('⚠️ Messages fetch failed or returned no data. Keeping existing messages. responseNull=${messagesResponse == null} status=${messagesResponse?.status}');
          // الاحتفاظ بالقائمة الحالية دون تغيير
        }
        _conversationError = null;
      } else if (conversationResponse != null && conversationResponse.status && conversationResponse.conversation == null) {
        // لا توجد محادثة بعد للمستخدم - حالة طبيعية: جهّز حالة فارغة
        _conversation = null;
        _messages = [];
        _currentMessagesPage = 1;
        _hasMoreMessages = false;
        _conversationError = null;
        debugPrint('📭 No conversation found, initializing empty state');
      } else {
        // فشل في جلب المحادثة (اتصال/سيرفر)، لا نفرغ الرسائل الحالية لتجنب وميض الواجهة
        debugPrint('⚠️ Failed to fetch conversation (null or status=false). Keeping existing messages');
        _conversationError = 'تعذر تحديث المحادثة مؤقتًا';
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
        conversationId: _conversation?.id,
      );

      if (response != null && response.status) {
        // After successfully sending, refresh the conversation to get the latest data
        // إعادة تعيين pagination عند إرسال رسالة جديدة
        _currentMessagesPage = 1;
        _hasMoreMessages = true;
        await fetchConversation();
        debugPrint('✅ Message sent and conversation refreshed');
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
    if (_token == null || _conversation?.id == null) return;

    try {
      await ConversationService.markMessagesAsRead(
        token: _token!,
        conversationId: _conversation!.id!,
      );
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
    if (message.senderId == null || _currentUserId == null) return false;
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