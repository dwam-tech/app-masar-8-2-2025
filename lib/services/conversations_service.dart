import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/conversation_model.dart';
import '../models/message_model.dart';
import '../utils/constants.dart';
import '../config/admin_settings.dart';

class ConversationsService {
  /// جلب جميع محادثات المستخدم
  static Future<ConversationsListResponse?> getUserConversations({
    required String token,
    int page = 1,
    int perPage = 20,
    String? type,
    String? status,
  }) async {
    
    try {
      final queryParams = {
        if (page > 1) 'page': page.toString(),
        'per_page': perPage.toString(),
        if (type != null) 'type': type,
        if (status != null) 'status': status,
      };
      
      final uri = Uri.parse('${Constants.baseUrl}/api/conversations')
          .replace(queryParameters: queryParams);
      
      
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );



      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        
        final conversationsResponse = ConversationsListResponse.fromJson(jsonData);
      
        return conversationsResponse;
      } else {
       
        return null;
      }
    } catch (e) {
     
      return null;
    }
  }

  /// إنشاء محادثة جديدة مع مستخدم آخر
  static Future<ConversationResponse?> createConversation({
    required String token,
    required int otherUserId,
    String? type,
    String? title,
  }) async {
    
    try {
      final response = await http.post(
        Uri.parse('${Constants.baseUrl}/api/conversations'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'participant_id': otherUserId,
          if (type != null) 'type': type,
           if (title != null) 'title': title,
        }),
      );

     

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonData = json.decode(response.body);
        
        
        final conversationResponse = ConversationResponse.fromJson(jsonData);
        
        return conversationResponse;
      } else {
       
        return null;
      }
    } catch (e) {
     
      return null;
    }
  }

  /// إرسال رسالة في محادثة محددة
  static Future<MessageSendResponse?> sendMessage({
    required String token,
    required int conversationId,
    required String content,
  }) async {
    
    try {
      final response = await http.post(
        Uri.parse('${Constants.baseUrl}/api/conversations/$conversationId/messages'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'content': content,
        }),
      );

      

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonData = json.decode(response.body);
        return MessageSendResponse.fromJson(jsonData);
      } else {
        
        return MessageSendResponse(
          status: false,
          errorMessage: 'فشل في إرسال الرسالة: ${response.statusCode}',
        );
      }
    } catch (e) {
      
      return MessageSendResponse(
        status: false,
        errorMessage: 'خطأ في الاتصال: $e',
      );
    }
  }

  /// جلب رسائل محادثة محددة
  static Future<MessagesResponse?> getConversationMessages({
    required String token,
    required int conversationId,
    int page = 1,
    int perPage = 50,
  }) async {
    
    try {
      final queryParams = {
        if (page > 1) 'page': page.toString(),
        'per_page': perPage.toString(),
      };
      
      final uri = Uri.parse('${Constants.baseUrl}/api/conversations/$conversationId/messages')
          .replace(queryParameters: queryParams);
      
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return MessagesResponse.fromJson(jsonData);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  /// تحديد جميع رسائل المحادثة كمقروءة
  static Future<bool> markConversationAsRead({
    required String token,
    required int conversationId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${Constants.baseUrl}/api/conversations/$conversationId/mark-all-read'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// إنشاء أو جلب محادثة الدعم الفني
  static Future<ConversationResponse?> getSupportConversation({
    required String token,
  }) async {
   
    try {
      final response = await http.post(
        Uri.parse('${Constants.baseUrl}/api/conversations'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'participant_email': AdminSettings.supportAdminEmail,
          'type': AdminSettings.conversationTypeSupport,
          'title': AdminSettings.supportChatTitle,
        }),
      );

     
      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonData = json.decode(response.body);
        return ConversationResponse.fromJson(jsonData);
      } else {
        
        return null;
      }
    } catch (e) {
      return null;
    }
  }
}