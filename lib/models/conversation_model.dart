import 'package:flutter/foundation.dart';
import 'message_model.dart';

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
    
    final conversation = json['data'] != null 
        ? Conversation.fromJson(json['data'] as Map<String, dynamic>)
        : null;
    
    final response = ConversationResponse(
      status: json['status'] as bool,
      conversation: conversation,
      message: json['message'] as String?,
    );
    
    debugPrint('✅ ConversationResponse created: conversation=${response.conversation != null}');
    return response;
  }
}