import 'package:flutter/foundation.dart';
import '../models/conversation_model.dart';
import '../services/conversations_service.dart';
import '../utils/storage_helper.dart';
import '../config/admin_settings.dart';

class ConversationsProvider with ChangeNotifier {
  List<ConversationListItem> _conversations = [];
  bool _isLoading = false;
  String? _error;
  PaginationInfo? _pagination;
  int _currentPage = 1;
  bool _hasMorePages = true;
  String? _token;
  int? _currentUserId;

  // Getters
  List<ConversationListItem> get conversations => _conversations;
  bool get isLoading => _isLoading;
  String? get error => _error;
  PaginationInfo? get pagination => _pagination;
  bool get hasMorePages => _hasMorePages;
  int get totalUnreadCount => _conversations.fold(0, (sum, conv) => sum + conv.unreadCount);

  /// تهيئة المزود
  Future<void> initialize() async {
    debugPrint('🔧 ConversationsProvider: Initializing...');
    
    try {
      _token = await StorageHelper.getToken();
      _currentUserId = await StorageHelper.getCurrentUserId();
      
      if (_token != null) {
        await loadConversations(refresh: true);
      }
    } catch (e) {
      debugPrint('❌ ConversationsProvider initialization error: $e');
      _error = 'خطأ في تهيئة المحادثات';
      notifyListeners();
    }
  }

  /// تحميل المحادثات
  Future<void> loadConversations({
    bool refresh = false,
    String? type,
    String? status,
  }) async {
    if (_token == null) {
      debugPrint('❌ No token available for loading conversations');
      return;
    }

    if (refresh) {
      _currentPage = 1;
      _conversations.clear();
      _hasMorePages = true;
    }

    if (_isLoading || !_hasMorePages) return;

    debugPrint('📱 ConversationsProvider: Loading conversations (page $_currentPage)');
    
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ConversationsService.getUserConversations(
        token: _token!,
        page: _currentPage,
        perPage: 20,
        type: type,
        status: status,
      );

      if (response != null && response.status) {
        if (response.conversations != null) {
          if (refresh) {
            _conversations = response.conversations!;
          } else {
            _conversations.addAll(response.conversations!);
          }
        }
        
        _pagination = response.pagination;
        _hasMorePages = response.pagination?.hasMorePages ?? false;
        _currentPage++;
        
        debugPrint('✅ Conversations loaded: ${_conversations.length} total');
      } else {
        _error = response?.message ?? 'فشل في تحميل المحادثات';
        debugPrint('❌ Failed to load conversations: $_error');
      }
    } catch (e) {
      _error = 'خطأ في الاتصال';
      debugPrint('💥 Exception in loadConversations: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// تحديث محادثة محددة
  void updateConversation(ConversationListItem updatedConversation) {
    final index = _conversations.indexWhere((conv) => conv.id == updatedConversation.id);
    if (index != -1) {
      _conversations[index] = updatedConversation;
      // إعادة ترتيب المحادثات حسب آخر رسالة
      _conversations.sort((a, b) {
        final aTime = a.lastMessageAt ?? a.createdAt;
        final bTime = b.lastMessageAt ?? b.createdAt;
        return bTime.compareTo(aTime);
      });
      notifyListeners();
    }
  }

  /// إضافة محادثة جديدة
  void addConversation(ConversationListItem newConversation) {
    // التحقق من عدم وجود المحادثة مسبقاً
    if (!_conversations.any((conv) => conv.id == newConversation.id)) {
      _conversations.insert(0, newConversation);
      notifyListeners();
    }
  }

  /// تحديد محادثة كمقروءة
  Future<void> markConversationAsRead(int conversationId) async {
    if (_token == null) return;

    try {
      final success = await ConversationsService.markConversationAsRead(
        token: _token!,
        conversationId: conversationId,
      );

      if (success) {
        final index = _conversations.indexWhere((conv) => conv.id == conversationId);
        if (index != -1) {
          final updatedConversation = ConversationListItem(
            id: _conversations[index].id,
            type: _conversations[index].type,
            status: _conversations[index].status,
            title: _conversations[index].title,
            otherParticipant: _conversations[index].otherParticipant,
            lastMessage: _conversations[index].lastMessage,
            unreadCount: 0, // تصفير عدد الرسائل غير المقروءة
            lastMessageAt: _conversations[index].lastMessageAt,
            createdAt: _conversations[index].createdAt,
          );
          _conversations[index] = updatedConversation;
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('❌ Error marking conversation as read: $e');
    }
  }

  /// إنشاء محادثة جديدة
  Future<ConversationListItem?> createNewConversation({
    required int otherUserId,
    String type = AdminSettings.conversationTypeUser,
    String? title,
  }) async {
    if (_token == null) return null;

    try {
      final response = await ConversationsService.createConversation(
        token: _token!,
        otherUserId: otherUserId,
        type: type,
        title: title,
      );

      if (response != null && response.status && response.conversation != null) {
        // تحويل Conversation إلى ConversationListItem
        final conversation = response.conversation!;
        final conversationItem = ConversationListItem(
          id: conversation.id!,
          type: type,
          status: conversation.status,
          title: title ?? 'محادثة جديدة',
          otherParticipant: null, // سيتم تحديثها من الخادم
          lastMessage: null,
          unreadCount: 0,
          lastMessageAt: conversation.lastMessageAt,
          createdAt: DateTime.now(),
        );
        
        addConversation(conversationItem);
        return conversationItem;
      }
    } catch (e) {
      debugPrint('❌ Error creating conversation: $e');
    }
    
    return null;
  }

  /// البحث في المحادثات
  List<ConversationListItem> searchConversations(String query) {
    if (query.isEmpty) return _conversations;
    
    return _conversations.where((conversation) {
      final titleMatch = conversation.title.toLowerCase().contains(query.toLowerCase());
      final participantMatch = conversation.otherParticipant?.name.toLowerCase().contains(query.toLowerCase()) ?? false;
      final lastMessageMatch = conversation.lastMessage?.content.toLowerCase().contains(query.toLowerCase()) ?? false;
      
      return titleMatch || participantMatch || lastMessageMatch;
    }).toList();
  }

  /// تصفية المحادثات حسب النوع
  List<ConversationListItem> filterByType(String type) {
    return _conversations.where((conversation) => conversation.type == type).toList();
  }

  /// تصفية المحادثات غير المقروءة
  List<ConversationListItem> getUnreadConversations() {
    return _conversations.where((conversation) => conversation.unreadCount > 0).toList();
  }

  /// تحديث الرمز المميز
  void updateToken(String? token) {
    _token = token;
    if (token != null) {
      loadConversations(refresh: true);
    } else {
      clearData();
    }
  }

  /// مسح البيانات
  void clearData() {
    _conversations.clear();
    _error = null;
    _pagination = null;
    _currentPage = 1;
    _hasMorePages = true;
    notifyListeners();
  }

  /// إعادة تحميل المحادثات
  Future<void> refresh() async {
    await loadConversations(refresh: true);
  }

  /// تحميل المزيد من المحادثات
  Future<void> loadMore() async {
    if (!_hasMorePages || _isLoading) return;
    await loadConversations();
  }

  @override
  void dispose() {
    debugPrint('🗑️ ConversationsProvider: Disposing...');
    super.dispose();
  }
}