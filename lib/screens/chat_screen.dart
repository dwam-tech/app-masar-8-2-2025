import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/conversation_provider.dart';
import '../providers/auth_provider.dart';
import '../models/message_model.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  @override
  void initState() {
    super.initState();
    
    // إضافة listener لتتبع الكتابة
    _messageController.addListener(_onTextChanged);
    
    // التحقق من التهيئة وجلب المحادثة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ensureInitialized();
      // إشعار المزود بدخول شاشة الشات
      final conversationProvider = context.read<ConversationProvider>();
      conversationProvider.enterChatScreen();
    });
  }

  void _onTextChanged() {
    final provider = context.read<ConversationProvider>();
    final isTyping = _messageController.text.isNotEmpty;
    provider.setUserTyping(isTyping);
  }

  void _ensureInitialized() {
    debugPrint('🚀 ChatScreen: _ensureInitialized called');
    
    final authProvider = context.read<AuthProvider>();
    final conversationProvider = context.read<ConversationProvider>();
    
    debugPrint('🔐 Auth status: ${authProvider.isLoggedIn}');
    debugPrint('💬 Conversation initialized: ${conversationProvider.isInitialized}');
    
    // التحقق من تسجيل الدخول وتهيئة ConversationProvider إذا لم يكن مُهيأ
    if (authProvider.isLoggedIn && !conversationProvider.isInitialized) {
      debugPrint('🔧 Initializing ConversationProvider...');
      debugPrint('   - Token: ${authProvider.token != null ? "Available" : "Missing"}');
      debugPrint('   - User ID: ${authProvider.userData?['id']}');
      
      conversationProvider.initialize(
        authProvider.token!,
        authProvider.userData!['id'],
      );
    }
    
    // Always fetch conversation data when screen loads
    if (conversationProvider.isInitialized) {
      debugPrint('📞 Calling fetchConversation...');
      conversationProvider.fetchConversation();
    } else {
      debugPrint('❌ ConversationProvider not initialized, cannot fetch conversation');
    }
  }

  @override
  void dispose() {
    // إشعار المزود بخروج شاشة الشات
    final conversationProvider = context.read<ConversationProvider>();
    conversationProvider.exitChatScreen();
    
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الدعم الفني'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          Consumer<ConversationProvider>(
            builder: (context, provider, child) {
              if (provider.hasUnreadMessages) {
                return IconButton(
                  onPressed: () => provider.markMessagesAsRead(),
                  icon: const Icon(Icons.mark_chat_read),
                  tooltip: 'تعليم كمقروءة',
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Consumer<ConversationProvider>(
        builder: (context, provider, child) {
          return GestureDetector(
            onTap: () => provider.recordUserActivity(),
            onPanUpdate: (_) => provider.recordUserActivity(),
            child: Column(
              children: [
                // منطقة الرسائل
                Expanded(
                  child: _buildMessagesArea(provider),
                ),
                // منطقة إدخال الرسالة
                _buildMessageInput(provider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMessagesArea(ConversationProvider provider) {
    debugPrint('🎨 Building messages area...');
    debugPrint('   - Is loading: ${provider.isLoading}');
    debugPrint('   - Messages count: ${provider.messages.length}');
    debugPrint('   - Error: ${provider.error}');
    
    if (provider.isLoading && provider.messages.isEmpty) {
      debugPrint('⏳ Showing loading indicator');
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF2E7D32),
        ),
      );
    }

    if (provider.error != null && provider.messages.isEmpty) {
      debugPrint('❌ Showing error state: ${provider.error}');
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              provider.error!,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => provider.fetchConversation(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                foregroundColor: Colors.white,
              ),
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      );
    }

    if (provider.messages.isEmpty) {
      debugPrint('📭 Showing empty state');
      return const Center(
        child: Text(
          'لا توجد رسائل\nابدأ المحادثة بإرسال رسالة',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
      );
    }

    debugPrint('📝 Building ListView with ${provider.messages.length} messages');
    return ListView.builder(
      controller: _scrollController,
      reverse: true, // الرسائل الأحدث في الأسفل
      padding: const EdgeInsets.all(16),
      itemCount: provider.messages.length,
      itemBuilder: (context, index) {
        // الرسائل مرتبة بالعكس، لذا نحتاج لعكس الفهرس
        final messageIndex = provider.messages.length - 1 - index;
        final message = provider.messages[messageIndex];
        final isMyMessage = provider.isMyMessage(message);

        debugPrint('   Building message $messageIndex: sender=${message.senderId}, isMyMessage=$isMyMessage');

        return _MessageBubble(
          message: message,
          isMyMessage: isMyMessage,
        );
      },
    );
  }

  Widget _buildMessageInput(ConversationProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'اكتب رسالتك...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: const BorderSide(color: Color(0xFF2E7D32)),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              maxLines: null,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendMessage(provider),
              onTap: () => provider.recordUserActivity(),
              onChanged: (_) => provider.recordUserActivity(),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFF2E7D32),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: provider.isLoading 
                  ? null 
                  : () => _sendMessage(provider),
              icon: provider.isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(
                      Icons.send,
                      color: Colors.white,
                    ),
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage(ConversationProvider provider) async {
    final content = _messageController.text.trim();
    if (content.isEmpty) return;

    // تسجيل نشاط المستخدم وإيقاف تتبع الكتابة
    provider.recordUserActivity();
    provider.setUserTyping(false);

    _messageController.clear();
    
    final success = await provider.sendMessage(content);
    
    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('فشل في إرسال الرسالة'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

class _MessageBubble extends StatelessWidget {
  final Message message;
  final bool isMyMessage;

  const _MessageBubble({
    required this.message,
    required this.isMyMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: isMyMessage 
            ? MainAxisAlignment.end 
            : MainAxisAlignment.start,
        children: [
          if (!isMyMessage) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: const Color(0xFF2E7D32),
              backgroundImage: message.senderAvatar != null
                  ? NetworkImage(message.senderAvatar!)
                  : null,
              child: message.senderAvatar == null
                  ? const Icon(Icons.support_agent, color: Colors.white, size: 16)
                  : null,
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: isMyMessage 
                    ? const Color(0xFF2E7D32)
                    : Colors.grey[200],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isMyMessage && message.senderName != null) ...[
                    Text(
                      message.senderName!,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                  ],
                  Text(
                    message.content,
                    style: TextStyle(
                      color: isMyMessage ? Colors.white : Colors.black87,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _formatTime(message.createdAt),
                        style: TextStyle(
                          fontSize: 12,
                          color: isMyMessage 
                              ? Colors.white70 
                              : Colors.grey[600],
                        ),
                      ),
                      if (isMyMessage) ...[
                        const SizedBox(width: 4),
                        Icon(
                          message.isLocal 
                              ? Icons.access_time 
                              : (message.isRead ? Icons.done_all : Icons.done),
                          size: 16,
                          color: message.isLocal 
                              ? Colors.white70
                              : (message.isRead ? Colors.blue[300] : Colors.white70),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (isMyMessage) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.grey[300],
              child: const Icon(Icons.person, color: Colors.grey, size: 16),
            ),
          ],
        ],
      ),
    );
  }

  String _formatTime(DateTime? dateTime) {
    if (dateTime == null) return '';

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (messageDate == today) {
      // اليوم - إظهار الوقت فقط
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (messageDate == today.subtract(const Duration(days: 1))) {
      // أمس
      return 'أمس';
    } else {
      // تاريخ آخر
      return '${dateTime.day}/${dateTime.month}';
    }
  }
}