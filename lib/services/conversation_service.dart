import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/conversation_model.dart';
import '../models/message_model.dart';
import '../utils/constants.dart';

class ConversationService {
  /// جلب أو إنشاء محادثة المستخدم مع الأدمن
  static Future<ConversationResponse?> getUserConversation({
    required String token,
  }) async {
    debugPrint('🌐 ConversationService: Starting getUserConversation');
    debugPrint('🔗 API URL: ${Constants.baseUrl}/api/chat');
    
    try {
      final response = await http.get(
        Uri.parse('${Constants.baseUrl}/api/chat'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      debugPrint('📡 HTTP Response received:');
      debugPrint('   - Status Code: ${response.statusCode}');
      debugPrint('   - Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        debugPrint('📋 Parsed JSON: $jsonData');
        
        final conversationResponse = ConversationResponse.fromJson(jsonData);
        debugPrint('✅ ConversationResponse created successfully');
        debugPrint('   - Status: ${conversationResponse.status}');
        debugPrint('   - Has conversation: ${conversationResponse.conversation != null}');
        debugPrint('   - Messages count: ${conversationResponse.conversation?.messages?.length ?? 0}');
        
        return conversationResponse;
      } else {
        debugPrint('❌ HTTP Error: ${response.statusCode}');
        debugPrint('   - Error Body: ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('💥 Exception in getUserConversation: $e');
      return null;
    }
  }

  /// إرسال رسالة من المستخدم العادي إلى الأدمن
  static Future<MessageSendResponse?> sendUserMessage({
    required String token,
    required String content,
  }) async {
    try {
      final url = Uri.parse('${Constants.baseUrl}/api/chat');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'content': content,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return MessageSendResponse.fromJson(data);
      } else {
        debugPrint('Error sending user message: ${response.statusCode} - ${response.body}');
        return MessageSendResponse(
          status: false,
          errorMessage: 'فشل في إرسال الرسالة: ${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint('Exception in sendUserMessage: $e');
      return MessageSendResponse(
        status: false,
        errorMessage: 'خطأ في الاتصال: $e',
      );
    }
  }

  /// تحديث حالة قراءة الرسائل (إذا كان مطلوباً)
  static Future<bool> markMessagesAsRead({
    required String token,
  }) async {
    try {
      final url = Uri.parse('${Constants.baseUrl}/api/chat/mark-read');
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Exception in markMessagesAsRead: $e');
      return false;
    }
  }
}