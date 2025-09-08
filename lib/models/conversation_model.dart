import 'package:flutter/foundation.dart';
import 'message_model.dart';
import '../config/admin_settings.dart';

class Conversation {
  final int? id;
  final String status;
  final DateTime? lastMessageAt;
  final String? lastMessageContent;
  final List<Message> messages;

  Conversation({
    this.id,
    required this.status,
    this.lastMessageAt,
    this.lastMessageContent,
    this.messages = const [],
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    debugPrint('🔍 Conversation.fromJson called with: $json');
    
    // استخراج الرسائل من الـ API response
    final messagesList = (json['messages'] as List<dynamic>?)
            ?.map((e) => Message.fromJson(e as Map<String, dynamic>))
            .toList() ?? [];
    
    debugPrint('📨 Messages parsed: ${messagesList.length} messages');
    
    // حساب آخر رسالة إذا كانت موجودة
    final lastMessage = messagesList.isNotEmpty ? messagesList.last : null;
    
    final conversation = Conversation(
      id: json['id'] as int?,
      status: json['status'] as String? ?? 'active',
      lastMessageAt: lastMessage?.createdAt,
      lastMessageContent: lastMessage?.content,
      messages: messagesList,
    );
    
    debugPrint('✅ Conversation created: ID=${conversation.id}, Messages=${conversation.messages.length}');
    return conversation;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': status,
      'last_message_at': lastMessageAt?.toIso8601String(),
      'last_message_content': lastMessageContent,
      'messages': messages.map((m) => m.toJson()).toList(),
    };
  }
}

class ConversationResponse {
  final bool status;
  final Conversation? conversation;
  final String? message;

  ConversationResponse({
    required this.status,
    this.conversation,
    this.message,
  });

  factory ConversationResponse.fromJson(Map<String, dynamic> json) {
    debugPrint('🔍 ConversationResponse.fromJson called');
    debugPrint('   - JSON keys: ${json.keys.toList()}');
    debugPrint('   - Status: ${json['status']}');
    debugPrint('   - Data exists: ${json['data'] != null}');
    debugPrint('   - Conversation key exists: ${json['conversation'] != null}');
    
    // دعم كلا المفتاحين: data و conversation
    Map<String, dynamic>? convJson;
    final dataVal = json['data'];
    final conversationVal = json['conversation'];

    if (dataVal is Map<String, dynamic>) {
      convJson = dataVal;
    } else if (conversationVal is Map<String, dynamic>) {
      convJson = conversationVal;
    }
    
    final conversation = convJson != null 
        ? Conversation.fromJson(convJson)
        : null;
    
    final response = ConversationResponse(
      status: (json['status'] as bool?) ?? false,
      conversation: conversation,
      message: json['message'] as String?,
    );
    
    debugPrint('✅ ConversationResponse created: conversation=${response.conversation != null}');
    return response;
  }
}

class ConversationListItem {
  final int id;
  final String type;
  final String status;
  final String title;
  final OtherParticipant? otherParticipant;
  final LastMessage? lastMessage;
  final int unreadCount;
  final DateTime? lastMessageAt;
  final DateTime createdAt;

  ConversationListItem({
    required this.id,
    required this.type,
    required this.status,
    required this.title,
    this.otherParticipant,
    this.lastMessage,
    required this.unreadCount,
    this.lastMessageAt,
    required this.createdAt,
  });

  factory ConversationListItem.fromJson(Map<String, dynamic> json) {
    final rawType = json['type'] as String?;
    final normalizedType = _normalizeConversationType(rawType);
    return ConversationListItem(
      id: json['id'] as int,
      type: normalizedType,
      status: json['status'] as String,
      title: json['title'] as String,
      otherParticipant: json['other_participant'] != null
          ? OtherParticipant.fromJson(json['other_participant'] as Map<String, dynamic>)
          : null,
      lastMessage: json['last_message'] != null
          ? LastMessage.fromJson(json['last_message'] as Map<String, dynamic>)
          : null,
      unreadCount: json['unread_count'] as int,
      lastMessageAt: json['last_message_at'] != null
          ? DateTime.parse(json['last_message_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

class OtherParticipant {
  final int id;
  final String name;
  final String userType;

  OtherParticipant({
    required this.id,
    required this.name,
    required this.userType,
  });

  factory OtherParticipant.fromJson(Map<String, dynamic> json) {
    return OtherParticipant(
      id: json['id'] as int,
      name: json['name'] as String,
      userType: json['user_type'] as String,
    );
  }
}

class LastMessage {
  final int id;
  final String content;
  final Map<String, dynamic>? sender;
  final DateTime createdAt;

  LastMessage({
    required this.id,
    required this.content,
    this.sender,
    required this.createdAt,
  });

  factory LastMessage.fromJson(Map<String, dynamic> json) {
    return LastMessage(
      id: json['id'] as int,
      content: json['content'] as String,
      sender: json['sender'] is Map<String, dynamic>
          ? json['sender'] as Map<String, dynamic>
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

class ConversationsListResponse {
  final bool status;
  final List<ConversationListItem>? conversations;
  final PaginationInfo? pagination;
  final String? message;

  ConversationsListResponse({
    required this.status,
    this.conversations,
    this.pagination,
    this.message,
  });

  factory ConversationsListResponse.fromJson(Map<String, dynamic> json) {
    debugPrint('🔍 ConversationsListResponse.fromJson called');
    
    final conversationsData = json['conversations'];
    List<ConversationListItem>? conversations;
    PaginationInfo? pagination;
    
    if (conversationsData != null) {
      if (conversationsData is Map<String, dynamic> && conversationsData.containsKey('data')) {
        // Paginated response
        conversations = (conversationsData['data'] as List<dynamic>?)
            ?.map((e) => ConversationListItem.fromJson(e as Map<String, dynamic>))
            .toList();
        pagination = PaginationInfo.fromJson(conversationsData);
      } else if (conversationsData is List<dynamic>) {
        // Simple list response
        conversations = conversationsData
            .map((e) => ConversationListItem.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    }
    
    return ConversationsListResponse(
      status: json['status'] as bool,
      conversations: conversations,
      pagination: pagination,
      message: json['message'] as String?,
    );
  }
}

class PaginationInfo {
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;
  final bool hasMorePages;

  PaginationInfo({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
    required this.hasMorePages,
  });

  factory PaginationInfo.fromJson(Map<String, dynamic> json) {
    return PaginationInfo(
      currentPage: json['current_page'] as int,
      lastPage: json['last_page'] as int,
      perPage: json['per_page'] as int,
      total: json['total'] as int,
      hasMorePages: json['current_page'] < json['last_page'],
    );
  }
}

String _normalizeConversationType(String? raw) {
  final t = (raw ?? '').trim().toLowerCase();

  // اعتبارات الخلفية المحتملة
  if (t == 'admin_user' || t == 'admin') {
    return AdminSettings.conversationTypeSupport; // 'admin_user'
  }

  if (t == 'user_service_provider' || t == 'provider_user' || t == 'service') {
    return AdminSettings.conversationTypeProvider; // 'user_service_provider'
  }

  // اعتبر "support" و "private" كمحادثة مستخدم-مستخدم في تطبيقنا
  if (t == 'user_user' || t == 'support' || t == 'private' || t.isEmpty) {
    return AdminSettings.conversationTypeUser; // 'user_user'
  }

  // fallback: أعد القيمة كما هي إن لم نتعرف عليها
  return raw ?? AdminSettings.conversationTypeUser;
}