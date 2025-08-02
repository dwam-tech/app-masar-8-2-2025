class Message {
  final int id;
  final int? conversationId;
  final int senderId;
  final String content;
  final DateTime? readAt;
  final DateTime createdAt;
  final String? senderName;
  final String? senderAvatar;

  Message({
    required this.id,
    this.conversationId,
    required this.senderId,
    required this.content,
    this.readAt,
    required this.createdAt,
    this.senderName,
    this.senderAvatar,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] as int,
      conversationId: json['conversation_id'] as int?,
      senderId: json['sender_id'] as int,
      content: json['content'] as String,
      readAt: json['read_at'] != null 
          ? DateTime.parse(json['read_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      senderName: json['sender_name'] as String?,
      senderAvatar: json['sender_avatar'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversation_id': conversationId,
      'sender_id': senderId,
      'content': content,
      'read_at': readAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'sender_name': senderName,
      'sender_avatar': senderAvatar,
    };
  }

  /// إنشاء رسالة محلية مؤقتة قبل الإرسال للخادم
  Message.local({
    this.conversationId,
    required this.senderId,
    required this.content,
    this.senderName,
    this.senderAvatar,
  })  : id = -1, // معرف مؤقت
        readAt = null,
        createdAt = DateTime.now();

  /// نسخ الرسالة مع تحديث بعض الحقول
  Message copyWith({
    int? id,
    int? conversationId,
    int? senderId,
    String? content,
    DateTime? readAt,
    DateTime? createdAt,
    String? senderName,
    String? senderAvatar,
  }) {
    return Message(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      senderId: senderId ?? this.senderId,
      content: content ?? this.content,
      readAt: readAt ?? this.readAt,
      createdAt: createdAt ?? this.createdAt,
      senderName: senderName ?? this.senderName,
      senderAvatar: senderAvatar ?? this.senderAvatar,
    );
  }

  /// التحقق من كون الرسالة محلية (لم يتم إرسالها للخادم بعد)
  bool get isLocal => id == -1;
  
  /// التحقق من كون الرسالة مقروءة
  bool get isRead => readAt != null;
}

class MessagesResponse {
  final bool status;
  final List<Message> messages;
  final String? message;

  MessagesResponse({
    required this.status,
    required this.messages,
    this.message,
  });

  factory MessagesResponse.fromJson(Map<String, dynamic> json) {
    return MessagesResponse(
      status: json['status'] as bool,
      messages: (json['messages'] as List<dynamic>?)
              ?.map((e) => Message.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      message: json['message'] as String?,
    );
  }
}

class MessageSendResponse {
  final bool status;
  final Message? message;
  final String? errorMessage;

  MessageSendResponse({
    required this.status,
    this.message,
    this.errorMessage,
  });

  factory MessageSendResponse.fromJson(Map<String, dynamic> json) {
    return MessageSendResponse(
      status: json['status'] as bool,
      message: json['data'] != null 
          ? Message.fromJson(json['data'] as Map<String, dynamic>)
          : null,
      errorMessage: json['message'] as String?,
    );
  }
}